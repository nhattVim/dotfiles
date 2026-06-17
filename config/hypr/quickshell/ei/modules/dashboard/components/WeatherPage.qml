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
            opacity: 0.2
            visible: source !== ""
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(ThemeService.background.r, ThemeService.background.g, ThemeService.background.b, 0.62)
        }
    }

    Item {
        anchors.fill: parent

        PanelFrame {
            id: summaryPanel
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: 300
            radius: 24
            color: Qt.rgba(ThemeService.surface.r, ThemeService.surface.g, ThemeService.surface.b, 0.86)
            border.width: 1
            border.color: Qt.rgba(ThemeService.border.r, ThemeService.border.g, ThemeService.border.b, ThemeService.borderOpacity)

            Flickable {
                anchors.fill: parent
                anchors.margins: 18
                clip: true
                contentWidth: width
                contentHeight: summaryContent.implicitHeight
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: summaryContent
                    width: parent.width
                    spacing: 2

                    Text {
                        width: parent.width
                        text: WeatherService.city
                        color: ThemeService.textBright
                        font.family: ThemeService.fontName
                        font.pixelSize: 25
                        font.weight: Font.Black
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: WeatherService.todayLabel
                        color: ThemeService.foreground
                        opacity: 0.82
                        font.family: ThemeService.fontName
                        font.pixelSize: 11
                    }

                    Text {
                        width: parent.width
                        topPadding: 18
                        text: WeatherService.icon
                        color: ThemeService.foreground
                        font.family: ThemeService.iconFont
                        font.pixelSize: 68
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        width: parent.width
                        text: WeatherService.ready ? Math.round(WeatherService.temperature) + "°C" : "--°C"
                        color: ThemeService.textBright
                        font.family: ThemeService.fontName
                        font.pixelSize: 54
                        font.weight: Font.Black
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        width: parent.width
                        topPadding: 4
                        text: WeatherService.loading && !WeatherService.ready ? "Loading" : WeatherService.condition
                        color: ThemeService.foreground
                        opacity: 0.86
                        font.family: ThemeService.fontName
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        topPadding: 14
                        spacing: 22

                        SunTime {
                            icon: "󰖜"
                            label: "Sunrise"
                            value: WeatherService.sunrise
                        }

                        SunTime {
                            icon: "󰖛"
                            label: "Sunset"
                            value: WeatherService.sunset
                        }
                    }
                }
            }
        }

        PanelFrame {
            id: detailPanel
            anchors {
                left: summaryPanel.right
                leftMargin: 8
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }
            radius: 24
            color: Qt.rgba(ThemeService.surface.r, ThemeService.surface.g, ThemeService.surface.b, 0.86)
            border.width: 1
            border.color: Qt.rgba(ThemeService.border.r, ThemeService.border.g, ThemeService.border.b, ThemeService.borderOpacity)

            Flickable {
                id: detailScroll
                anchors.fill: parent
                anchors.margins: 12
                clip: true
                contentWidth: width
                contentHeight: detailContent.implicitHeight
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: detailContent
                    width: detailScroll.width
                    spacing: 14

                    Row {
                        id: metricsRow
                        width: parent.width
                        height: 74
                        spacing: 8

                        WeatherMetricCard {
                            width: (metricsRow.width - metricsRow.spacing * 2) / 3
                            height: parent.height
                            icon: "󰖎"
                            label: "Humidity"
                            value: WeatherService.humidity + "%"
                        }

                        WeatherMetricCard {
                            width: (metricsRow.width - metricsRow.spacing * 2) / 3
                            height: parent.height
                            icon: "󰔏"
                            label: "Feels Like"
                            value: Math.round(WeatherService.feelsLike) + "°C"
                        }

                        WeatherMetricCard {
                            width: (metricsRow.width - metricsRow.spacing * 2) / 3
                            height: parent.height
                            icon: "󰖝"
                            label: "Wind"
                            value: WeatherService.windSpeed + " km/h"
                        }
                    }

                    Text {
                        width: parent.width
                        text: "7-Day Forecast"
                        color: ThemeService.textBright
                        font.family: ThemeService.fontName
                        font.pixelSize: 13
                        font.weight: Font.Bold
                    }

                    Flow {
                        id: forecastFlow
                        width: parent.width
                        height: Math.ceil(WeatherService.forecast.length / 4) * 86 + Math.max(0, Math.ceil(WeatherService.forecast.length / 4) - 1) * spacing
                        spacing: 8

                        Repeater {
                            model: WeatherService.forecast

                            Rectangle {
                                width: (forecastFlow.width - forecastFlow.spacing * 3) / 4
                                height: 86
                                radius: 18
                                color: Qt.rgba(ThemeService.surfaceBright.r, ThemeService.surfaceBright.g, ThemeService.surfaceBright.b, index === 0 ? 0.54 : 0.34)

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 8

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 32
                                        text: modelData.icon
                                        color: ThemeService.foreground
                                        font.family: ThemeService.iconFont
                                        font.pixelSize: 26
                                        horizontalAlignment: Text.AlignHCenter
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - 40
                                        spacing: 2

                                        Text {
                                            width: parent.width
                                            text: modelData.day
                                            color: index === 0 ? ThemeService.primary : ThemeService.textBright
                                            font.family: ThemeService.fontName
                                            font.pixelSize: 12
                                            font.weight: Font.Bold
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            width: parent.width
                                            text: modelData.date
                                            color: ThemeService.foreground
                                            opacity: 0.72
                                            font.family: ThemeService.fontName
                                            font.pixelSize: 10
                                        }

                                        Text {
                                            width: parent.width
                                            text: modelData.high + "° / " + modelData.low + "°"
                                            color: ThemeService.textBright
                                            font.family: ThemeService.fontName
                                            font.pixelSize: 11
                                            font.weight: Font.Bold
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            visible: !WeatherService.ready && WeatherService.error !== ""
            text: WeatherService.error
            color: ThemeService.foreground
            font.family: ThemeService.fontName
            font.pixelSize: 13
        }
    }

    component SunTime: Row {
        property string icon: ""
        property string label: ""
        property string value: ""

        spacing: 7

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: icon
            color: ThemeService.textBright
            font.family: ThemeService.iconFont
            font.pixelSize: 20
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Text {
                text: label
                color: ThemeService.foreground
                font.family: ThemeService.fontName
                font.pixelSize: 10
            }

            Text {
                text: value
                color: ThemeService.textBright
                font.family: ThemeService.fontName
                font.pixelSize: 11
                font.weight: Font.Bold
            }
        }
    }

    component WeatherMetricCard: Rectangle {
        property string icon: ""
        property string label: ""
        property string value: ""

        radius: 18
        color: Qt.rgba(ThemeService.surfaceBright.r, ThemeService.surfaceBright.g, ThemeService.surfaceBright.b, 0.34)

        Row {
            anchors.centerIn: parent
            spacing: 10

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: icon
                color: ThemeService.textBright
                font.family: ThemeService.iconFont
                font.pixelSize: 20
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text {
                    text: label
                    color: ThemeService.foreground
                    font.family: ThemeService.fontName
                    font.pixelSize: 10
                }

                Text {
                    text: value
                    color: ThemeService.textBright
                    font.family: ThemeService.fontName
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }
            }
        }
    }
}
