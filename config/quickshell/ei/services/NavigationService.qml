pragma Singleton
import QtQuick
import Quickshell

Singleton {
    function clampIndex(index, count) {
        if (count <= 0) return 0;
        return Math.max(0, Math.min(index, count - 1));
    }

    function nextIndex(index, count) {
        if (count <= 0) return 0;
        return (clampIndex(index, count) + 1) % count;
    }

    function previousIndex(index, count) {
        if (count <= 0) return 0;
        return (clampIndex(index, count) - 1 + count) % count;
    }

    function offsetIndex(index, count, offset) {
        if (count <= 0) return 0;
        return clampIndex(clampIndex(index, count) + offset, count);
    }
}
