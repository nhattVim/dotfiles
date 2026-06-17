pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property bool locked: lockProcess.running
    property string message: ""
    readonly property string configPath: Qt.resolvedUrl("../config/hyprlock.conf").toString().replace("file://", "")

    function lock() {
        if (lockProcess.running) return;
        message = "";
        lockProcess.running = true;
    }

    function unlock() {
        if (lockProcess.running) {
            stopProcess.running = true;
        }
    }

    function toggle() {
        if (locked) unlock();
        else lock();
    }

    Process {
        id: lockProcess
        command: ["hyprlock", "-c", root.configPath]

        stderr: StdioCollector {
            id: lockError
            waitForEnd: true
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.message = lockError.text.trim() || "hyprlock failed. Is hyprlock installed?";
                notifyError.command = ["notify-send", "-u", "critical", "Lockscreen", root.message];
                notifyError.running = true;
            } else {
                root.message = "";
            }
        }
    }

    Process {
        id: stopProcess
        command: ["pkill", "-f", "hyprlock"]
    }

    Process {
        id: notifyError
    }
}
