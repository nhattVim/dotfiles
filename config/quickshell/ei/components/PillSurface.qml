import QtQuick
import "../config"

StyledRect {
    id: root

    default property alias content: contentLayer.data

    property real idleOpacity: ThemeService.bgOpacity
    property real hoverOpacity: 1.0
    property bool hoverEnabled: true
    property int cursorShape: Qt.PointingHandCursor

    signal clicked(var event)
    signal pressed(var event)

    radius: height / 2
    rectColor: ThemeService.background
    rectOpacity: pillMouse.containsMouse ? hoverOpacity : idleOpacity
    borderOpacityValue: 0.0

    Item {
        id: contentLayer
        anchors.fill: parent
    }

    MouseArea {
        id: pillMouse
        anchors.fill: parent
        hoverEnabled: root.hoverEnabled
        cursorShape: root.cursorShape
        onClicked: event => root.clicked(event)
        onPressed: event => root.pressed(event)
    }
}
