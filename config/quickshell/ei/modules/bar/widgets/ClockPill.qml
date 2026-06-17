import QtQuick
import "../../../services"
import "../../../config"
import "../../../components"

StyledRect {
    id: root

    property int pillHeight: ThemeService.sideCapsuleHeight

    height: pillHeight
    width: statsRow.implicitWidth + ThemeService.radiusLarge
    radius: height / 2
    rectColor: ThemeService.background
    rectOpacity: ThemeService.bgOpacity
    borderOpacityValue: 0.0

    Row {
        id: statsRow
        anchors.centerIn: parent
        spacing: ThemeService.spacingLarge

        Text {
            text: ClockService.time
            font.family: ThemeService.fontName
            font.pixelSize: 12
            font.weight: Font.DemiBold
            color: ThemeService.foreground
        }
    }
}
