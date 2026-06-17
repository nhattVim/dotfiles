import QtQuick
import Quickshell
import "../config"

PopupWindow {
    id: root

    default property alias content: contentLayer.data

    property int popupPadding: 8
    property int surfaceRadius: ThemeService.radiusMedium
    property color surfaceColor: ThemeService.background
    property real surfaceOpacity: ThemeService.bgOpacityHigh
    property color surfaceBorderColor: ThemeService.border
    property real surfaceBorderOpacity: ThemeService.borderOpacity
    property real popupOpacity: 0
    property real popupScale: 0.94
    property int closeDelay: ThemeService.animDuration + 50
    property int surfaceTransformOrigin: Item.TopRight

    signal opening()
    signal closing()

    color: "transparent"
    grabFocus: true
    visible: false

    Rectangle {
        anchors.fill: parent
        radius: root.surfaceRadius
        color: Qt.rgba(root.surfaceColor.r, root.surfaceColor.g, root.surfaceColor.b, root.surfaceOpacity)
        border.width: 1
        border.color: Qt.rgba(root.surfaceBorderColor.r, root.surfaceBorderColor.g, root.surfaceBorderColor.b, root.surfaceBorderOpacity)
        opacity: root.popupOpacity
        scale: root.popupScale
        transformOrigin: root.surfaceTransformOrigin

        Behavior on opacity { NumberAnimation { duration: ThemeService.animDuration; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: ThemeService.animDuration; easing.type: Easing.OutCubic } }

        Item {
            id: contentLayer
            anchors.fill: parent
            anchors.margins: root.popupPadding
        }
    }

    Timer {
        id: closeTimer
        interval: root.closeDelay
        onTriggered: root.visible = false
    }

    function open() {
        if (visible && !closeTimer.running) return;
        closeTimer.stop();
        opening();
        if (!visible) {
            popupOpacity = 0;
            popupScale = 0.94;
            visible = true;
        }
        Qt.callLater(() => {
            popupOpacity = 1;
            popupScale = 1;
        });
    }

    function close() {
        if (!visible || closeTimer.running) return;
        closing();
        popupOpacity = 0;
        popupScale = 0.94;
        closeTimer.restart();
    }

    function toggle() {
        if (visible && !closeTimer.running) close();
        else open();
    }
}
