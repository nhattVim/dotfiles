pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "."
import "../config"

Singleton {
    id: root

    property bool enabled: true
    property string sampledWallpaper: ""
    property string pendingWallpaper: ""

    function refresh() {
        if (!enabled) return;

        const path = WallpaperService.currentWallpaper;
        if (path === "") {
            sampledWallpaper = "";
            pendingWallpaper = "";
            ThemeService.resetPalette();
            return;
        }

        if (sampleProcess.running) {
            pendingWallpaper = path;
            return;
        }

        pendingWallpaper = "";
        sampledWallpaper = path;
        sampleProcess.command = ["magick", path, "-resize", "1x1!", "-format", "%[hex:p{0,0}]", "info:"];
        sampleProcess.running = true;
    }

    function applySample(text) {
        const hex = String(text || "").trim().slice(0, 6);
        if (hex.length !== 6) {
            ThemeService.resetPalette();
            return;
        }

        ThemeService.applyAccentHex(hex);
    }

    Connections {
        target: WallpaperService

        function onCurrentWallpaperChanged() {
            root.refresh();
        }

        function onCurrentIndexChanged() {
            root.refresh();
        }

        function onWallpaperPathsChanged() {
            root.refresh();
        }
    }

    Process {
        id: sampleProcess
        running: false

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.applySample(text)
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                ThemeService.resetPalette();
            }

            if (root.pendingWallpaper !== "" && root.pendingWallpaper !== root.sampledWallpaper) {
                Qt.callLater(root.refresh);
            }
        }
    }

    Component.onCompleted: Qt.callLater(root.refresh)
}
