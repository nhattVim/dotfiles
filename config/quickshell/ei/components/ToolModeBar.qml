import QtQuick
import "../config"

Rectangle {
    id: root

    property var modes: [
        { mode: "region", icon: "󰩭" },
        { mode: "window", icon: "󰖲" },
        { mode: "screen", icon: "󰍹" }
    ]
    property string currentMode: "region"
    property int buttonSize: 40
    property int iconPixelSize: 18
    property int rowSpacing: 8
    property real surfaceOpacity: 0.94
    property Component prefixContent: null

    signal modeSelected(string mode)

    height: 56
    radius: height / 2
    color: Qt.rgba(ThemeService.surface.r, ThemeService.surface.g, ThemeService.surface.b, surfaceOpacity)
    border.color: Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.14)
    border.width: 1
    z: 10

    Row {
        anchors.centerIn: parent
        spacing: root.rowSpacing

        Loader {
            active: root.prefixContent !== null
            visible: active
            sourceComponent: root.prefixContent
        }

        Repeater {
            model: root.modes

            delegate: ToolModeButton {
                required property var modelData

                width: root.buttonSize
                height: root.buttonSize
                icon: modelData.icon
                iconPixelSize: root.iconPixelSize
                active: root.currentMode === modelData.mode
                onClicked: root.modeSelected(modelData.mode)
            }
        }
    }
}
