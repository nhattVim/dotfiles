import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Services.Mpris
import "../../services"
import "../../config"
import "../../components"
import "components"

Item {
    id: root
    anchors.fill: parent
    clip: true

    signal requestClose()
    property var activePlayer: null
    property string currentPage: "dashboard"
    readonly property var pageOrder: ["dashboard", "weather", "performance"]

    readonly property bool hasPlayer: activePlayer !== null && activePlayer !== undefined
    readonly property bool isPlaying: activePlayer?.playbackState === MprisPlaybackState.Playing
    readonly property string wallpaperPath: WallpaperService.currentWallpaper ? "file://" + WallpaperService.currentWallpaper : ""
    readonly property string artworkSource: (activePlayer?.trackArtUrl ?? "") !== "" ? activePlayer.trackArtUrl : ""
    readonly property string mediaSource: artworkSource !== "" ? artworkSource : wallpaperPath

    onVisibleChanged: if (visible) forceActiveFocus()

    function currentPageIndex() {
        const index = pageOrder.indexOf(currentPage);
        return index >= 0 ? index : 0;
    }

    function selectPageOffset(offset) {
        const next = (currentPageIndex() + offset + pageOrder.length) % pageOrder.length;
        OverlayService.openDashboard(pageOrder[next]);
    }

    focus: visible

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            root.requestClose();
            event.accepted = true;
        } else if (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier)) {
            root.selectPageOffset(1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
            root.selectPageOffset(-1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Right) {
            root.selectPageOffset(1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Left) {
            root.selectPageOffset(-1);
            event.accepted = true;
        }
    }

    Timer {
        running: root.isPlaying && root.visible
        interval: 1000
        repeat: true
        onTriggered: root.activePlayer?.positionChanged()
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.ArrowCursor
        onPressed: mouse => mouse.accepted = true
    }

    StyledRect {
        anchors.fill: parent
        anchors.margins: 8
        radius: ThemeService.radiusLarge
        rectColor: ThemeService.background
        rectOpacity: 1.0
        borderOpacityValue: 0.0
        clip: true

        Item {
            id: dashboardGrid
            anchors.fill: parent
            anchors.margins: 8

            readonly property int gap: 8
            readonly property int railWidth: 64
            readonly property int mediaWidth: 216
            readonly property int widgetsWidth: 272
            readonly property int notificationWidth: 268
            readonly property int volumeWidth: 56

            DashboardRail {
                x: 0
                y: 0
                width: dashboardGrid.railWidth
                height: dashboardGrid.height
                currentPage: root.currentPage
                onPageRequested: page => OverlayService.openDashboard(page)
                onRequestClose: root.requestClose()
            }

            Item {
                id: pageArea
                x: dashboardGrid.railWidth + dashboardGrid.gap
                y: 0
                width: root.currentPage === "dashboard"
                    ? dashboardGrid.mediaWidth + dashboardGrid.widgetsWidth + dashboardGrid.notificationWidth + dashboardGrid.gap * 2
                    : dashboardGrid.width - dashboardGrid.railWidth - dashboardGrid.gap
                height: dashboardGrid.height

                Item {
                    anchors.fill: parent
                    visible: root.currentPage === "dashboard"

                    MediaDialCard {
                        x: 0
                        y: 0
                        width: dashboardGrid.mediaWidth
                        height: parent.height
                        activePlayer: root.activePlayer
                        mediaSource: root.mediaSource
                    }

                    ColumnLayout {
                        x: dashboardGrid.mediaWidth + dashboardGrid.gap
                        y: 0
                        width: dashboardGrid.widgetsWidth
                        height: parent.height
                        spacing: 8

                        ToggleStrip {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 56
                        }

                        CalendarPanel {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }

                    NotificationsPanel {
                        x: dashboardGrid.mediaWidth + dashboardGrid.widgetsWidth + dashboardGrid.gap * 2
                        y: 0
                        width: dashboardGrid.notificationWidth
                        height: parent.height
                    }
                }

                WeatherPage {
                    anchors.fill: parent
                    visible: root.currentPage === "weather"
                    backgroundSource: root.mediaSource
                }

                PerformancePage {
                    anchors.fill: parent
                    visible: root.currentPage === "performance"
                    backgroundSource: root.mediaSource
                }
            }

            VolumeRail {
                x: dashboardGrid.railWidth + dashboardGrid.mediaWidth + dashboardGrid.widgetsWidth + dashboardGrid.notificationWidth + dashboardGrid.gap * 4
                y: 0
                width: dashboardGrid.volumeWidth
                height: dashboardGrid.height
                visible: root.currentPage === "dashboard"
            }
        }
    }
}
