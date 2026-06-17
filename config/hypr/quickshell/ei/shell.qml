//@ pragma ShellId ei
import Quickshell
import QtQuick
import "modules/shell"
import "modules/launcher"
import "modules/clipboard"
import "modules/osd"
import "modules/frame"
import "modules/wallpaper"
import "modules/notifications"
import "modules/tools"
import "services"

ShellRoot {
    id: shellRoot

    ShellIpc {}

    readonly property bool idleServiceLoaded: IdleService.enabled
    readonly property bool wallpaperThemeLoaded: WallpaperThemeService.enabled
    readonly property var activeScreen: MonitorService.focusedScreen || Quickshell.screens[0]

    // Instantiates the floating Bar on all connected monitors
    Variants {
        model: Quickshell.screens

        Item {
            id: screenBarContainer
            required property var modelData

            ReservationWindow {
                screen: screenBarContainer.modelData
            }

            ShellPanel {
                screen: screenBarContainer.modelData
            }
        }
    }

    // Instantiates the Screen Frame on all connected monitors
    Variants {
        model: Quickshell.screens

        ScreenFrame {
            required property var modelData
            targetScreen: modelData
        }
    }

    // Instantiates the OSD on all connected monitors
    Variants {
        model: Quickshell.screens

        OSD {
            required property var modelData
            targetScreen: modelData
        }
    }

    // Instantiates screenshot region overlays on all connected monitors
    Variants {
        model: Quickshell.screens

        ScreenshotOverlay {
            required property var modelData
            targetScreen: modelData
        }
    }

    // Instantiates screen recording overlays on all connected monitors
    Variants {
        model: Quickshell.screens

        RecordOverlay {
            required property var modelData
            targetScreen: modelData
        }
    }

    // Shows single-instance overlays on the currently focused monitor
    RecordIndicator {
        targetScreen: shellRoot.activeScreen
    }

    NotificationPopup {
        targetScreen: shellRoot.activeScreen
    }

    Launcher {
        screen: shellRoot.activeScreen
    }

    Clipboard {
        screen: shellRoot.activeScreen
    }

    WallpaperPicker {
        screen: shellRoot.activeScreen
    }

}
