

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <math.h>
#include <poll.h>


/* ============================================================
 * NVIDIA RM
 * ============================================================ */

#define NV_ESC_RM_ALLOC       0x2B
#define NV_ESC_RM_CONTROL     0x2A
#define NV_ESC_REGISTER_FD    201

#define NV01_ROOT_CLIENT      0x41
#define NV01_DEVICE_0         0x80
#define NV04_DISPLAY_COMMON   0x73

#define CMD_GET_SUPPORTED     0x730107
#define CMD_GET_CONNECT_STATE 0x730108
#define CMD_DP_AUXCH_CTRL     0x731341


/* ============================================================
 * NVIDIA handles
 * ============================================================ */

#define CLIENT_HANDLE  0xBB000001
#define DEVICE_HANDLE  0xBB000002
#define DISPLAY_HANDLE 0xBB000003


/* ============================================================
 * DPCD registers
 * ============================================================ */

#define DPCD_REV                    0x700
#define DPCD_GENERAL_CAP1           0x701
#define DPCD_GENERAL_CAP2           0x702
#define DPCD_BACKLIGHT_CAP          0x703

#define DPCD_DISPLAY_CONTROL        0x720
#define DPCD_BACKLIGHT_MODE_SET     0x721

#define DPCD_BRIGHTNESS_MSB         0x722
#define DPCD_BRIGHTNESS_LSB         0x723

#define DPCD_PANEL_TARGET_LUMINANCE 0x734

/*
 * DPCD 0x721 bit 7
 */
#define PANEL_LUMINANCE_ENABLE      0x80


/* ============================================================
 * RM API structures
 * ============================================================ */

typedef struct {
    uint32_t hRoot;
    uint32_t hObjectParent;
    uint32_t hObjectNew;
    int32_t hClass;
    uint64_t pAllocParms;
    uint32_t paramsSize;
    int32_t status;
} NVOS21;


typedef struct {
    uint32_t hClient;
    uint32_t hObject;
    int32_t cmd;
    uint32_t flags;
    uint64_t params;
    uint32_t paramsSize;
    int32_t status;
} NVOS54;


typedef struct {
    uint32_t deviceId;
    uint32_t hClientShare;
    uint32_t hTargetClient;
    uint32_t hTargetDevice;
    int32_t flags;
    uint32_t _p;
    uint64_t vaSpaceSize;
    uint64_t vaStartInternal;
    uint64_t vaLimitInternal;
    int32_t vaMode;
    uint32_t _p2;
} NV0080;


typedef struct {
    uint32_t subDeviceInstance;
    uint32_t displayMask;
    uint32_t displayMaskDDC;
} GET_SUP;


typedef struct {
    uint32_t subDeviceInstance;
    uint32_t flags;
    uint32_t displayMask;
    uint32_t retryTimeMs;
} GET_CON;


typedef struct {
    uint32_t subDeviceInstance;
    uint32_t displayId;

    uint8_t bAddrOnly;
    uint8_t pad[3];

    uint32_t cmd;
    uint32_t addr;

    uint8_t data[16];

    uint32_t size;
    uint32_t replyType;
    uint32_t retryTimeMs;
} AUXCH;


typedef struct {
    int ctl_fd;
} REG_FD;


/* ============================================================
 * Globals
 * ============================================================ */

static int ctl_fd = -1;
static int dev_fd = -1;

static int quiet = 0;


/* ============================================================
 * RM allocation
 * ============================================================ */

static int rm_alloc(
    int fd,
    uint32_t root,
    uint32_t parent,
    uint32_t object,
    int32_t class,
    void *params,
    uint32_t params_size
)
{
    NVOS21 x = {
        root,
        parent,
        object,
        class,
        (uint64_t)(uintptr_t)params,
        params_size,
        0
    };

    if (ioctl(
            fd,
            _IOWR('F', NV_ESC_RM_ALLOC, NVOS21),
            &x
        ) < 0)
    {
        return -errno;
    }

    if (x.status)
        return x.status;

    return 0;
}


/* ============================================================
 * RM control
 * ============================================================ */

static int rm_ctrl(
    uint32_t object,
    int32_t command,
    void *params,
    uint32_t params_size
)
{
    NVOS54 x = {
        CLIENT_HANDLE,
        object,
        command,
        0,
        (uint64_t)(uintptr_t)params,
        params_size,
        0
    };

    if (ioctl(
            ctl_fd,
            _IOWR('F', NV_ESC_RM_CONTROL, NVOS54),
            &x
        ) < 0)
    {
        return -errno;
    }

    if (x.status)
        return x.status;

    return 0;
}


/* ============================================================
 * DPCD READ
 * ============================================================ */

static int dpcd_read(
    uint32_t display_id,
    uint32_t addr,
    uint8_t *buf,
    uint32_t size
)
{
    AUXCH a = {0};

    a.displayId = display_id;

    /*
     * NVIDIA RM native AUX read.
     */
    a.cmd = 0x09;

    a.addr = addr;

    if (size > 16)
        size = 16;

    a.size = size;


    int r = rm_ctrl(
        DISPLAY_HANDLE,
        CMD_DP_AUXCH_CTRL,
        &a,
        sizeof(a)
    );


    if (r)
    {
        if (!quiet)
        {
            fprintf(
                stderr,
                "DPCD read 0x%04x failed: 0x%x\n",
                addr,
                r
            );
        }

        return r;
    }


    if (buf)
    {
        memcpy(
            buf,
            a.data,
            size
        );
    }


    if (!quiet)
    {
        printf(
            "  DPCD 0x%04x:",
            addr
        );

        for (uint32_t i = 0; i < size; i++)
        {
            printf(
                " %02x",
                a.data[i]
            );
        }

        printf("\n");
    }


    return 0;
}


/* ============================================================
 * DPCD WRITE
 * ============================================================ */

static int dpcd_write(
    uint32_t display_id,
    uint32_t addr,
    const uint8_t *buf,
    uint32_t size
)
{
    AUXCH a = {0};

    a.displayId = display_id;

    /*
     * NVIDIA RM native AUX write.
     */
    a.cmd = 0x08;

    a.addr = addr;

    if (size > 16)
        size = 16;

    a.size = size;

    memcpy(
        a.data,
        buf,
        size
    );


    return rm_ctrl(
        DISPLAY_HANDLE,
        CMD_DP_AUXCH_CTRL,
        &a,
        sizeof(a)
    );
}


/* ============================================================
 * INITIALIZE RM
 * ============================================================ */

static int init_rm(void)
{
    ctl_fd = open(
        "/dev/nvidiactl",
        O_RDWR
    );


    if (ctl_fd < 0)
    {
        perror("open /dev/nvidiactl");
        return -1;
    }


    dev_fd = open(
        "/dev/nvidia0",
        O_RDWR
    );


    if (dev_fd < 0)
    {
        perror("open /dev/nvidia0");

        close(ctl_fd);

        ctl_fd = -1;

        return -1;
    }


    /*
     * Register control FD.
     */
    REG_FD reg = {
        .ctl_fd = ctl_fd
    };


    if (ioctl(
            dev_fd,
            _IOWR(
                'F',
                NV_ESC_REGISTER_FD,
                REG_FD
            ),
            &reg
        ) < 0)
    {
        perror("NV_ESC_REGISTER_FD");
        return -1;
    }


    /*
     * Allocate client.
     */
    int r = rm_alloc(
        ctl_fd,
        CLIENT_HANDLE,
        CLIENT_HANDLE,
        CLIENT_HANDLE,
        NV01_ROOT_CLIENT,
        NULL,
        0
    );


    if (r)
    {
        fprintf(
            stderr,
            "x2-bright: RM client alloc failed: 0x%x\n",
            r
        );

        return -1;
    }


    /*
     * Allocate device.
     */
    NV0080 dp = {0};


    r = rm_alloc(
        ctl_fd,
        CLIENT_HANDLE,
        CLIENT_HANDLE,
        DEVICE_HANDLE,
        NV01_DEVICE_0,
        &dp,
        sizeof(dp)
    );


    if (r)
    {
        fprintf(
            stderr,
            "x2-bright: RM device alloc failed: 0x%x\n",
            r
        );

        return -1;
    }


    /*
     * Allocate display.
     */
    r = rm_alloc(
        ctl_fd,
        CLIENT_HANDLE,
        DEVICE_HANDLE,
        DISPLAY_HANDLE,
        NV04_DISPLAY_COMMON,
        NULL,
        0
    );


    if (r)
    {
        fprintf(
            stderr,
            "x2-bright: RM display alloc failed: 0x%x\n",
            r
        );

        return -1;
    }


    return 0;
}


/* ============================================================
 * CLEANUP
 * ============================================================ */

static void cleanup(void)
{
    if (dev_fd >= 0)
    {
        close(dev_fd);
        dev_fd = -1;
    }


    if (ctl_fd >= 0)
    {
        close(ctl_fd);
        ctl_fd = -1;
    }
}


/* ============================================================
 * FIND eDP
 * ============================================================ */

static uint32_t find_edp(void)
{
    GET_SUP s = {0};


    if (rm_ctrl(
            DISPLAY_HANDLE,
            CMD_GET_SUPPORTED,
            &s,
            sizeof(s)
        ))
    {
        return 0;
    }


    GET_CON c = {0};


    c.displayMask = s.displayMask;
    c.flags = 1;


    if (rm_ctrl(
            DISPLAY_HANDLE,
            CMD_GET_CONNECT_STATE,
            &c,
            sizeof(c)
        ))
    {
        return 0;
    }


    for (int bit = 0; bit < 32; bit++)
    {
        uint32_t did =
            1u << bit;


        if (!(c.displayMask & did))
            continue;


        uint8_t cap[4] = {0};


        /*
         * IMPORTANT:
         *
         * cap[0] = 0x700
         * cap[1] = 0x701
         * cap[2] = 0x702
         * cap[3] = 0x703
         *
         * Your panel reports:
         *
         * 05 9b 86 14
         *
         * Therefore cap[2] = 0x86.
         */
        if (
            dpcd_read(
                did,
                DPCD_REV,
                cap,
                4
            ) == 0 &&
            (cap[2] & 0x02)
        )
        {
            return did;
        }
    }


    return 0;
}


/* ============================================================
 * ENABLE LUMINANCE CONTROL
 *
 * DPCD 0x721 bit 7
 *
 * IMPORTANT:
 *
 * Do NOT write to 0x720 here.
 * ============================================================ */

static int enable_luminance_control(
    uint32_t edp
)
{
    uint8_t mode = 0;


    /*
     * Read current BACKLIGHT_MODE_SET.
     */
    if (dpcd_read(
            edp,
            DPCD_BACKLIGHT_MODE_SET,
            &mode,
            1
        ) != 0)
    {
        return -1;
    }


    /*
     * Preserve all existing bits.
     *
     * Only enable PANEL_LUMINANCE_CONTROL.
     */
    mode |= PANEL_LUMINANCE_ENABLE;


    /*
     * Write it back.
     */
    if (dpcd_write(
            edp,
            DPCD_BACKLIGHT_MODE_SET,
            &mode,
            1
        ) != 0)
    {
        return -1;
    }


    return 0;
}


/* ============================================================
 * SET LUMINANCE
 * ============================================================ */

static int set_luminance(
    uint32_t edp,
    uint32_t mcd
)
{
    /*
     * PANEL_TARGET_LUMINANCE is 24-bit.
     */
    if (mcd > 0xFFFFFF)
        mcd = 0xFFFFFF;


    /*
     * Ensure luminance-control mode is enabled.
     */
    if (
        enable_luminance_control(edp)
        != 0
    )
    {
        fprintf(
            stderr,
            "x2-bright: failed to enable "
            "panel luminance control\n"
        );

        return -1;
    }


    /*
     * PANEL_TARGET_LUMINANCE
     *
     * 0x734
     * 0x735
     * 0x736
     *
     * 24-bit little endian.
     */
    uint8_t data[3];

    data[0] =
        (uint8_t)(mcd & 0xff);

    data[1] =
        (uint8_t)((mcd >> 8) & 0xff);

    data[2] =
        (uint8_t)((mcd >> 16) & 0xff);


    /*
     * Write target luminance.
     */
    if (
        dpcd_write(
            edp,
            DPCD_PANEL_TARGET_LUMINANCE,
            data,
            3
        ) != 0
    )
    {
        fprintf(
            stderr,
            "x2-bright: TARGET_LUMINANCE write failed\n"
        );

        return -1;
    }


    return 0;
}


/* ============================================================
 * GET LUMINANCE
 * ============================================================ */

static uint32_t get_luminance(
    uint32_t edp
)
{
    uint8_t data[3] = {0};


    if (
        dpcd_read(
            edp,
            DPCD_PANEL_TARGET_LUMINANCE,
            data,
            3
        ) != 0
    )
    {
        return 0;
    }


    return
        ((uint32_t)data[0]) |
        ((uint32_t)data[1] << 8) |
        ((uint32_t)data[2] << 16);
}


/* ============================================================
 * BRIGHTNESS → LUMINANCE
 * ============================================================ */

static uint32_t brightness_to_luminance(
    int value,
    double min_lum,
    double max_lum
)
{
    if (value <= 0)
        return (uint32_t)min_lum;


    if (value >= 100)
        return (uint32_t)max_lum;


    double x =
        value / 100.0;


    /*
     * Logarithmic mapping.
     */
    double lum =
        min_lum *
        pow(
            max_lum / min_lum,
            x
        );


    if (lum < min_lum)
        lum = min_lum;


    if (lum > max_lum)
        lum = max_lum;


    return (uint32_t)lum;
}


/* ============================================================
 * MAIN
 * ============================================================ */

int main(
    int argc,
    char **argv
)
{
    /*
     * Watch mode has minimal output.
     */
    quiet =
        argc >= 2 &&
        strcmp(
            argv[1],
            "watch"
        ) == 0;


    /* --------------------------------------------------------
     * Initialize NVIDIA RM
     * -------------------------------------------------------- */

    if (init_rm() != 0)
        return 1;


    /* --------------------------------------------------------
     * Find eDP
     * -------------------------------------------------------- */

    uint32_t edp =
        find_edp();


    if (!edp)
    {
        fprintf(
            stderr,
            "x2-bright: no eDP display with "
            "DPCD backlight found\n"
        );

        cleanup();

        return 1;
    }


    /* ========================================================
     * WATCH MODE
     * ======================================================== */

    if (quiet)
    {
        const char *sysfs =
            "/sys/class/backlight/nvidia_0/brightness";


        /*
         * Default Samsung OLED range:
         *
         * 5 nits → 500 nits
         */
        double LUM_MIN =
            5000.0;


        double LUM_MAX =
            500000.0;


        /*
         * Custom:
         *
         * x2-bright watch 5 500
         */
        if (argc >= 4)
        {
            LUM_MIN =
                strtod(
                    argv[2],
                    NULL
                ) * 1000.0;


            LUM_MAX =
                strtod(
                    argv[3],
                    NULL
                ) * 1000.0;
        }


        int sysfs_fd =
            open(
                sysfs,
                O_RDONLY
            );


        if (sysfs_fd < 0)
        {
            perror(sysfs);

            cleanup();

            return 1;
        }


        fprintf(
            stderr,
            "x2-bright: watching %s\n",
            sysfs
        );


        fprintf(
            stderr,
            "x2-bright: display 0x%x\n",
            edp
        );


        fprintf(
            stderr,
            "x2-bright: range %.0f-%.0f mcd/m²\n",
            LUM_MIN,
            LUM_MAX
        );


        /*
         * Enable luminance mode.
         */
        enable_luminance_control(edp);


        int last_val = -1;


        for (;;)
        {
            char buf[32];


            lseek(
                sysfs_fd,
                0,
                SEEK_SET
            );


            int n =
                read(
                    sysfs_fd,
                    buf,
                    sizeof(buf) - 1
                );


            if (n <= 0)
            {
                usleep(500000);
                continue;
            }


            buf[n] = '\0';


            int val =
                atoi(buf);


            /*
             * Only write when brightness changes.
             */
            if (val != last_val)
            {
                uint32_t lum =
                    brightness_to_luminance(
                        val,
                        LUM_MIN,
                        LUM_MAX
                    );


                if (
                    set_luminance(
                        edp,
                        lum
                    ) != 0
                )
                {
                    fprintf(
                        stderr,
                        "x2-bright: DPCD write failed; "
                        "reinitializing RM\n"
                    );


                    cleanup();


                    if (
                        init_rm() == 0
                    )
                    {
                        uint32_t new_edp =
                            find_edp();


                        if (new_edp)
                        {
                            edp =
                                new_edp;


                            if (
                                set_luminance(
                                    edp,
                                    lum
                                ) == 0
                            )
                            {
                                last_val =
                                    val;
                            }
                        }
                    }


                    usleep(500000);
                }
                else
                {
                    last_val =
                        val;
                }
            }


            /*
             * Poll every 50 ms.
             */
            struct pollfd pfd = {
                .fd = sysfs_fd,
                .events = POLLPRI | POLLERR
            };


            poll(
                &pfd,
                1,
                50
            );
        }


        close(sysfs_fd);

        cleanup();

        return 0;
    }


    /* ========================================================
     * INTERACTIVE INFORMATION
     * ======================================================== */

    uint8_t cap[4] = {0};
    uint8_t ctl[4] = {0};


    /*
     * Read 0x700-0x703.
     */
    dpcd_read(
        edp,
        DPCD_REV,
        cap,
        4
    );


    /*
     * Read 0x720-0x723.
     */
    dpcd_read(
        edp,
        DPCD_DISPLAY_CONTROL,
        ctl,
        4
    );


    uint16_t cur_bright =
        ((uint16_t)ctl[2] << 8) |
        ctl[3];


    int backlight_enabled =
        ctl[0] & 1;


    int control_mode =
        ctl[1] & 3;


    int luminance_enabled =
        (ctl[1] >> 7) & 1;


    printf(
        "Display: 0x%x\n",
        edp
    );


    printf(
        "eDP rev: 1.%d\n",
        cap[0]
    );


    printf(
        "GENERAL_CAP1: 0x%02x\n",
        cap[1]
    );


    printf(
        "BACKLIGHT_CAP: 0x%02x\n",
        cap[2]
    );


    printf(
        "DPCD 0x703: 0x%02x\n",
        cap[3]
    );


    printf(
        "DISPLAY_CONTROL: 0x%02x\n",
        ctl[0]
    );


    printf(
        "BACKLIGHT_MODE_SET: 0x%02x\n",
        ctl[1]
    );


    printf(
        "  BACKLIGHT_ENABLE = %d\n",
        backlight_enabled
    );


    printf(
        "  CONTROL_MODE = %d\n",
        control_mode
    );


    printf(
        "  LUMINANCE_CONTROL = %d\n",
        luminance_enabled
    );


    printf(
        "  BACKLIGHT_BRIGHTNESS = %u\n",
        cur_bright
    );


    uint32_t current_luminance =
        get_luminance(edp);


    printf(
        "  TARGET_LUMINANCE = %u mcd/m² "
        "(%u.%03u cd/m²)\n",
        current_luminance,
        current_luminance / 1000,
        current_luminance % 1000
    );


    /* ========================================================
     * No command
     * ======================================================== */

    if (argc < 2)
    {
        printf(
            "\n"
            "Usage:\n"
            "  x2-bright\n"
            "  x2-bright lum N\n"
            "  x2-bright watch [min_nits] [max_nits]\n"
            "  x2-bright dump\n"
            "  x2-bright read ADDR [N]\n"
            "  x2-bright raw ADDR B1 B2 ...\n"
        );


        cleanup();

        return 0;
    }


    /* ========================================================
     * LUMINANCE COMMAND
     * ======================================================== */

    if (
        strcmp(
            argv[1],
            "lum"
        ) == 0 &&
        argc >= 3
    )
    {
        uint32_t value =
            strtoul(
                argv[2],
                NULL,
                0
            );


        printf(
            "\n"
            "Setting TARGET_LUMINANCE\n"
        );


        printf(
            "  %u mcd/m²\n",
            value
        );


        printf(
            "  %u.%03u cd/m²\n\n",
            value / 1000,
            value % 1000
        );


        int success = 0;


        /*
         * Retry a few times.
         */
        for (
            int attempt = 1;
            attempt <= 5;
            attempt++
        )
        {
            if (
                set_luminance(
                    edp,
                    value
                ) != 0
            )
            {
                fprintf(
                    stderr,
                    "Attempt %d: write failed\n",
                    attempt
                );


                usleep(80000);

                continue;
            }


            /*
             * Allow AUX/panel update.
             */
            usleep(80000);


            uint32_t readback =
                get_luminance(edp);


            printf(
                "Attempt %d: "
                "readback = %u mcd/m²\n",
                attempt,
                readback
            );


            if (
                readback == value
            )
            {
                success = 1;
                break;
            }


            usleep(80000);
        }


        uint32_t final =
            get_luminance(edp);


        printf(
            "\nFinal readback: "
            "%u mcd/m² "
            "(%u.%03u cd/m²)\n",
            final,
            final / 1000,
            final % 1000
        );


        if (!success)
        {
            fprintf(
                stderr,
                "x2-bright: WARNING: "
                "readback does not match requested value\n"
            );
        }
    }


    /* ========================================================
     * READ
     * ======================================================== */

    else if (
        strcmp(
            argv[1],
            "read"
        ) == 0 &&
        argc >= 3
    )
    {
        uint32_t addr =
            strtoul(
                argv[2],
                NULL,
                16
            );


        uint32_t count =
            argc >= 4
                ? (uint32_t)atoi(argv[3])
                : 4;


        if (count > 16)
            count = 16;


        uint8_t data[16];


        dpcd_read(
            edp,
            addr,
            data,
            count
        );
    }


    /* ========================================================
     * RAW WRITE
     * ======================================================== */

    else if (
        strcmp(
            argv[1],
            "raw"
        ) == 0 &&
        argc >= 4
    )
    {
        uint32_t addr =
            strtoul(
                argv[2],
                NULL,
                16
            );


        uint32_t count =
            argc - 3;


        if (count > 16)
            count = 16;


        uint8_t data[16];


        for (
            uint32_t i = 0;
            i < count;
            i++
        )
        {
            data[i] =
                (uint8_t)strtoul(
                    argv[3 + i],
                    NULL,
                    16
                );
        }


        printf(
            "Writing %u bytes to "
            "DPCD 0x%04x:",
            count,
            addr
        );


        for (
            uint32_t i = 0;
            i < count;
            i++
        )
        {
            printf(
                " %02x",
                data[i]
            );
        }


        printf("\n");


        if (
            dpcd_write(
                edp,
                addr,
                data,
                count
            ) != 0
        )
        {
            fprintf(
                stderr,
                "DPCD write failed\n"
            );
        }


        dpcd_read(
            edp,
            addr,
            NULL,
            count
        );
    }


    /* ========================================================
     * DUMP
     * ======================================================== */

    else if (
        strcmp(
            argv[1],
            "dump"
        ) == 0
    )
    {
        printf(
            "\neDP capabilities "
            "(0x700-0x71F):\n"
        );


        for (
            uint32_t addr = 0x700;
            addr < 0x720;
            addr += 4
        )
        {
            dpcd_read(
                edp,
                addr,
                NULL,
                4
            );
        }


        printf(
            "\neDP control "
            "(0x720-0x73F):\n"
        );


        for (
            uint32_t addr = 0x720;
            addr < 0x740;
            addr += 4
        )
        {
            dpcd_read(
                edp,
                addr,
                NULL,
                4
            );
        }
    }


    else
    {
        fprintf(
            stderr,
            "Unknown command: %s\n",
            argv[1]
        );


        fprintf(
            stderr,
            "Use: x2-bright [lum|watch|read|raw|dump]\n"
        );
    }


    cleanup();

    return 0;
}