pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool toggled: false

    function toggle() {
        if (applyProcess.running) return;
        toggled = !toggled;
        applyProcess.command = toggled ? [
            "hyprctl",
            "--batch",
            "keyword animations:enabled false; keyword decoration:shadow:enabled false; keyword decoration:blur:enabled false; keyword general:gaps_in 0; keyword general:gaps_out 0; keyword general:border_size 1; keyword decoration:rounding 0"
        ] : ["hyprctl", "reload"];
        applyProcess.running = true;
    }

    Process {
        id: applyProcess
        running: false
        onExited: code => {
            if (code !== 0) root.toggled = !root.toggled;
        }
    }
}
