pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string socketPath: {
        let xdg = Quickshell.env("XDG_RUNTIME_DIR");
        let sig = Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE");
        if (xdg && sig) {
            return xdg + "/hypr/" + sig + "/.socket2.sock";
        }
        return "/tmp/hypr/" + (sig || "") + "/.socket2.sock";
    }

    // Signals broadcast to other services
    signal workspaceChanged(int id, string name)
    signal activeWindowChanged(string clientClass, string title)
    signal workspaceCreated(int id, string name)
    signal workspaceDestroyed(int id, string name)
    signal clientsChanged()

    property Socket socket: Socket {
        id: socket
        path: root.socketPath
        connected: true

        parser: SplitParser {
            onRead: data => {
                if (data) {
                    root.parseEvent(data.trim());
                }
            }
        }
    }

    function parseEvent(eventStr) {
        let parts = eventStr.split(">>");
        if (parts.length < 2) return;

        let eventName = parts[0];
        let eventData = parts[1];

        if (eventName === "workspacev2") {
            let subparts = eventData.split(",");
            let id = parseInt(subparts[0]) || 0;
            let name = subparts.slice(1).join(",");
            workspaceChanged(id, name);
        } else if (eventName === "workspace") {
            let id = parseInt(eventData) || 0;
            workspaceChanged(id, eventData);
        } else if (eventName === "activewindow") {
            let subparts = eventData.split(",");
            if (subparts.length >= 2) {
                let clientClass = subparts[0];
                let title = subparts.slice(1).join(",");
                activeWindowChanged(clientClass, title);
            } else {
                activeWindowChanged(eventData, "");
            }
        } else if (eventName === "createworkspacev2") {
            let subparts = eventData.split(",");
            let id = parseInt(subparts[0]) || 0;
            let name = subparts.slice(1).join(",");
            workspaceCreated(id, name);
        } else if (eventName === "createworkspace") {
            let id = parseInt(eventData) || 0;
            workspaceCreated(id, eventData);
        } else if (eventName === "destroyworkspacev2") {
            let subparts = eventData.split(",");
            let id = parseInt(subparts[0]) || 0;
            let name = subparts.slice(1).join(",");
            workspaceDestroyed(id, name);
        } else if (eventName === "destroyworkspace") {
            let id = parseInt(eventData) || 0;
            workspaceDestroyed(id, eventData);
        } else if (eventName === "openwindow" || eventName === "closewindow" || eventName === "movewindow" || eventName === "movewindowv2") {
            clientsChanged();
        }
    }

    Connections {
        target: socket
        function onConnectedChanged() {
            if (!socket.connected) {
                reconnectTimer.restart();
            }
        }
    }

    Timer {
        id: reconnectTimer
        interval: 1000
        running: false
        onTriggered: {
            console.log("Hyprland socket disconnected. Attempting reconnect...");
            socket.connected = false;
            socket.connected = true;
        }
    }
}
