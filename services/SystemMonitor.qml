pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real cpuUsage: 0
    property real ramUsage: 0
    property real cpuTemp: 0
    property real gpuUsage: 0
    property real gpuTemp: 0
    property real storageUsage: 0    // percentage used

    property real downloadSpeed: 0   // bytes/sec
    property real uploadSpeed: 0     // bytes/sec
    property string uptimeString: "0m"

    property var _lastIdle: 0
    property var _lastTotal: 0

    property real _lastRxBytes: 0
    property real _lastTxBytes: 0
    property bool _netInitialized: false

    // ---------------- CPU USAGE via FileView (/proc/stat) ----------------
    FileView {
        id: statFile
        path: "/proc/stat"
    }

    function parseCpu() {
        const text = statFile.text();
        const line = text.split("\n")[0].trim().split(/\s+/);
        const nums = line.slice(1).map(Number);
        const idle = nums[3] + nums[4];
        const total = nums.reduce((a, b) => a + b, 0);
        const deltaIdle = idle - root._lastIdle;
        const deltaTotal = total - root._lastTotal;
        if (root._lastTotal !== 0 && deltaTotal > 0) {
            root.cpuUsage = (1 - deltaIdle / deltaTotal) * 100;
        }
        root._lastIdle = idle;
        root._lastTotal = total;
    }

    // ---------------- RAM USAGE via FileView (/proc/meminfo) ----------------
    FileView {
        id: memFile
        path: "/proc/meminfo"
    }

    function parseRam() {
        const text = memFile.text();

        const totalMatch = text.match(/MemTotal:\s+(\d+)/);
        const availMatch = text.match(/MemAvailable:\s+(\d+)/);

        if (!totalMatch || !availMatch)
            return;

        const total = Number(totalMatch[1]);
        const avail = Number(availMatch[1]);

        if (!Number.isFinite(total) || !Number.isFinite(avail) || total <= 0)
            return;

        root.ramUsage = Math.max(
            0,
            Math.min(
                100,
                ((total - avail) / total) * 100
            )
        );
    }

    // ---------------- CPU TEMP via FileView (hwmon) ----------------
    // Find the right path once with:
    //      for f in /sys/class/hwmon/hwmon*/name; do echo "$f: $(cat $f)"; done
    // Look for "coretemp" (Intel) or "k10temp" (AMD), then find the matching
    // tempN_input file whose tempN_label is "Package id 0" / "Tctl" / "Tdie".
    FileView {
        id: cpuTempFile
        path: "/sys/class/hwmon/hwmon4/temp1_input"  // k10temp (AMD) - Tctl
    }

    function parseCpuTemp() {
        const v = parseFloat(cpuTempFile.text());
        if (!isNaN(v)) root.cpuTemp = v / 1000; // millidegrees -> degrees C
    }

    // ---------------- NETWORK SPEED via FileView (/proc/net/dev) ----------------
    // Find your interface name once with: `ip -o link show` or `cat /proc/net/dev`
    // Common names: eth0, enp3s0, wlan0, wlp2s0. Skip "lo" (loopback).
    FileView {
        id: netFile
        path: "/proc/net/dev"
    }

    // Leave blank to auto-detect the interface with the most total traffic
    // (skips "lo"). Set explicitly (e.g. "wlan0", "enp3s0") to force one.
    property string netInterface: ""
    property string _detectedInterface: ""

    function parseNet() {
        const text = netFile.text();
        const lines = text.split("\n");

        let rxBytes = 0, txBytes = 0;
        let targetIface = root.netInterface;

        if (!targetIface) {
            // Auto-detect: pick the non-loopback interface with the highest
            // combined rx+tx byte count (i.e. the one actually in use).
            let bestIface = "";
            let bestTotal = -1;
            for (let i = 2; i < lines.length; i++) {
                const line = lines[i].trim();
                if (!line) continue;
                const [ifaceRaw, rest] = line.split(":");
                if (!rest) continue;
                const iface = ifaceRaw.trim();
                if (iface === "lo" || iface === "") continue;

                const fields = rest.trim().split(/\s+/).map(Number);
                const total = fields[0] + fields[8];
                if (total > bestTotal) {
                    bestTotal = total;
                    bestIface = iface;
                }
            }
            targetIface = bestIface;
            root._detectedInterface = bestIface;
        }

        if (!targetIface) return;

        for (let i = 2; i < lines.length; i++) {
            const line = lines[i].trim();
            if (!line) continue;
            const [ifaceRaw, rest] = line.split(":");
            if (!rest) continue;
            const iface = ifaceRaw.trim();
            if (iface !== targetIface) continue;

            const fields = rest.trim().split(/\s+/).map(Number);
            rxBytes = fields[0];
            txBytes = fields[8];
            break;
        }

        if (root._netInitialized) {
            const rxDelta = rxBytes - root._lastRxBytes;
            const txDelta = txBytes - root._lastTxBytes;
            // interval is 1000ms, so bytes/interval == bytes/sec here
            root.downloadSpeed = Math.max(0, rxDelta);
            root.uploadSpeed = Math.max(0, txDelta);
        }

        root._lastRxBytes = rxBytes;
        root._lastTxBytes = txBytes;
        root._netInitialized = true;
    }

    // ---------------- UPTIME via FileView (/proc/uptime) ----------------
    FileView {
        id: uptimeFile
        path: "/proc/uptime"
    }

    function parseUptime() {
        const text = uptimeFile.text();
        const seconds = parseFloat(text.split(" ")[0]);
        if (isNaN(seconds)) return;

        const days = Math.floor(seconds / 86400);
        const hours = Math.floor((seconds % 86400) / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);

        let result = "";
        if (days > 0) result += days + "d ";
        if (hours > 0 || days > 0) result += hours + "h ";
        result += minutes + "m";

        root.uptimeString = result.trim();
    }

    // ---------------- GPU (AMD) via FileView, no subprocess ----------------
    // Uncomment and adjust hwmon index for AMD cards:
    // FileView { id: gpuBusyFile; path: "/sys/class/drm/card0/device/gpu_busy_percent" }
    // FileView { id: gpuTempFile; path: "/sys/class/hwmon/hwmon3/temp1_input" }
    // function parseGpuAmd() {
    //     root.gpuUsage = parseFloat(gpuBusyFile.text());
    //     root.gpuTemp = parseFloat(gpuTempFile.text()) / 1000;
    // }

    // ---------------- GPU (NVIDIA) - still needs a subprocess ----------------
    Process {
        id: gpuProc
        command: ["nvidia-smi", "--query-gpu=utilization.gpu,temperature.gpu",
                  "--format=csv,noheader,nounits"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(",").map(s => parseFloat(s));
                if (parts.length === 2 && !isNaN(parts[0]) && !isNaN(parts[1])) {
                    root.gpuUsage = parts[0];
                    root.gpuTemp = parts[1];
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                console.log("SystemMonitor: nvidia-smi failed (exit " + exitCode + "), keeping last known GPU values");
            }
        }
    }

    // ---------------- STORAGE USAGE via Process (df) ----------------
    // Change "/" to another mount point if you want a different disk/partition.
    Process {
        id: storageProc
        command: ["df", "--output=pcent", "/"]
        stdout: StdioCollector {
            onStreamFinished: {
                // output looks like:
                // Use%
                //  42%
                const lines = this.text.trim().split("\n");
                if (lines.length >= 2) {
                    const pcent = parseFloat(lines[1].replace("%", "").trim());
                    if (!isNaN(pcent)) root.storageUsage = pcent;
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                console.log("SystemMonitor: df failed (exit " + exitCode + "), keeping last known storage value");
            }
        }
    }

    // ---------------- Poll timer (fast: cpu/ram/temp/net/uptime) ----------------
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            statFile.reload();
            memFile.reload();
            cpuTempFile.reload();
            netFile.reload();
            uptimeFile.reload();
            root.parseCpu();
            root.parseRam();
            root.parseCpuTemp();
            root.parseNet();
            root.parseUptime();
        }
    }

    // GPU subprocess polled less frequently since it's more expensive.
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: gpuProc.running = true
    }

    // Storage barely changes moment to moment, poll infrequently.
    Timer {
        interval: 100000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: storageProc.running = true
    }
}
