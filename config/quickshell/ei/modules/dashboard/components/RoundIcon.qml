import QtQuick
import "../../../services"
import "../../../config"

Item {
    id: root
    property string icon: ""

    Rectangle {
        anchors.fill: parent
        radius: Math.min(width, height) / 2
        color: ThemeService.surfaceBright
        opacity: 0.72
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        font.family: ThemeService.iconFont
        font.pixelSize: 16
        color: ThemeService.primary
    }
}
