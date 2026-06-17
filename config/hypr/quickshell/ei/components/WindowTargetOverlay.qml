import QtQuick
import "../config"

Item {
    id: root

    property var windows: []
    property real screenX: 0
    property real screenY: 0
    property bool showTitle: true
    property real inactiveBorderOpacity: 0.5

    signal selected(var windowData)

    Repeater {
        model: root.windows

        delegate: Rectangle {
            required property int index
            required property var modelData

            readonly property bool onThisScreen: modelData.x + modelData.width > root.screenX
                && modelData.x < root.screenX + root.width
                && modelData.y + modelData.height > root.screenY
                && modelData.y < root.screenY + root.height

            x: modelData.x - root.screenX
            y: modelData.y - root.screenY
            width: modelData.width
            height: modelData.height
            z: 5 + index
            visible: onThisScreen
            color: windowMouse.containsMouse ? Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.22) : "transparent"
            border.color: windowMouse.containsMouse ? ThemeService.primary : Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, root.inactiveBorderOpacity)
            border.width: 2
            radius: 8

            Text {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.margins: 8
                width: parent.width - 16
                text: modelData.app || modelData.title || "Window"
                font.family: ThemeService.fontName
                font.pixelSize: 12
                font.weight: Font.Bold
                color: ThemeService.textBright
                elide: Text.ElideRight
                visible: root.showTitle && parent.width > 90 && parent.height > 48
            }

            MouseArea {
                id: windowMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.selected(modelData)
            }
        }
    }
}
