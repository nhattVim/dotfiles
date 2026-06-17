import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../services"
import "../../config"

PanelWindow {
    id: reservationWindow

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Math.max(1, ThemeService.barTotalHeight)
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    exclusiveZone: ThemeService.barTotalHeight
    exclusionMode: ExclusionMode.Normal

    Item {
        id: noInputRegion
        width: 0
        height: 0
        visible: false
    }

    mask: Region {
        item: noInputRegion
    }
}
