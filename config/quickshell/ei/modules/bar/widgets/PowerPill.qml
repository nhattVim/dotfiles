import QtQuick
import "../../../services"
import "../../../config"
import "../../../components"

PillSurface {
    id: root

    property int pillHeight: ThemeService.sideCapsuleHeight
    property string islandState: ""

    signal requestIslandState(string state)

    height: pillHeight
    width: height
    onPressed: root.requestIslandState(root.islandState === "powerMenu" ? "windowTitle" : "powerMenu")

    Text {
        anchors.centerIn: parent
        text: ""
        font.pixelSize: 14
        color: ThemeService.danger
    }
}
