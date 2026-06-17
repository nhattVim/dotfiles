import QtQuick
import "../../../config"

Item {
    id: root

    property string icon: ""
    property bool selected: false
    property color accent: ThemeService.primary
    property bool stableSize: false
    property int stableButtonSize: 40
    property int iconPixelSize: 18
    readonly property bool hovered: buttonMouse.containsMouse

    signal clicked()

    Rectangle {
        anchors.centerIn: parent
        width: root.stableSize ? root.stableButtonSize : (root.selected ? 48 : 42)
        height: root.stableSize ? root.stableButtonSize : (root.selected ? 48 : 42)
        radius: root.stableSize ? 16 : (root.selected ? 18 : 16)
        color: root.selected ? root.accent : ThemeService.surfaceBright
        opacity: root.selected ? 1.0 : 0.86
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        font.family: ThemeService.iconFont
        font.pixelSize: root.iconPixelSize
        color: root.selected ? ThemeService.background : root.accent
    }

    MouseArea {
        id: buttonMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
