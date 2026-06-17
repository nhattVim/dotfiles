import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../services"
import "../../config"

PanelWindow {
    id: indicator

    required property var targetScreen
    screen: targetScreen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    visible: ScreenRecorderService.isRecording
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "ei-record-indicator"

    mask: Region {
        item: indicator.visible ? recMenu : emptyMask
    }

    Item {
        id: emptyMask
        width: 0
        height: 0
    }

    Rectangle {
        id: recMenu
        width: 172
        height: 42
        radius: 21
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        color: Qt.rgba(ThemeService.surface.r, ThemeService.surface.g, ThemeService.surface.b, 0.94)
        border.color: Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.14)
        border.width: 1

        Row {
            anchors.centerIn: parent
            spacing: 10

            Rectangle {
                width: 12
                height: 12
                radius: 6
                color: ThemeService.danger
                anchors.verticalCenter: parent.verticalCenter
                opacity: ScreenRecorderService.paused ? 0.45 : 1

                SequentialAnimation on opacity {
                    running: ScreenRecorderService.isRecording && !ScreenRecorderService.paused
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.45; duration: 700 }
                    NumberAnimation { to: 1.0; duration: 700 }
                }
            }

            Text {
                text: ScreenRecorderService.paused ? "PAUSED" : "REC"
                font.family: ThemeService.fontName
                font.pixelSize: 12
                font.weight: Font.Bold
                color: ThemeService.textBright
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                width: 1
                height: 20
                color: Qt.rgba(ThemeService.foreground.r, ThemeService.foreground.g, ThemeService.foreground.b, 0.2)
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: pauseMouse.containsMouse ? Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.22) : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: ScreenRecorderService.paused ? "" : ""
                    font.family: ThemeService.iconFont
                    font.pixelSize: 15
                    color: ThemeService.foreground
                }

                MouseArea {
                    id: pauseMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ScreenRecorderService.togglePause()
                }
            }

            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: stopMouse.containsMouse ? Qt.rgba(ThemeService.danger.r, ThemeService.danger.g, ThemeService.danger.b, 0.22) : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: ""
                    font.family: ThemeService.iconFont
                    font.pixelSize: 14
                    color: ThemeService.danger
                }

                MouseArea {
                    id: stopMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ScreenRecorderService.stop()
                }
            }
        }
    }
}
