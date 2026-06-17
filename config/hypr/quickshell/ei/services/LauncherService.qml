pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var applications: []

    function buildIndex() {
        let list = Array.from(DesktopEntries.applications.values);
        let filtered = [];
        for (let i = 0; i < list.length; i++) {
            let app = list[i];
            if (app && app.name && !app.noDisplay) {
                filtered.push({
                    name: app.name,
                    icon: app.icon || "application-x-executable",
                    comment: app.comment || "",
                    entry: app
                });
            }
        }
        filtered.sort((a, b) => a.name.localeCompare(b.name));
        applications = filtered;
    }

    Component.onCompleted: {
        buildIndex();
    }

    Connections {
        target: DesktopEntries.applications
        ignoreUnknownSignals: true
        function onValuesChanged() {
            buildIndex();
        }
    }

    function search(query) {
        if (!query || query.trim() === "") {
            return applications.slice(0, 50);
        }

        let q = query.toLowerCase().trim();
        let matches = [];

        for (let i = 0; i < applications.length; i++) {
            let app = applications[i];
            let score = 0;
            let name = app.name.toLowerCase();
            let comment = app.comment.toLowerCase();

            if (name === q) {
                score += 100;
            } else if (name.startsWith(q)) {
                score += 80;
            } else if (name.includes(q)) {
                score += 50;
            } else if (comment.includes(q)) {
                score += 20;
            }

            if (score > 0) {
                matches.push({
                    app: app,
                    score: score
                });
            }
        }

        matches.sort((a, b) => b.score - a.score);

        let result = [];
        for (let i = 0; i < Math.min(50, matches.length); i++) {
            result.push(matches[i].app);
        }
        return result;
    }

    function launch(app) {
        if (app && app.entry) {
            app.entry.execute();
        }
    }
}
