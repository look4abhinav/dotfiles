import Quickshell
import Quickshell.Io
import QtQml
import QtQuick

BarItem {
    id: root

    leftMargin: 28

    property var prevSamples: null
    property real total: 0
    property var cores: []
    property real load: 0

    readonly property real loadPercent: Math.min(100, load * 100 / Math.max(1, cores.length))

    content: Text {
        text: "\u{f2db} " + Math.round(root.total) + "%"
        color: Theme.stateColor(root.total, Theme.cpuWarn, Theme.cpuCrit)
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    onClicked: Quickshell.execDetached(["ghostty", "--title=btop", "-e", "btop"])

    Tooltip {
        target: root.hoverItem
        html: {
            const c = v => `<span style="color:${Theme.stateColor(v, Theme.cpuWarn, Theme.cpuCrit)}">${Math.round(v)}%</span>`;
            let out = `<b>CPU</b><br/>`;
            out += `Total: ${c(root.total)}<br/>`;
            out += `Load: <span style="color:${Theme.stateColor(root.loadPercent, Theme.cpuWarn, Theme.cpuCrit)}">${root.load.toFixed(2)}</span><br/>`;
            root.cores.forEach((v, i) => out += `Core ${i}: ${c(v)}<br/>`);
            return out;
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.sample()
    }

    FileView {
        id: statView
        path: "/proc/stat"
        blockLoading: true
    }

    FileView {
        id: loadView
        path: "/proc/loadavg"
        blockLoading: true
    }

    function sample(): void {
        statView.reload();
        loadView.reload();

        const current = {};
        for (const line of statView.text().split("\n")) {
            const fields = line.trim().split(/\s+/);
            const name = fields[0];
            if (name !== "cpu" && !/^cpu\d+$/.test(name))
                continue;
            const values = fields.slice(1, 9).map(Number);
            if (values.length < 5 || values.some(Number.isNaN))
                continue;
            let total = 0;
            for (const v of values)
                total += v;
            current[name] = [total, values[3] + values[4]];
        }

        const usage = {};
        if (prevSamples) {
            for (const name of Object.keys(current)) {
                const prev = prevSamples[name];
                if (!prev || current[name][0] <= prev[0]) {
                    usage[name] = 0;
                    continue;
                }
                const dTotal = current[name][0] - prev[0];
                const dIdle = Math.max(0, current[name][1] - prev[1]);
                usage[name] = Math.max(0, Math.min(100, (dTotal - dIdle) * 100 / dTotal));
            }
        }

        prevSamples = current;
        if (!("cpu" in usage))
            return;

        const cores = [];
        for (const name of Object.keys(usage).sort()) {
            if (name !== "cpu")
                cores.push(usage[name]);
        }
        root.cores = cores;
        root.total = usage["cpu"];

        const loadText = loadView.text().trim().split(/\s+/)[0];
        root.load = parseFloat(loadText) || 0;
    }

    Component.onCompleted: sample()
}
