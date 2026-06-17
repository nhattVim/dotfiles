pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool active: false

    function toggle() {
        if (active) {
            if (!killProcess.running) killProcess.running = true;
        } else {
            if (!wlsunsetProcess.running) wlsunsetProcess.running = true;
        }
    }

    function refresh() {
        if (!checkProcess.running) checkProcess.running = true;
    }

    Process {
        id: wlsunsetProcess
        command: ["wlsunset", "-t", "4499", "-T", "4500"]
        running: false
        onStarted: root.active = true
        onExited: root.active = false
    }

    Process {
        id: killProcess
        command: ["pkill", "wlsunset"]
        running: false
        onExited: root.refresh()
    }

    Process {
        id: checkProcess
        command: ["pgrep", "wlsunset"]
        running: true
        onExited: code => root.active = code === 0
    }
}
