import QtQuick
import "../config"

Rectangle {
    id: rect

    property color rectColor: ThemeService.background
    property real rectOpacity: ThemeService.bgOpacity
    property color borderColor: ThemeService.border
    property real borderOpacityValue: ThemeService.borderOpacity

    // Individual corner radius values
    property real topLeftRadiusVal: -1
    property real topRightRadiusVal: -1
    property real bottomLeftRadiusVal: -1
    property real bottomRightRadiusVal: -1

    radius: ThemeService.radius
    
    topLeftRadius: topLeftRadiusVal >= 0 ? topLeftRadiusVal : radius
    topRightRadius: topRightRadiusVal >= 0 ? topRightRadiusVal : radius
    bottomLeftRadius: bottomLeftRadiusVal >= 0 ? bottomLeftRadiusVal : radius
    bottomRightRadius: bottomRightRadiusVal >= 0 ? bottomRightRadiusVal : radius

    color: Qt.rgba(rectColor.r, rectColor.g, rectColor.b, rectOpacity)
    border.color: Qt.rgba(borderColor.r, borderColor.g, borderColor.b, borderOpacityValue)
    border.width: 1

    Behavior on color {
        ColorAnimation { duration: ThemeService.animDuration }
    }
    Behavior on border.color {
        ColorAnimation { duration: ThemeService.animDuration }
    }
    Behavior on topLeftRadius {
        NumberAnimation { duration: ThemeService.animDuration }
    }
    Behavior on topRightRadius {
        NumberAnimation { duration: ThemeService.animDuration }
    }
    Behavior on bottomLeftRadius {
        NumberAnimation { duration: ThemeService.animDuration }
    }
    Behavior on bottomRightRadius {
        NumberAnimation { duration: ThemeService.animDuration }
    }
}
