import QtQuick
import "../config"
import "../services"

Column {
    id: root

    property string title: ""
    property var actions: []
    property int selectedIndex: 0
    property int tileWidth: 90
    property int tileHeight: 90
    property int tileLabelPixelSize: 10

    signal actionTriggered(string action)

    spacing: ThemeService.spacingLarge
    anchors.fill: parent
    anchors.margins: ThemeService.spacingExtraLarge
    focus: visible

    Text {
        text: root.title
        font.family: ThemeService.fontName
        font.pixelSize: 14
        font.bold: true
        color: ThemeService.primary
        anchors.horizontalCenter: parent.horizontalCenter
        visible: root.title !== ""
    }

    Row {
        spacing: ThemeService.spacingExtraLarge
        anchors.horizontalCenter: parent.horizontalCenter

        Repeater {
            model: root.actions

            delegate: ActionTile {
                required property int index
                required property var modelData

                width: root.tileWidth
                height: root.tileHeight
                radius: ThemeService.radiusMedium
                icon: modelData.icon
                label: modelData.label
                iconColor: modelData.iconColor || modelData.color
                labelPixelSize: root.tileLabelPixelSize
                selected: root.selectedIndex === index
                onClicked: root.actionTriggered(modelData.action)
                onEntered: root.selectedIndex = index
            }
        }
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            root.actionTriggered("close");
            event.accepted = true;
        } else if (event.key === Qt.Key_Right || (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier))) {
            root.selectedIndex = NavigationService.nextIndex(root.selectedIndex, root.actions.length);
            event.accepted = true;
        } else if (event.key === Qt.Key_Left || (event.key === Qt.Key_Backtab) || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
            root.selectedIndex = NavigationService.previousIndex(root.selectedIndex, root.actions.length);
            event.accepted = true;
        } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            if (root.actions.length > 0) {
                const index = NavigationService.clampIndex(root.selectedIndex, root.actions.length);
                root.actionTriggered(root.actions[index].action);
            }
            event.accepted = true;
        }
    }
}
