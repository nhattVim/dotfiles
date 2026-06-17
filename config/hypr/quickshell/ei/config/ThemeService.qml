pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    // Palette: Sleek dark obsidian theme
    readonly property color defaultBackground: "#050505"
    readonly property color defaultSurface: "#0c0d12"
    readonly property color defaultSurfaceBright: "#1e2030"
    readonly property color defaultPrimary: "#bb9af7"
    readonly property color defaultSecondary: "#7aa2f7"
    readonly property color defaultForeground: "#a9b1d6"
    readonly property color defaultTextDim: "#565f89"
    readonly property color defaultBorder: "#bb9af7"

    property color background: defaultBackground
    property color surface: defaultSurface
    property color surfaceBright: defaultSurfaceBright
    
    property color primary: defaultPrimary // Accent from wallpaper when available
    property color secondary: defaultSecondary // Secondary accent from wallpaper when available
    readonly property color danger: "#ff5555" // Red for power/alerts
    readonly property color warning: "#ffb86c" // Orange for reboot/performance
    readonly property color success: "#50fa7b" // Green for logout/success
    
    property color foreground: defaultForeground // Light gray text
    property color textDim: defaultTextDim // Darker gray for muted text
    readonly property color textBright: "#ffffff" // Pure white for titles/emphasis
    readonly property color scrimColor: "#66000000" // 40% black for overlay/scrim
    
    property color border: defaultBorder
    readonly property real borderOpacity: 0.15
    readonly property real bgOpacity: 0.8
    readonly property real bgOpacityHigh: 0.9

    function clamp(value, min, max) {
        return Math.max(min, Math.min(max, value));
    }

    function normalizeHue(hue) {
        let next = hue % 1;
        return next < 0 ? next + 1 : next;
    }

    function parseHexColor(hex) {
        const cleaned = String(hex || "").replace("#", "").trim();
        if (cleaned.length !== 6) return null;

        const r = parseInt(cleaned.slice(0, 2), 16);
        const g = parseInt(cleaned.slice(2, 4), 16);
        const b = parseInt(cleaned.slice(4, 6), 16);
        if (isNaN(r) || isNaN(g) || isNaN(b)) return null;

        return { r: r / 255, g: g / 255, b: b / 255 };
    }

    function rgbToHsl(r, g, b) {
        const max = Math.max(r, g, b);
        const min = Math.min(r, g, b);
        const l = (max + min) / 2;
        const d = max - min;

        if (d === 0) return { h: 0, s: 0, l: l };

        const s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
        let h = 0;
        if (max === r) h = (g - b) / d + (g < b ? 6 : 0);
        else if (max === g) h = (b - r) / d + 2;
        else h = (r - g) / d + 4;

        return { h: h / 6, s: s, l: l };
    }

    function resetPalette() {
        background = defaultBackground;
        surface = defaultSurface;
        surfaceBright = defaultSurfaceBright;
        primary = defaultPrimary;
        secondary = defaultSecondary;
        foreground = defaultForeground;
        textDim = defaultTextDim;
        border = defaultBorder;
    }

    function applyAccentHex(hex) {
        const rgb = parseHexColor(hex);
        if (rgb === null) {
            resetPalette();
            return false;
        }

        const hsl = rgbToHsl(rgb.r, rgb.g, rgb.b);
        if (hsl.s < 0.08 || hsl.l < 0.04 || hsl.l > 0.96) {
            resetPalette();
            return false;
        }

        const hue = hsl.h;
        const accentS = clamp(Math.max(hsl.s * 1.35, 0.52), 0.52, 0.76);
        const accentL = clamp(hsl.l + (hsl.l < 0.45 ? 0.25 : 0.02), 0.58, 0.70);

        background = Qt.hsla(hue, 0.10, 0.035, 1);
        surface = Qt.hsla(hue, 0.16, 0.06, 1);
        surfaceBright = Qt.hsla(hue, 0.26, 0.155, 1);
        primary = Qt.hsla(hue, accentS, accentL, 1);
        secondary = Qt.hsla(normalizeHue(hue + 0.08), clamp(accentS * 0.86, 0.46, 0.66), clamp(accentL + 0.02, 0.60, 0.72), 1);
        foreground = Qt.hsla(hue, 0.22, 0.78, 1);
        textDim = Qt.hsla(hue, 0.22, 0.44, 1);
        border = primary;
        return true;
    }
    
    // Geometry
    readonly property int radius: 19
    readonly property int radiusLarge: 24
    readonly property int radiusMedium: 12
    readonly property int radiusSmall: 8
    readonly property int screenRadius: 20 // Dedicated for the 4 corners
    readonly property int animDuration: 250
    readonly property real frameThickness: 0.5

    // Spacings
    readonly property int spacingSmall: 8
    readonly property int spacingMedium: 10
    readonly property int spacingLarge: 15
    readonly property int spacingExtraLarge: 20

    // Bar specific
    readonly property int barTotalHeight: 40
    readonly property int barMargin: 10
    readonly property int sideCapsuleHeight: 35
    
    // Dynamic Island specific
    readonly property int islandWidth: 285
    readonly property int islandDashboardWidth: 940
    readonly property int islandDashboardHeight: 360
    readonly property int islandCompactHeight: 48
    readonly property int islandMenuWidth: 360
    readonly property int islandMenuHeight: 160
    readonly property int islandEarSize: 20
    
    // Launcher specific
    readonly property int launcherWidth: 440
    readonly property int launcherHeight: 383
    readonly property int launcherListHeight: 282
    readonly property int launcherItemHeight: 42
    readonly property int launcherSearchHeight: 40

    // Icon sizes
    readonly property int iconSize: 15
    readonly property int iconSizeTray: 20
    readonly property int iconSizeLauncher: 18

    // Typography
    readonly property string fontName: "Sans Serif"
    readonly property string iconFont: "Symbols Nerd Font Mono"
}
