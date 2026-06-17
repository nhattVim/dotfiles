pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "."

Singleton {
    id: root

    property string activeWindowTitle: ""
    property string activeWindowClass: ""
    property string activeWindowAddress: ""

    function applyActiveWindowPayload(text) {
        try {
            let obj = JSON.parse(text);
            root.activeWindowTitle = obj.title || "";
            root.activeWindowClass = obj.class || "";
            root.activeWindowAddress = obj.address || "";
        } catch(e) {
            // No window focused or parsing failed
        }
    }

    function refreshActiveWindow() {
        if (!activeWindowProcess.running) {
            activeWindowProcess.running = true;
        }
    }

    Process {
        id: activeWindowProcess
        command: ["hyprctl", "activewindow", "-j"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.applyActiveWindowPayload(text)
        }
    }

    // Connect to dynamic socket updates
    Connections {
        target: HyprlandSocket

        function onActiveWindowChanged(clientClass, title) {
            root.activeWindowClass = clientClass || "";
            root.activeWindowTitle = title || "";
            root.refreshActiveWindow();
        }
    }
}
