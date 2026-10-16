#!/bin/sh
# de25web-supervisor.sh - runs the DE25-Nano web GUI and keeps a bad
# release from sticking. Started by init (/etc/inittab ::respawn:) and
# installed once, outside every release (linux/tools/install_webapp.py), so
# no GUI update can break the thing that rolls GUI updates back.
#
# Layout under BASE (see linux/webapp/README.md):
#   releases/<name>/  current -> releases/<name>  previous -> releases/<name>
#   pending           the release on test (written by POST /api/update)
#
# A release on test is reverted to "previous" when
#   - it is still unconfirmed TEST_SECONDS after it first started,
#   - it exits MAX_FAILS times while on test, or
#   - the board restarts while it is on test (this script starting with a
#     pending file means the test never finished).
# Confirmation is POST /api/update/confirm - the GUI page does it once it
# has loaded and read the board; linux/tools/deploy_web.py does it after
# its own checks.
BASE="${DE25WEB_BASE:-/opt/de25web}"
PORT="${DE25WEB_PORT:-80}"
PYTHON="${DE25WEB_PYTHON:-python3}"
TEST_SECONDS="${DE25WEB_TEST_SECONDS:-120}"
MAX_FAILS="${DE25WEB_MAX_FAILS:-3}"
LOG="${BASE}/supervisor.log"
EXTRA_ARGS="${DE25WEB_ARGS:-}"

cd "${BASE}" || exit 1

log() { echo "$(date '+%F %T') $*" >> "${LOG}"; }
uptime_s() { cut -d. -f1 /proc/uptime; }
current() { basename "$(readlink current)"; }
# true while release $1 is the one on test (pending names it)
on_test() { [ -n "$1" ] && [ -f pending ] && [ "$(cat pending)" = "$1" ]; }

revert() {
    prev="$(readlink previous)"
    if [ -z "${prev}" ]; then
        log "revert wanted ($1) but there is no previous release - keeping $(current)"
        rm -f pending
        return
    fi
    bad="$(current)"
    # -n: replace the link itself, not create one inside the directory it
    # points at (no mv -T in busybox; the server is stopped here anyway)
    ln -sfn "${prev}" current
    ln -sfn "releases/${bad}" previous
    rm -f pending
    log "reverted ${bad} -> $(current): $1"
}

# trim the log now and then (the rootfs is an SD card)
[ -f "${LOG}" ] && [ "$(wc -c < "${LOG}")" -gt 200000 ] && tail -n 500 "${LOG}" > "${LOG}.1" && mv -f "${LOG}.1" "${LOG}"

if [ -f pending ]; then
    revert "the board restarted while $(cat pending) was on test"
fi

test_rel=""
test_t0=0
fails=0
while :; do
    rel="$(current)"
    if on_test "${rel}"; then
        if [ "${test_rel}" != "${rel}" ]; then
            test_rel="${rel}"; test_t0="$(uptime_s)"; fails=0
            log "testing ${rel} for ${TEST_SECONDS} s"
        fi
    else
        test_rel=""
    fi

    log "starting ${rel}"
    # shellcheck disable=SC2086
    "${PYTHON}" "${BASE}/current/fpga_web.py" --port "${PORT}" --base "${BASE}" ${EXTRA_ARGS} \
        >> "${BASE}/server.log" 2>&1 &
    pid=$!

    while kill -0 "${pid}" 2>/dev/null; do
        sleep 1
        # confirmed (pending gone), or replaced by a newer upload: no
        # longer this release's test - the next start picks up a new one
        on_test "${test_rel}" || test_rel=""
        if [ -n "${test_rel}" ] && [ $(( $(uptime_s) - test_t0 )) -ge "${TEST_SECONDS}" ]; then
            kill "${pid}" 2>/dev/null; wait "${pid}" 2>/dev/null
            revert "not confirmed within ${TEST_SECONDS} s"
            test_rel=""
            pid=""
            break
        fi
    done
    [ -z "${pid}" ] && { sleep 1; continue; }     # reverted above
    wait "${pid}" 2>/dev/null
    rc=$?

    if on_test "${test_rel}" && [ "$(current)" = "${test_rel}" ]; then
        fails=$((fails + 1))
        log "${test_rel} exited (${rc}) while on test, ${fails}/${MAX_FAILS}"
        if [ "${fails}" -ge "${MAX_FAILS}" ]; then
            revert "exited ${fails} times while on test"
            test_rel=""
        fi
    elif [ "${rc}" -ne 0 ]; then
        log "$(current) exited (${rc})"
    fi
    sleep 1
done
