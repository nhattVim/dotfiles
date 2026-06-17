import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../../services"
import "../../../config"
import "../../../components"
import "../popups"
import "../../dashboard"

Item {
    id: root
    width: centerCapsule.width + (ThemeService.islandEarSize * 2)
    height: centerCapsule.height

    property int baseHeight: ThemeService.barTotalHeight
    property string islandState: "windowTitle"
    property var activePlayer: null
    property var triggerPower: null
    property var triggerProfile: null
    signal requestIslandState(string state)

    // Left "Ear" (Concave Corner)
    RoundCorner {
        anchors.right: centerCapsule.left
        anchors.top: parent.top
        size: ThemeService.islandEarSize
        corner: RoundCorner.CornerEnum.TopRight
        color: ThemeService.background
    }
    
    // Right "Ear" (Concave Corner)
    RoundCorner {
        anchors.left: centerCapsule.right
        anchors.top: parent.top
        size: ThemeService.islandEarSize
        corner: RoundCorner.CornerEnum.TopLeft
        color: ThemeService.background
    }

    StyledRect {
        id: centerCapsule
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        clip: true
        rectColor: ThemeService.background
        rectOpacity: ThemeService.bgOpacityHigh
        borderOpacityValue: 0.0
        
        property bool isHovered: false
        
        onIsHoveredChanged: {
            if (isHovered) {
                islandTimer.stop();
            } else {
                if (root.islandState !== "powerMenu" && root.islandState !== "media" && root.islandState !== "batteryMenu") islandTimer.restart();
            }
        }
        
        height: {
            if (root.islandState === "powerMenu" || root.islandState === "batteryMenu") return ThemeService.islandMenuHeight; 
            if (root.islandState === "media") return ThemeService.islandDashboardHeight;
            if (root.islandState !== "windowTitle") return ThemeService.islandCompactHeight; 
            return root.baseHeight;
        }
        
        width: {
            if (root.islandState === "powerMenu" || root.islandState === "batteryMenu") return ThemeService.islandMenuWidth; 
            if (root.islandState === "media") return ThemeService.islandDashboardWidth;
            return ThemeService.islandWidth;
        }
        
        topLeftRadiusVal: 0
        topRightRadiusVal: 0
        bottomLeftRadiusVal: (root.islandState === "media" || root.islandState === "powerMenu" || root.islandState === "batteryMenu") ? ThemeService.radiusLarge : ThemeService.radius
        bottomRightRadiusVal: (root.islandState === "media" || root.islandState === "powerMenu" || root.islandState === "batteryMenu") ? ThemeService.radiusLarge : ThemeService.radius
        
        Behavior on width { NumberAnimation { duration: ThemeService.animDuration + 100; easing.type: Easing.OutExpo } }
        Behavior on height { NumberAnimation { duration: ThemeService.animDuration + 100; easing.type: Easing.OutExpo } }
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: centerCapsule.isHovered = true
            onExited: centerCapsule.isHovered = false
        }

        Item {
            anchors.fill: parent
            
            // 1. COLLAPSED VIEW
            Item {
                anchors.fill: parent
                visible: root.islandState !== "media" && root.islandState !== "powerMenu" && root.islandState !== "batteryMenu"
                
                Row {
                    anchors.centerIn: parent
                    width: parent.width - 16
                    spacing: ThemeService.spacingSmall

                    Item {
                        id: dashToggleItem
                        width: 32; height: 32
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            anchors.centerIn: parent
                            text: ""
                            font.pixelSize: 16
                            color: dashToggleMouse.containsMouse ? ThemeService.primary : ThemeService.foreground
                            opacity: dashToggleMouse.containsMouse ? 1.0 : 0.8
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        MouseArea {
                            id: dashToggleMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: OverlayService.toggleDashboard()
                        }
                    }

                    Rectangle { width: 2; height: 18; radius: 1; color: ThemeService.foreground; opacity: 0.2; anchors.verticalCenter: parent.verticalCenter }

                    StyledRect {
                        id: titleFrame
                        width: parent.width - (dashToggleItem.width + notifIndicatorItem.width + (parent.spacing * 2) + 4 + 16)
                        height: parent.height - 4
                        radius: height / 2
                        anchors.verticalCenter: parent.verticalCenter
                        rectColor: ThemeService.surfaceBright
                        rectOpacity: 0.6 
                        borderOpacityValue: 0.15
                        Text {
                            anchors.centerIn: parent
                            text: root.islandState === "windowTitle" ? (WindowService.activeWindowTitle || "Desktop") : ""
                            color: ThemeService.textBright; font.family: ThemeService.fontName; font.pixelSize: 11; font.weight: Font.Bold
                            visible: root.islandState === "windowTitle"; elide: Text.ElideRight; width: parent.width - 24; horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    Rectangle { width: 2; height: 18; radius: 1; color: ThemeService.foreground; opacity: 0.2; anchors.verticalCenter: parent.verticalCenter }

                    Item {
                        id: notifIndicatorItem; width: 32; height: 32; anchors.verticalCenter: parent.verticalCenter
                        Text { anchors.centerIn: parent; text: "󰂚"; font.pixelSize: 16; color: ThemeService.foreground; opacity: 0.8 }
                    }
                }
            }
            
            PowerMenuPopup {
                id: powerMenu
                visible: root.islandState === "powerMenu"
                triggerPower: root.triggerPower
                onVisibleChanged: if (visible) powerMenu.forceActiveFocus()
            }

            BatteryProfilePopup {
                id: batteryMenu
                visible: root.islandState === "batteryMenu"
                triggerProfile: root.triggerProfile
                onVisibleChanged: if (visible) batteryMenu.forceActiveFocus()
            }
            
            Item {
                anchors.fill: parent
                visible: root.islandState === "media"
                Dashboard {
                    anchors.fill: parent
                    visible: parent.visible
                    activePlayer: root.activePlayer
                    currentPage: OverlayService.dashboardPage
                    onRequestClose: OverlayService.closeIsland()
                }
            }
        }
    }
    
    Timer {
        id: islandTimer
        interval: 3000
        running: false
        repeat: false
        onTriggered: if (root.islandState !== "media" && root.islandState !== "powerMenu" && root.islandState !== "batteryMenu") OverlayService.closeIsland()
    }

    function triggerIsland(state) {
        OverlayService.setIslandState(state);
        islandTimer.restart();
    }
}
