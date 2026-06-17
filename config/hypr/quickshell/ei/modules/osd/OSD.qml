import QtQuick
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

    anchors {
        left: true
        right: true
        bottom: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "ei:osd"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.margins.bottom: 100
    exclusionMode: ExclusionMode.Ignore

    implicitHeight: 80
    color: "transparent"
    visible: osdVisible

    property bool startupCompleted: false
    property bool osdVisible: false
    property string osdIndicator: "volume"
    property real osdValue: 0
    property bool osdMuted: false

    function volumeIcon(value, muted) {
        if (muted) return "󰝟";
        if (value <= 0) return "󰕿";
        if (value < 0.33) return "󰖀";
        if (value < 0.66) return "󰕾";
        return "󰕾";
    }

    function micIcon(muted) {
        return muted ? "󰍭" : "󰍬";
    }

    function indicatorIcon() {
        if (root.osdIndicator === "brightness") return "󰃠";
        if (root.osdIndicator === "mic") return root.micIcon(root.osdMuted);
        return root.volumeIcon(root.osdValue, root.osdMuted);
    }

    function indicatorLabel() {
        if (root.osdIndicator === "brightness") return "Brightness";
        if (root.osdIndicator === "mic") return "Microphone";
        return "Volume";
    }

    function show(indicator, value, muted) {
        if (!startupCompleted) return;
        root.osdIndicator = indicator;
        root.osdValue = Math.max(0, Math.min(1, value));
        root.osdMuted = muted || false;
        root.osdVisible = true;
        hideTimer.restart();
    }

    Item {
        anchors.fill: parent

        StyledRect {
            id: osdRect
            width: 220
            height: 52
            radius: ThemeService.radiusMedium
            rectColor: ThemeService.background
            rectOpacity: ThemeService.bgOpacityHigh
            borderOpacityValue: ThemeService.borderOpacity
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            clip: true

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 18
                anchors.topMargin: 8
                anchors.bottomMargin: 8
                spacing: 14

                Text {
                    text: root.indicatorIcon()
                    font.family: ThemeService.iconFont
                    font.pixelSize: 22
                    color: root.osdMuted ? ThemeService.textDim : ThemeService.primary
                    Layout.alignment: Qt.AlignVCenter
                    rotation: root.osdIndicator === "brightness" ? root.osdValue * 180 : 0
                    scale: root.osdIndicator === "brightness" ? 0.85 + root.osdValue * 0.15 : 1

                    Behavior on rotation { NumberAnimation { duration: ThemeService.animDuration; easing.type: Easing.OutQuart } }
                    Behavior on scale { NumberAnimation { duration: ThemeService.animDuration; easing.type: Easing.OutQuart } }
                    Behavior on color { ColorAnimation { duration: ThemeService.animDuration } }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: root.indicatorLabel()
                            color: ThemeService.textBright
                            font.family: ThemeService.fontName
                            font.pixelSize: 13
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: Math.round(root.osdValue * 100).toString()
                            color: ThemeService.foreground
                            font.family: ThemeService.fontName
                            font.pixelSize: 13
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 4
                        radius: 2
                        color: Qt.rgba(ThemeService.foreground.r, ThemeService.foreground.g, ThemeService.foreground.b, 0.18)

                        Rectangle {
                            width: parent.width * root.osdValue
                            height: parent.height
                            radius: parent.radius
                            color: root.osdMuted ? ThemeService.textDim : ThemeService.primary

                            Behavior on width { NumberAnimation { duration: ThemeService.animDuration; easing.type: Easing.OutQuart } }
                            Behavior on color { ColorAnimation { duration: ThemeService.animDuration } }
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.osdVisible = false
        onClicked: root.osdVisible = false
    }

    Timer {
        id: startupTimer
        interval: 1500
        running: true
        onTriggered: root.startupCompleted = true
    }

    Timer {
        id: hideTimer
        interval: 2500
        onTriggered: root.osdVisible = false
    }

    Connections {
        target: AudioService
        function onVolumeChanged() {
            root.show("volume", AudioService.volume, AudioService.muted);
        }
        function onMutedChanged() {
            root.show("volume", AudioService.volume, AudioService.muted);
        }
        function onMicVolumeChanged() {
            root.show("mic", AudioService.micVolume, AudioService.micMuted);
        }
        function onMicMutedChanged() {
            root.show("mic", AudioService.micVolume, AudioService.micMuted);
        }
    }

    Connections {
        target: BrightnessService
        function onBrightnessChanged(value, screen) {
            if (!screen || !root.targetScreen || screen.name === root.targetScreen.name) {
                root.show("brightness", value, false);
            }
        }
    }
}
