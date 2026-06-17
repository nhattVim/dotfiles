pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property bool active: inhibitProcess.running

    function toggle() {
        inhibitProcess.running = !inhibitProcess.running;
    }

    Process {
        id: inhibitProcess
        command: ["systemd-inhibit", "--what=idle:sleep", "--who=ei", "--why=Caffeine mode", "sleep", "infinity"]
        running: false
    }
}
