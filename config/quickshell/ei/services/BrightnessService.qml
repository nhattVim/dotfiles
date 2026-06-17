pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    signal brightnessChanged(real value, var screen)

    property real value: 0
    property bool ready: false
    property int rawBrightness: 0
    property int rawMaxBrightness: 100

    function clamp(value, min, max) {
        return Math.max(min, Math.min(max, value));
    }

    function refresh() {
        if (!readProcess.running) {
            readProcess.running = true;
        }
    }

    function setBrightness(value, screen) {
        const nextValue = clamp(value, 0.01, 1.0);
        root.value = nextValue;
        root.ready = true;
        root.brightnessChanged(root.value, screen || null);

        const raw = Math.round(root.value * root.rawMaxBrightness);
        setProcess.command = ["brightnessctl", "--class", "backlight", "s", raw.toString(), "--quiet"];
        setProcess.running = true;
    }

    function changeBrightness(delta, screen) {
        setBrightness((root.ready ? root.value : 0.5) + delta, screen);
    }

    IpcHandler {
        target: "brightness"

        function increment(): void {
            root.changeBrightness(0.05, null);
        }

        function decrement(): void {
            root.changeBrightness(-0.05, null);
        }

        function adjust(delta: real): void {
            root.changeBrightness(delta, null);
        }

        function set(value: real): void {
            root.setBrightness(value, null);
        }

        function refresh(): void {
            root.refresh();
        }
    }

    Process {
        id: readProcess
        command: ["brightnessctl", "--class", "backlight", "-m"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split(",");
                if (fields.length < 5) {
                    root.ready = false;
                    return;
                }

                const current = parseInt(fields[2]);
                const max = parseInt(fields[4]);
                if (isNaN(current) || isNaN(max) || max <= 0) {
                    root.ready = false;
                    return;
                }

                root.rawBrightness = current;
                root.rawMaxBrightness = max;
                root.value = root.clamp(current / max, 0, 1);
                root.ready = true;
                root.brightnessChanged(root.value, null);
            }
        }

        onExited: code => {
            if (code !== 0) {
                root.ready = false;
            }
        }
    }

    Process {
        id: setProcess
        running: false
        onExited: root.refresh()
    }
}
