# Fan control on the DE25-Nano

The DE25-Nano cools itself with a PWM fan driven by an **AMC6821**
intelligent temperature monitor / fan controller (TI, `Datasheet/Fan_Control/amc6821.pdf`).
The FPGA does not drive the fan directly — it talks to the AMC6821 over I2C,
and the AMC6821 generates the PWM and measures the tachometer.

## What is wired where

| signal | pin | IO standard | note |
|--------|-----|-------------|------|
| `HDMI_I2C_SCL` | BT1  | 3.3-V LVCMOS | I2C clock, board pull-up |
| `HDMI_I2C_SDA` | BW2  | 3.3-V LVCMOS | I2C data, board pull-up |
| `FAN_ALERT_n`  | DK32 | 1.1-V | active-low fan alert, input only |

The AMC6821 is on the **HDMI I2C bus**, not a bus of its own — it shares
`HDMI_I2C_SCL` / `HDMI_I2C_SDA` with the ADV7513 HDMI transmitter. The two
answer to different addresses (AMC6821 at 7-bit `0x2E`, ADV7513 at
`0x72`/`0x7A`), so they coexist, but anything in this project that wanted to
drive HDMI would have to share the bus with the fan controller rather than
assume it owns it.

That wiring is not in the golden top's port list in any obvious way — it
comes from Terasic's own board-management demo,
`Demonstration/FPGA/Board_Info_RTL/board_management_ip/BOARD_MANAGEMENT.v`,
which instantiates its I2C master on `HDMI_I2C_SCL` / `HDMI_I2C_SDA` and
talks to slave address `0x5C` (`0x2E << 1`).

## Control mode: Software-DCY, not Software-RPM

The AMC6821 has three fan modes, selected by `[FDRC1:FDRC0]` in
Configuration Register 1:

| FDRC | mode | what it does |
|------|------|--------------|
| `00` | Software-DCY | open loop; the DCY register **is** the PWM duty cycle |
| `01` | Software-RPM | closed loop; regulates to a target TACH value |
| `10` | Auto Temperature-Fan | closed loop on temperature, stand-alone |

This project uses **Software-DCY** (`FDRC = 00`). UART register 9 is written
straight into the DCY register (`0x22`), where `0x00` is 0 % and `0xFF` is
100 %, at 1/255 per step.

Terasic's demo uses Software-RPM instead. Software-DCY is the better fit
here for two reasons:

- **Predictability.** Open loop means the duty cycle is exactly what was
  asked for. A closed loop asked for an RPM the fan cannot reach winds the
  duty to an extreme trying to get there, which is the opposite of a stable
  "run at minimum" setting.
- **It is what the register means.** "Speed mapped to a register" is honest
  about being a duty cycle; the measured RPM is reported separately in
  register 10, so you can see what that duty actually produced.

## Registers written at startup

Written in this order, with Configuration Register 1 last so the chip only
starts once everything else is in place:

| reg | value | why |
|----:|-------|-----|
| `0x01` Config2  | `0x07` | `PWM-EN=1`, `TACH-EN=1`, `TACH-MODE=1`, interrupts off |
| `0x04` Config4  | `0xC8` | `PSPR=1` (four TACH pulses/rev), `TACH-FAST=1` (250 ms RPM updates) |
| `0x20` FanChar  | `0xBD` | `FSPD=1` (spin-up **disabled**), PWM = 40 kHz, spin-up time bits left at default |
| `0x22` DCY      | duty   | the setpoint — the fan speed |
| `0x00` Config1  | `0x09` | `FDRC=00` (Software-DCY), `PWMINV=1`, `START=1` |

Three of those deserve explanation.

**`TACH-MODE=1`** (bit 1 of `0x01`). Required for a four-wire fan that is
powered from dc rather than through the PWM transistor. It also has two
side effects this design depends on: RPM monitoring keeps running below 7 %
duty, and the DCY register is *not* force-cleared to 0 below 7 % duty. With
`TACH-MODE=0` the datasheet says the duty is forced to 0 % whenever DCY is
under 7 % — which would silently stop the fan at low setpoints.

**`PWMINV=1`** (bit 3 of `0x00`). This picks the polarity of the PWM-Out
pin to match the board's fan drive transistor — `PWMINV=0` suits a PMOS,
`PWMINV=1` an NMOS. Terasic sets it, so the DE25-Nano uses an NMOS drive.
Getting this wrong does not merely invert a status bit: the fan would run
*fast* when asked to run slow.

**`FSPD=1`** (bit 7 of `0x20`) disables the AMC6821's own spin-up. Left
enabled, the chip shoves the duty cycle back up to 33 % every time it
measures an RPM below its TACH low limit — repeatedly, fighting a
deliberately low setpoint and making the fan surge. Disabling it means the
duty stays exactly where it was put.

## Starting from rest

With spin-up disabled, a fan may not start at all from a standstill at a low
duty cycle. So `amc6821_fan_control` does its own one-shot kick: it holds
`g_kick_duty` (default 100 %) for `g_kick_cycles` (default ~0.5 s), then
drops to the setpoint. "Initialise at minimum speed" therefore means the fan
is actually turning at minimum, not stalled at minimum. Set
`g_kick_cycles = 0` to skip the kick.

The kick does not repeat on an I2C retry — by then the fan is already
turning.

## Thermal fail-safe is kept

Configuration Register 3 (`0x3F`) is deliberately **not written**, so it
keeps its `0x82` power-on default and `THERM-FAN-EN` stays set. The AMC6821
then forces the fan to 100 % on its own whenever either temperature sensor
crosses its THERM limit. That is chip behaviour, independent of whatever
duty cycle the UART asked for, and it is the safety net that makes running
the fan slowly reasonable.

Terasic's demo writes `0x02` to this register, which clears `THERM-FAN-EN`
and throws that protection away. This project does not.

Note what this does and does not buy you: over-temperature protection comes
from the AMC6821's own limits, not from anything in the FPGA. There is no
temperature-driven fan curve in this design — register 9 holds whatever it
was last written. If you want a curve, read the temperature registers
(`0x0A` local, `0x0B` remote) and drive register 9 from the host, or switch
the chip to Auto Temperature-Fan mode (`FDRC = 10`).

## Measuring speed

`RPM = (100000 × 60) / TACH = 6000000 / TACH`, from the datasheet, for
`PSPR = 1` (four pulses per revolution) — which is why Config4 sets `PSPR`.
Change one and you must change the other.

`amc6821_fan_control` reads `0x08`/`0x09` for the 16-bit TACH count and does
the division in fabric with a 24-step restoring divider, so register 10 is
RPM directly. Register 11 is the raw TACH count, which is the thing to look
at if the RPM number seems wrong. A TACH of 0 reports as 0 RPM rather than
dividing by zero.

For reference, Terasic's automatic fan curve for this board ramps between
**3000 and 10000 RPM**, which is a reasonable expectation of the range.

## Trimming the minimum

`g_fan_min_duty` in `de25_nano_uart_top.vhd` is the reset value of register
9, and the single place the minimum speed is defined. It ships at **30/255
(~11.8 %, ≈430 rpm)**, measured on hardware (see below). Register 9 accepts
0, which stops the fan — the design will happily do that if asked.

To trim it yourself, walk register 9 down and watch register 10:

```
python test_uart.py --fan-sweep      # confirms speed follows the register
```

then set `g_fan_min_duty` to the lowest value that still reports a stable
non-zero RPM, with some margin, and rebuild.

### What was measured

Walking duty down live over the UART (this particular board's fan, not
necessarily true of every unit) while watching registers 10/11:

| duty | duty % | behaviour |
|-----:|-------:|-----------|
| 28-51 | 11-20 % | steady, valid TACH, RPM scales linearly with duty |
| 24 | 9.4 % | borderline — settles, but noisier and slower to stabilise |
| 18-22 | 7-9 % | **unreliable** — TACH alternates between a real reading and `0xFFFF` (over-range/no-count), and occasionally reports an implausible spike (RPM > 2000) between saturated reads. That is the AMC6821 losing and re-catching valid tach pulses, not a real, controllable speed. |
| ≤ 16 | ≤ 6 % | TACH pinned at `0xFFFF` (reads as 91 rpm, the datasheet's over-range floor) |

**30/255 (11.8 %) was then soak-tested from a cold stop** — duty forced to 0,
fan given time to fully stop, then written directly to 30 with no kick:

```
stopped: rpm=91 (over-range - not turning)
duty=30:  t+1.5s rpm=458 ... settles to 419-429 rpm, holds there for 30 s
```

It started on its own without the design's kick sequence and held a steady
±10 rpm band for the full 30 s soak — comfortable margin above the ~18-22
zone where the AMC6821 starts losing lock on the tach signal. That margin,
not the bare lowest-duty-that-moves-at-all number, is what `g_fan_min_duty`
should track: 24 "worked" in the sense of producing a number, but was
visibly less settled than 28 and up.

This was done live against the running design (writing register 9 directly)
rather than by rebuilding for every candidate — the real POR + kick path
only needs to be exercised once, for the final chosen value, since the kick
(`g_kick_duty` for `g_kick_cycles`) always spins the fan up to full speed
before dropping to `g_fan_min_duty`; a value that sustains cleanly once
already spinning will start fine after that kick.

## Debugging the I2C link

Register 12 is the place to start:

- **device ID (bits 7..0) reads `0x21`** — the I2C link works. Anything else
  (usually `0x00`) means the master is not getting valid data back.
- **`init_done` (bit 24)** — the configuration sequence completed. It drops
  while the controller is retrying.
- **`i2c_error` (bit 25)** — sticky: at least one write went unacknowledged
  since reset. `init_done` set together with `i2c_error` set means it failed
  once and has since recovered.

A write the AMC6821 does not acknowledge is followed by a STOP so the shared
bus is always released — never abandoned mid-frame, which would wedge it for
the HDMI transmitter too — and the whole configuration is retried after a
~100 ms back-off.
