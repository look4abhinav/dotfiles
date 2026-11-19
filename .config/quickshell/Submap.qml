import Quickshell.Hyprland
import QtQuick

// Hyprland submap indicator: visible chip while a non-default submap
// (e.g. window move/resize) is active, hidden otherwise. State syncs
// from events only: a bar restart during an active submap stays hidden
// until the next submap event (Hyprland exposes no query API).
BarItem {
    id: root

    property string submap: "default"

    visible: submap !== "" && submap !== "default"

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "submap")
                root.submap = event.data;
        }
    }

    content: Text {
        text: Theme.escapeHtml(root.submap)
        color: Theme.warn
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
