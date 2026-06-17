import QtQuick
import "../../../services"
import "../../../config"

Item {
    id: root

    readonly property int controlSize: 48
    readonly property int controlRadius: 18
    readonly property int edgeMargin: 1
    readonly property int contentGap: 8

    Rectangle {
        anchors.fill: parent
        radius: 28
        color: ThemeService.background
    }

    Rectangle {
        id: brightnessButton
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.edgeMargin
        width: root.controlSize
        height: root.controlSize
        radius: root.controlRadius
        color: ThemeService.surfaceBright

        Text {
            anchors.centerIn: parent
            text: "󰃠"
            font.family: ThemeService.iconFont
            font.pixelSize: 18
            color: ThemeService.primary
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onWheel: wheel => {
                BrightnessService.changeBrightness(wheel.angleDelta.y > 0 ? 0.04 : -0.04, null);
                wheel.accepted = true;
            }
        }
    }

    Item {
        id: brightnessSlider
        anchors {
            top: brightnessButton.bottom
            topMargin: root.contentGap
            bottom: volumeButton.top
            bottomMargin: root.contentGap
            left: parent.left
            right: parent.right
        }

        readonly property real value: BrightnessService.ready ? BrightnessService.value : 0
        readonly property real clampedValue: Math.max(0, Math.min(1, value))

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 5
            height: parent.height
            radius: 3
            color: ThemeService.surfaceBright
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * (1 - brightnessSlider.clampedValue)
            width: 5
            height: parent.height * brightnessSlider.clampedValue
            radius: 3
            color: ThemeService.primary
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: Math.max(0, Math.min(parent.height - height, parent.height * (1 - brightnessSlider.clampedValue) - height / 2))
            width: 18
            height: 5
            radius: 3
            color: ThemeService.textBright
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            preventStealing: true

            onPressed: mouse => root.updateBrightness(mouse.y)
            onPositionChanged: mouse => {
                if (pressed) root.updateBrightness(mouse.y);
            }
            onWheel: wheel => {
                BrightnessService.changeBrightness(wheel.angleDelta.y > 0 ? 0.04 : -0.04, null);
                wheel.accepted = true;
            }
        }
    }

    RoundLevelButton {
        id: volumeButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: micButton.top
        anchors.bottomMargin: root.contentGap
        width: root.controlSize
        height: root.controlSize
        value: AudioService.ready ? AudioService.volume : 0
        muted: AudioService.muted
        enabledControl: AudioService.ready
        icon: AudioService.muted ? "󰝟" : "󰕾"

        onControlValueChanged: value => AudioService.setVolume(value)
        onToggleRequested: AudioService.toggleMute()
    }

    RoundLevelButton {
        id: micButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.edgeMargin
        width: root.controlSize
        height: root.controlSize
        value: AudioService.micReady ? AudioService.micVolume : 0
        muted: AudioService.micMuted
        enabledControl: AudioService.micReady
        icon: AudioService.micMuted ? "󰍭" : "󰍬"

        onControlValueChanged: value => AudioService.setMicVolume(value)
        onToggleRequested: AudioService.toggleMicMute()
    }

    function sliderValue(yPos, item) {
        const localY = Math.max(0, Math.min(item.height, yPos));
        return Math.round((1 - localY / Math.max(1, item.height)) * 100) / 100;
    }

    function updateBrightness(yPos) {
        if (BrightnessService.ready) {
            BrightnessService.setBrightness(sliderValue(yPos, brightnessSlider), null);
        }
    }

    component RoundLevelButton: Item {
        id: control

        property real value: 0
        property bool muted: false
        property bool enabledControl: true
        property string icon: ""
        property real pressY: 0
        property real pressValue: 0
        property bool dragged: false

        signal controlValueChanged(real value)
        signal toggleRequested()

        readonly property real clampedValue: Math.max(0, Math.min(1, value))
        readonly property color activeColor: muted ? ThemeService.textDim : ThemeService.primary

        Rectangle {
            anchors.fill: parent
            radius: root.controlRadius
            color: ThemeService.surfaceBright
            opacity: control.enabledControl ? 1.0 : 0.55
        }

        Canvas {
            id: progressCanvas
            anchors.fill: parent
            antialiasing: true

            property real progress: control.clampedValue
            property color progressColor: control.activeColor

            onProgressChanged: requestPaint()
            onProgressColorChanged: requestPaint()
            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();

                const cx = width / 2;
                const cy = height / 2;
                const radius = Math.min(width, height) / 2 - 6;
                const start = Math.PI * 0.72;
                const sweep = Math.PI * 1.56;
                const end = start + sweep;

                ctx.lineWidth = 4;
                ctx.lineCap = "round";
                ctx.strokeStyle = Qt.rgba(ThemeService.foreground.r, ThemeService.foreground.g, ThemeService.foreground.b, 0.26);
                ctx.beginPath();
                ctx.arc(cx, cy, radius, start, end, false);
                ctx.stroke();

                if (progress > 0.005) {
                    ctx.strokeStyle = progressColor;
                    ctx.beginPath();
                    ctx.arc(cx, cy, radius, start, start + sweep * progress, false);
                    ctx.stroke();
                }
                const handleAngle = start + sweep * Math.max(0.01, progress);
                const innerRadius = radius - 2;
                const outerRadius = radius + 5;
                ctx.strokeStyle = ThemeService.textBright;
                ctx.beginPath();
                ctx.moveTo(cx + innerRadius * Math.cos(handleAngle), cy + innerRadius * Math.sin(handleAngle));
                ctx.lineTo(cx + outerRadius * Math.cos(handleAngle), cy + outerRadius * Math.sin(handleAngle));
                ctx.stroke();
            }
        }

        Text {
            anchors.centerIn: parent
            text: control.icon
            font.family: ThemeService.iconFont
            font.pixelSize: 18
            color: control.muted ? ThemeService.textDim : ThemeService.textBright
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: control.enabledControl ? Qt.PointingHandCursor : Qt.ArrowCursor
            preventStealing: true

            onPressed: mouse => {
                control.pressY = mouse.y;
                control.pressValue = control.clampedValue;
                control.dragged = false;
            }
            onPositionChanged: mouse => {
                if (!pressed || !control.enabledControl) return;

                const delta = (control.pressY - mouse.y) / 100;
                if (Math.abs(delta) > 0.03) control.dragged = true;
                control.controlValueChanged(Math.max(0, Math.min(1, control.pressValue + delta)));
            }
            onReleased: {
                if (control.enabledControl && !control.dragged) control.toggleRequested();
            }
            onWheel: wheel => {
                if (control.enabledControl) {
                    control.controlValueChanged(Math.max(0, Math.min(1, control.clampedValue + (wheel.angleDelta.y > 0 ? 0.04 : -0.04))));
                }
                wheel.accepted = true;
            }
        }
    }
}
