import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import "../../services"
import "../../config"
import "../../components"
import "../bar/groups"

PanelWindow {
    id: barWindow

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    exclusionMode: ExclusionMode.Ignore

    // Robust keyboard focus logic
    readonly property bool focusedScreen: MonitorService.isFocusedScreen(screen)
    readonly property string effectiveIslandState: focusedScreen ? OverlayService.islandState : "windowTitle"
    readonly property bool islandOverlayOpen: focusedScreen && OverlayService.islandOpen

    WlrLayershell.keyboardFocus: islandOverlayOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.layer: WlrLayer.Top

    Item {
        id: fullScreenHitbox
        anchors.fill: parent
    }

    // DYNAMIC MASK
    mask: Region {
        item: islandOverlayOpen ? fullScreenHitbox : null
        regions: [
            Region { item: leftGroup },
            Region { item: dynamicIsland },
            Region { item: rightGroup }
        ]
    }

    ClickOutsideArea {
        id: clickOutsideDetector
        anchors.fill: parent
        visible: barWindow.islandOverlayOpen
        z: -1
        onClicked: OverlayService.closeIsland()
    }

    // --- VISIBLE UI LAYER ---
    Item {
        id: mainBarContent
        anchors.fill: parent

        LeftGroup {
            id: leftGroup
            anchors.left: parent.left
            anchors.leftMargin: ThemeService.barMargin
            anchors.top: parent.top
            anchors.topMargin: ThemeService.barTotalHeight - ThemeService.sideCapsuleHeight
            pillHeight: ThemeService.sideCapsuleHeight
        }

        CenterIsland {
            id: dynamicIsland
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 0
            baseHeight: ThemeService.barTotalHeight
            
            islandState: barWindow.effectiveIslandState
            activePlayer: barWindow.activePlayer
            triggerPower: barWindow.triggerPower
            triggerProfile: barWindow.triggerProfile
            
            onRequestIslandState: state => OverlayService.setIslandState(state)
        }

        RightGroup {
            id: rightGroup
            anchors.right: parent.right
            anchors.rightMargin: ThemeService.barMargin
            anchors.top: parent.top
            anchors.topMargin: ThemeService.barTotalHeight - ThemeService.sideCapsuleHeight
            pillHeight: ThemeService.sideCapsuleHeight
            
            islandState: barWindow.effectiveIslandState
            triggerProfile: barWindow.triggerProfile
            onRequestIslandState: state => OverlayService.setIslandState(state)
        }
    }

    function chooseActivePlayer() {
        const players = Mpris.players.values || [];
        if (players.length === 0) return null;

        const playingPlayer = players.find(player => player.playbackState === MprisPlaybackState.Playing);
        if (playingPlayer) return playingPlayer;

        const nonFirefoxPlayer = players.find(player => {
            const dbusName = (player.dbusName || "").toLowerCase();
            return !dbusName.includes("firefox");
        });
        if (nonFirefoxPlayer) return nonFirefoxPlayer;

        return players[0];
    }

    readonly property var activePlayer: chooseActivePlayer()

    function triggerPower(action) {
        if (action === "close") { OverlayService.closeIsland(); return; }
        SystemActionService.runPowerAction(action);
        OverlayService.closeIsland();
    }

    function triggerProfile(profile) {
        if (profile === "close") { OverlayService.closeIsland(); return; }
        PowerProfileService.setProfile(profile);
        OverlayService.closeIsland();
    }
}
