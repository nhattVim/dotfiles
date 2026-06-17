import QtQuick
import "../config"

Rectangle {
    id: root

    property string icon: ""
    property bool active: false
    property int iconPixelSize: 18
    property color activeColor: ThemeService.primary
    property color inactiveIconColor: ThemeService.foreground
    property color activeIconColor: ThemeService.background

    signal clicked()

    width: 40
    height: 40
    radius: width / 2
    color: active ? Qt.rgba(activeColor.r, activeColor.g, activeColor.b, 0.75) : "transparent"

    Text {
        anchors.centerIn: parent
        text: root.icon
        font.family: ThemeService.iconFont
        font.pixelSize: root.iconPixelSize
        color: root.active ? root.activeIconColor : root.inactiveIconColor
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
