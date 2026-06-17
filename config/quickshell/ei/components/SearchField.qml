import QtQuick
import "../config"

Rectangle {
    id: root

    property alias text: input.text
    property alias inputItem: input
    property string icon: "󰍉"
    property string placeholder: ""
    property string iconFont: ThemeService.iconFont
    property int iconPixelSize: 16
    property int inputPixelSize: 13
    property int horizontalPadding: 14
    property int fieldSpacing: 10
    property color fieldColor: ThemeService.surface
    property color focusedBorderColor: Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.75)
    property color idleBorderColor: Qt.rgba(ThemeService.border.r, ThemeService.border.g, ThemeService.border.b, 0.16)
    property color focusedIconColor: ThemeService.primary
    property color idleIconColor: ThemeService.textDim
    property bool iconTracksFocus: true

    signal keyPressed(var event)

    function forceInputFocus() {
        input.forceActiveFocus();
    }

    radius: ThemeService.radiusSmall
    color: fieldColor
    border.width: 1
    border.color: input.activeFocus ? focusedBorderColor : idleBorderColor

    Row {
        anchors.fill: parent
        anchors.leftMargin: root.horizontalPadding
        anchors.rightMargin: root.horizontalPadding
        spacing: root.fieldSpacing

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            color: root.iconTracksFocus
                ? (input.activeFocus ? root.focusedIconColor : root.idleIconColor)
                : root.focusedIconColor
            font.family: root.iconFont
            font.pixelSize: root.iconPixelSize
        }

        TextInput {
            id: input
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - x
            color: ThemeService.foreground
            selectionColor: Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.35)
            selectedTextColor: ThemeService.textBright
            font.family: ThemeService.fontName
            font.pixelSize: root.inputPixelSize
            selectByMouse: true
            clip: true

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                text: root.placeholder
                color: ThemeService.textDim
                font.family: ThemeService.fontName
                font.pixelSize: root.inputPixelSize
                visible: parent.text.length === 0
                elide: Text.ElideRight
            }

            Keys.onPressed: event => root.keyPressed(event)
        }
    }
}
