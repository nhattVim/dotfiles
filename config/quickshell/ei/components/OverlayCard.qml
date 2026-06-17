import QtQuick
import "../config"

StyledRect {
    id: root

    default property alias content: contentLayer.data

    radius: ThemeService.radius
    rectColor: ThemeService.background
    rectOpacity: ThemeService.bgOpacity
    borderOpacityValue: ThemeService.borderOpacity
    clip: true

    MouseArea {
        anchors.fill: parent
        onClicked: {}
    }

    Item {
        id: contentLayer
        anchors.fill: parent
    }
}
