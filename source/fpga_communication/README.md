# vendored from johonkanen/fpga_communication

`fpga_interconnect_16bit_pkg.vhd` - the 32 data / 16 address instance of
`hVHDL_fpga_interconnect`'s generic package - is copied verbatim from
<https://github.com/johonkanen/fpga_communication> (same file the
`axc3000_test` build vendors). It is vendored, not a submodule, because
`fpga_communication` pulls in several unrelated nested submodules.

`communications.vhd` and `serial_protocol_generic_pkg.vhd` came from the
same place for the fabric register UART, retired when HPS UART1 took over
the `FPGA_UART` pins (commit `247409b`); they are no longer built.

To update: copy the newer version from upstream and re-run the build.
