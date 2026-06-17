import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../services"
import "../../../config"
import "../../../components"

StyledRect {
    id: root

    property int pillHeight: ThemeService.sideCapsuleHeight
    property int closePopupsToken: 0

    signal popupOpened()

    height: pillHeight
    width: trayRow.implicitWidth + ThemeService.islandEarSize
    radius: height / 2
    visible: trayRow.count > 0
    rectColor: ThemeService.background
    rectOpacity: ThemeService.bgOpacity
    borderOpacityValue: 0.0

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: ThemeService.spacingSmall
        property int count: trayRepeater.count

        Repeater {
            id: trayRepeater
            model: SystemTray.items

            Item {
                id: trayDelegate
                required property var modelData
                width: ThemeService.iconSizeTray
                height: width

                IconImage {
                    anchors.fill: parent
                    source: {
                        const icon = trayDelegate.modelData.icon ? trayDelegate.modelData.icon.toString() : "";
                        if (icon.length === 0) return Quickshell.iconPath("image-missing");
                        if (icon.includes("/") || icon.includes(".")) return trayDelegate.modelData.icon;
                        return Quickshell.iconPath(icon, "image-missing");
                    }
                    smooth: true
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: event => {
                        if (event.button === Qt.LeftButton) {
                            trayDelegate.modelData.activate();
                        } else if (event.button === Qt.RightButton && trayDelegate.modelData.hasMenu) {
                            trayPopup.toggle();
                        }
                        event.accepted = true;
                    }
                }

                PopupSurface {
                    id: trayPopup

                    property int popupWidth: 240
                    property int popupMaxHeight: 420
                    property int popupPadding: 8

                    anchor.item: trayDelegate
                    anchor.rect.x: trayDelegate.width - implicitWidth
                    anchor.rect.y: trayDelegate.height + ThemeService.spacingMedium
                    anchor.rect.width: 0
                    anchor.rect.height: 0

                    implicitWidth: popupWidth
                    implicitHeight: Math.min(menuColumn.implicitHeight + popupPadding * 2, popupMaxHeight)

                    onOpening: {
                        OverlayService.closeIsland(false);
                        root.popupOpened();
                    }

                    QsMenuOpener {
                        id: menuOpener
                        menu: trayDelegate.modelData.menu
                    }

                    Flickable {
                        anchors.fill: parent
                        contentWidth: width
                        contentHeight: menuColumn.implicitHeight
                        clip: true

                        Column {
                            id: menuColumn
                            width: parent.width
                            spacing: 2

                            Repeater {
                                model: menuOpener.children ? menuOpener.children.values : []

                                Column {
                                    required property var modelData
                                    width: menuColumn.width
                                    spacing: 2
                                    property bool submenuExpanded: false

                                    TrayMenuItem {
                                        width: parent.width
                                        textStr: modelData.text || ""
                                        iconSource: modelData.icon || ""
                                        isSeparator: modelData.isSeparator || false
                                        hasSubmenu: modelData.hasChildren || false
                                        expanded: parent.submenuExpanded
                                        buttonType: modelData.buttonType || 0
                                        checkState: modelData.checkState || 0

                                        onClicked: {
                                            if (modelData.hasChildren) {
                                                parent.submenuExpanded = !parent.submenuExpanded;
                                            } else {
                                                if (modelData.triggered) modelData.triggered();
                                                else if (modelData.activate) modelData.activate();
                                                trayPopup.close();
                                            }
                                        }
                                    }

                                    Column {
                                        visible: parent.submenuExpanded && modelData.hasChildren
                                        width: parent.width
                                        spacing: 2

                                        QsMenuOpener {
                                            id: subMenuOpener
                                            menu: modelData.hasChildren ? modelData : null
                                        }

                                        Repeater {
                                            model: subMenuOpener.children ? subMenuOpener.children.values : []

                                            TrayMenuItem {
                                                required property var modelData
                                                width: parent.width
                                                depth: 1
                                                textStr: modelData.text || ""
                                                iconSource: modelData.icon || ""
                                                isSeparator: modelData.isSeparator || false
                                                buttonType: modelData.buttonType || 0
                                                checkState: modelData.checkState || 0

                                                onClicked: {
                                                    if (modelData.triggered) modelData.triggered();
                                                    else if (modelData.activate) modelData.activate();
                                                    trayPopup.close();
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Connections {
                    target: root
                    function onClosePopupsTokenChanged() {
                        trayPopup.close();
                    }
                }
            }
        }
    }
}
