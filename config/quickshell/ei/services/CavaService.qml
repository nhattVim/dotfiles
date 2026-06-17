pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int barCount: 28
    property var bars: Array(barCount).fill(0)
    property bool available: false

    readonly property string configText:
        "[general]\n" +
        "bars = " + barCount + "\n" +
        "framerate = 30\n" +
        "[input]\n" +
        "method = pipewire\n" +
        "[output]\n" +
        "method = raw\n" +
        "raw_target = /dev/stdout\n" +
        "data_format = ascii\n" +
        "ascii_max_range = 100\n"

    Process {
        id: cavaProcess
        command: ["sh", "-c", "printf '" + root.configText.replace(/'/g, "'\\''") + "' | cava -p /dev/stdin"]
        running: true

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const values = data.trim()
                    .split(/[;,\s]+/)
                    .map(value => parseInt(value))
                    .filter(value => !isNaN(value));

                if (values.length === 0) return;

                const next = [];
                for (let i = 0; i < root.barCount; i++) {
                    next.push(Math.max(0, Math.min(1, (values[i] || 0) / 100)));
                }
                root.bars = next;
                root.available = true;
            }
        }

        onExited: {
            root.available = false;
            restartTimer.restart();
        }
    }

    Timer {
        id: restartTimer
        interval: 3000
        repeat: false
        onTriggered: if (!cavaProcess.running) cavaProcess.running = true
    }
}
