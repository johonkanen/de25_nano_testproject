#!/usr/bin/env bash
# Stamp build_id_pkg.vhd with a new build id: the Unix time now. The design
# shows it on register 19, so a running core says which build it is; run
# this before every quartus_syn. linux/make_jic.sh copies the same number
# into the core's manifest (de25_nano.core.json), and the board's core
# reload (fpga_access.py) reads register 19 back after a load to confirm
# it. The file is generated (git-ignored).
set -euo pipefail
cd "$(dirname "$0")"

id=$(date +%s)

cat > build_id_pkg.vhd <<VHDL
library ieee;
    use ieee.std_logic_1164.all;

package build_id_pkg is

    -- $(date -u -d "@${id}" +%FT%TZ)
    constant build_id : std_logic_vector(31 downto 0) := x"$(printf %08x "${id}")";
end package;
VHDL

echo "build_id_pkg.vhd -> build id ${id} ($(printf %#010x "${id}"))"
