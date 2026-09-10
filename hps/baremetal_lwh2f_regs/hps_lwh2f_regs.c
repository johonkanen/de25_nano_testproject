/*------------------------------------------------------------------------
 * hps_lwh2f_regs.c - minimal bare-metal test letting a human, typing over
 * HPS UART1, read/write the fpga_interconnect register file
 * (de25_nano_uart_top.vhd) through the HPS's lwhps2fpga (LWH2F)
 * lightweight bridge - the same registers the fabric UART already
 * reaches, now poked from the ARM cores instead.
 *
 * Startup sequence is identical to hps_uart1_test.c (see that file /
 * hps/baremetal_uart1_test/README.md for the full account): pin-mux
 * (fsbl_configuration()), clock-manager PLL bring-up (clkmgr_bringup.c),
 * then UART1 opened and its baud divisor reprogrammed against the
 * measured clock. No ATF, no U-Boot, no Linux, no SD card.
 *
 * Everything from bridge-enable() down is ported directly from
 * de25_std_testproject's own hps/baremetal_lwh2f_regs/hps_lwh2f_regs.c,
 * which took a very long trail to get right there (see that project's
 * hps/README.md and hps/baremetal_lwh2f_regs/README.md for the full
 * story - a de25_soc_top.vhd RTL reset-polarity bug, and a missing Ncore
 * CCU crossbar routing window ATF normally programs). Applied here from
 * the start rather than re-derived - two things worth flagging though:
 *
 *   - de25_nano_uart_top.vhd's own lwhps2fpga_axi_reset_reset wiring was
 *     checked BEFORE writing this file and is already correct (driven
 *     directly by system_reset, no inversion) - so the RTL bug that hit
 *     de25_std_testproject does not appear to be present here. Confirm
 *     this file's own self-test still passes; if it does, that's further
 *     confirmation.
 *   - LWH2F_BASE and the Ncore CCU addresses/values below are Agilex 5
 *     HPS Technical Reference Manual / Arteris Ncore addresses, not
 *     board-specific - expected to be identical on this board.
 *
 * LWH2F_BASE: physical base address of the LWH2F bridge window as seen by
 * the ARM cores. Startup self-tests register 1 (the constant ID,
 * 0x0000DE25) immediately and prints PASS/FAIL before accepting commands.
 *----------------------------------------------------------------------*/
#include <stdint.h>

#include "clkmgr_bringup.h"
#include "fsbl_boot_help.h"
#include "hps_address_map.h"
#include "noc_firewall.h"
#include "rstmgr.h"
#include "rstmgr_regs.h"
#include "smmu.h"
#include "sysmgr.h"
#include "uart.h"
#include "uart_regs.h"

extern int32_t stdout_uart_fd;

/* vectors.S - minimal EL3 exception vector table, installed just before the
 * LWH2F self-test read below so a real exception (rather than a genuinely
 * stuck bus transaction) reports itself instead of just going silent. */
extern uint64_t read_current_el(void);
extern void vbar_el3_install(void);

/* Set by main() right after opening it, so the asm exception handler (which
 * has no other way to reach main()'s locals) can still print through it. */
static volatile int32_t g_uart1_fd = -1;

/* Physical base address of the LWH2F window as seen by the ARM cores. */
#define LWH2F_BASE 0x20000000UL

/* axi_lwh2f_bridge.vhd decodes AXI address bits [19:4] as the register
 * number - each fpga_interconnect register is a 16-byte-aligned LWH2F
 * offset. */
static inline volatile uint32_t *lwh2f_reg(uint32_t n) {
    return (volatile uint32_t *)(LWH2F_BASE + ((uintptr_t)n << 4));
}

static void send_str(int32_t fd, const char *s) {
    size_t len = 0;
    while (s[len] != '\0') {
        len++;
    }
    (void)uart_write(fd, (uintptr_t)s, len);
}

static void send_hex_u32(int32_t fd, uint32_t v) {
    static const char digits[] = "0123456789ABCDEF";
    char buf[8];
    for (int i = 7; i >= 0; i--) {
        buf[i] = digits[v & 0xFU];
        v >>= 4;
    }
    (void)uart_write(fd, (uintptr_t)buf, sizeof(buf));
}

static void send_hex_u64(int32_t fd, uint64_t v) {
    send_hex_u32(fd, (uint32_t)(v >> 32));
    send_hex_u32(fd, (uint32_t)v);
}

/* Called from vectors.S's el3_common_handler on any EL3 exception. Not
 * static (needs external linkage for the assembly to call it) - see that
 * file's own header comment for why this exists. */
void exception_report(uint64_t esr, uint64_t far, uint64_t elr) {
    int32_t fd = g_uart1_fd;
    if (fd < 0) {
        while (1) {
        }
    }
    send_str(fd, "\r\n*** EL3 EXCEPTION ***\r\n");
    send_str(fd, "ESR_EL3 = 0x");
    send_hex_u64(fd, esr);
    send_str(fd, "  (EC=0x");
    send_hex_u32(fd, (uint32_t)((esr >> 26) & 0x3FU));
    send_str(fd, ", ISS=0x");
    send_hex_u32(fd, (uint32_t)(esr & 0x1FFFFFFU));
    send_str(fd, ")\r\n");
    send_str(fd, "FAR_EL3 = 0x");
    send_hex_u64(fd, far);
    send_str(fd, "\r\n");
    send_str(fd, "ELR_EL3 = 0x");
    send_hex_u64(fd, elr);
    send_str(fd, "  (faulting/next instruction address)\r\n");
}

static void uart_set_divisor(uintptr_t base, uint32_t divisor) {
    uart_regs_t *u = (uart_regs_t *)base;
    u->LCR |= (uint32_t)(1UL << 7UL);
    u->RBR = divisor & 0xFFU;
    u->IER = (divisor >> 8) & 0xFFU;
    u->LCR &= (uint32_t)(~(1UL << 7UL));
}

#define RST_MGR_BRGMODRST_LWSOC2FPGA 0x00000002U
#define RST_MGR_HDSKREQ_LWSOC2FPGAFLUSHREQ 0x00000200U
#define RST_MGR_HDSKACK_LWSOC2FPGAFLUSHACK 0x00000200U
#define SYS_MGR_FPGA_BRIDGE_CTRL_LWSOC2FPGA_EN 0x00000002U

/* ~1ms-ish busy delay - no timer device opened in this minimal test, and
 * these are ATF's own settling margins, not tight protocol timing, so an
 * approximate/generous wait is fine. */
static void busy_delay(void) {
    for (volatile uint32_t i = 0; i < 300000U; i++) {
    }
}

/* Same idiom as busy_delay() above, just a caller-supplied iteration count -
 * a generous wait before the first LWH2F transaction, matching
 * de25_std_testproject's own margin there even though the specific bug
 * that made it necessary there (a reset-polarity inversion holding the
 * lwhps2fpga hard macro in fabric-side reset far longer than intended)
 * does not appear to be present in this project's RTL - cheap insurance. */
static void long_busy_delay(uint32_t iters) {
    for (volatile uint32_t i = 0; i < iters; i++) {
    }
}

/* Arteris Ncore CCU (the actual NoC crossbar/interconnect fabric, not to be
 * confused with the RSTMGR/SYSMGR bridge-enable registers above) - the ARM
 * cores' own AXI master ports into the NoC (caiu0 = coherent, ncaiu0 =
 * non-coherent) each have a routing/window table entry that must be
 * programmed before a transaction targeting LWSOC2FPGA has anywhere valid
 * to go. ATF's BL2 configures this unconditionally, very early, via
 * init_ncore_ccu() (plat/intel/soc/common/drivers/ccu/ncore_ccu.c's
 * ccu_caiu0[]/ccu_ncaiu0[]'s "NCAIU0_LWSOC2FPGA" entries) - completely
 * separate from bridge_enable()'s rstmgr/sysmgr sequence above. These are
 * Agilex 5 die-level Ncore CCU addresses, not board-specific - confirmed
 * on de25_std_testproject's own hardware (live from a working U-Boot
 * prompt, 0x1C000440/0x1C001440 both read 0xC1100006 00020000 00000000
 * after a real boot chain) - expected identical here. */
#define NCORE_CAIU0_BASE  0x1C000000UL
#define NCORE_NCAIU0_BASE 0x1C001000UL

static void ncore_program_lwsoc2fpga_window(uint64_t base, int32_t dbg_fd) {
    volatile uint32_t *r444 = (volatile uint32_t *)(base + 0x444UL);
    volatile uint32_t *r448 = (volatile uint32_t *)(base + 0x448UL);
    volatile uint32_t *r440 = (volatile uint32_t *)(base + 0x440UL);

    *r444 = 0x00020000U;                                            /* mask 0xFFFFFFFF */
    *r448 = (*r448 & ~0x000000FFU) | (0x00000000U & 0x000000FFU);   /* mask 0x000000FF */
    *r440 = (*r440 & ~0xC1F03E1FU) | (0xC1100006U & 0xC1F03E1FU);   /* mask 0xC1F03E1F */

    send_str(dbg_fd, "ncore window @0x");
    send_hex_u64(dbg_fd, base);
    send_str(dbg_fd, " = 0x");
    send_hex_u32(dbg_fd, *r440);
    send_str(dbg_fd, " 0x");
    send_hex_u32(dbg_fd, *r444);
    send_str(dbg_fd, " 0x");
    send_hex_u32(dbg_fd, *r448);
    send_str(dbg_fd, "\r\n");
}

static uint32_t rstmgr_get(int32_t rstmgr_handle, int32_t op) {
    uint32_t v = 0;
    (void)rstmgr_ioctl(rstmgr_handle, op, (uintptr_t)&v, sizeof(v));
    return v;
}

/* Bring the LWH2F bridge itself out of reset and enable it in the system
 * manager, using the sequence Intel's own arm-trusted-firmware uses for
 * Agilex 5 specifically (plat/intel/soc/common/soc/socfpga_reset_manager.c
 * socfpga_bridges_enable(), guarded #if PLATFORM_MODEL ==
 * PLAT_SOCFPGA_AGILEX5). Ported from de25_std_testproject's own working
 * implementation - see that project's hps/baremetal_lwh2f_regs/README.md
 * for how this sequence was found (via freertos-socfpga's
 * samples/bridge/lwhps2fpga_bridge.c pointing at ATF's SMC handler). */
static void lwh2f_bridge_enable(int32_t rstmgr_handle, int32_t sysmgr_handle, int32_t dbg_fd) {
    uint32_t param = 0;

    uint32_t brgmodrst = rstmgr_get(rstmgr_handle, (int32_t)IOCTL_RSTMGR_GET_BRGMODRST);
    send_str(dbg_fd, "brgmodrst = 0x");
    send_hex_u32(dbg_fd, brgmodrst);
    send_str(dbg_fd, "\r\n");
    if (!(brgmodrst & RST_MGR_BRGMODRST_LWSOC2FPGA)) {
        send_str(dbg_fd, "LWSOC2FPGA already out of reset\r\n");
        return;
    }

    /* 1. Request the handshake (set, not clear) */
    param = rstmgr_get(rstmgr_handle, (int32_t)IOCTL_RSTMGR_GET_HDSKREQ);
    param |= RST_MGR_HDSKREQ_LWSOC2FPGAFLUSHREQ;
    (void)rstmgr_ioctl(rstmgr_handle, (int32_t)IOCTL_RSTMGR_SET_HDSKREQ, (uintptr_t)&param, sizeof(param));
    busy_delay();

    /* 2. Poll HDSKACK until it ASSERTS (not clears) */
    uint32_t i, ack = 0;
    for (i = 0; i < 3000000U; i++) {
        ack = rstmgr_get(rstmgr_handle, (int32_t)IOCTL_RSTMGR_GET_HDSKACK);
        if (ack & RST_MGR_HDSKACK_LWSOC2FPGAFLUSHACK) {
            break;
        }
    }
    send_str(dbg_fd, "hdskack assert poll: ");
    send_str(dbg_fd, (i < 3000000U) ? "asserted, iters=0x" : "TIMED OUT, iters=0x");
    send_hex_u32(dbg_fd, i);
    send_str(dbg_fd, " ack=0x");
    send_hex_u32(dbg_fd, ack);
    send_str(dbg_fd, "\r\n");
    busy_delay();

    /* 3. Assert reset (again, explicitly) */
    param = rstmgr_get(rstmgr_handle, (int32_t)IOCTL_RSTMGR_GET_BRGMODRST);
    param |= RST_MGR_BRGMODRST_LWSOC2FPGA;
    (void)rstmgr_ioctl(rstmgr_handle, (int32_t)IOCTL_RSTMGR_SET_BRGMODRST, (uintptr_t)&param, sizeof(param));
    busy_delay();

    /* 4. Clear the handshake request */
    param = rstmgr_get(rstmgr_handle, (int32_t)IOCTL_RSTMGR_GET_HDSKREQ);
    param &= ~RST_MGR_HDSKREQ_LWSOC2FPGAFLUSHREQ;
    (void)rstmgr_ioctl(rstmgr_handle, (int32_t)IOCTL_RSTMGR_SET_HDSKREQ, (uintptr_t)&param, sizeof(param));
    busy_delay();

    /* 5. Clear the ack (write-1-to-clear) */
    param = RST_MGR_HDSKACK_LWSOC2FPGAFLUSHACK;
    (void)rstmgr_ioctl(rstmgr_handle, (int32_t)IOCTL_RSTMGR_SET_HDSKACK, (uintptr_t)&param, sizeof(param));
    busy_delay();

    /* 6. Deassert reset */
    param = rstmgr_get(rstmgr_handle, (int32_t)IOCTL_RSTMGR_GET_BRGMODRST);
    param &= ~RST_MGR_BRGMODRST_LWSOC2FPGA;
    (void)rstmgr_ioctl(rstmgr_handle, (int32_t)IOCTL_RSTMGR_SET_BRGMODRST, (uintptr_t)&param, sizeof(param));
    param = rstmgr_get(rstmgr_handle, (int32_t)IOCTL_RSTMGR_GET_BRGMODRST);
    send_str(dbg_fd, "brgmodrst after deassert = 0x");
    send_hex_u32(dbg_fd, param);
    send_str(dbg_fd, "\r\n");

    /* 7. Enable the bridge in the system manager */
    (void)sysmgr_ioctl(sysmgr_handle, (int32_t)IOCTL_SYSMGR_GET_FPGA_BRIDGE_CTRL, (uintptr_t)&param, sizeof(param));
    send_str(dbg_fd, "fpga_bridge_ctrl before = 0x");
    send_hex_u32(dbg_fd, param);
    param |= SYS_MGR_FPGA_BRIDGE_CTRL_LWSOC2FPGA_EN;
    (void)sysmgr_ioctl(sysmgr_handle, (int32_t)IOCTL_SYSMGR_SET_FPGA_BRIDGE_CTRL, (uintptr_t)&param, sizeof(param));
    (void)sysmgr_ioctl(sysmgr_handle, (int32_t)IOCTL_SYSMGR_GET_FPGA_BRIDGE_CTRL, (uintptr_t)&param, sizeof(param));
    send_str(dbg_fd, " after = 0x");
    send_hex_u32(dbg_fd, param);
    send_str(dbg_fd, "\r\n");
}

static int32_t recv_char_blocking(int32_t fd) {
    uint8_t c;
    while (uart_recv(fd, (uintptr_t)&c, 1, 0) != 1U) {
        /* spin */
    }
    return (int32_t)c;
}

/* Read one line (up to CR or LF), echoing every byte back so a terminal
 * shows what was typed. Supports backspace (0x08 / 0x7F). Returns the
 * length, excluding the terminator. */
static size_t read_line(int32_t fd, char *buf, size_t max_len) {
    size_t len = 0;
    while (1) {
        int32_t c = recv_char_blocking(fd);
        if (c == '\r' || c == '\n') {
            (void)uart_write(fd, (uintptr_t)"\r\n", 2);
            buf[len] = '\0';
            return len;
        }
        if ((c == 0x08 || c == 0x7F) && len > 0) {
            len--;
            (void)uart_write(fd, (uintptr_t)"\x08 \x08", 3);
            continue;
        }
        if (len + 1 < max_len && c >= 0x20 && c < 0x7F) {
            buf[len++] = (char)c;
            (void)uart_write(fd, (uintptr_t)&c, 1);
        }
    }
}

/* Parses an unsigned integer: "0x..." / "0X..." as hex, otherwise
 * decimal. Returns the number of characters consumed, or 0 on error. */
static size_t parse_uint(const char *s, uint32_t *out) {
    const char *p = s;
    uint32_t base = 10;
    uint32_t v = 0;
    size_t n = 0;

    if (p[0] == '0' && (p[1] == 'x' || p[1] == 'X')) {
        base = 16;
        p += 2;
    }
    while (*p != '\0') {
        uint32_t digit;
        if (*p >= '0' && *p <= '9') {
            digit = (uint32_t)(*p - '0');
        } else if (base == 16 && *p >= 'a' && *p <= 'f') {
            digit = (uint32_t)(*p - 'a' + 10);
        } else if (base == 16 && *p >= 'A' && *p <= 'F') {
            digit = (uint32_t)(*p - 'A' + 10);
        } else {
            break;
        }
        v = v * base + digit;
        p++;
        n++;
    }
    if (n == 0) {
        return 0;
    }
    *out = v;
    return (size_t)(p - s);
}

static void skip_spaces(const char **p) {
    while (**p == ' ') {
        (*p)++;
    }
}

static void print_help(int32_t fd) {
    send_str(fd, "\r\ncommands:\r\n"
                 "  r <reg>          - read fpga_interconnect register <reg>\r\n"
                 "  w <reg> <value>  - write <value> to register <reg>\r\n"
                 "  ?                - this help\r\n"
                 "register map (see de25_nano_uart_top.vhd):\r\n"
                 "  1 id (RO)  2 git hash (RO)  3 loopback (RW)  4 read counter (RO)\r\n"
                 "  5 LED reg (RW)  6 SW (RO)  7 KEY (RO)  8 uptime counter (RO)\r\n"
                 "  9 fan duty (RW)  10 fan rpm (RO)  11 fan tach (RO)  12 fan status (RO)\r\n"
                 "values/registers: decimal, or 0x-prefixed hex\r\n\r\n");
}

int main(void) {
    if (stdout_uart_fd > 0) {
        (void)uart_close(stdout_uart_fd);
    }

    int32_t fsbl_rc = fsbl_configuration();
    (void)fsbl_rc;

    uint32_t uart_clk_hz = 0;
    int32_t clk_rc = clkmgr_bringup(&uart_clk_hz);
    (void)clk_rc;

    int32_t rstmgr_handle = rstmgr_open("/dev/rstmgr", 0);
    if (rstmgr_handle >= 0) {
        hps_rstmgr_regs_t regs;
        (void)rstmgr_ioctl(rstmgr_handle, (int32_t)IOCTL_RSTMGR_READ, (uintptr_t)(&regs), sizeof(regs));
        regs.per1modrst &= ~((uint32_t)0x00030000);
        (void)rstmgr_ioctl(rstmgr_handle, (int32_t)IOCTL_RSTMGR_WRITE, (uintptr_t)(&regs), sizeof(regs));
    }

    int32_t uart1 = uart_open("/dev/uart1", 0);
    if (uart1 < 0) {
        while (1) {
        }
    }
    g_uart1_fd = uart1;

    if (uart_clk_hz > 0U) {
        uint32_t divisor = uart_clk_hz / (115200U * 16U);
        if (divisor == 0U) {
            divisor = 1U;
        }
        uart_set_divisor((uintptr_t)uart1, divisor);
    }

    send_str(uart1, "\r\n\r\n=== de25_nano_testproject HPS LWH2F register test ===\r\n");
    send_str(uart1, "reads/writes de25_nano_uart_top.vhd's registers over lwhps2fpga\r\n");
    send_str(uart1, "LWH2F_BASE = 0x");
    send_hex_u32(uart1, (uint32_t)LWH2F_BASE);
    send_str(uart1, "\r\n");

    /* Reordered to match ATF's actual sequence: init_ncore_ccu() (BL2) and
     * enable_nonsecure_access() (BL31) both run very early, well before
     * U-Boot's `bridge enable` command ever performs the RSTMGR
     * HDSKREQ/HDSKACK flush-handshake dance. This test previously did
     * lwh2f_bridge_enable() FIRST and NCore CCU + firewall LAST - on
     * hardware that produced "hdskack assert poll: TIMED OUT" (see git
     * history) even though the identical handshake completes cleanly in
     * the real ATF boot chain. Doing the NCore CCU window + firewall
     * unlock first, matching ATF's order, to see if that's what HDSKACK
     * was actually waiting on. */
    ncore_program_lwsoc2fpga_window(NCORE_CAIU0_BASE, uart1);
    ncore_program_lwsoc2fpga_window(NCORE_NCAIU0_BASE, uart1);

    /* NOC firewall: bridge_enable() only takes the bridge out of reset and
     * flags it enabled in the system manager - a *separate* per-master
     * security/permission register (noc_firewall0's LWSOC2FPGA SCR) gates
     * which masters may actually use it. Reset default locks this down;
     * in the normal boot chain ATF's security setup opens it before
     * anything else runs. */
    int32_t noc_fw_handle = noc_firewall_open("/dev/noc_firewall0", 0);
    if (noc_fw_handle >= 0) {
        uint32_t scr = 0;
        (void)noc_firewall_ioctl(noc_fw_handle, (int32_t)IOCTL_NOC_FIREWALL_GET_LWSOC2FPGA, (uintptr_t)&scr,
                                  sizeof(scr));
        send_str(uart1, "lwsoc2fpga SCR before = 0x");
        send_hex_u32(uart1, scr);
        scr = 0x1U;
        (void)noc_firewall_ioctl(noc_fw_handle, (int32_t)IOCTL_NOC_FIREWALL_SET_LWSOC2FPGA, (uintptr_t)&scr,
                                  sizeof(scr));
        (void)noc_firewall_ioctl(noc_fw_handle, (int32_t)IOCTL_NOC_FIREWALL_GET_LWSOC2FPGA, (uintptr_t)&scr,
                                  sizeof(scr));
        send_str(uart1, " after = 0x");
        send_hex_u32(uart1, scr);
        send_str(uart1, "\r\n");
        (void)noc_firewall_close(noc_fw_handle);
    } else {
        send_str(uart1, "noc_firewall_open failed\r\n");
    }

    if (rstmgr_handle >= 0) {
        int32_t sysmgr_handle = sysmgr_open("/dev/sysmgr", 0);
        if (sysmgr_handle >= 0) {
            lwh2f_bridge_enable(rstmgr_handle, sysmgr_handle, uart1);
            (void)sysmgr_close(sysmgr_handle);
        } else {
            send_str(uart1, "sysmgr_open failed\r\n");
        }
        (void)rstmgr_close(rstmgr_handle);
    } else {
        send_str(uart1, "rstmgr_open failed\r\n");
    }

    /* Diagnostic only. See de25_std_testproject's own note: SMMU is
     * expected disabled by default (checked, not blindly assumed). */
    int32_t smmu_handle = smmu_open("/dev/smmu0", 0);
    if (smmu_handle >= 0) {
        uint32_t smmu_iidr = 0, smmu_cr0 = 0;
        (void)smmu_ioctl(smmu_handle, (uint32_t)IOCTL_SMMU_IIDR_GET, (uintptr_t)&smmu_iidr, sizeof(smmu_iidr));
        (void)smmu_ioctl(smmu_handle, (uint32_t)IOCTL_SMMU_CR0_GET, (uintptr_t)&smmu_cr0, sizeof(smmu_cr0));
        send_str(uart1, "smmu IIDR = 0x");
        send_hex_u32(uart1, smmu_iidr);
        send_str(uart1, " CR0 = 0x");
        send_hex_u32(uart1, smmu_cr0);
        send_str(uart1, (smmu_cr0 & 0x1U) ? "  -> SMMU_EN set\r\n" : "  -> SMMU_EN clear\r\n");
        (void)smmu_close(smmu_handle);
    } else {
        send_str(uart1, "smmu_open failed\r\n");
    }

    /* Install a real exception vector table (see vectors.S's header
     * comment) before touching LWH2F, so a real fault reports itself
     * (ESR/FAR/ELR) instead of silently vectoring into garbage. */
    uint64_t current_el = read_current_el();
    send_str(uart1, "CurrentEL = ");
    send_hex_u32(uart1, (uint32_t)current_el);
    if (current_el == 3U) {
        vbar_el3_install();
        send_str(uart1, "  -> VBAR_EL3 installed\r\n");
    } else {
        send_str(uart1, "  -> not EL3, vector table NOT installed (vectors.S is EL3-only)\r\n");
    }

    long_busy_delay(60000000U);

    /* Wait for the fabric itself to report configuration complete before
     * touching LWH2F. build_de25_nano_uart.tcl now sets HPS_INITIALIZATION
     * "HPS FIRST" (needed to fix a QSPI-controller cold-boot hang) - the ARM
     * cores can start running before the FPGA fabric has finished
     * configuring, unlike when this test last passed (FPGA-first default).
     * SYSMGR_SOC64_FPGA_CONFIG bit 1 (EARLY_USERMODE) is the same bit
     * u-boot-socfpga's is_fpga_config_ready() polls before allowing
     * `bridge enable` to proceed - check it here too. */
    {
        int32_t sysmgr_handle2 = sysmgr_open("/dev/sysmgr", 0);
        if (sysmgr_handle2 >= 0) {
            uint32_t fpga_config = 0;
            uint32_t iters;
            for (iters = 0; iters < 10000000U; iters++) {
                (void)sysmgr_ioctl(sysmgr_handle2, (int32_t)IOCTL_SYSMGR_GET_FPGA_CONFIG,
                                    (uintptr_t)&fpga_config, sizeof(fpga_config));
                if (fpga_config & 0x2U) {
                    break;
                }
            }
            send_str(uart1, "fpga_config poll: ");
            send_str(uart1, (iters < 10000000U) ? "ready, iters=0x" : "TIMED OUT, iters=0x");
            send_hex_u32(uart1, iters);
            send_str(uart1, " fpga_config=0x");
            send_hex_u32(uart1, fpga_config);
            send_str(uart1, "\r\n");
            (void)sysmgr_close(sysmgr_handle2);
        } else {
            send_str(uart1, "sysmgr_open (fpga_config poll) failed\r\n");
        }
    }

    /* self-test: register 1 is the constant id, 0x0000DE25 */
    uint32_t id = *lwh2f_reg(1);
    send_str(uart1, "self-test: register 1 (id) = 0x");
    send_hex_u32(uart1, id);
    if (id == 0x0000DE25U) {
        send_str(uart1, "  -> PASS\r\n");
    } else {
        send_str(uart1, "  -> FAIL (expected 0x0000DE25) - do not trust reads/writes below.\r\n");
    }

    print_help(uart1);

    char line[64];
    while (1) {
        send_str(uart1, "> ");
        size_t len = read_line(uart1, line, sizeof(line));
        const char *p = line;
        skip_spaces(&p);

        if (len == 0) {
            continue;
        }
        if (*p == '?') {
            print_help(uart1);
            continue;
        }
        if (*p == 'r' && (p[1] == ' ' || p[1] == '\0')) {
            p++;
            skip_spaces(&p);
            uint32_t reg;
            if (parse_uint(p, &reg) == 0U) {
                send_str(uart1, "usage: r <reg>\r\n");
                continue;
            }
            uint32_t value = *lwh2f_reg(reg);
            send_str(uart1, "reg ");
            send_hex_u32(uart1, reg);
            send_str(uart1, " = 0x");
            send_hex_u32(uart1, value);
            send_str(uart1, "\r\n");
            continue;
        }
        if (*p == 'w' && (p[1] == ' ' || p[1] == '\0')) {
            p++;
            skip_spaces(&p);
            uint32_t reg;
            size_t n = parse_uint(p, &reg);
            if (n == 0U) {
                send_str(uart1, "usage: w <reg> <value>\r\n");
                continue;
            }
            p += n;
            skip_spaces(&p);
            uint32_t value;
            if (parse_uint(p, &value) == 0U) {
                send_str(uart1, "usage: w <reg> <value>\r\n");
                continue;
            }
            *lwh2f_reg(reg) = value;
            send_str(uart1, "wrote 0x");
            send_hex_u32(uart1, value);
            send_str(uart1, " to reg ");
            send_hex_u32(uart1, reg);
            send_str(uart1, "\r\n");
            continue;
        }
        send_str(uart1, "unknown command - '?' for help\r\n");
    }

    return 0; /* unreachable */
}
