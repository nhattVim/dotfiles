import QtQuick
import "../../../services"
import "../../../config"

Item {
    id: root

    signal clicked()
    property string icon: ""
    property bool filled: false
    property bool enabledState: true

    opacity: enabledState ? 1.0 : 0.42

    Rectangle {
        anchors.fill: parent
        radius: Math.min(width, height) / 2
        color: root.filled ? ThemeService.primary : "transparent"
        opacity: root.filled ? (buttonArea.containsMouse ? 1.0 : 0.9) : 0.0
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        font.family: ThemeService.iconFont
        font.pixelSize: root.filled ? 18 : 16
        color: root.filled ? ThemeService.background : ThemeService.foreground
    }

    MouseArea {
        id: buttonArea
        anchors.fill: parent
        enabled: root.enabledState
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
