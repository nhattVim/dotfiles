import QtQuick
import QtQuick.Layouts
import "../../../services"
import "../../../config"

PanelFrame {
    id: root

    property date todayDate: new Date()
    property date shownDate: new Date()
    readonly property int year: shownDate.getFullYear()
    readonly property int month: shownDate.getMonth()
    readonly property int today: todayDate.getDate()
    readonly property bool showingCurrentMonth: year === todayDate.getFullYear() && month === todayDate.getMonth()
    readonly property int firstDay: {
        var day = new Date(year, month, 1).getDay();
        return day === 0 ? 6 : day - 1;
    }
    readonly property int daysInMonth: new Date(year, month + 1, 0).getDate()
    readonly property var monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

    function previousMonth() {
        shownDate = new Date(year, month - 1, 1);
    }

    function nextMonth() {
        shownDate = new Date(year, month + 1, 1);
    }

    function goToday() {
        var now = new Date();
        todayDate = now;
        shownDate = now;
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.todayDate = new Date()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            spacing: 8

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 17
                color: ThemeService.background

                Text {
                    anchors.centerIn: parent
                    text: root.monthNames[root.month] + " " + root.year
                    font.family: ThemeService.fontName
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    color: ThemeService.textBright
                }
            }

            TextButton {
                Layout.preferredWidth: 34
                Layout.fillHeight: true
                icon: "󰅁"
                onClicked: root.previousMonth()
            }

            TextButton {
                Layout.preferredWidth: 34
                Layout.fillHeight: true
                icon: "󰅂"
                onClicked: root.nextMonth()
            }

            TextButton {
                Layout.preferredWidth: 34
                Layout.fillHeight: true
                icon: "󰔚"
                filled: root.showingCurrentMonth
                onClicked: root.goToday()
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 7
            rowSpacing: 0
            columnSpacing: 0

            Repeater {
                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                delegate: Text {
                    required property string modelData
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 26
                    text: modelData
                    font.family: ThemeService.fontName
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    color: ThemeService.foreground
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: ThemeService.surfaceBright
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 7
            rowSpacing: 0
            columnSpacing: 0

            Repeater {
                model: 42
                delegate: Item {
                    required property int index
                    readonly property int value: index - root.firstDay + 1
                    readonly property bool inMonth: value >= 1 && value <= root.daysInMonth
                    readonly property int displayValue: inMonth ? value : (value < 1 ? new Date(root.year, root.month, 0).getDate() + value : value - root.daysInMonth)
                    readonly property bool selected: root.showingCurrentMonth && inMonth && value === root.today

                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 26

                    Rectangle {
                        anchors.centerIn: parent
                        width: 30
                        height: 24
                        radius: 12
                        color: selected ? ThemeService.primary : "transparent"
                    }

                    Text {
                        anchors.centerIn: parent
                        text: displayValue
                        font.family: ThemeService.fontName
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: selected ? ThemeService.background : (inMonth ? ThemeService.textBright : ThemeService.textDim)
                    }
                }
            }
        }
    }
}
