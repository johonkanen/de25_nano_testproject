#!/usr/bin/env python3
"""
test_uart.py - exercise the DE25-Nano `de25_nano_uart` register interface.

    python test_uart.py [PORT] [BAUD]        # defaults: /dev/ttyUSB0 115200

PORT is the DE25-Nano's on-board USB serial bridge - the FPGA-fabric UART is
wired to it directly (FPGA_UART_TX/RX), so no external adapter is needed.

Self-contained - only needs pyserial (`pip install pyserial`).  Speaks the
fpga_interconnect serial protocol directly: 1-byte command, 2-byte address,
4-byte data, big-endian.

Register map (see de25_nano_uart_top.vhd):
    1   id            0x0000DE25                     RO
    2   git hash                                     RO
    3   loopback                                     RW
    4   read counter  (+1 on every read of addr 4)   RO
    5   LED register  (low 7 bits -> LED[6:0])       RW
    6   SW[3:0] slide switches                        RO
    7   KEY[1:0] push-buttons, 1 = pressed            RO
    8   free-running core-clock uptime counter        RO
    9   fan duty cycle, AMC6821 DCY, low 8 bits      RW
    10  fan speed, RPM                                RO
    11  fan raw TACH count                            RO
    12  fan controller status                         RO

Register 12 fields:
    bits  7..0  AMC6821 device ID, 0x21 when the I2C link is good
    bits 15..8  AMC6821 Status 1 register
    bits 23..16 duty cycle currently programmed into the chip
    bit  24     init_done  - configuration sequence completed
    bit  25     i2c_error  - sticky, a write went unacknowledged
    bit  26     FAN_ALERT_n pin level

The fan comes up at minimum speed. `--fan-sweep` additionally drives it to
FAN_SWEEP_DUTY for a few seconds to prove the speed really follows the
register, then puts it back to the minimum.

Exit status: 0 = all tests passed, 1 = one or more failed.
"""

import sys
import time

try:
    import serial
except ImportError:
    sys.exit("this script needs pyserial:  pip install pyserial")

FAN_SWEEP_DUTY = 0xC0      # ~75 %, used only with --fan-sweep
FAN_SETTLE_S = 3.0         # time for the fan and the TACH reading to respond

CMD_READ = 0x02
CMD_WRITE = 0x04
ADDR_BYTES = 2
DATA_BYTES = 4
FRAME_LEN = 1 + ADDR_BYTES + DATA_BYTES


class Uart:
    def __init__(self, port, baud):
        self.s = serial.Serial(port, baud, timeout=0.25)
        self.s.reset_input_buffer()
        self.s.reset_output_buffer()

    def close(self):
        self.s.close()

    def read(self, addr):
        self.s.reset_input_buffer()
        self.s.write(bytes([CMD_READ, (addr >> 8) & 0xFF, addr & 0xFF]))
        frame = self.s.read(FRAME_LEN)
        if len(frame) != FRAME_LEN:
            raise TimeoutError(
                f"no/short response reading addr {addr}: got {len(frame)} bytes {frame.hex()}"
            )
        return int.from_bytes(frame[1 + ADDR_BYTES:], "big")

    def write(self, addr, value):
        value &= 0xFFFFFFFF
        self.s.write(
            bytes([CMD_WRITE, (addr >> 8) & 0xFF, addr & 0xFF])
            + value.to_bytes(DATA_BYTES, "big")
        )
        self.s.flush()


class Runner:
    def __init__(self):
        self.passed = 0
        self.failed = 0

    def check(self, name, ok, detail=""):
        tag = "PASS" if ok else "FAIL"
        print(f"  [{tag}] {name}" + (f"  - {detail}" if detail else ""))
        if ok:
            self.passed += 1
        else:
            self.failed += 1

    def info(self, msg):
        print(f"  [info] {msg}")


def test_link_and_id(u, r):
    print("link / id (addr 1)")
    val = u.read(1)
    r.check("addr 1 == 0x0000DE25", val == 0x0000DE25, f"read 0x{val:08X}")


def test_git_hash(u, r):
    print("git hash (addr 2)")
    val = u.read(2)
    r.info(f"git hash = 0x{val:08X}"
           + ("  (run ./write_githash.sh before building to populate this)" if val == 0 else ""))


def test_loopback(u, r):
    print("loopback register (addr 3)")
    for pat in (0x00000000, 0xFFFFFFFF, 0xDEADBEEF, 0x12345678, 0xA5A5A5A5, 0x5A5A5A5A):
        u.write(3, pat)
        got = u.read(3)
        r.check(f"0x{pat:08X}", got == pat, f"read 0x{got:08X}")
    u.write(3, 0)


def test_read_counter(u, r):
    print("read strobe counter (addr 4)")
    seq = [u.read(4) for _ in range(6)]
    deltas = [(b - a) & 0xFFFFFFFF for a, b in zip(seq, seq[1:])]
    r.check("increments by 1 per read", all(d == 1 for d in deltas), f"{seq}")


def test_leds(u, r):
    print("LED register (addr 5 -> LED[6:0])")
    for pat in (0x00, 0x7F, 0x2A, 0x55):
        u.write(5, pat)
        got = u.read(5) & 0x7F
        r.check(f"0x{pat:02X}", got == (pat & 0x7F), f"read 0x{got:02X}")
    u.write(5, 0)
    r.info("watch LED[6:0] change as this runs; LED[7] is the heartbeat")


def test_switches_and_keys(u, r):
    print("SW (addr 6) and KEY (addr 7) readback")
    sw_raw = u.read(6)
    key_raw = u.read(7)
    sw, key = sw_raw & 0xF, key_raw & 0x3
    r.info(f"SW  = 0b{sw:04b}  (0x{sw:X})")
    r.info(f"KEY = 0b{key:02b}    (1 = pressed)")
    # the DE25-Nano has 4 switches and 2 keys - the upper bits must read 0
    r.check("SW register has no bits above SW[3]", sw_raw == sw, f"read 0x{sw_raw:08X}")
    r.check("KEY register has no bits above KEY[1]", key_raw == key, f"read 0x{key_raw:08X}")


def test_uptime(u, r):
    print("uptime counter (addr 8)")
    a = u.read(8)
    time.sleep(0.1)
    b = u.read(8)
    delta = (b - a) & 0xFFFFFFFF
    # 50 MHz core clock -> ~5e6 ticks in 100 ms; just check it moved forward a lot
    r.check("advances with wall-clock time", 1_000_000 < delta < 20_000_000,
            f"+{delta} ticks in ~100 ms")


def test_fan(u, r):
    print("fan controller (addr 9..12)")
    status = u.read(12)
    dev_id = status & 0xFF
    amc_status = (status >> 8) & 0xFF
    duty_prog = (status >> 16) & 0xFF
    init_done = (status >> 24) & 1
    i2c_error = (status >> 25) & 1
    fan_alert = (status >> 26) & 1

    r.check("AMC6821 device id == 0x21", dev_id == 0x21, f"read 0x{dev_id:02X}")
    r.check("fan controller init_done", init_done == 1)
    r.check("no I2C error", i2c_error == 0)
    r.info(f"AMC6821 Status 1 = 0x{amc_status:02X}, FAN_ALERT_n = {fan_alert}")

    duty = u.read(9) & 0xFF
    tach = u.read(11) & 0xFFFF
    rpm = u.read(10) & 0xFFFF
    r.info(f"duty setpoint = {duty}/255 ({100 * duty / 255:.0f} %), "
           f"programmed = {duty_prog}/255")
    r.info(f"TACH = {tach}, speed = {rpm} rpm")
    r.check("programmed duty matches the setpoint register", duty_prog == duty,
            f"{duty_prog} vs {duty}")
    r.check("fan is turning (rpm > 0)", rpm > 0, f"{rpm} rpm")


def test_fan_sweep(u, r):
    print(f"fan speed control (addr 9 -> {FAN_SWEEP_DUTY}/255, then back)")
    base_duty = u.read(9) & 0xFF
    base_rpm = u.read(10) & 0xFFFF
    r.info(f"baseline: duty {base_duty}/255, {base_rpm} rpm")

    try:
        u.write(9, FAN_SWEEP_DUTY)
        got = u.read(9) & 0xFF
        r.check("duty register accepted the new value", got == FAN_SWEEP_DUTY,
                f"read {got}")
        time.sleep(FAN_SETTLE_S)
        fast_rpm = u.read(10) & 0xFFFF
        r.info(f"at duty {FAN_SWEEP_DUTY}/255: {fast_rpm} rpm")
        r.check("fan speeds up when the duty cycle is raised",
                fast_rpm > base_rpm, f"{base_rpm} -> {fast_rpm} rpm")
    finally:
        # always hand the fan back at its original, minimum speed
        u.write(9, base_duty)
        time.sleep(FAN_SETTLE_S)

    back = u.read(9) & 0xFF
    slow_rpm = u.read(10) & 0xFFFF
    r.check("duty restored to the minimum", back == base_duty, f"read {back}")
    r.info(f"back at duty {base_duty}/255: {slow_rpm} rpm")


def main():
    args = [a for a in sys.argv[1:] if a != "--fan-sweep"]
    fan_sweep = "--fan-sweep" in sys.argv[1:]

    port = args[0] if len(args) > 0 else "/dev/ttyUSB0"
    baud = int(args[1]) if len(args) > 1 else 115200

    print(f"de25_nano_uart register test  -  {port} @ {baud} baud\n")
    try:
        u = Uart(port, baud)
    except serial.SerialException as e:
        sys.exit(f"could not open {port}: {e}")

    r = Runner()
    tests = [
        test_link_and_id,
        test_git_hash,
        test_loopback,
        test_read_counter,
        test_leds,
        test_switches_and_keys,
        test_uptime,
        test_fan,
    ]
    if fan_sweep:
        tests.append(test_fan_sweep)

    try:
        for t in tests:
            t(u, r)
            print()
    except (TimeoutError, serial.SerialException) as e:
        print(f"\n  [FAIL] communication error: {e}")
        r.failed += 1
    finally:
        u.close()

    total = r.passed + r.failed
    print(f"result: {r.passed}/{total} passed" + (f", {r.failed} FAILED" if r.failed else ""))
    sys.exit(1 if r.failed else 0)


if __name__ == "__main__":
    main()
