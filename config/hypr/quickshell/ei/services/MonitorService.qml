pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property string focusedMonitorName: Hyprland.focusedMonitor?.name ?? fallbackScreenName
    readonly property var focusedScreen: screenForName(focusedMonitorName) || firstScreen()
    readonly property string focusedScreenName: focusedScreen?.name ?? ""
    readonly property string fallbackScreenName: firstScreen()?.name ?? ""

    function firstScreen() {
        const screens = Quickshell.screens || [];
        return screens.length > 0 ? screens[0] : null;
    }

    function screenForName(name) {
        if (!name) return null;

        const screens = Quickshell.screens || [];
        for (let i = 0; i < screens.length; i++) {
            if (screens[i].name === name) return screens[i];
        }

        return null;
    }

    function isFocusedScreen(screen) {
        if (!screen) return false;

        const monitor = Hyprland.monitorFor(screen);
        if (monitor) return monitor.focused;

        return focusedScreenName !== "" && screen.name === focusedScreenName;
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            const name = event?.name ?? "";
            if (name === "focusedmon" || name.indexOf("mon") !== -1 || name.indexOf("workspace") !== -1) {
                Hyprland.refreshMonitors();
            }
        }
    }
}
