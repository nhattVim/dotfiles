import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../../services"
import "../../../config"

PanelFrame {
    id: root

    Item {
        anchors.fill: parent
        anchors.margins: 8

        Item {
            id: header
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 34

            Rectangle {
                anchors.left: parent.left
                anchors.right: dndButton.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.rightMargin: 8
                radius: 17
                color: ThemeService.background

                Text {
                    anchors.centerIn: parent
                    text: "Notifications"
                    font.family: ThemeService.fontName
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    color: ThemeService.textBright
                }
            }

            RoundIcon {
                id: dndButton
                anchors.right: clearButton.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.rightMargin: 8
                width: 34
                icon: NotificationService.silent ? "󰂛" : "󰂚"

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NotificationService.silent = !NotificationService.silent
                }
            }

            RoundIcon {
                id: clearButton
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 34
                icon: "󰎟"

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NotificationService.clearAll()
                }
            }
        }

        ListView {
            id: notificationList
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            anchors.topMargin: 8
            anchors.bottom: parent.bottom
            spacing: 6
            clip: true
            visible: NotificationService.count > 0
            model: NotificationService.list

            delegate: Rectangle {
                required property var modelData
                property bool iconLoadFailed: false
                readonly property bool hasNotificationImage: (modelData.image || "") !== ""
                readonly property bool hasAppIcon: (modelData.appIcon || "") !== ""
                readonly property string iconSource: {
                    if (hasNotificationImage) return modelData.image;
                    if (hasAppIcon) return "image://icon/" + modelData.appIcon;
                    return "";
                }

                width: notificationList.width
                height: Math.max(68, content.implicitHeight + 18)
                radius: 14
                color: ThemeService.background
                border.width: 1
                border.color: ThemeService.surfaceBright
                clip: true

                RowLayout {
                    id: content
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 10
                    anchors.rightMargin: 8
                    spacing: 9

                    Rectangle {
                        Layout.preferredWidth: 38
                        Layout.preferredHeight: 38
                        radius: 12
                        color: ThemeService.surfaceBright
                        clip: true

                        Image {
                            anchors.fill: parent
                            anchors.margins: 7
                            source: iconLoadFailed ? "" : iconSource
                            fillMode: Image.PreserveAspectFit
                            visible: source !== ""
                            asynchronous: true
                            mipmap: true

                            onStatusChanged: {
                                if (status === Image.Error) {
                                    if (modelData.image && modelData.appIcon && source !== "image://icon/" + modelData.appIcon) {
                                        source = "image://icon/" + modelData.appIcon;
                                    } else {
                                        iconLoadFailed = true;
                                        source = "";
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: iconSource === "" || iconLoadFailed
                            text: "󰂚"
                            font.family: ThemeService.iconFont
                            font.pixelSize: 17
                            color: ThemeService.primary
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                Layout.fillWidth: true
                                text: modelData.summary || modelData.appName
                                font.family: ThemeService.fontName
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                color: ThemeService.textBright
                                elide: Text.ElideRight
                            }

                            Text {
                                text: NotificationService.formatTime(modelData.time)
                                font.family: ThemeService.fontName
                                font.pixelSize: 10
                                color: ThemeService.textDim
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.body || modelData.appName
                            font.family: ThemeService.fontName
                            font.pixelSize: 11
                            color: ThemeService.foreground
                            maximumLineCount: 2
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                        }
                    }

                    TextButton {
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                        icon: "󰅖"
                        onClicked: NotificationService.discard(modelData.id)
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                active: true
            }
        }

        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            anchors.topMargin: 8
            anchors.bottom: parent.bottom
            visible: NotificationService.count === 0

            Text {
                anchors.centerIn: parent
                text: "no notifications"
                font.family: ThemeService.fontName
                font.pixelSize: 24
                font.weight: Font.Black
                color: ThemeService.textDim
                opacity: 0.72
            }
        }
    }
}
