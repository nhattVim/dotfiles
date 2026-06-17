import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../services"
import "../../config"
import "../../components"

PanelWindow {
    id: root

    required property ShellScreen targetScreen
    screen: targetScreen

    visible: NotificationService.popupList.length > 0
    color: "transparent"
    implicitWidth: 360
    exclusiveZone: 0
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "ei:notificationPopup"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
        top: true
        right: true
        bottom: true
    }

    mask: Region {
        item: popupList.contentItem
    }

    ListView {
        id: popupList

        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
            topMargin: 12
            rightMargin: 12
        }

        width: 336
        spacing: 8
        clip: false
        interactive: false
        model: NotificationService.popupList

        displaced: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: ThemeService.animDuration
                easing.type: Easing.OutCubic
            }
        }

        delegate: StyledRect {
            id: card

            required property var modelData
            property bool iconLoadFailed: false
            readonly property bool hasNotificationImage: (modelData.image || "") !== ""
            readonly property bool hasAppIcon: (modelData.appIcon || "") !== ""
            readonly property string iconSource: {
                if (hasNotificationImage) return modelData.image;
                if (hasAppIcon) return "image://icon/" + modelData.appIcon;
                return "";
            }

            width: popupList.width
            height: Math.max(78, content.implicitHeight + 22)
            radius: ThemeService.radiusMedium
            rectColor: ThemeService.background
            rectOpacity: ThemeService.bgOpacityHigh
            borderOpacityValue: ThemeService.borderOpacity
            clip: true

            Timer {
                interval: 5200
                running: true
                repeat: false
                onTriggered: NotificationService.timeoutPopup(card.modelData.id)
            }

            RowLayout {
                id: content

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 12
                anchors.rightMargin: 10
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 42
                    Layout.alignment: Qt.AlignTop
                    radius: 12
                    color: ThemeService.surfaceBright
                    clip: true

                    Image {
                        anchors.fill: parent
                        anchors.margins: 7
                        source: card.iconLoadFailed ? "" : card.iconSource
                        fillMode: Image.PreserveAspectFit
                        visible: source !== ""
                        asynchronous: true
                        mipmap: true

                        onStatusChanged: {
                            if (status === Image.Error) {
                                if (card.modelData.image && card.modelData.appIcon && source !== "image://icon/" + card.modelData.appIcon) {
                                    source = "image://icon/" + card.modelData.appIcon;
                                } else {
                                    card.iconLoadFailed = true;
                                    source = "";
                                }
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: card.iconSource === "" || card.iconLoadFailed
                        text: "󰂚"
                        font.family: ThemeService.iconFont
                        font.pixelSize: 18
                        color: ThemeService.primary
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            Layout.fillWidth: true
                            text: card.modelData.summary || card.modelData.appName
                            color: ThemeService.textBright
                            font.family: ThemeService.fontName
                            font.pixelSize: 13
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        Text {
                            text: NotificationService.formatTime(card.modelData.time)
                            color: ThemeService.textDim
                            font.family: ThemeService.fontName
                            font.pixelSize: 10
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: card.modelData.body || card.modelData.appName
                        color: ThemeService.foreground
                        font.family: ThemeService.fontName
                        font.pixelSize: 11
                        wrapMode: Text.WordWrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                    }
                }

                Item {
                    Layout.preferredWidth: 26
                    Layout.preferredHeight: 26
                    Layout.alignment: Qt.AlignTop

                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        font.family: ThemeService.iconFont
                        font.pixelSize: 14
                        color: dismissMouse.containsMouse ? ThemeService.danger : ThemeService.textDim
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    MouseArea {
                        id: dismissMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NotificationService.discard(card.modelData.id)
                    }
                }
            }
        }
    }
}
