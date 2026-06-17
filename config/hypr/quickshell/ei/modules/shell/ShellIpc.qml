import QtQuick
import Quickshell
import Quickshell.Io
import "../../services"

Item {
    id: root

    IpcHandler {
        target: "ei"

        function launcher(): void {
            LauncherService.buildIndex();
            OverlayService.toggleOverlay("launcher");
        }

        function clipboard(): void {
            ClipboardService.refresh();
            OverlayService.toggleOverlay("clipboard");
        }

        function wallpaper(): void {
            WallpaperService.refresh();
            OverlayService.toggleOverlay("wallpaper");
        }

        function dashboard(): void {
            OverlayService.toggleDashboard();
        }

        function powerMenu(): void {
            OverlayService.togglePowerMenu();
        }

        function close(): void {
            OverlayService.closeAll();
        }

        function nextWallpaper(): void {
            WallpaperService.nextWallpaper();
        }

        function previousWallpaper(): void {
            WallpaperService.previousWallpaper();
        }

        function setWallpaper(path: string): void {
            WallpaperService.setWallpaperByPath(path);
        }

        function setWallpaperIndex(index: int): void {
            WallpaperService.setWallpaperByIndex(index);
        }

        function volumeUp(): void {
            AudioService.changeVolume(0.05);
        }

        function volumeDown(): void {
            AudioService.changeVolume(-0.05);
        }

        function micMute(): void {
            AudioService.toggleMicMute();
        }

        function brightnessUp(): void {
            BrightnessService.changeBrightness(0.05, null);
        }

        function brightnessDown(): void {
            BrightnessService.changeBrightness(-0.05, null);
        }

        function screenshot(): void {
            ScreenshotService.captureRegion();
        }

        function screenshotScreen(): void {
            ScreenshotService.captureScreen();
        }

        function screenrecord(): void {
            ScreenRecorderService.toggle();
        }

        function lock(): void {
            LockscreenService.lock();
        }
    }
}
