import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../services"
import "../../config"
import "../../components"

PanelWindow {
    id: root

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "ei:wallpaper-picker"
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0

    color: "transparent"
    visible: OverlayService.activeOverlay === "wallpaper"

    property string searchText: ""
    property var results: filterWallpapers(searchText)
    property int selectedIndex: 0
    readonly property string selectedPath: selectedIndex >= 0 && selectedIndex < results.length ? results[selectedIndex] : ""
    readonly property bool hasWallpapers: WallpaperService.wallpaperPaths.length > 0

    onVisibleChanged: {
        if (visible) {
            WallpaperService.refresh();
            searchText = "";
            searchInput.text = "";
            selectedIndex = NavigationService.clampIndex(WallpaperService.currentIndex, results.length);
            searchInput.forceInputFocus();
        }
    }

    ClickOutsideArea {
        anchors.fill: parent
        fillColor: ThemeService.scrimColor
        onClicked: OverlayService.closeOverlay("wallpaper")
    }

    OverlayCard {
        id: pickerCard
        width: Math.min(980, root.width - 64)
        height: Math.min(580, root.height - 64)
        anchors.centerIn: parent
        radius: 22
        rectColor: ThemeService.background
        rectOpacity: 0.96
        borderOpacityValue: 0.24

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Row {
                width: parent.width
                height: 42
                spacing: 12

                Rectangle {
                    width: 42
                    height: 42
                    radius: 14
                    color: Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.18)
                    border.width: 1
                    border.color: Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.24)

                    Text {
                        anchors.centerIn: parent
                        text: "󰸉"
                        color: ThemeService.primary
                        font.family: ThemeService.iconFont
                        font.pixelSize: 20
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 184
                    spacing: 2

                    Text {
                        width: parent.width
                        text: "Wallpapers"
                        color: ThemeService.textBright
                        font.family: ThemeService.fontName
                        font.pixelSize: 17
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: root.results.length + " shown / " + WallpaperService.wallpaperPaths.length
                        color: ThemeService.textDim
                        font.family: ThemeService.fontName
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                }

                SearchField {
                    id: searchInput
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 184 - 42 - 24
                    height: 40
                    radius: 14
                    fieldColor: ThemeService.surface
                    focusedBorderColor: Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.66)
                    idleBorderColor: Qt.rgba(ThemeService.border.r, ThemeService.border.g, ThemeService.border.b, 0.12)
                    horizontalPadding: 14
                    fieldSpacing: 10
                    placeholder: "Search name or path..."

                    onTextChanged: {
                        root.searchText = text;
                        root.selectedIndex = 0;
                    }

                    onKeyPressed: event => {
                        const count = wallpaperGrid.count;
                        const columns = Math.max(1, Math.floor(wallpaperGrid.width / wallpaperGrid.cellWidth));

                        if (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier)) {
                            root.selectNext();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                            root.selectPrevious();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Right) {
                            root.selectNext();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Left) {
                            root.selectPrevious();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Down) {
                            root.selectedIndex = NavigationService.offsetIndex(root.selectedIndex, count, columns);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up) {
                            root.selectedIndex = NavigationService.offsetIndex(root.selectedIndex, count, -columns);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                            root.applySelected();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Escape) {
                            OverlayService.closeOverlay("wallpaper");
                            event.accepted = true;
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(ThemeService.border.r, ThemeService.border.g, ThemeService.border.b, 0.14)
            }

            Row {
                width: parent.width
                height: parent.height - 42 - 1 - 24
                spacing: 14

                Rectangle {
                    id: previewPanel
                    width: 300
                    height: parent.height
                    radius: 20
                    color: Qt.rgba(ThemeService.surface.r, ThemeService.surface.g, ThemeService.surface.b, 0.96)
                    border.width: 1
                    border.color: Qt.rgba(ThemeService.border.r, ThemeService.border.g, ThemeService.border.b, 0.18)
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: root.selectedPath !== "" ? "file://" + root.selectedPath : ""
                        fillMode: Image.PreserveAspectCrop
                        sourceSize.width: 900
                        sourceSize.height: 1200
                        asynchronous: true
                        cache: true
                        visible: root.selectedPath !== ""
                    }

                    Rectangle {
                        anchors.fill: parent
                        visible: root.selectedPath !== ""
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: Qt.rgba(ThemeService.background.r, ThemeService.background.g, ThemeService.background.b, 0.04) }
                            GradientStop { position: 0.55; color: Qt.rgba(ThemeService.background.r, ThemeService.background.g, ThemeService.background.b, 0.08) }
                            GradientStop { position: 1.0; color: Qt.rgba(ThemeService.background.r, ThemeService.background.g, ThemeService.background.b, 0.82) }
                        }
                    }

                    Column {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 14
                        spacing: 10

                        Text {
                            width: parent.width
                            text: root.selectedPath !== "" ? root.fileName(root.selectedPath) : "No wallpaper selected"
                            color: ThemeService.textBright
                            font.family: ThemeService.fontName
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: root.selectedPath !== "" ? root.selectedPath : WallpaperService.wallpaperDir
                            color: ThemeService.foreground
                            opacity: 0.72
                            font.family: ThemeService.fontName
                            font.pixelSize: 11
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 10
                        visible: root.selectedPath === ""

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "󰋩"
                            color: ThemeService.textDim
                            font.family: ThemeService.iconFont
                            font.pixelSize: 38
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.hasWallpapers ? "No match" : "No wallpapers found"
                            color: ThemeService.textDim
                            font.family: ThemeService.fontName
                            font.pixelSize: 13
                        }
                    }
                }

                Item {
                    width: parent.width - previewPanel.width - parent.spacing
                    height: parent.height

                    Rectangle {
                        anchors.fill: parent
                        radius: 18
                        color: Qt.rgba(ThemeService.surface.r, ThemeService.surface.g, ThemeService.surface.b, 0.28)
                        border.width: 1
                        border.color: Qt.rgba(ThemeService.border.r, ThemeService.border.g, ThemeService.border.b, 0.06)
                    }

                    GridView {
                        id: wallpaperGrid
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: root.results
                        currentIndex: root.selectedIndex
                        boundsBehavior: Flickable.StopAtBounds
                        cellWidth: Math.max(132, Math.floor(width / 4))
                        cellHeight: 96

                        delegate: Item {
                            id: wallpaperItem
                            required property int index
                            required property string modelData
                            readonly property bool selected: index === root.selectedIndex
                            readonly property bool current: modelData === WallpaperService.currentWallpaper

                            width: wallpaperGrid.cellWidth
                            height: wallpaperGrid.cellHeight

                            Rectangle {
                                id: tile
                                anchors.fill: parent
                                anchors.margins: 5
                                radius: 15
                                color: Qt.rgba(ThemeService.surface.r, ThemeService.surface.g, ThemeService.surface.b, 0.92)
                                clip: true
                                scale: wallpaperItem.selected ? 1.0 : (itemMouse.containsMouse ? 0.995 : 0.976)

                                border.width: wallpaperItem.selected || wallpaperItem.current ? 2 : 1
                                border.color: wallpaperItem.selected
                                    ? ThemeService.primary
                                    : wallpaperItem.current
                                        ? Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.52)
                                        : Qt.rgba(ThemeService.border.r, ThemeService.border.g, ThemeService.border.b, itemMouse.containsMouse ? 0.20 : 0.08)

                                Behavior on border.color {
                                    ColorAnimation { duration: 120 }
                                }

                                Behavior on scale {
                                    NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                                }

                                Image {
                                    anchors.fill: parent
                                    source: "file://" + modelData
                                    fillMode: Image.PreserveAspectCrop
                                    sourceSize.width: 260
                                    sourceSize.height: 160
                                    asynchronous: true
                                    cache: true
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    color: itemMouse.containsMouse || wallpaperItem.selected
                                        ? Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, wallpaperItem.selected ? 0.18 : 0.10)
                                        : "transparent"

                                    Behavior on color {
                                        ColorAnimation { duration: 120 }
                                    }
                                }

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    height: 42
                                    visible: itemMouse.containsMouse || wallpaperItem.selected || wallpaperItem.current
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: Qt.rgba(ThemeService.background.r, ThemeService.background.g, ThemeService.background.b, 0.54) }
                                        GradientStop { position: 1.0; color: Qt.rgba(ThemeService.background.r, ThemeService.background.g, ThemeService.background.b, 0.0) }
                                    }
                                }

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    height: 28
                                    color: Qt.rgba(ThemeService.background.r, ThemeService.background.g, ThemeService.background.b, 0.72)
                                    visible: itemMouse.containsMouse || wallpaperItem.selected || wallpaperItem.current

                                    Text {
                                        anchors.left: parent.left
                                        anchors.right: currentMark.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.leftMargin: 9
                                        anchors.rightMargin: 6
                                        text: root.fileName(modelData)
                                        color: ThemeService.textBright
                                        font.family: ThemeService.fontName
                                        font.pixelSize: 10
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        id: currentMark
                                        anchors.right: parent.right
                                        anchors.rightMargin: 8
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: wallpaperItem.current ? 18 : 0
                                        text: "󰄬"
                                        color: ThemeService.primary
                                        font.family: ThemeService.iconFont
                                        font.pixelSize: 13
                                        visible: wallpaperItem.current
                                    }
                                }

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.margins: 8
                                    width: 24
                                    height: 22
                                    radius: 8
                                    visible: wallpaperItem.selected
                                    color: Qt.rgba(ThemeService.background.r, ThemeService.background.g, ThemeService.background.b, 0.72)
                                    border.width: 1
                                    border.color: ThemeService.primary

                                    Text {
                                        anchors.centerIn: parent
                                        text: index + 1
                                        color: ThemeService.primary
                                        font.family: ThemeService.fontName
                                        font.pixelSize: 10
                                        font.weight: Font.Bold
                                    }
                                }

                                MouseArea {
                                    id: itemMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: root.selectedIndex = index
                                    onClicked: {
                                        WallpaperService.setWallpaperByPath(modelData);
                                        OverlayService.closeOverlay("wallpaper");
                                    }
                                }
                            }
                        }

                        onCurrentIndexChanged: positionViewAtIndex(currentIndex, GridView.Contain)
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 18
                        color: Qt.rgba(ThemeService.surface.r, ThemeService.surface.g, ThemeService.surface.b, 0.42)
                        border.width: 1
                        border.color: Qt.rgba(ThemeService.border.r, ThemeService.border.g, ThemeService.border.b, 0.12)
                        visible: wallpaperGrid.count === 0

                        Column {
                            anchors.centerIn: parent
                            spacing: 10

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "󰋩"
                                color: ThemeService.textDim
                                font.family: ThemeService.iconFont
                                font.pixelSize: 34
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: root.hasWallpapers ? "No results" : "No wallpapers found"
                                color: ThemeService.textDim
                                font.family: ThemeService.fontName
                                font.pixelSize: 13
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 360
                                text: WallpaperService.wallpaperDir
                                color: ThemeService.textDim
                                font.family: ThemeService.fontName
                                font.pixelSize: 10
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideMiddle
                            }
                        }
                    }
                }
            }

            Row {
                width: parent.width
                height: 16
                spacing: 16

                Text {
                    text: "Arrow keys navigate"
                    color: ThemeService.textDim
                    font.family: ThemeService.fontName
                    font.pixelSize: 10
                }

                Text {
                    text: "Enter apply"
                    color: ThemeService.textDim
                    font.family: ThemeService.fontName
                    font.pixelSize: 10
                }

                Text {
                    text: "Esc close"
                    color: ThemeService.textDim
                    font.family: ThemeService.fontName
                    font.pixelSize: 10
                }

                Text {
                    width: parent.width - 260
                    text: WallpaperService.wallpaperDir
                    color: ThemeService.textDim
                    font.family: ThemeService.fontName
                    font.pixelSize: 10
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideMiddle
                }
            }
        }
    }

    function filterWallpapers(query) {
        const needle = (query || "").toLowerCase();
        if (needle === "") return WallpaperService.wallpaperPaths;
        return WallpaperService.wallpaperPaths.filter(path => fileName(path).toLowerCase().indexOf(needle) !== -1 || path.toLowerCase().indexOf(needle) !== -1);
    }

    function fileName(path) {
        const parts = String(path).split("/");
        return parts.length > 0 ? parts[parts.length - 1] : String(path);
    }

    function applySelected() {
        if (selectedIndex >= 0 && selectedIndex < results.length) {
            WallpaperService.setWallpaperByPath(results[selectedIndex]);
            OverlayService.closeOverlay("wallpaper");
        }
    }

    function selectNext() {
        selectedIndex = NavigationService.nextIndex(selectedIndex, results.length);
    }

    function selectPrevious() {
        selectedIndex = NavigationService.previousIndex(selectedIndex, results.length);
    }
}
