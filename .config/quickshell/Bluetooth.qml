import Quickshell
import Quickshell.Bluetooth
import QtQuick

BarItem {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool powered: adapter ? adapter.enabled : false
    readonly property var connectedDevices: adapter
        ? adapter.devices.values.filter(d => d.connected)
        : []

    content: Text {
        text: !root.powered ? "\u{f00b2}"
            : root.connectedDevices.length > 0 ? "\u{f00af}"
            : "\u{f294}"
        color: root.powered ? Theme.good : Theme.bad
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    onClicked: Quickshell.execDetached(["ghostty", "--title=bluetooth", "-e", "bluetui"])

    Tooltip {
        target: root.hoverItem
        html: {
            if (!root.adapter)
                return `Bluetooth: <span style="color:${Theme.bad}">No Controller</span>`;
            if (root.connectedDevices.length > 0) {
                let out = `Bluetooth: <span style="color:${Theme.good}">Connected</span>  ${root.adapter.name}`;
                out += `<br/><span style="color:${Theme.highlight}">${root.connectedDevices.length} device${root.connectedDevices.length > 1 ? "s" : ""}</span>`;
                for (const d of root.connectedDevices)
                    out += `<br/>${d.name}  ${d.address}`;
                return out;
            }
            if (root.powered)
                return `Bluetooth: <span style="color:${Theme.warn}">On</span>`;
            return `Bluetooth: <span style="color:${Theme.bad}">Off</span>`;
        }
    }
}
