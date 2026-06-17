import QtQuick
import "../../../services"
import "../../../config"

Item {
    id: root

    signal clicked()
    property string icon: ""
    property bool active: false

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: root.active ? ThemeService.primary : ThemeService.surfaceBright
        opacity: pillArea.containsMouse ? 1.0 : 0.96
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        font.family: ThemeService.iconFont
        font.pixelSize: 17
        color: root.active ? ThemeService.background : ThemeService.foreground
    }

    MouseArea {
        id: pillArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
