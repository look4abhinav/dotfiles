import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

// Volume group: pill plus a slider that expands on hover.
Item {
    id: root

    implicitHeight: 36
    implicitWidth: pill.width + slider.implicitWidth

    readonly property var allSinks: Pipewire.nodes.values.filter(n =>
        n.isSink && !n.isStream && n.audio && !/easy\s*effects/i.test(n.description))
    readonly property var sink: {
        const def = Pipewire.defaultAudioSink;
        if (def && /easy\s*effects/i.test(def.description))
            return root.allSinks[0] || def;
        return def;
    }
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false
    readonly property real volume: sink && sink.audio ? sink.audio.volume : 0

    PwObjectTracker {
        objects: Pipewire.nodes.values.filter(n => n.isSink)
    }

    HoverHandler {
        id: hover
    }

    BarItem {
        id: pill
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        content: Row {
            spacing: 6

            Text {
                text: root.muted ? "\u{f026}" : root.volume > 0.5 ? "\u{f028}" : "\u{f027}"
                color: root.muted ? Theme.bad : Theme.highlight
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }

            Text {
                visible: !root.muted
                text: Math.round(root.volume * 100) + "%"
                color: root.muted ? Theme.bad : Theme.highlight
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }
        }

        onClicked: Quickshell.execDetached(["pavucontrol"])

        onWheeled: delta => {
            if (!root.sink || !root.sink.audio)
                return;
            const step = delta > 0 ? 0.05 : -0.05;
            root.sink.audio.volume = Math.min(1, Math.max(0, root.volume + step));
        }

        Tooltip {
            target: pill.hoverItem
            html: `Volume: <span style="color:${Theme.highlight}">${Math.round(root.volume * 100)}%</span>  ${root.sink ? Theme.escapeHtml(root.sink.description) : ""}`
        }
    }

    Slider {
        id: slider
        anchors.left: pill.right
        anchors.verticalCenter: parent.verticalCenter
        expanded: hover.hovered
        initial: root.volume
        onUserChanged: value => {
            if (root.sink && root.sink.audio)
                root.sink.audio.volume = value;
        }
    }
}
