import QtQuick
import QtQuick.Layouts
import "../../../services"
import "../../../config"

PanelFrame {
    id: root
    radius: 16

    RowLayout {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 4

        TogglePill {
            Layout.fillHeight: true
            Layout.preferredWidth: 48
            icon: NetworkService.wifiIcon
            active: NetworkService.wifiEnabled
            onClicked: NetworkService.setWifiEnabled(!NetworkService.wifiEnabled)
        }

        TogglePill {
            Layout.fillHeight: true
            Layout.preferredWidth: 48
            icon: "󰂯"
            active: false
        }

        TogglePill {
            Layout.fillHeight: true
            Layout.preferredWidth: 48
            icon: "󰖔"
            active: NightLightService.active
            onClicked: NightLightService.toggle()
        }

        TogglePill {
            Layout.fillHeight: true
            Layout.preferredWidth: 48
            icon: "󰅶"
            active: CaffeineService.active
            onClicked: CaffeineService.toggle()
        }

        TogglePill {
            Layout.fillHeight: true
            Layout.preferredWidth: 48
            icon: "󰊴"
            active: GameModeService.toggled
            onClicked: GameModeService.toggle()
        }
    }
}
