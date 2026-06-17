pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Singleton {
    id: root

    property bool silent: false
    property var list: []
    property var popupList: []
    property int idOffset: 0
    property bool storeReady: false
    property int count: 0
    readonly property string cacheDir: Quickshell.env("HOME") + "/.cache/ei"
    readonly property string cachePath: cacheDir + "/notifications.json"

    FileView {
        id: notificationStore
        path: root.cachePath

        onLoaded: {
            root.storeReady = true;
            root.load();
        }
    }

    Process {
        id: ensureCacheDir
        command: ["sh", "-c", "mkdir -p '" + root.cacheDir + "' && [ -f '" + root.cachePath + "' ] || printf '[]' > '" + root.cachePath + "'"]
        running: true
        onExited: {
            notificationStore.reload();
        }
    }

    NotificationServer {
        id: server
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        bodySupported: true
        imageSupported: true
        keepOnReload: true
        persistenceSupported: true

        onNotification: notification => {
            if (!notification || (!notification.summary && !notification.body)) return;

            notification.tracked = true;

            const item = {
                id: notification.id + root.idOffset,
                appName: notification.appName || "Application",
                appIcon: notification.appIcon || "",
                image: liveImageSource(notification.image || ""),
                summary: notification.summary || "",
                body: stripMarkup(notification.body || ""),
                urgency: notification.urgency,
                time: Date.now(),
                source: notification
            };

            root.setList([item].concat(root.list).slice(0, 40));
            root.save();
            if (!root.silent) {
                root.showPopup(item);
            }
        }
    }

    onSilentChanged: {
        if (silent) {
            popupList = [];
        }
    }

    function toStoredItem(item) {
        return {
            id: item.id,
            appName: item.appName || "Application",
            appIcon: item.appIcon || "",
            image: persistentImageSource(item.image || ""),
            summary: item.summary || "",
            body: item.body || "",
            urgency: item.urgency,
            time: item.time || Date.now()
        };
    }

    function save() {
        if (!root.storeReady || notificationStore.path === "") return;
        const stored = root.list.map(toStoredItem).slice(0, 40);
        notificationStore.setText(JSON.stringify(stored, null, 2));
    }

    function setList(items) {
        root.list = items;
        root.count = items.length;
    }

    function showPopup(item) {
        popupList = [item].concat(popupList.filter(popup => popup.id !== item.id)).slice(0, 5);
    }

    function timeoutPopup(id) {
        popupList = popupList.filter(item => item.id !== id);
    }

    function load() {
        if (!root.storeReady || notificationStore.path === "") return;
        try {
            const text = notificationStore.text();
            if (!text || text.trim().length === 0) {
                root.idOffset = 0;
                return;
            }

            const stored = JSON.parse(text);
            if (!Array.isArray(stored)) {
                root.idOffset = 0;
                return;
            }

            const restored = stored.filter(item => item && (item.summary || item.body)).map(item => ({
                id: item.id,
                appName: item.appName || "Application",
                appIcon: item.appIcon || "",
                image: persistentImageSource(item.image || ""),
                summary: item.summary || "",
                body: item.body || "",
                urgency: item.urgency,
                time: item.time || Date.now(),
                source: null
            })).slice(0, 40);

            const seen = {};
            const merged = [];
            root.list.concat(restored).forEach(item => {
                const key = [
                    item.appName || "",
                    item.summary || "",
                    item.body || "",
                    item.time || 0
                ].join("\u001f");
                if (seen[key]) return;
                seen[key] = true;
                merged.push(item);
            });
            root.setList(merged.sort((a, b) => (b.time || 0) - (a.time || 0)).slice(0, 40));
            console.log("[NotificationService] restored notifications:", root.count);

            let maxId = 0;
            root.list.forEach(item => {
                if (item.id > maxId) maxId = item.id;
            });
            root.idOffset = maxId + 1;
            root.save();
        } catch (e) {
            console.log("[NotificationService] No saved notifications or invalid cache:", e);
            root.idOffset = 0;
        }
    }

    function liveImageSource(image) {
        return String(image || "");
    }

    function persistentImageSource(image) {
        const source = String(image || "");
        return source.indexOf("image://") === 0 ? "" : source;
    }

    function stripMarkup(text) {
        return text.replace(/<[^>]*>/g, "").replace(/&amp;/g, "&").replace(/&lt;/g, "<").replace(/&gt;/g, ">");
    }

    function formatTime(time) {
        const date = new Date(time);
        return date.toLocaleTimeString(Qt.locale(), "hh:mm");
    }

    function discard(id) {
        const found = root.list.find(item => item.id === id);
        if (found && found.source) found.source.dismiss();
        root.setList(root.list.filter(item => item.id !== id));
        root.timeoutPopup(id);
        root.save();
    }

    function clearAll() {
        root.list.forEach(item => {
            if (item.source) item.source.dismiss();
        });
        root.setList([]);
        root.popupList = [];
        root.save();
    }
}
