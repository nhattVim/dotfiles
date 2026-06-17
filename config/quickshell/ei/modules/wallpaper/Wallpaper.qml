import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../services"
import "../../config"

PanelWindow {
    id: wallpaperWindow

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "ei:wallpaper"
    exclusionMode: ExclusionMode.Ignore

    mask: Region {
        // Click-through
    }

    color: ThemeService.background // Background fallback

    Item {
        anchors.fill: parent

        // Main static background image
        Image {
            id: bgImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            mipmap: true
            smooth: true
            opacity: 1
            source: WallpaperService.currentWallpaper ? "file://" + WallpaperService.currentWallpaper : ""
            
            sourceSize: Qt.size(parent.width > 0 ? parent.width : 1920, parent.height > 0 ? parent.height : 1080)
        }

        // Foreground buffer image for fading transition
        Image {
            id: fgImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            mipmap: true
            smooth: true
            opacity: 0
            
            sourceSize: Qt.size(parent.width > 0 ? parent.width : 1920, parent.height > 0 ? parent.height : 1080)

            onStatusChanged: {
                if (status === Image.Ready) {
                    opacity = 1;
                }
            }

            Behavior on opacity {
                NumberAnimation { duration: 800; easing.type: Easing.InOutQuad }
            }

            // Once the fade-in reaches 100%, copy back to bgImage and reset opacity
            onOpacityChanged: {
                if (opacity === 1) {
                    bgImage.source = fgImage.source;
                    opacity = 0;
                }
            }
        }

        Connections {
            target: WallpaperService
            ignoreUnknownSignals: true
            function onCurrentWallpaperChanged() {
                let nextSource = WallpaperService.currentWallpaper ? "file://" + WallpaperService.currentWallpaper : "";
                if (nextSource === "" || nextSource === bgImage.source || nextSource === fgImage.source) return;

                // Load new wallpaper in fgImage to trigger cross-fade
                fgImage.source = nextSource;
            }
        }
    }
}
