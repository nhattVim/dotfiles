import QtQuick
import "../../../services"
import "../../../config"

Item {
    id: root

    property string backgroundSource: ""

    Rectangle {
        anchors.fill: parent
        radius: ThemeService.radiusLarge
        color: ThemeService.surface
        clip: true

        Image {
            anchors.fill: parent
            source: root.backgroundSource
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            opacity: 0.16
            visible: source !== ""
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(ThemeService.background.r, ThemeService.background.g, ThemeService.background.b, 0.68)
        }
    }

    Item {
        anchors.fill: parent

        Row {
            anchors.fill: parent
            spacing: 8

            PerformanceFrame {
                width: (parent.width - 16) / 3
                height: parent.height

                GaugeCard {
                    width: parent.width
                    height: 150
                    title: "CPU"
                    icon: "󰍛"
                    value: PerformanceService.cpuUsage
                    subtitle: PerformanceService.cpuCores + " cores  " + Math.round(PerformanceService.cpuTemp) + "°C"
                    accent: ThemeService.primary
                }

                InfoCard {
                    width: parent.width
                    height: 74
                    icon: "󰔟"
                    label: "Uptime"
                    value: PerformanceService.uptime
                    progress: 0
                    accent: ThemeService.success
                    showProgress: false
                }

                SectionLabel {
                    width: parent.width
                    text: "Load Average"
                }

                LoadBar {
                    label: "1 min"
                    valueText: PerformanceService.load1.toFixed(2)
                    value: PerformanceService.cpuCores > 0 ? PerformanceService.load1 / PerformanceService.cpuCores * 100 : 0
                }

                LoadBar {
                    label: "5 min"
                    valueText: PerformanceService.load5.toFixed(2)
                    value: PerformanceService.cpuCores > 0 ? PerformanceService.load5 / PerformanceService.cpuCores * 100 : 0
                }

                LoadBar {
                    label: "15 min"
                    valueText: PerformanceService.load15.toFixed(2)
                    value: PerformanceService.cpuCores > 0 ? PerformanceService.load15 / PerformanceService.cpuCores * 100 : 0
                }
            }

            PerformanceFrame {
                width: (parent.width - 16) / 3
                height: parent.height

                GaugeCard {
                    width: parent.width
                    height: 150
                    title: "Memory"
                    icon: "󰘚"
                    value: PerformanceService.memoryUsage
                    subtitle: PerformanceService.memoryUsed.toFixed(1) + " / " + PerformanceService.memoryTotal.toFixed(1) + " GiB"
                    accent: ThemeService.secondary
                }

                InfoCard {
                    width: parent.width
                    height: 82
                    icon: "󰋊"
                    label: "Root Disk"
                    value: PerformanceService.diskUsed.toFixed(1) + " / " + PerformanceService.diskTotal.toFixed(1) + " GiB"
                    progress: PerformanceService.diskUsage
                    accent: ThemeService.primary
                }

                InfoCard {
                    width: parent.width
                    height: 82
                    icon: "󰓡"
                    label: "Swap"
                    value: PerformanceService.swapTotal > 0 ? PerformanceService.swapUsed.toFixed(1) + " / " + PerformanceService.swapTotal.toFixed(1) + " GiB" : "Disabled"
                    progress: PerformanceService.swapUsage
                    accent: ThemeService.secondary
                }

                InfoCard {
                    width: parent.width
                    height: 74
                    icon: "󰋁"
                    label: "Total Memory"
                    value: PerformanceService.memoryTotal.toFixed(1) + " GiB"
                    progress: 0
                    accent: ThemeService.secondary
                    showProgress: false
                }
            }

            PerformanceFrame {
                width: (parent.width - 16) / 3
                height: parent.height

                GaugeCard {
                    width: parent.width
                    height: 150
                    title: "GPU"
                    icon: "󰢮"
                    value: PerformanceService.gpuAvailable ? PerformanceService.gpuUsage : 0
                    subtitle: PerformanceService.gpuAvailable
                        ? Math.round(PerformanceService.gpuTemp) + "°C  " + PerformanceService.gpuMemoryUsed.toFixed(1) + "/" + PerformanceService.gpuMemoryTotal.toFixed(1) + " GiB"
                        : "Not detected"
                    accent: ThemeService.warning
                }

                InfoCard {
                    width: parent.width
                    height: 82
                    icon: "󰾲"
                    label: "GPU Memory"
                    value: PerformanceService.gpuAvailable ? PerformanceService.gpuMemoryUsed.toFixed(1) + " / " + PerformanceService.gpuMemoryTotal.toFixed(1) + " GiB" : "Unavailable"
                    progress: PerformanceService.gpuMemoryUsage
                    accent: ThemeService.warning
                }

                InfoCard {
                    width: parent.width
                    height: 74
                    icon: "󰓅"
                    label: "Power Profile"
                    value: PowerProfileService.activeProfile || "unknown"
                    progress: 0
                    accent: ThemeService.warning
                    showProgress: false
                }

                InfoCard {
                    width: parent.width
                    height: 74
                    icon: BatteryService.isCharging ? "󰂄" : "󰁹"
                    label: "Battery"
                    value: BatteryService.available ? Math.round(BatteryService.percentage) + "%" : "Desktop power"
                    progress: BatteryService.available ? BatteryService.percentage : 0
                    accent: ThemeService.success
                    showProgress: BatteryService.available
                }
            }
        }
    }

    component PerformanceFrame: PanelFrame {
        id: frame

        default property alias content: contentColumn.data

        radius: 18
        color: Qt.rgba(ThemeService.surface.r, ThemeService.surface.g, ThemeService.surface.b, 0.86)
        border.width: 1
        border.color: Qt.rgba(ThemeService.border.r, ThemeService.border.g, ThemeService.border.b, ThemeService.borderOpacity)

        Item {
            anchors.fill: parent
            anchors.margins: 10

            Flickable {
                id: frameScroll
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                clip: true
                contentWidth: width
                contentHeight: contentColumn.implicitHeight
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: contentColumn
                    width: frameScroll.width
                    spacing: 10
                }
            }
        }
    }

    component SectionLabel: Text {
        color: ThemeService.textBright
        font.family: ThemeService.fontName
        font.pixelSize: 12
        font.weight: Font.Bold
    }

    component GaugeCard: Rectangle {
        id: card

        property string title: ""
        property string icon: ""
        property real value: 0
        property string subtitle: ""
        property color accent: ThemeService.primary

        radius: 22
        color: Qt.rgba(ThemeService.surfaceBright.r, ThemeService.surfaceBright.g, ThemeService.surfaceBright.b, 0.34)

        Text {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 16
            anchors.topMargin: 12
            text: card.title
            color: ThemeService.textBright
            font.family: ThemeService.fontName
            font.pixelSize: 14
            font.weight: Font.Bold
        }

        Text {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 16
            anchors.topMargin: 12
            text: card.icon
            color: card.accent
            font.family: ThemeService.iconFont
            font.pixelSize: 20
        }

        Canvas {
            id: gaugeCanvas
            anchors.centerIn: parent
            width: 96
            height: 96
            antialiasing: true

            property real progress: Math.max(0, Math.min(100, card.value))
            property color progressColor: card.accent

            onProgressChanged: requestPaint()
            onProgressColorChanged: requestPaint()
            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();
                const cx = width / 2;
                const cy = height / 2;
                const radius = width / 2 - 8;
                const start = Math.PI * 0.72;
                const sweep = Math.PI * 1.56;

                ctx.lineWidth = 8;
                ctx.lineCap = "round";
                ctx.strokeStyle = Qt.rgba(ThemeService.foreground.r, ThemeService.foreground.g, ThemeService.foreground.b, 0.18);
                ctx.beginPath();
                ctx.arc(cx, cy, radius, start, start + sweep, false);
                ctx.stroke();

                ctx.strokeStyle = progressColor;
                ctx.beginPath();
                ctx.arc(cx, cy, radius, start, start + sweep * (progress / 100), false);
                ctx.stroke();
            }
        }

        Text {
            anchors.centerIn: parent
            text: Math.round(card.value) + "%"
            color: ThemeService.textBright
            font.family: ThemeService.fontName
            font.pixelSize: 24
            font.weight: Font.Black
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 13
            width: parent.width - 24
            text: card.subtitle
            color: ThemeService.foreground
            opacity: 0.86
            font.family: ThemeService.fontName
            font.pixelSize: 11
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }

    component LoadBar: Item {
        property string label: ""
        property string valueText: ""
        property real value: 0

        width: parent.width
        height: 34

        Text {
            anchors.left: parent.left
            anchors.top: parent.top
            text: label
            color: ThemeService.foreground
            font.family: ThemeService.fontName
            font.pixelSize: 11
        }

        Text {
            anchors.right: parent.right
            anchors.top: parent.top
            text: valueText
            color: ThemeService.textBright
            font.family: ThemeService.fontName
            font.pixelSize: 11
            font.weight: Font.Bold
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 5
            radius: 3
            color: Qt.rgba(ThemeService.foreground.r, ThemeService.foreground.g, ThemeService.foreground.b, 0.18)

            Rectangle {
                width: parent.width * Math.max(0, Math.min(100, value)) / 100
                height: parent.height
                radius: parent.radius
                color: ThemeService.primary
            }
        }
    }

    component InfoCard: Rectangle {
        property string icon: ""
        property string label: ""
        property string value: ""
        property real progress: 0
        property color accent: ThemeService.primary
        property bool showProgress: true

        radius: 18
        color: Qt.rgba(ThemeService.surfaceBright.r, ThemeService.surfaceBright.g, ThemeService.surfaceBright.b, 0.32)

        Text {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 14
            anchors.topMargin: 13
            text: icon
            color: accent
            font.family: ThemeService.iconFont
            font.pixelSize: 20
        }

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 48
            anchors.rightMargin: 14
            anchors.topMargin: 13
            text: label
            color: ThemeService.foreground
            font.family: ThemeService.fontName
            font.pixelSize: 11
            elide: Text.ElideRight
        }

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 48
            anchors.rightMargin: 14
            anchors.topMargin: 32
            text: value
            color: ThemeService.textBright
            font.family: ThemeService.fontName
            font.pixelSize: 13
            font.weight: Font.Bold
            elide: Text.ElideRight
        }

        Rectangle {
            visible: showProgress
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            anchors.bottomMargin: 13
            height: 5
            radius: 3
            color: Qt.rgba(ThemeService.foreground.r, ThemeService.foreground.g, ThemeService.foreground.b, 0.18)

            Rectangle {
                width: parent.width * Math.max(0, Math.min(100, progress)) / 100
                height: parent.height
                radius: parent.radius
                color: accent
            }
        }
    }
}
