pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property string time: ""
    property string date: ""

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            let d = new Date();
            let hh = String(d.getHours()).padStart(2, '0');
            let mm = String(d.getMinutes()).padStart(2, '0');
            root.time = hh + ":" + mm;

            let day = String(d.getDate()).padStart(2, '0');
            let month = String(d.getMonth() + 1).padStart(2, '0');
            let year = d.getFullYear();
            root.date = day + "/" + month + "/" + year;
        }
    }
}
