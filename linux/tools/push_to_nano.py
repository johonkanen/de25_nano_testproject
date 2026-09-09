#!/usr/bin/env python3
"""
push_to_nano.py - push a file to the DE25-Nano's running Linux over the
network, using the HPS UART1 serial console to drive the remote side (the
board's toybox rootfs has no scp/ssh, only plain `nc`).

Requires:
  - the board already running Linux with eth0 configured (see
    linux/README.md's "Networking" section for the one-time setup)
  - pyserial (`pip install pyserial`)

Usage:
  python3 push_to_nano.py <local_file> <remote_path> [--run] [--port PORT]
                           [--serial /dev/ttyUSB0] [--nano-ip 192.168.1.222]

  --run     chmod +x the remote file and execute it, streaming its output
  --port    TCP port to use for the transfer (default 8080)

Why this exists instead of scp: toybox's minimal rootfs (see
linux/README.md) has no ssh/scp/dhcp client, only `nc`. WSL2's own virtual
network can reach a LAN device but not vice versa, so the working direction
is: board listens (`nc -l -p PORT > file`), host pushes
(`nc <board-ip> PORT < file`). This script drives the board side over the
serial console (since there's no other way to start the listener remotely)
and then does the network push itself.
"""
import argparse
import serial
import socket
import sys
import time


def drain(ser, settle=0.3):
    time.sleep(settle)
    return ser.read(65536)


def send_and_wait(ser, cmd, wait=1.0):
    ser.write((cmd + "\n").encode())
    return drain(ser, wait)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("local_file")
    ap.add_argument("remote_path")
    ap.add_argument("--run", action="store_true", help="chmod +x and execute after transfer")
    ap.add_argument("--port", type=int, default=8080)
    ap.add_argument("--serial", default="/dev/ttyUSB0")
    ap.add_argument("--nano-ip", default="192.168.1.222")
    ap.add_argument("--baud", type=int, default=115200)
    args = ap.parse_args()

    with open(args.local_file, "rb") as f:
        data = f.read()

    ser = serial.Serial(args.serial, args.baud, timeout=0.5)
    drain(ser)  # clear any pending output

    print(f">> starting listener on the board: nc -l -p {args.port} > {args.remote_path}")
    out = send_and_wait(ser, f"nc -l -p {args.port} > {args.remote_path}", wait=0.5)
    sys.stdout.write(out.decode(errors="replace"))
    time.sleep(1.0)  # let the listener actually bind before we connect

    print(f">> pushing {len(data)} bytes to {args.nano_ip}:{args.port}")
    sock = socket.create_connection((args.nano_ip, args.port), timeout=5)
    sock.sendall(data)
    sock.shutdown(socket.SHUT_WR)
    sock.close()

    out = drain(ser, 1.0)
    sys.stdout.write(out.decode(errors="replace"))
    print(">> transfer complete")

    if args.run:
        print(f">> running {args.remote_path}")
        out = send_and_wait(ser, f"chmod +x {args.remote_path} && {args.remote_path}", wait=2.0)
        sys.stdout.write(out.decode(errors="replace"))

    ser.close()


if __name__ == "__main__":
    main()
