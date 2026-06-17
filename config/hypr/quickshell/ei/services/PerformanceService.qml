pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool ready: false

    property real cpuUsage: 0
    property real cpuTemp: 0
    property int cpuCores: 0
    property real load1: 0
    property real load5: 0
    property real load15: 0

    property real memoryTotal: 0
    property real memoryUsed: 0
    property real memoryUsage: 0
    property real swapTotal: 0
    property real swapUsed: 0
    property real swapUsage: 0

    property real diskTotal: 0
    property real diskUsed: 0
    property real diskUsage: 0
    property string uptime: "--"

    property bool gpuAvailable: false
    property string gpuName: "GPU"
    property real gpuUsage: 0
    property real gpuTemp: 0
    property real gpuMemoryTotal: 0
    property real gpuMemoryUsed: 0
    property real gpuMemoryUsage: 0

    property real previousCpuTotal: 0
    property real previousCpuIdle: 0

    function refresh() {
        if (!sampleProcess.running) sampleProcess.running = true;
    }

    function parseSample(text) {
        const lines = text.trim().split("\n");
        let memTotalKb = 0;
        let memAvailableKb = 0;
        let swapTotalKb = 0;
        let swapFreeKb = 0;

        for (let i = 0; i < lines.length; i++) {
            const parts = lines[i].trim().split(/\s+/);
            if (parts.length === 0) continue;

            if (parts[0] === "cpu" && parts.length >= 9) {
                let total = 0;
                for (let c = 1; c < parts.length; c++) total += Number(parts[c]) || 0;
                const idle = (Number(parts[4]) || 0) + (Number(parts[5]) || 0);
                if (previousCpuTotal > 0) {
                    const totalDelta = total - previousCpuTotal;
                    const idleDelta = idle - previousCpuIdle;
                    cpuUsage = totalDelta > 0 ? Math.max(0, Math.min(100, (1 - idleDelta / totalDelta) * 100)) : 0;
                }
                previousCpuTotal = total;
                previousCpuIdle = idle;
            } else if (parts[0] === "cores" && parts.length >= 2) {
                cpuCores = Number(parts[1]) || 0;
            } else if (parts[0] === "temp" && parts.length >= 2) {
                cpuTemp = Number(parts[1]) || 0;
            } else if (parts[0] === "memTotal" && parts.length >= 2) {
                memTotalKb = Number(parts[1]) || 0;
            } else if (parts[0] === "memAvailable" && parts.length >= 2) {
                memAvailableKb = Number(parts[1]) || 0;
            } else if (parts[0] === "swapTotal" && parts.length >= 2) {
                swapTotalKb = Number(parts[1]) || 0;
            } else if (parts[0] === "swapFree" && parts.length >= 2) {
                swapFreeKb = Number(parts[1]) || 0;
            } else if (parts[0] === "load" && parts.length >= 4) {
                load1 = Number(parts[1]) || 0;
                load5 = Number(parts[2]) || 0;
                load15 = Number(parts[3]) || 0;
            } else if (parts[0] === "uptime" && parts.length >= 2) {
                uptime = formatDuration(Number(parts[1]) || 0);
            } else if (parts[0] === "disk" && parts.length >= 4) {
                diskTotal = kbToGb(Number(parts[1]) || 0);
                diskUsed = kbToGb(Number(parts[2]) || 0);
                diskUsage = diskTotal > 0 ? Math.max(0, Math.min(100, diskUsed / diskTotal * 100)) : 0;
            } else if (parts[0] === "gpu" && parts.length >= 6) {
                gpuAvailable = true;
                gpuUsage = Number(parts[1]) || 0;
                gpuTemp = Number(parts[2]) || 0;
                gpuMemoryUsed = Number(parts[3]) / 1024 || 0;
                gpuMemoryTotal = Number(parts[4]) / 1024 || 0;
                gpuMemoryUsage = gpuMemoryTotal > 0 ? Math.max(0, Math.min(100, gpuMemoryUsed / gpuMemoryTotal * 100)) : 0;
                gpuName = parts.slice(5).join(" ");
            }
        }

        memoryTotal = kbToGb(memTotalKb);
        memoryUsed = kbToGb(Math.max(0, memTotalKb - memAvailableKb));
        memoryUsage = memoryTotal > 0 ? Math.max(0, Math.min(100, memoryUsed / memoryTotal * 100)) : 0;
        swapTotal = kbToGb(swapTotalKb);
        swapUsed = kbToGb(Math.max(0, swapTotalKb - swapFreeKb));
        swapUsage = swapTotal > 0 ? Math.max(0, Math.min(100, swapUsed / swapTotal * 100)) : 0;
        ready = true;
    }

    function kbToGb(value) {
        return Math.round(value / 1024 / 1024 * 10) / 10;
    }

    function formatDuration(seconds) {
        const days = Math.floor(seconds / 86400);
        const hours = Math.floor((seconds % 86400) / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        if (days > 0) return days + "d " + hours + "h";
        if (hours > 0) return hours + "h " + minutes + "m";
        return minutes + "m";
    }

    Process {
        id: sampleProcess
        running: true
        command: ["sh", "-c", "awk '/^cpu /{print}' /proc/stat; printf 'cores '; nproc; awk '/MemTotal/{print \"memTotal \"$2} /MemAvailable/{print \"memAvailable \"$2} /SwapTotal/{print \"swapTotal \"$2} /SwapFree/{print \"swapFree \"$2}' /proc/meminfo; awk '{print \"load \"$1\" \"$2\" \"$3}' /proc/loadavg; awk '{print \"uptime \"$1}' /proc/uptime; df -k / | awk 'NR==2{print \"disk \"$2\" \"$3\" \"$4}'; temp=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | sort -nr | head -n1); if [ -n \"$temp\" ]; then awk -v t=\"$temp\" 'BEGIN{printf \"temp %.1f\\n\", t/1000}'; fi; if command -v nvidia-smi >/dev/null 2>&1; then nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total,name --format=csv,noheader,nounits 2>/dev/null | head -n1 | awk -F ', ' '{print \"gpu \"$1\" \"$2\" \"$3\" \"$4\" \"$5}'; fi"]

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.parseSample(text)
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
