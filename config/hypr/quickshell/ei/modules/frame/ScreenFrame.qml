import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../../services"
import "../../config"

PanelWindow {
    id: screenFrame

    required property ShellScreen targetScreen
    screen: targetScreen

    visible: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "ei:screenFrame"
    WlrLayershell.layer: WlrLayer.Overlay
    
    mask: Region {
        // Empty region makes the window click-through
    }

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    readonly property real thickness: ThemeService.frameThickness
    readonly property color frameColor: ThemeService.background

    // The Frame with rounded cutout
    Item {
        anchors.fill: parent
        
        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: frameMask
            maskInverted: true
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
        }

        Rectangle {
            anchors.fill: parent
            color: screenFrame.frameColor
        }
    }

    Item {
        id: frameMask
        anchors.fill: parent
        visible: false
        layer.enabled: true // Required for maskSource to work reliably

        Rectangle {
            anchors.fill: parent
            anchors.margins: screenFrame.thickness
            radius: ThemeService.screenRadius
            color: "white"
        }
    }
}
