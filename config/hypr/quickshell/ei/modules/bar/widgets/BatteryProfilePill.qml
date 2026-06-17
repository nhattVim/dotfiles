import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../../services"
import "../../../config"
import "../../../components"

PillSurface {
    id: root

    property int pillHeight: ThemeService.sideCapsuleHeight
    property int closePopupsToken: 0
    property var triggerProfile: null
    property var profileActions: [
        { icon: "󰌪", label: "Power Saver", color: ThemeService.secondary, action: "power-saver" },
        { icon: "󰗑", label: "Balanced", color: ThemeService.primary, action: "balanced" },
        { icon: "󰓅", label: "Performance", color: ThemeService.warning, action: "performance" }
    ]

    signal popupOpened()

    height: pillHeight
    width: batteryRow.implicitWidth + ThemeService.radiusLarge
    onClicked: batteryPopup.toggle()

    Row {
        id: batteryRow
        anchors.centerIn: parent
        spacing: ThemeService.spacingSmall

        Text {
            text: BatteryService.isCharging ? "󰂄" : ""
            font.family: ThemeService.iconFont
            font.pixelSize: 12
            color: BatteryService.isCharging ? ThemeService.success : ThemeService.secondary
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: BatteryService.available ? Math.round(BatteryService.percentage) + "%" : "AC"
            font.family: ThemeService.fontName
            font.pixelSize: 11
            font.weight: Font.DemiBold
            color: ThemeService.foreground
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    PopupSurface {
        id: batteryPopup

        property int popupWidth: 306
        property int popupPadding: 10

        anchor.item: root
        anchor.rect.x: root.width - implicitWidth
        anchor.rect.y: root.height + ThemeService.spacingMedium
        anchor.rect.width: 0
        anchor.rect.height: 0

        implicitWidth: popupWidth
        implicitHeight: profileRow.implicitHeight + popupPadding * 2

        onOpening: {
            OverlayService.closeIsland(false);
            root.popupOpened();
            PowerProfileService.refresh();
        }

        Row {
            id: profileRow
            anchors.centerIn: parent
            spacing: ThemeService.spacingSmall

            Repeater {
                model: root.profileActions

                ActionTile {
                    id: profileItem
                    required property var modelData

                    width: 90
                    height: 76
                    radius: ThemeService.radiusSmall
                    icon: modelData.icon
                    label: modelData.label
                    iconColor: modelData.color
                    labelColor: ThemeService.foreground
                    iconPixelSize: 23
                    labelPixelSize: 9
                    labelWeight: Font.DemiBold
                    hoverOpacity: 0.55
                    active: PowerProfileService.activeProfile === modelData.action
                    onClicked: {
                        if (root.triggerProfile) root.triggerProfile(modelData.action);
                        batteryPopup.close();
                    }
                }
            }
        }
    }

    onClosePopupsTokenChanged: batteryPopup.close()
}
