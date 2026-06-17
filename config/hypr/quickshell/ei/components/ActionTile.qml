import QtQuick
import "../config"

StyledRect {
    id: root

    property string icon: ""
    property string label: ""
    property color iconColor: ThemeService.foreground
    property color labelColor: ThemeService.textBright
    property color activeLabelColor: ThemeService.textBright
    property int iconPixelSize: 24
    property int labelPixelSize: 10
    property int labelWeight: Font.Bold
    property real labelHorizontalPadding: 12

    property bool active: false
    property bool selected: false
    readonly property bool hovered: tileMouse.containsMouse

    property color idleColor: ThemeService.surfaceBright
    property color activeColor: ThemeService.primary
    property color idleBorderColor: ThemeService.border
    property color activeBorderColor: ThemeService.primary
    property real idleOpacity: 0.2
    property real hoverOpacity: 0.6
    property real selectedOpacity: hoverOpacity
    property real activeOpacity: 0.22
    property real idleBorderOpacity: 0.0
    property real hoverBorderOpacity: 0.2
    property real selectedBorderOpacity: hoverBorderOpacity
    property real activeBorderOpacity: 0.55

    signal clicked()
    signal entered()

    rectColor: active ? activeColor : idleColor
    rectOpacity: active ? activeOpacity : (selected ? selectedOpacity : (hovered ? hoverOpacity : idleOpacity))
    borderColor: active ? activeBorderColor : idleBorderColor
    borderOpacityValue: active ? activeBorderOpacity : (selected ? selectedBorderOpacity : (hovered ? hoverBorderOpacity : idleBorderOpacity))

    Column {
        anchors.centerIn: parent
        spacing: ThemeService.spacingSmall

        Text {
            text: root.icon
            font.family: ThemeService.iconFont
            font.pixelSize: root.iconPixelSize
            color: root.iconColor
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            width: Math.max(0, root.width - root.labelHorizontalPadding)
            text: root.label
            font.family: ThemeService.fontName
            font.pixelSize: root.labelPixelSize
            font.weight: root.labelWeight
            color: root.active ? root.activeLabelColor : root.labelColor
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: tileMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
        onEntered: root.entered()
    }
}
