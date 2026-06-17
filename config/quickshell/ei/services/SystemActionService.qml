pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    function commandForPowerAction(action) {
        if (action === "shutdown") return ["systemctl", "poweroff"];
        if (action === "reboot") return ["reboot"];
        if (action === "logout") return ["hyprshutdown"];
        return [];
    }

    function runPowerAction(action) {
        const command = commandForPowerAction(action);
        if (command.length === 0) return false;

        Quickshell.execDetached(command);
        return true;
    }
}
