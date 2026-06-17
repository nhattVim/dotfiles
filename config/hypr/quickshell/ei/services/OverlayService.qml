pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "."

Singleton {
    id: root

    property string activeOverlay: ""
    property string islandState: "windowTitle"
    property string dashboardPage: "dashboard"
    property string restoreWindowAddress: ""

    readonly property bool overlayOpen: activeOverlay !== ""
    readonly property bool islandOpen: islandState !== "windowTitle"
    readonly property bool focusSurfaceOpen: overlayOpen || islandOpen

    function normalizeOverlay(name) {
        if (name === "launcher" || name === "clipboard" || name === "wallpaper") return name;
        return "";
    }

    function normalizeDashboardPage(page) {
        if (page === "weather" || page === "performance") return page;
        return "dashboard";
    }

    function rememberFocus() {
        if (focusSurfaceOpen && restoreWindowAddress !== "") return;
        if (WindowService.activeWindowAddress !== "") {
            restoreWindowAddress = WindowService.activeWindowAddress;
        }
    }

    function restoreFocus() {
        if (focusSurfaceOpen || restoreWindowAddress === "" || restoreFocusProcess.running) return;
        restoreFocusProcess.command = ["hyprctl", "dispatch", "focuswindow", "address:" + restoreWindowAddress];
        restoreFocusProcess.running = true;
    }

    function openOverlay(name) {
        const overlay = normalizeOverlay(name);
        if (overlay === "") return;
        if (activeOverlay === overlay && islandState === "windowTitle") return;

        rememberFocus();
        islandState = "windowTitle";
        activeOverlay = overlay;
    }

    function closeOverlay(name) {
        const overlay = normalizeOverlay(name);
        if (overlay !== "" && activeOverlay !== overlay) return;
        if (activeOverlay === "") return;

        activeOverlay = "";
        Qt.callLater(restoreFocus);
    }

    function toggleOverlay(name) {
        const overlay = normalizeOverlay(name);
        if (overlay === "") return;

        if (activeOverlay === overlay) {
            closeOverlay(overlay);
        } else {
            openOverlay(overlay);
        }
    }

    function openDashboard(page) {
        rememberFocus();
        activeOverlay = "";
        dashboardPage = normalizeDashboardPage(page);
        islandState = "media";
    }

    function toggleDashboard() {
        if (islandState === "media") {
            closeIsland();
            return;
        }

        openDashboard(dashboardPage);
    }

    function openIsland(state) {
        if (state === "media") {
            openDashboard(dashboardPage);
            return;
        }
        if (state !== "powerMenu" && state !== "batteryMenu") return;

        rememberFocus();
        activeOverlay = "";
        islandState = state;
    }

    function toggleIsland(state) {
        if (islandState === state) {
            closeIsland();
        } else {
            openIsland(state);
        }
    }

    function setIslandState(state) {
        if (state === "windowTitle" || state === "") {
            closeIsland();
        } else if (state === "media") {
            openDashboard(dashboardPage);
        } else {
            openIsland(state);
        }
    }

    function togglePowerMenu() {
        toggleIsland("powerMenu");
    }

    function closeIsland(restoreFocusAfter) {
        if (islandState === "windowTitle") return;
        islandState = "windowTitle";
        if (restoreFocusAfter !== false) Qt.callLater(restoreFocus);
    }

    function closeAll() {
        const hadFocusSurface = activeOverlay !== "" || islandState !== "windowTitle";
        activeOverlay = "";
        islandState = "windowTitle";
        if (hadFocusSurface) Qt.callLater(restoreFocus);
    }

    Process {
        id: restoreFocusProcess
        running: false
        onExited: root.restoreWindowAddress = ""
    }
}
