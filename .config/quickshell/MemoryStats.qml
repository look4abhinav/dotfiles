import Quickshell
import Quickshell.Io
import QtQml
import QtQuick

BarItem {
    id: root

    rightMargin: 14

    property real ramPercent: 0
    property real swapPercent: 0
    property real ramUsedGib: 0
    property real ramTotalGib: 0
    property real swapUsedGib: 0
    property real swapTotalGib: 0

    content: Text {
        text: "\u{efc5} " + Math.round(root.ramPercent) + "%"
        color: Theme.stateColor(root.ramPercent, Theme.memWarn, Theme.memCrit)
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    onClicked: Quickshell.execDetached(["ghostty", "--title=htop", "-e", "htop"])

    Tooltip {
        target: root.hoverItem
        html: {
            const ramColor = Theme.stateColor(root.ramPercent, Theme.memWarn, Theme.memCrit);
            const swapColor = Theme.stateColor(root.swapPercent, Theme.swapWarn, Theme.swapCrit);
            let out = `<b>Memory</b><br/>`;
            out += `RAM: <span style="color:${ramColor}">${Math.round(root.ramPercent)}%</span> `;
            out += `(${root.ramUsedGib.toFixed(1)}G/${root.ramTotalGib.toFixed(1)}G used)<br/>`;
            if (root.swapTotalGib > 0) {
                out += `Swap: <span style="color:${swapColor}">${Math.round(root.swapPercent)}%</span> `;
                out += `(${root.swapUsedGib.toFixed(1)}G/${root.swapTotalGib.toFixed(1)}G used)`;
            } else {
                out += `Swap: <span style="color:${Theme.highlight}">Off</span>`;
            }
            return out;
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.sample()
    }

    FileView {
        id: memView
        path: "/proc/meminfo"
        blockLoading: true
    }

    function sample(): void {
        memView.reload();
        const values = {};
        for (const line of memView.text().split("\n")) {
            const parts = line.split(":");
            if (parts.length < 2)
                continue;
            const fields = parts[1].trim().split(/\s+/);
            if (fields.length)
                values[parts[0]] = parseInt(fields[0], 10);
        }

        const total = values["MemTotal"] || 0;
        const available = values["MemAvailable"] || 0;
        const used = Math.max(0, total - available);
        const swapTotal = values["SwapTotal"] || 0;
        const swapFree = values["SwapFree"] || 0;
        const swapUsed = Math.max(0, swapTotal - swapFree);

        const gib = kib => kib / 1048576;
        root.ramPercent = total > 0 ? Math.min(100, used * 100 / total) : 0;
        root.ramUsedGib = gib(used);
        root.ramTotalGib = gib(total);
        root.swapPercent = swapTotal > 0 ? Math.min(100, swapUsed * 100 / swapTotal) : 0;
        root.swapUsedGib = gib(swapUsed);
        root.swapTotalGib = gib(swapTotal);
    }

    Component.onCompleted: sample()
}
