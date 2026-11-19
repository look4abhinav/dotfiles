import Quickshell.Hyprland
import QtQuick

// Hyprland submap indicator: visible chip while a non-default submap
// (e.g. window move/resize) is active, hidden otherwise.
BarItem {
    id: root

    property string submap: "default"

    visible: submap !== "" && submap !== "default"

    Connections {
        target: Hyprland

        function onEvent(event) {
            if (event.name === "submap")
                root.submap = event.data;
        }
    }

    content: Text {
        text: root.submap
        color: Theme.warn
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
