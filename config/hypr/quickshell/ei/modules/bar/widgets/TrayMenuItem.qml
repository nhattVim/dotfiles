import QtQuick
import Quickshell
import Quickshell.Widgets
import "../../../services"
import "../../../config"

Item {
    id: root

    property string textStr: ""
    property string iconSource: ""
    property bool isSeparator: false
    property bool hasSubmenu: false
    property bool expanded: false
    property int depth: 0
    property int buttonType: 0
    property int checkState: 0

    readonly property string cleanText: {
        let text = String(textStr || "");
        if (text.startsWith(":/// ")) text = text.substring(5);
        return text.trim();
    }

    signal clicked()

    implicitWidth: 220
    implicitHeight: isSeparator ? 10 : 34

    Rectangle {
        anchors.fill: parent
        radius: ThemeService.radiusSmall
        color: !root.isSeparator && menuMouse.containsMouse ? Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.18) : "transparent"
    }

    Rectangle {
        visible: root.isSeparator
        anchors.centerIn: parent
        width: parent.width - 18
        height: 1
        color: ThemeService.surfaceBright
        opacity: 0.8
    }

    Row {
        visible: !root.isSeparator
        anchors.fill: parent
        anchors.leftMargin: 9 + root.depth * 14
        anchors.rightMargin: 9
        spacing: ThemeService.spacingSmall

        Item {
            width: root.buttonType > 0 ? 16 : 0
            height: parent.height
            visible: root.buttonType > 0

            Rectangle {
                visible: root.buttonType === 1
                anchors.centerIn: parent
                width: 14
                height: 14
                radius: 3
                color: root.checkState === Qt.Unchecked ? "transparent" : ThemeService.primary
                border.width: 1
                border.color: root.checkState === Qt.Unchecked ? ThemeService.textDim : ThemeService.primary

                Text {
                    anchors.centerIn: parent
                    visible: root.checkState !== Qt.Unchecked
                    text: root.checkState === Qt.PartiallyChecked ? "-" : "✓"
                    color: ThemeService.background
                    font.pixelSize: 10
                    font.bold: true
                }
            }

            Rectangle {
                visible: root.buttonType === 2
                anchors.centerIn: parent
                width: 14
                height: 14
                radius: 7
                color: "transparent"
                border.width: 1
                border.color: root.checkState === Qt.Checked ? ThemeService.primary : ThemeService.textDim

                Rectangle {
                    visible: root.checkState === Qt.Checked
                    anchors.centerIn: parent
                    width: 7
                    height: 7
                    radius: 4
                    color: ThemeService.primary
                }
            }
        }

        IconImage {
            visible: root.iconSource !== "" && root.buttonType === 0
            anchors.verticalCenter: parent.verticalCenter
            width: visible ? 16 : 0
            height: 16
            smooth: true
            source: {
                if (root.iconSource === "") return "";
                if (root.iconSource.includes("/") || root.iconSource.includes(".")) return root.iconSource;
                return Quickshell.iconPath(root.iconSource, "image-missing");
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - x - chevron.width
            text: root.cleanText
            color: menuMouse.containsMouse ? ThemeService.textBright : ThemeService.foreground
            font.family: ThemeService.fontName
            font.pixelSize: 12
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            id: chevron
            visible: root.hasSubmenu
            anchors.verticalCenter: parent.verticalCenter
            width: visible ? 14 : 0
            text: root.expanded ? "▾" : "▸"
            color: ThemeService.textDim
            font.pixelSize: 12
            horizontalAlignment: Text.AlignRight
        }
    }

    MouseArea {
        id: menuMouse
        anchors.fill: parent
        enabled: !root.isSeparator
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
