pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string activeProfile: ""

    function refresh() {
        if (!getProfile.running) {
            getProfile.running = true;
        }
    }

    function setProfile(profile) {
        if (!profile || setProfileProcess.running) return;
        setProfileProcess.command = ["powerprofilesctl", "set", profile];
        setProfileProcess.running = true;
    }

    Process {
        id: getProfile
        command: ["powerprofilesctl", "get"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root.activeProfile = text.trim()
        }
    }

    Process {
        id: setProfileProcess
        running: false
        onExited: root.refresh()
    }
}
