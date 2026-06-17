import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "../../services"
import "../../config"
import "../../components"

PanelWindow {
    id: launcherWindow

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // Layer shell settings
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-launcher"
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0

    color: "transparent"
    visible: OverlayService.activeOverlay === "launcher"

    onVisibleChanged: {
        if (visible) {
            searchText = "";
            searchInputText.text = "";
            searchInputText.forceInputFocus();
        }
    }

    ClickOutsideArea {
        anchors.fill: parent
        onClicked: OverlayService.closeOverlay("launcher")
    }

    // Centered glassmorphic launcher card
    OverlayCard {
        id: launcherCard
        width: ThemeService.launcherWidth
        height: ThemeService.launcherHeight
        anchors.centerIn: parent

        // Inner layout
        Column {
            anchors.fill: parent
            anchors.margins: ThemeService.spacingLarge
            spacing: ThemeService.spacingLarge

            // --- SEARCH BOX ---
            SearchField {
                id: searchInputText
                width: parent.width
                height: ThemeService.launcherSearchHeight
                radius: ThemeService.radiusSmall
                fieldColor: ThemeService.surfaceBright
                focusedBorderColor: ThemeService.primary
                idleBorderColor: ThemeService.primary
                icon: " "
                iconFont: ThemeService.iconFont
                iconTracksFocus: false
                horizontalPadding: ThemeService.radiusMedium
                fieldSpacing: ThemeService.spacingMedium
                placeholder: "Search applications..."

                onTextChanged: {
                    launcherWindow.searchText = text;
                    launcherWindow.selectedIndex = 0;
                }

                onKeyPressed: event => {
                    let resultsCount = resultsListView.count;
                    if (event.key === Qt.Key_Down || (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier))) {
                        launcherWindow.selectedIndex = NavigationService.nextIndex(launcherWindow.selectedIndex, resultsCount);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Up || (event.key === Qt.Key_Backtab) || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                        launcherWindow.selectedIndex = NavigationService.previousIndex(launcherWindow.selectedIndex, resultsCount);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                        if (resultsCount > 0 && launcherWindow.selectedIndex >= 0 && launcherWindow.selectedIndex < resultsCount) {
                            LauncherService.launch(launcherWindow.results[launcherWindow.selectedIndex]);
                            OverlayService.closeOverlay("launcher");
                        }
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Escape) {
                        OverlayService.closeOverlay("launcher");
                        event.accepted = true;
                    }
                }
            }

            // --- SEPARATOR ---
            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(ThemeService.border.r, ThemeService.border.g, ThemeService.border.b, 0.1)
            }

            // --- RESULTS LIST ---
            ListView {
                id: resultsListView
                width: parent.width
                height: ThemeService.launcherListHeight // Exactly 6 items
                model: launcherWindow.results
                clip: true
                spacing: ThemeService.spacingSmall
                
                currentIndex: launcherWindow.selectedIndex
                highlightFollowsCurrentItem: true
                
                delegate: Rectangle {
                    id: itemRect
                    required property int index
                    required property var modelData // { name, icon, comment, entry }

                    width: resultsListView.width
                    height: ThemeService.launcherItemHeight
                    radius: ThemeService.radiusSmall
                    color: (index === launcherWindow.selectedIndex) ? Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.15) : (itemMouseArea.containsMouse ? Qt.rgba(ThemeService.surfaceBright.r, ThemeService.surfaceBright.g, ThemeService.surfaceBright.b, 0.4) : "transparent")
                    border.color: (index === launcherWindow.selectedIndex) ? ThemeService.primary : "transparent"
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: ThemeService.radiusMedium
                        anchors.rightMargin: ThemeService.radiusMedium
                        spacing: ThemeService.radiusMedium

                        IconImage {
                            width: 24
                            height: 24
                            anchors.verticalCenter: parent.verticalCenter
                            source: Quickshell.iconPath(modelData.icon) || ""
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 44

                            Text {
                                text: modelData.name
                                color: (index === launcherWindow.selectedIndex) ? ThemeService.primary : ThemeService.foreground
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }
                            Text {
                                text: modelData.comment
                                color: ThemeService.textDim
                                font.pixelSize: 10
                                elide: Text.ElideRight
                                visible: text !== ""
                            }
                        }
                    }

                    MouseArea {
                        id: itemMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: launcherWindow.selectedIndex = index
                        onClicked: {
                            LauncherService.launch(modelData);
                            OverlayService.closeOverlay("launcher");
                        }
                    }
                }
                
                onCurrentIndexChanged: {
                    positionViewAtIndex(currentIndex, ListView.Contain);
                }
            }

            // Optional notice when no results
            Text {
                text: "No applications found"
                color: ThemeService.textDim
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
                visible: launcherWindow.results.length === 0
                padding: 20
            }
        }
    }

    // Properties tracking search state
    property string searchText: ""
    property var results: LauncherService.search(searchText)
    property int selectedIndex: 0
}
