import QtQuick
import "../../../services"
import "../../../config"

Rectangle {
    id: root
    default property alias content: contentLayer.data

    radius: 16
    color: ThemeService.surface
    border.width: 2
    border.color: Qt.rgba(ThemeService.border.r, ThemeService.border.g, ThemeService.border.b, ThemeService.borderOpacity)
    clip: true

    Item {
        id: contentLayer
        anchors.fill: parent
    }
}
