import Quickshell
import Quickshell.Wayland
import QtQuick

// Hover tooltip shown below `target` (BarItem.hoverItem), centered on it.
// Rendered as its own layer-shell window so the compositor's blur rule applies.
PanelWindow {
    id: root

    required property Item target

    property string html: ""

    anchors {
        top: true
        left: true
    }
    margins.top: 44
    exclusiveZone: -1
    color: "transparent"
    visible: root.target !== null && root.target.containsMouse

    // mapToItem() results are not tracked by bindings, so reposition
    // imperatively each time the tooltip is shown.
    onVisibleChanged: {
        if (visible)
            margins.left = tooltipX();
    }

    WlrLayershell.namespace: "quickshell"
    WlrLayershell.layer: WlrLayer.Overlay

    implicitWidth: Math.max(140, tipText.implicitWidth + 20)
    implicitHeight: tipText.implicitHeight + 12

    function tooltipX(): int {
        const win = root.target ? root.target.Window.window : null;
        if (!win)
            return 4;
        const targetX = root.target.mapToItem(null, 0, 0).x;
        const center = targetX + root.target.width / 2 - root.implicitWidth / 2;
        return Math.max(4, Math.min(win.width - root.implicitWidth - 4, Math.round(center)));
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.tooltipBg
        border.color: Theme.pillBorder
        border.width: 1
        radius: 8

        Text {
            id: tipText
            anchors.centerIn: parent
            text: root.html
            textFormat: root.html !== "" ? Text.RichText : Text.AutoText
            color: Theme.white
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }
}
