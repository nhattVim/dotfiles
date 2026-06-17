import QtQuick
import "../../../services"
import "../../../config"
import "../../../components"

ActionTileMenu {
    id: root

    property var triggerProfile: null

    title: "Performance Profiles"
    actions: [
        { icon: "󰌪", label: "Power Saver", color: ThemeService.secondary, action: "power-saver" },
        { icon: "󰗑", label: "Balanced", color: ThemeService.primary, action: "balanced" },
        { icon: "󰓅", label: "Performance", color: ThemeService.warning, action: "performance" }
    ]
    onActionTriggered: action => { if (triggerProfile) triggerProfile(action); }
}
