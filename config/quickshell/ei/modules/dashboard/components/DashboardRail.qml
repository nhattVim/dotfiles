import QtQuick
import "../../../services"
import "../../../config"

Item {
    id: root
    signal requestClose()
    signal pageRequested(string page)

    property string currentPage: "dashboard"

    readonly property color accent: ThemeService.primary
    readonly property color panel: ThemeService.surface
    readonly property color dim: ThemeService.textDim

    Rectangle {
        anchors.fill: parent
        radius: 28
        color: ThemeService.background
    }

    Column {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 6
        spacing: 20

        RailButton {
            width: 48
            height: 48
            icon: ""
            selected: root.currentPage === "dashboard"
            accent: root.accent
            onClicked: root.pageRequested("dashboard")
        }

        RailButton {
            width: 48
            height: 36
            icon: "󰖕"
            selected: root.currentPage === "weather"
            accent: root.accent
            onClicked: root.pageRequested("weather")
        }

        RailButton {
            width: 48
            height: 36
            icon: "󰍛"
            selected: root.currentPage === "performance"
            accent: root.accent
            onClicked: root.pageRequested("performance")
        }
    }

    RailButton {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        width: 48
        height: 48
        icon: "󰒓"
        accent: root.accent
        selected: hovered
        onClicked: root.requestClose()
    }
}
