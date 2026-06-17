import QtQuick
import "../../../services"
import "../../../config"
import "../widgets"

Row {
    id: root

    spacing: ThemeService.spacingMedium

    property int pillHeight: ThemeService.sideCapsuleHeight
    property string islandState: ""
    property int closePopupsToken: 0
    property var triggerProfile: null

    signal requestIslandState(string state)

    function closePopups() {
        closePopupsToken++;
    }

    onIslandStateChanged: {
        if (islandState !== "windowTitle") closePopups();
    }

    Connections {
        target: OverlayService

        function onActiveOverlayChanged() {
            if (OverlayService.activeOverlay !== "") root.closePopups();
        }
    }

    WifiPill {
        pillHeight: root.pillHeight
        closePopupsToken: root.closePopupsToken
        onPopupOpened: root.closePopups()
    }

    SystemTrayPill {
        pillHeight: root.pillHeight
        closePopupsToken: root.closePopupsToken
        onPopupOpened: root.closePopups()
    }

    BatteryProfilePill {
        pillHeight: root.pillHeight
        closePopupsToken: root.closePopupsToken
        triggerProfile: root.triggerProfile
        onPopupOpened: root.closePopups()
    }

    ClockPill {
        pillHeight: root.pillHeight
    }

    PowerPill {
        pillHeight: root.pillHeight
        islandState: root.islandState
        onRequestIslandState: state => {
            root.closePopups();
            root.requestIslandState(state);
        }
    }
}
