import Quickshell
import Quickshell.Wayland
import QtQuick

BarItem {
    id: root

    required property IdleInhibitor inhibitor

    rightMargin: 14

    content: Text {
        text: root.inhibitor.enabled ? "\u{f0208}" : "\u{f0209}"
        color: root.inhibitor.enabled ? Theme.good : Theme.highlight
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    onClicked: root.inhibitor.enabled = !root.inhibitor.enabled

    Tooltip {
        target: root.hoverItem
        html: root.inhibitor.enabled
            ? `<b>Awake: <span style="color:${Theme.good}">Active</span></b>`
            : `<b>Awake: <span style="color:${Theme.highlight}">Inactive</span></b>`
    }
}
