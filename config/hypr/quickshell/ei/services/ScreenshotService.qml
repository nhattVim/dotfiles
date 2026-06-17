pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string screenshotsDir: Quickshell.env("HOME") + "/Pictures/Screenshots"
    property string lastPath: ""
    property string lastError: ""
    property bool busy: false
    property string pendingMode: "region"
    property bool regionOverlayVisible: false
    property int regionRequestSerial: 0
    property string overlayMode: "region"
    property var windows: []

    function shellQuote(value) {
        return "'" + String(value).replace(/'/g, "'\\''") + "'";
    }

    function timestamp() {
        const d = new Date();
        const pad = n => String(n).padStart(2, "0");
        return d.getFullYear() + "-" + pad(d.getMonth() + 1) + "-" + pad(d.getDate()) + "-" + pad(d.getHours()) + "-" + pad(d.getMinutes()) + "-" + pad(d.getSeconds());
    }

    function nextPath() {
        return screenshotsDir + "/Screenshot_" + timestamp() + ".png";
    }

    function capture(mode) {
        if (busy) return;

        pendingMode = mode === "screen" ? "screen" : "region";
        lastPath = nextPath();
        lastError = "";

        busy = true;
        ensureDirProcess.running = true;
    }

    function captureRegion() {
        requestRegion();
    }

    function captureScreen() {
        capture("screen");
    }

    function requestRegion() {
        if (busy) return;
        lastError = "";
        overlayMode = "region";
        regionRequestSerial += 1;
        regionOverlayVisible = true;
        refreshWindows();
    }

    function cancelRegion() {
        regionOverlayVisible = false;
    }

    function setOverlayMode(mode) {
        overlayMode = (mode === "window" || mode === "screen") ? mode : "region";
        if (overlayMode === "window") {
            refreshWindows();
        }
    }

    function refreshWindows() {
        if (!windowsProcess.running) {
            windowsProcess.running = true;
        }
    }

    function captureGeometry(x, y, w, h) {
        if (busy) return;
        if (w < 4 || h < 4) {
            cancelRegion();
            return;
        }

        pendingMode = "geometry";
        lastPath = nextPath();
        lastError = "";
        busy = true;
        regionOverlayVisible = false;
        pendingGeometry = Math.round(x) + "," + Math.round(y) + " " + Math.round(w) + "x" + Math.round(h);

        captureDelay.restart();
    }

    function fail(message) {
        busy = false;
        lastError = message || "Capture cancelled or failed";
        console.warn("[ScreenshotService]", lastError);
        notifyErrorProcess.command = ["notify-send", "-u", "critical", "Screenshot", lastError];
        notifyErrorProcess.running = true;
    }

    function runGrim(region) {
        if (region && region.length > 0) {
            captureProcess.command = ["grim", "-g", region, lastPath];
        } else {
            captureProcess.command = ["grim", lastPath];
        }
        captureProcess.running = true;
    }

    Process {
        id: ensureDirProcess
        command: ["mkdir", "-p", root.screenshotsDir]

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.fail("Cannot create screenshots directory: " + root.screenshotsDir);
                return;
            }

            if (root.pendingMode === "screen") {
                root.runGrim("");
            } else if (root.pendingMode === "geometry") {
                root.runGrim(root.pendingGeometry);
            } else {
                slurpProcess.running = true;
            }
        }
    }

    Timer {
        id: captureDelay
        interval: 420
        repeat: false
        onTriggered: ensureDirProcess.running = true
    }

    Process {
        id: slurpProcess
        command: ["slurp"]

        stdout: StdioCollector {
            id: slurpOutput
            waitForEnd: true
        }

        stderr: StdioCollector {
            id: slurpError
            waitForEnd: true
        }

        onExited: exitCode => {
            const region = slurpOutput.text.trim();
            if (exitCode !== 0 || region.length === 0) {
                root.fail(slurpError.text.trim() || "Region selection cancelled");
                return;
            }
            root.runGrim(region);
        }
    }

    Process {
        id: captureProcess

        stderr: StdioCollector {
            id: captureError
            waitForEnd: true
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.fail(captureError.text.trim() || "grim failed");
                return;
            }

            copyNotifyProcess.command = ["sh", "-c", "wl-copy --type image/png < " + root.shellQuote(root.lastPath) + " && notify-send " + root.shellQuote("Screenshot") + " " + root.shellQuote("Saved to " + root.lastPath)];
            copyNotifyProcess.running = true;
            root.busy = false;
        }
    }

    Process {
        id: copyNotifyProcess
    }

    Process {
        id: notifyErrorProcess
    }

    Process {
        id: windowsProcess
        command: ["sh", "-c", "printf '__MONITORS__\\n'; hyprctl monitors -j; printf '\\n__CLIENTS__\\n'; hyprctl clients -j"]

        stdout: StdioCollector {
            id: windowsOutput
            waitForEnd: true
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.windows = [];
                return;
            }

            try {
                const parts = windowsOutput.text.split("__CLIENTS__");
                const monitorsText = parts[0].replace("__MONITORS__", "").trim();
                const clientsText = parts.length > 1 ? parts[1].trim() : "[]";
                const monitors = JSON.parse(monitorsText);
                const activeWorkspaceIds = monitors.map(monitor => monitor?.activeWorkspace?.id).filter(id => id !== undefined && id !== null);
                const clients = JSON.parse(clientsText);
                root.windows = clients.filter(client => {
                    const workspaceId = client?.workspace?.id;
                    return client && client.mapped && !client.hidden && client.at && client.size
                        && (client.pinned || activeWorkspaceIds.indexOf(workspaceId) !== -1);
                }).map(client => ({
                    title: client.title || "",
                    app: client.class || client.initialClass || "",
                    x: Number(client.at[0] || 0),
                    y: Number(client.at[1] || 0),
                    width: Number(client.size[0] || 0),
                    height: Number(client.size[1] || 0),
                    focusHistoryId: Number(client.focusHistoryID ?? 9999)
                })).filter(client => client.width > 4 && client.height > 4)
                    .sort((a, b) => b.focusHistoryId - a.focusHistoryId);
            } catch (e) {
                console.warn("[ScreenshotService] failed to parse windows:", e);
                root.windows = [];
            }
        }
    }

    property string pendingGeometry: ""
}
