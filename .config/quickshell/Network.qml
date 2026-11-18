import Quickshell
import Quickshell.Networking
import QtQuick

BarItem {
    id: root

    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi) || null
    readonly property var wired: Networking.devices.values.find(d => d.type === DeviceType.Wired) || null
    readonly property var wifiNet: wifi && wifi.connected
        ? wifi.networks.values.find(n => n.connected)
        : null
    readonly property bool connected: (wifi && wifi.connected) || (wired && wired.connected)

    content: Text {
        text: root.wired && root.wired.connected ? "\u{f0201}"
            : root.connected ? "\u{f0928}"
            : "\u{f092e}"
        color: root.connected ? Theme.good : Theme.bad
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    onClicked: Quickshell.execDetached([
        Quickshell.env("HOME") + "/.config/hypr/scripts/wifi-menu.sh",
    ])

    Tooltip {
        target: root.hoverItem
        html: {
            if (root.wired && root.wired.connected)
                return `${root.wired.name}  <span style="color:${Theme.good}">Connected</span>`;
            if (root.wifiNet) {
                const signal = Math.round(root.wifiNet.signalStrength * 100);
                return `${root.wifiNet.name}  <span style="color:${Theme.good}">Connected</span>  `
                    + `Signal: <span style="color:${Theme.highlight}">${signal}%</span>`;
            }
            if (!Networking.wifiEnabled)
                return `<span style="color:${Theme.bad}">Wi-Fi Disabled</span>`;
            return `<span style="color:${Theme.bad}">Disconnected</span>`;
        }
    }
}
