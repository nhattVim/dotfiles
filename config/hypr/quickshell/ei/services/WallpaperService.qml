pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string wallpaperDir: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    property var wallpaperPaths: []
    property int currentIndex: -1
    property string currentWallpaper: (currentIndex >= 0 && currentIndex < wallpaperPaths.length) ? wallpaperPaths[currentIndex] : ""
    property bool hyprpaperEnabled: true
    property string appliedWallpaper: ""
    property string pendingWallpaper: ""
    property string lastError: ""
    property int applyRetryCount: 0
    property bool applyAfterEnsure: false
    readonly property string cacheDir: Quickshell.env("HOME") + "/.cache/ei"
    readonly property string hyprpaperConfigPath: cacheDir + "/hyprpaper.conf"
    readonly property bool hyprpaperBusy: ensureHyprpaperProcess.running || applyHyprpaperProcess.running || applyDelay.running

    function refresh() {
        if (!scanWallpapers.running) {
            scanWallpapers.running = true;
        }
    }

    function applyScanResults(text) {
        const paths = text.split("\n")
            .map(line => line.trim())
            .filter(path => path.length > 0)
            .sort();

        root.wallpaperPaths = paths;
        if (paths.length > 0) {
            loadConfig();
        } else {
            root.currentIndex = -1;
            console.log("[WallpaperService] No wallpapers found in", root.wallpaperDir);
        }
    }

    function shellQuote(value) {
        return "'" + String(value).replace(/'/g, "'\\''") + "'";
    }

    function monitorWallpaperCommands(path) {
        const screens = Quickshell.screens || [];
        let commands = [];

        if (screens.length === 0) {
            commands.push("hyprctl hyprpaper wallpaper " + shellQuote(", " + path + ", cover"));
            return commands;
        }

        for (let i = 0; i < screens.length; i++) {
            commands.push("hyprctl hyprpaper wallpaper " + shellQuote(screens[i].name + ", " + path + ", cover"));
        }

        return commands;
    }

    function hyprpaperConfigText(path) {
        const screens = Quickshell.screens || [];
        let lines = [
            "ipc = true",
            "splash = false"
        ];

        if (screens.length === 0) {
            lines.push("wallpaper {");
            lines.push("    monitor = ");
            lines.push("    path = " + path);
            lines.push("    fit_mode = cover");
            lines.push("}");
        } else {
            for (let i = 0; i < screens.length; i++) {
                lines.push("wallpaper {");
                lines.push("    monitor = " + screens[i].name);
                lines.push("    path = " + path);
                lines.push("    fit_mode = cover");
                lines.push("}");
            }
        }

        return lines.join("\n") + "\n";
    }

    function syncHyprpaperConfig(path) {
        if (!path) return;
        hyprpaperConfigFile.setText(hyprpaperConfigText(path));
    }

    function ensureHyprpaperRunning(path) {
        if (!hyprpaperEnabled || !path) return;

        pendingWallpaper = path;
        lastError = "";
        applyRetryCount = 0;
        applyAfterEnsure = false;
        syncHyprpaperConfig(path);

        if (ensureHyprpaperProcess.running || applyHyprpaperProcess.running) return;
        ensureHyprpaperProcess.running = true;
    }

    function requestHyprpaperApply(path) {
        if (!hyprpaperEnabled || !path) return;

        pendingWallpaper = path;
        lastError = "";
        applyRetryCount = 0;
        applyAfterEnsure = true;
        syncHyprpaperConfig(path);

        if (ensureHyprpaperProcess.running || applyHyprpaperProcess.running) return;
        ensureHyprpaperProcess.running = true;
    }

    function runHyprpaperApply() {
        if (applyHyprpaperProcess.running) return;

        const path = pendingWallpaper || currentWallpaper;
        if (!path) return;

        const coreCommand = monitorWallpaperCommands(path).join(" && ");

        applyHyprpaperProcess.command = [
            "sh",
            "-c",
            coreCommand
        ];
        applyHyprpaperProcess.running = true;
    }

    // Scans wall dir for files
    Process {
        id: scanWallpapers
        running: false
        
        command: ["find", wallpaperDir, "-maxdepth", "2", "-name", ".*", "-prune", "-o", "-type", "f", "(", "-name", "*.jpg", "-o", "-name", "*.jpeg", "-o", "-name", "*.png", "-o", "-name", "*.webp", ")", "-print"]

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.applyScanResults(text)
        }
    }

    // Persistent storage for active wallpaper
    FileView {
        id: configFile
        path: root.cacheDir + "/wallpaper.json"
    }

    FileView {
        id: hyprpaperConfigFile
        path: root.hyprpaperConfigPath
    }
    
    Process {
        id: ensureCacheDir
        command: ["mkdir", "-p", root.cacheDir]
        onExited: root.refresh()
    }

    function loadConfig() {
        try {
            let txt = configFile.text();
            if (txt) {
                let data = JSON.parse(txt);
                if (data && data.currentWallpaper) {
                    let idx = wallpaperPaths.indexOf(data.currentWallpaper);
                    if (idx !== -1) {
                        currentIndex = idx;
                        ensureHyprpaperRunning(currentWallpaper);
                        return;
                    }
                }
            }
        } catch(e) {
            console.log("[WallpaperService] Config file not found or invalid. Loading defaults.");
        }
        
        // Fallback to first wallpaper in directory
        if (wallpaperPaths.length > 0) {
            currentIndex = 0;
            ensureHyprpaperRunning(currentWallpaper);
        }
    }

    function saveConfig() {
        if (!currentWallpaper) return;
        let data = {
            "currentWallpaper": currentWallpaper
        };
        configFile.setText(JSON.stringify(data, null, 2));
    }

    function nextWallpaper() {
        if (wallpaperPaths.length === 0) return;
        currentIndex = (currentIndex + 1) % wallpaperPaths.length;
        saveConfig();
        requestHyprpaperApply(currentWallpaper);
    }

    function previousWallpaper() {
        if (wallpaperPaths.length === 0) return;
        currentIndex = (currentIndex - 1 + wallpaperPaths.length) % wallpaperPaths.length;
        saveConfig();
        requestHyprpaperApply(currentWallpaper);
    }

    // Allow setting via global methods
    function setWallpaperByIndex(idx) {
        if (idx >= 0 && idx < wallpaperPaths.length) {
            if (idx === currentIndex) return;
            currentIndex = idx;
            saveConfig();
            requestHyprpaperApply(currentWallpaper);
        }
    }
    
    function setWallpaperByPath(path) {
        let idx = wallpaperPaths.indexOf(path);
        if (idx !== -1) {
            if (idx === currentIndex) return;
            currentIndex = idx;
            saveConfig();
            requestHyprpaperApply(currentWallpaper);
        }
    }

    Component.onCompleted: {
        ensureCacheDir.running = true;
    }

    Process {
        id: ensureHyprpaperProcess
        running: false
        command: [
            "sh",
            "-c",
            "command -v hyprpaper >/dev/null 2>&1 || exit 127; " +
            "sock_a=\"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.hyprpaper.sock\"; " +
            "sock_b=\"/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.hyprpaper.sock\"; " +
            "if pgrep -x hyprpaper >/dev/null 2>&1 && [ ! -S \"$sock_a\" ] && [ ! -S \"$sock_b\" ]; then " +
            "pkill -x hyprpaper || true; " +
            "fi; " +
            "if ! pgrep -x hyprpaper >/dev/null 2>&1; then " +
            "setsid -f hyprpaper --config " + root.shellQuote(root.hyprpaperConfigPath) + " >/tmp/ei-hyprpaper.log 2>&1 < /dev/null; " +
            "fi"
        ]

        stderr: StdioCollector {
            id: ensureHyprpaperError
            waitForEnd: true
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.lastError = ensureHyprpaperError.text.trim() || "hyprpaper is not available";
                console.warn("[WallpaperService]", root.lastError);
                return;
            }

            if (root.applyAfterEnsure) {
                applyDelay.restart();
            }
        }
    }

    Timer {
        id: applyDelay
        interval: 600
        repeat: false
        onTriggered: root.runHyprpaperApply()
    }

    Process {
        id: applyHyprpaperProcess
        running: false

        stdout: StdioCollector {
            id: applyHyprpaperOutput
            waitForEnd: true
        }

        stderr: StdioCollector {
            id: applyHyprpaperError
            waitForEnd: true
        }

        onExited: exitCode => {
            if (exitCode === 0) {
                root.appliedWallpaper = root.pendingWallpaper;
                root.pendingWallpaper = "";
                root.lastError = "";
                root.applyRetryCount = 0;
                root.applyAfterEnsure = false;
                return;
            }

            root.lastError = applyHyprpaperError.text.trim() || applyHyprpaperOutput.text.trim() || "hyprpaper failed to apply wallpaper";
            if (root.applyRetryCount < 2 && root.lastError.indexOf("failed to connect") !== -1) {
                root.applyRetryCount++;
                ensureHyprpaperProcess.running = true;
                return;
            }

            console.warn("[WallpaperService]", root.lastError);
        }
    }
}
