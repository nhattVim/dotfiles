import QtQuick
import Quickshell
import "../../../services"
import "../../../config"
import "../../../components"

Row {
    id: root
    spacing: ThemeService.spacingMedium
    width: implicitWidth
    height: implicitHeight
    
    property int pillHeight: ThemeService.sideCapsuleHeight

    // Launcher Pill
    PillSurface {
        id: launcherPill
        height: root.pillHeight
        width: height
        onClicked: {
            LauncherService.buildIndex();
            OverlayService.toggleOverlay("launcher");
        }

        Text {
            anchors.centerIn: parent
            text: ""
            font.family: ThemeService.iconFont
            font.pixelSize: 18
            color: ThemeService.primary
        }
    }

    // Workspaces Pill
    StyledRect {
        id: workspacesPill
        height: root.pillHeight
        width: workspacesTrack.width + (workspacesTrack.padding * 2)
        radius: height / 2
        rectColor: ThemeService.background
        rectOpacity: ThemeService.bgOpacity
        borderOpacityValue: 0.0
        clip: true

        readonly property int workspaceCount: 10
        readonly property int workspaceGroup: Math.floor((WorkspaceService.activeWorkspaceId - 1) / workspaceCount)
        readonly property int workspaceButtonSize: root.pillHeight - 8
        readonly property int activeIndex: Math.max(0, Math.min(workspaceCount - 1, (WorkspaceService.activeWorkspaceId - 1) % workspaceCount))
        readonly property string occupiedKey: WorkspaceService.occupiedWorkspaceIds.join(",")
        readonly property var occupiedRanges: {
            occupiedKey;
            workspaceGroup;
            return buildOccupiedRanges();
        }

        function workspaceId(index) {
            return workspaceGroup * workspaceCount + index + 1;
        }

        function buildOccupiedRanges() {
            let ranges = [];
            let start = -1;

            for (let i = 0; i < workspaceCount; i++) {
                let occupied = WorkspaceService.isWorkspaceOccupied(workspaceId(i));
                if (occupied && start === -1) {
                    start = i;
                } else if (!occupied && start !== -1) {
                    ranges.push({ start: start, end: i - 1 });
                    start = -1;
                }
            }

            if (start !== -1) {
                ranges.push({ start: start, end: workspaceCount - 1 });
            }

            return ranges;
        }

        function dispatchWorkspace(target) {
            WorkspaceService.focusWorkspace(target);
        }

        function workspaceAtPosition(xPos) {
            let localX = Math.max(0, Math.min(workspacesTrack.width - 1, xPos - workspacesTrack.x));
            let index = Math.floor(localX / workspaceButtonSize);
            return workspaceId(Math.max(0, Math.min(workspaceCount - 1, index)));
        }

        Item {
            id: workspacesTrack
            anchors.centerIn: parent
            property int padding: 4
            width: workspacesPill.workspaceButtonSize * workspacesPill.workspaceCount
            height: workspacesPill.workspaceButtonSize

            Repeater {
                model: workspacesPill.occupiedRanges

                Rectangle {
                    required property var modelData
                    required property int index
                    x: modelData.start * workspacesPill.workspaceButtonSize
                    y: 0
                    width: (modelData.end - modelData.start + 1) * workspacesPill.workspaceButtonSize
                    height: workspacesPill.workspaceButtonSize
                    radius: Math.max(0, workspacesPill.radius - workspacesTrack.padding)
                    color: ThemeService.surfaceBright
                    opacity: 0.62
                    Behavior on x { NumberAnimation { duration: ThemeService.animDuration; easing.type: Easing.OutQuad } }
                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuint } }
                }
            }

            Rectangle {
                id: activeWorkspaceHighlight
                property real idx1: workspacesPill.activeIndex
                property real idx2: workspacesPill.activeIndex
                readonly property int margin: 4

                x: Math.min(idx1, idx2) * workspacesPill.workspaceButtonSize + margin
                y: margin
                width: Math.abs(idx1 - idx2) * workspacesPill.workspaceButtonSize + workspacesPill.workspaceButtonSize - margin * 2
                height: workspacesPill.workspaceButtonSize - margin * 2
                radius: WorkspaceService.isWorkspaceOccupied(WorkspaceService.activeWorkspaceId) ? Math.max(0, workspacesPill.radius - workspacesTrack.padding - margin) : height / 2
                color: ThemeService.primary
                opacity: 0.95

                Behavior on idx1 { NumberAnimation { duration: ThemeService.animDuration / 3; easing.type: Easing.OutSine } }
                Behavior on idx2 { NumberAnimation { duration: ThemeService.animDuration; easing.type: Easing.OutSine } }
                Behavior on width { NumberAnimation { duration: ThemeService.animDuration; easing.type: Easing.OutSine } }
                Behavior on radius { NumberAnimation { duration: ThemeService.animDuration; easing.type: Easing.OutQuad } }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: event => workspacesPill.dispatchWorkspace(workspacesPill.workspaceAtPosition(event.x + workspacesTrack.x))
            }

            Repeater {
                model: workspacesPill.workspaceCount

                Item {
                    required property int index
                    readonly property int value: workspacesPill.workspaceId(index)
                    readonly property bool active: value === WorkspaceService.activeWorkspaceId
                    readonly property bool occupied: {
                        workspacesPill.occupiedKey;
                        return WorkspaceService.isWorkspaceOccupied(value);
                    }

                    x: index * workspacesPill.workspaceButtonSize
                    y: 0
                    width: workspacesPill.workspaceButtonSize
                    height: workspacesPill.workspaceButtonSize

                    Text {
                        anchors.centerIn: parent
                        text: parent.value
                        font.family: ThemeService.fontName
                        font.pixelSize: text.length > 1 ? 10 : 11
                        font.weight: parent.active || parent.occupied ? Font.DemiBold : Font.Medium
                        color: parent.active ? ThemeService.background : (parent.occupied ? ThemeService.textBright : ThemeService.textDim)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: event => {
                let delta = event.angleDelta.y > 0 ? -1 : 1;
                WorkspaceService.focusWorkspace(delta > 0 ? "r+1" : "r-1");
            }
        }
    }
}
