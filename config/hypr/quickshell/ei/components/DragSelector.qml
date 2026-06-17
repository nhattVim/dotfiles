import QtQuick

MouseArea {
    id: root

    property bool screenMode: false
    property real startX: 0
    property real startY: 0
    property real currentX: 0
    property real currentY: 0
    property bool selecting: false

    signal screenClicked()
    signal regionSelected(real localX, real localY, real localWidth, real localHeight)

    cursorShape: screenMode ? Qt.PointingHandCursor : Qt.CrossCursor
    hoverEnabled: true

    function reset() {
        startX = 0;
        startY = 0;
        currentX = 0;
        currentY = 0;
        selecting = false;
    }

    onPressed: mouse => {
        if (screenMode) {
            screenClicked();
            return;
        }

        startX = mouse.x;
        startY = mouse.y;
        currentX = mouse.x;
        currentY = mouse.y;
        selecting = true;
    }

    onPositionChanged: mouse => {
        if (!selecting) return;
        currentX = Math.max(0, Math.min(width, mouse.x));
        currentY = Math.max(0, Math.min(height, mouse.y));
    }

    onReleased: {
        if (!selecting) return;
        selecting = false;

        regionSelected(
            Math.round(Math.min(startX, currentX)),
            Math.round(Math.min(startY, currentY)),
            Math.round(Math.abs(currentX - startX)),
            Math.round(Math.abs(currentY - startY))
        );
        reset();
    }
}
