import QtQuick
import "../config"

Rectangle {
    id: root

    required property var selector

    x: Math.min(selector.startX, selector.currentX)
    y: Math.min(selector.startY, selector.currentY)
    width: Math.abs(selector.currentX - selector.startX)
    height: Math.abs(selector.currentY - selector.startY)
    visible: selector.selecting
    color: Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.18)
    border.color: ThemeService.primary
    border.width: 2
    radius: 6
}
