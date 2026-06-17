pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var entries: []
    property bool loading: false
    property string error: ""

    function refresh() {
        if (listProcess.running) return;
        loading = true;
        error = "";
        listProcess.running = true;
    }

    function search(query) {
        const needle = (query || "").toLowerCase();
        if (needle === "") return entries;
        return entries.filter(entry => entry.preview.toLowerCase().indexOf(needle) !== -1 || entry.id.indexOf(needle) !== -1);
    }

    function copyEntry(line) {
        if (!line || copyProcess.running) return;
        copyProcess.command = ["sh", "-c", "printf '%s\\n' " + shellQuote(line) + " | cliphist decode | wl-copy"];
        copyProcess.running = true;
    }

    function deleteEntry(line) {
        if (!line || deleteProcess.running) return;
        deleteProcess.command = ["sh", "-c", "printf '%s\\n' " + shellQuote(line) + " | cliphist delete"];
        deleteProcess.running = true;
    }

    function deleteById(id) {
        const key = String(id);
        for (let i = 0; i < entries.length; i++) {
            if (entries[i].id === key) {
                deleteEntry(entries[i].line);
                return;
            }
        }
    }

    function clearAll() {
        if (wipeProcess.running) return;
        wipeProcess.running = true;
    }

    function parseList(text) {
        const rows = [];
        const lines = text.trim().length > 0 ? text.trim().split("\n") : [];

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const tab = line.indexOf("\t");
            if (tab <= 0) continue;

            const id = line.slice(0, tab);
            const preview = line.slice(tab + 1).replace(/\s+/g, " ").trim();
            rows.push({
                id: id,
                preview: preview.length > 0 ? preview : "(empty)",
                line: line
            });
        }

        entries = rows;
        loading = false;
    }

    function shellQuote(value) {
        return "'" + String(value).replace(/'/g, "'\\''") + "'";
    }

    Process {
        id: listProcess
        command: ["cliphist", "list"]
        running: false

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.parseList(text)
        }

        onExited: exitCode => {
            root.loading = false;
            if (exitCode !== 0) root.error = "Unable to read clipboard history";
        }
    }

    Process {
        id: copyProcess
        running: false
    }

    Process {
        id: deleteProcess
        running: false
        onExited: root.refresh()
    }

    Process {
        id: wipeProcess
        command: ["cliphist", "wipe"]
        running: false
        onExited: root.refresh()
    }
}
