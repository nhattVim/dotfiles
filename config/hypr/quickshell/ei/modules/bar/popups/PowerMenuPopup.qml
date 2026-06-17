import QtQuick
import "../../../services"
import "../../../config"
import "../../../components"

ActionTileMenu {
    id: root

    property var triggerPower: null

    actions: [
        { icon: "󰐥", label: "Shutdown", color: ThemeService.danger, action: "shutdown" },
        { icon: "󰑓", label: "Reboot", color: ThemeService.warning, action: "reboot" },
        { icon: "󰍃", label: "Logout", color: ThemeService.success, action: "logout" }
    ]
    tileWidth: 80
    tileHeight: 80
    tileLabelPixelSize: 9
    onActionTriggered: action => { if (triggerPower) triggerPower(action); }
}
