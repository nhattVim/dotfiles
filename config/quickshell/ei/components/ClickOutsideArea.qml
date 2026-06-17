import QtQuick

Item {
    id: root

    property color fillColor: "transparent"

    signal clicked()

    Rectangle {
        anchors.fill: parent
        color: root.fillColor
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
