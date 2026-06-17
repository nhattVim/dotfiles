pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Wayland

Singleton {
    id: root

    property bool enabled: true
    property int lockTimeoutSeconds: 300

    IdleMonitor {
        id: lockMonitor
        enabled: root.enabled && !CaffeineService.active && !LockscreenService.locked
        timeout: root.lockTimeoutSeconds
        respectInhibitors: true

        onIsIdleChanged: {
            if (isIdle) {
                LockscreenService.lock();
            }
        }
    }
}
