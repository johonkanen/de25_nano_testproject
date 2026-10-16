// DE25-Nano web GUI: the board drawing, live from /api/events (20 updates a
// second, polling /api/board if the stream drops), the blinker picker, the
// LED register, the fan, and GUI release updates.
"use strict";

const $ = (id) => document.getElementById(id);
const MODE_INFO = {
  software: "register 5",
  off: "all dark",
  counter: "binary count",
  scanner: "sweep",
  breathing: "fade",
  sparkle: "random",
};
let state = null;
let svg = null;
let release = null;      // /api/version

async function api(path, body, headers = {}) {
  const opts = body === undefined ? {} : {
    method: "POST",
    headers: body instanceof Blob ? headers : { "Content-Type": "application/json", ...headers },
    body: body instanceof Blob ? body : JSON.stringify(body),
  };
  const r = await fetch(path, opts);
  const j = await r.json().catch(() => ({}));
  if (!r.ok) throw new Error(j.error || r.status + " " + r.statusText);
  return j;
}

// ---------------------------------------------------------------- board
function buildLedBar() {
  const bar = $("ledbar");
  for (let i = 7; i >= 0; i--) {
    const b = document.createElement("button");
    b.type = "button";
    b.dataset.led = i;
    b.title = i === 7 ? "LED7 (heartbeat in software mode)" : "LED" + i;
    b.innerHTML = `<span>LED${i}</span>`;
    b.addEventListener("click", () => {
      if (state && state.blinker.name === "software" && i !== 7) toggleLed(i);
      else focusCard("blinker-card");
    });
    bar.appendChild(b);
  }
}

async function loadBoard() {
  const text = await (await fetch("/static/board.svg")).text();
  $("board").innerHTML = text;
  svg = $("board").querySelector("svg");
  svg.querySelector("#leds").addEventListener("click", (e) => {
    const led = e.target.closest(".led");
    if (led && state && state.blinker.name === "software" && led.dataset.led !== "7") {
      toggleLed(Number(led.dataset.led));
    } else {
      focusCard("blinker-card");
    }
  });
  svg.querySelector("#leds").addEventListener("keydown", (e) => {
    if (e.key === "Enter" || e.key === " ") { e.preventDefault(); focusCard("blinker-card"); }
  });
}

function focusCard(id) {
  const card = $(id);
  card.scrollIntoView({ behavior: "smooth", block: "nearest" });
  card.classList.add("flash");
  setTimeout(() => card.classList.remove("flash"), 700);
  const checked = card.querySelector('[aria-checked="true"]') || card.querySelector("button");
  if (checked) checked.focus({ preventScroll: true });
}

function renderBoard(s) {
  if (!svg) return;
  s.levels.forEach((l, i) => {
    const g = svg.querySelector("#led" + i);
    const on = l / 255;
    g.querySelector(".led-glow").style.opacity = (on * 0.95).toFixed(2);
    g.querySelector(".led-body").style.fill = on > 0.02
      ? `color-mix(in srgb, var(--led-on) ${Math.round(on * 100)}%, var(--led-off))` : "";
  });
  document.querySelectorAll("#ledbar button").forEach((b) => {
    const on = s.levels[Number(b.dataset.led)] / 255;
    b.style.background = on > 0.02
      ? `color-mix(in srgb, var(--led-on) ${Math.round(on * 100)}%, var(--led-off))` : "";
    b.style.boxShadow = on > 0.02 ? `0 0 ${Math.round(4 + on * 16)}px rgba(77, 255, 122, ${(on * 0.8).toFixed(2)})` : "";
  });
  s.switches.forEach((v, i) => svg.querySelector("#sw" + i).classList.toggle("up", !!v));
  s.keys.forEach((v, i) => svg.querySelector("#key" + i).classList.toggle("pressed", !!v));
  const rotor = svg.querySelector("#fan-rotor");
  const rpm = s.fan.rpm;
  rotor.classList.toggle("spin", rpm > 0);
  // shown slowed down (a real rotation would be a blur): one turn per 6000/rpm s
  if (rpm > 0) rotor.style.setProperty("--fan-period", Math.max(0.15, 6000 / rpm).toFixed(2) + "s");
  svg.querySelector("#fan-label").textContent = rpm > 0 ? rpm + " rpm" : "FAN";
}

// ---------------------------------------------------------------- panels
function buildPanels() {
  const modes = $("modes");
  Object.keys(MODE_INFO).forEach((name, i) => {
    const b = document.createElement("button");
    b.type = "button";
    b.role = "radio";
    b.dataset.mode = i;
    b.setAttribute("aria-checked", "false");
    b.title = MODE_INFO[name];
    b.textContent = name;
    b.addEventListener("click", () => setMode(i));
    modes.appendChild(b);
  });
  const bits = $("led-bits");
  for (let i = 7; i >= 0; i--) {
    const b = document.createElement("button");
    b.type = "button";
    b.dataset.bit = i;
    b.textContent = i;
    b.title = i === 7 ? "LED7: heartbeat" : "LED" + i;
    if (i === 7) b.disabled = true;
    else b.addEventListener("click", () => toggleLed(i));
    bits.appendChild(b);
  }
  const duty = $("fan-duty");
  duty.addEventListener("input", () => { $("fan-duty-val").textContent = duty.value; });
  duty.addEventListener("change", () => api("/api/fan", { duty: Number(duty.value) }).catch(showError));
  $("update-form").addEventListener("submit", (e) => { e.preventDefault(); upload(); });
  $("rollback").addEventListener("click", rollback);
}

function renderPanels(s) {
  $("hw-note").hidden = s.hw_blinkers;
  document.querySelectorAll("#modes button").forEach((b) => {
    const m = Number(b.dataset.mode);
    b.setAttribute("aria-checked", String(m === s.blinker.mode));
    b.disabled = !s.hw_blinkers && m > 1;
  });
  $("module-id").textContent = s.blinker.module_id || (s.blinker.name === "software" ? "register 5" : "-");
  const soft = s.blinker.name === "software";
  document.querySelectorAll("#led-bits button").forEach((b) => {
    const i = Number(b.dataset.bit);
    const on = i === 7 ? s.levels[7] > 127 : (s.led_register >> i) & 1;
    b.classList.toggle("on", !!on);
    if (i !== 7) b.disabled = !soft;
  });
  const duty = $("fan-duty");
  if (document.activeElement !== duty) {
    duty.value = s.fan.duty;
    $("fan-duty-val").textContent = s.fan.duty;
  }
  $("fan-rpm").textContent = s.fan.rpm;
  $("fan-ok").textContent = s.fan.i2c_error ? "I2C error" : s.fan.init_done ? "ok" : "starting";
  $("git").textContent = s.git_hash;
  $("uptime").textContent = formatUptime(s.linux_uptime_s);
}

// the SoC's temperatures (deg C) and supply voltages, sampled by the server
// once a second from the kernel's soc64-hwmon (the SDM's sensors)
const TEMP_MAX_C = 100;          // Agilex 5 junction limit (industrial grades go higher)
const esc = (t) => String(t).replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]);
const shortLabel = (l) => l.replace(/^Main Die /, "").replace(/ max$/, "").replace(/^corner /, "corner ");

function renderSoc(soc) {
  const temps = (soc && soc.temps) || [];
  $("soc-none").hidden = !!(soc && soc.available);
  $("soc-temps").innerHTML = temps.map((t) => {
    const pct = Math.max(0, Math.min(100, (t.c / TEMP_MAX_C) * 100));
    const cls = t.c >= 85 ? "hot" : t.c >= 70 ? "warm" : "";
    return `<span class="name" title="${esc(t.label)}">${esc(shortLabel(t.label))}</span>` +
           `<span class="val">${t.c.toFixed(1)} °C</span>` +
           `<span class="bar"><span class="${cls}" style="width:${pct.toFixed(0)}%"></span></span>`;
  }).join("");
  $("soc-volts").innerHTML = ((soc && soc.volts) || []).map((v) =>
    `<span class="name">${esc(v.label)}</span><span class="val">${v.v.toFixed(3)} V</span>`).join("");
  // on the die in the drawing, each sensor at its corner (board.svg)
  if (svg) {
    svg.querySelectorAll("#soc-sensors .tsd").forEach((g) => {
      const t = temps.find((x) => x.label.includes(g.dataset.sensor));
      g.classList.toggle("none", !t);
      if (!t) return;
      g.classList.toggle("hot", t.c >= 85);
      g.classList.toggle("warm", t.c >= 70 && t.c < 85);
      g.querySelector(".tsd-val").textContent = t.c.toFixed(1) + " °C";
    });
  }
}

function formatUptime(sec) {
  // Linux's, not register 8 (32 bits at 50 MHz: it wraps every ~86 s)
  const d = Math.floor(sec / 86400), h = Math.floor(sec / 3600) % 24;
  const m = Math.floor(sec / 60) % 60, s = Math.floor(sec % 60);
  return (d ? d + "d " : "") + [h, m, s].map((x) => String(x).padStart(2, "0")).join(":");
}

async function setMode(m) {
  try { await api("/api/blinker", { mode: m }); } catch (e) { showError(e); }
}

async function toggleLed(i) {
  if (!state) return;
  try { await api("/api/leds", { value: state.led_register ^ (1 << i) }); } catch (e) { showError(e); }
}

function showError(e) {
  setConn("bad", String(e.message || e));
}

function setConn(kind, text) {
  const c = $("conn");
  c.className = "pill pill-" + kind;
  c.textContent = text;
}

function onState(s) {
  if (s.error) { setConn("bad", "register read failed"); return; }
  state = s;
  setConn(s.id_ok ? "ok" : "bad", s.id_ok ? "live" : "unexpected id " + s.id.toString(16));
  renderBoard(s);
  renderPanels(s);
  renderSoc(s.soc);
}

// ---------------------------------------------------------------- live data
function connect() {
  if (!window.EventSource) return poll();
  const es = new EventSource("/api/events");
  es.onmessage = (e) => onState(JSON.parse(e.data));
  es.onerror = () => {
    setConn("wait", "reconnecting");
    es.close();
    setTimeout(connect, 1500);
  };
}

async function poll() {
  try { onState(await api("/api/board")); } catch (e) { setConn("bad", "offline"); }
  setTimeout(poll, 250);
}

// ---------------------------------------------------------------- releases
async function loadVersion() {
  release = await api("/api/version");
  $("ver").textContent = release.managed ? release.release : release.version;
  $("prev").textContent = release.previous || "-";
  $("pending").hidden = !release.pending;
  const managed = release.managed;
  $("update-form").querySelectorAll("input, button").forEach((el) => { el.disabled = !managed; });
  if (!managed) $("update-msg").textContent = "Not an installed release - updates are off (development run).";
  // This page loaded and read the board: the release on test works. Keep it.
  if (managed && release.pending && release.pending === release.release) {
    await api("/api/update/confirm", {});
    $("update-msg").textContent = `Release ${release.release} confirmed.`;
    $("pending").hidden = true;
  }
}

async function upload() {
  const file = $("update-file").files[0];
  if (!file) { $("update-msg").textContent = "Pick a release .tar.gz first."; return; }
  const buf = await file.arrayBuffer();
  const sha = await sha256hex(buf);
  $("update-msg").textContent = `Uploading ${file.name} (${buf.byteLength} bytes)...`;
  try {
    const r = await api("/api/update", new Blob([buf]), {
      "X-Sha256": sha, "X-Token": $("update-token").value,
    });
    $("update-msg").textContent = `Installed ${r.installed}; restarting...`;
    waitForRestart();
  } catch (e) {
    $("update-msg").textContent = "Update refused: " + e.message;
  }
}

async function rollback() {
  try {
    const r = await api("/api/update/rollback", {}, { "X-Token": $("update-token").value });
    $("update-msg").textContent = `Rolling back to ${r.current}...`;
    waitForRestart();
  } catch (e) {
    $("update-msg").textContent = "Rollback refused: " + e.message;
  }
}

function waitForRestart() {
  // the server restarts into the new release; reload once it answers again
  const t0 = Date.now();
  const tick = async () => {
    try {
      const v = await api("/api/version");
      if (v.release !== release.release) { location.reload(); return; }
    } catch (e) { /* still restarting */ }
    if (Date.now() - t0 < 60000) setTimeout(tick, 1000);
    else $("update-msg").textContent = "The board did not come back within a minute.";
  };
  setTimeout(tick, 1500);
}

// SHA-256: crypto.subtle only exists in secure contexts (https, localhost),
// and the board is plain http - so a small implementation as the fallback.
async function sha256hex(buf) {
  if (window.crypto && crypto.subtle) {
    const d = await crypto.subtle.digest("SHA-256", buf);
    return [...new Uint8Array(d)].map((b) => b.toString(16).padStart(2, "0")).join("");
  }
  return sha256Fallback(new Uint8Array(buf));
}

function sha256Fallback(data) {
  const K = new Uint32Array([
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2]);
  const H = new Uint32Array([0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
                             0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19]);
  const len = data.length;
  const total = Math.ceil((len + 9) / 64) * 64;
  const m = new Uint8Array(total);
  m.set(data);
  m[len] = 0x80;
  const dv = new DataView(m.buffer);
  dv.setUint32(total - 8, Math.floor(len / 0x20000000));
  dv.setUint32(total - 4, (len * 8) >>> 0);
  const w = new Uint32Array(64);
  const rotr = (x, n) => (x >>> n) | (x << (32 - n));
  for (let off = 0; off < total; off += 64) {
    for (let i = 0; i < 16; i++) w[i] = dv.getUint32(off + 4 * i);
    for (let i = 16; i < 64; i++) {
      const s0 = rotr(w[i - 15], 7) ^ rotr(w[i - 15], 18) ^ (w[i - 15] >>> 3);
      const s1 = rotr(w[i - 2], 17) ^ rotr(w[i - 2], 19) ^ (w[i - 2] >>> 10);
      w[i] = (w[i - 16] + s0 + w[i - 7] + s1) >>> 0;
    }
    let [a, b, c, d, e, f, g, h] = H;
    for (let i = 0; i < 64; i++) {
      const t1 = (h + (rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25)) + ((e & f) ^ (~e & g)) + K[i] + w[i]) >>> 0;
      const t2 = ((rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22)) + ((a & b) ^ (a & c) ^ (b & c))) >>> 0;
      h = g; g = f; f = e; e = (d + t1) >>> 0; d = c; c = b; b = a; a = (t1 + t2) >>> 0;
    }
    H[0] += a; H[1] += b; H[2] += c; H[3] += d; H[4] += e; H[5] += f; H[6] += g; H[7] += h;
  }
  return [...H].map((x) => x.toString(16).padStart(8, "0")).join("");
}

// ---------------------------------------------------------------- start
buildPanels();
buildLedBar();
loadBoard().then(connect);
loadVersion().catch((e) => { $("update-msg").textContent = "Version unknown: " + e.message; });
