import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.Mpris
import "../../../services"
import "../../../config"

PanelFrame {
    id: root

    property var activePlayer: null
    property string mediaSource: ""

    readonly property bool hasPlayer: activePlayer !== null && activePlayer !== undefined
    readonly property bool isPlaying: activePlayer?.playbackState === MprisPlaybackState.Playing
    readonly property real position: activePlayer?.position ?? 0
    readonly property real length: activePlayer?.length ?? 1

    border.color: ThemeService.border
    color: ThemeService.surface

    function formatTime(value) {
        var totalSeconds = Math.max(0, Math.floor(value));
        var minutes = Math.floor(totalSeconds / 60);
        var seconds = totalSeconds % 60;
        return minutes + ":" + String(seconds).padStart(2, "0");
    }

    Image {
        anchors.fill: parent
        source: root.mediaSource
        fillMode: Image.PreserveAspectCrop
        sourceSize.width: Math.max(1, width)
        sourceSize.height: Math.max(1, height)
        visible: root.mediaSource !== ""
        asynchronous: true
        mipmap: true
        opacity: 0.42
    }

    Rectangle {
        anchors.fill: parent
        color: ThemeService.background
        opacity: 0.38
    }

    Canvas {
        id: cavaBand
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 22
        width: 172
        height: 122
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.lineCap = "round";

            var values = CavaService.bars;
            var count = values.length;
            var radius = 74;
            var centerX = width / 2;
            var centerY = 88;
            var start = Math.PI * 1.11;
            var end = Math.PI * 1.89;

            ctx.strokeStyle = Qt.rgba(ThemeService.foreground.r, ThemeService.foreground.g, ThemeService.foreground.b, 0.28);
            ctx.lineWidth = 3;
            ctx.beginPath();
            ctx.arc(centerX, centerY, radius, start, end, false);
            ctx.stroke();

            for (var i = 0; i < count; i++) {
                var t = count <= 1 ? 0 : i / (count - 1);
                var angle = start + (end - start) * t;
                var level = root.isPlaying ? Math.max(0.04, values[i]) : 0.04;
                var barLength = 7 + level * 28;
                var inner = radius - barLength * 0.35;
                var outer = radius + barLength * 0.65;
                var x1 = centerX + Math.cos(angle) * inner;
                var y1 = centerY + Math.sin(angle) * inner;
                var x2 = centerX + Math.cos(angle) * outer;
                var y2 = centerY + Math.sin(angle) * outer;

                ctx.globalAlpha = 0.46 + level * 0.54;
                ctx.lineWidth = 3.5;
                ctx.strokeStyle = ThemeService.primary;
                ctx.beginPath();
                ctx.moveTo(x1, y1);
                ctx.lineTo(x2, y2);
                ctx.stroke();
            }
            ctx.globalAlpha = 1;
        }

        Connections {
            target: CavaService
            function onBarsChanged() { cavaBand.requestPaint(); }
        }

        Connections {
            target: root
            function onIsPlayingChanged() { cavaBand.requestPaint(); }
        }

        Component.onCompleted: requestPaint()
    }

    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 44
        width: 122
        height: 122

        ClippingRectangle {
            anchors.fill: parent
            radius: width / 2
            color: ThemeService.surfaceBright
            border.width: 1
            border.color: ThemeService.border

            Image {
                anchors.fill: parent
                source: root.mediaSource
                fillMode: Image.PreserveAspectCrop
                sourceSize.width: Math.max(1, width)
                sourceSize.height: Math.max(1, height)
                visible: root.mediaSource !== ""
                asynchronous: true
                mipmap: true
            }

            Rectangle {
                anchors.fill: parent
                color: ThemeService.background
                opacity: root.mediaSource === "" ? 0.0 : 0.22
            }
        }

        Text {
            anchors.centerIn: parent
            text: "ei"
            font.family: ThemeService.fontName
            font.pixelSize: 14
            font.weight: Font.Black
            color: ThemeService.textBright
            rotation: -18
            opacity: 0.92
        }
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 8

        Text {
            Layout.fillWidth: true
            text: root.hasPlayer ? (root.activePlayer.trackTitle || "Unknown Title") : "Nothing Playing"
            font.family: ThemeService.fontName
            font.pixelSize: 15
            font.weight: Font.Bold
            color: ThemeService.textBright
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            text: root.hasPlayer ? (root.activePlayer.trackArtist || root.activePlayer.identity || "Player") : "Enjoy the silence"
            font.family: ThemeService.fontName
            font.pixelSize: 12
            color: ThemeService.primary
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            text: "\\_(ツ)_/"
            font.family: ThemeService.fontName
            font.pixelSize: 15
            color: ThemeService.foreground
            horizontalAlignment: Text.AlignHCenter
            opacity: root.hasPlayer ? 0.0 : 0.95
            visible: opacity > 0
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 8
            spacing: 12

            TextButton {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                icon: "󰋋"
                enabledState: false
            }
            TextButton {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                icon: "󰒮"
                enabledState: root.hasPlayer && root.activePlayer.canGoPrevious
                onClicked: root.activePlayer.previous()
            }
            TextButton {
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
                icon: root.isPlaying ? "󰏤" : "󰐊"
                filled: true
                enabledState: root.hasPlayer
                onClicked: root.activePlayer.togglePlaying()
            }
            TextButton {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                icon: "󰒭"
                enabledState: root.hasPlayer && root.activePlayer.canGoNext
                onClicked: root.activePlayer.next()
            }
            TextButton {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                icon: "󰒝"
                enabledState: false
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.hasPlayer ? root.formatTime(root.position) + " / " + root.formatTime(root.length) : "--:-- / --:--"
            font.family: ThemeService.fontName
            font.pixelSize: 11
            color: ThemeService.textDim
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
