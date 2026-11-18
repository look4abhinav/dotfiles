import Quickshell
import Quickshell.Hyprland
import QtQuick

BarItem {
    id: root

    readonly property var icons: ({
        1: "\u{f0239}",
        2: "\u{f120}",
        3: "\u{f0a1e}",
        4: "\u{f024b}",
        5: "\u{f03d1}",
    })

    // Persistent 1-5 plus any extra live workspaces on this monitor.
    readonly property var entries: {
        const mon = Hyprland.focusedMonitor;
        const all = Hyprland.workspaces.values;
        const live = mon ? all.filter(w => !w.monitor || w.monitor === mon) : all;
        const out = [];
        const seen = [];
        for (let i = 1; i <= 5; i++) {
            out.push({ id: i, ws: live.find(w => w.id === i) || null });
            seen.push(i);
        }
        live.filter(w => !seen.includes(w.id)).forEach(w => out.push({ id: w.id, ws: w }));
        return out;
    }

    content: Row {
        spacing: 3

        Repeater {
            model: root.entries

            delegate: Rectangle {
                id: wsButton

                required property var modelData
                readonly property var ws: modelData.ws
                readonly property bool active: ws ? ws.active : false
                readonly property bool urgent: ws ? ws.urgent : false
                readonly property bool empty: ws ? ws.toplevels.values.length === 0 : true
                readonly property string icon: {
                    const known = root.icons[modelData.id];
                    return known !== undefined ? known : String(modelData.id);
                }

                width: Math.max(wsText.implicitWidth + 10, 24)
                height: 28
                radius: 4
                color: wsButton.urgent ? Theme.bad
                    : wsButton.active ? Theme.highlight
                    : wsMouse.containsMouse ? Theme.pillHover
                    : "transparent"

                Text {
                    id: wsText
                    anchors.centerIn: parent
                    text: wsButton.icon
                    color: wsButton.urgent || wsButton.active ? "black"
                        : wsButton.empty ? Theme.emptyWs
                        : Theme.white
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.bold: wsButton.active
                }

                MouseArea {
                    id: wsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        const target = wsButton.ws ? wsButton.ws.name : String(wsButton.modelData.id);
                        // Lua config: dispatch takes a hl.dsp.* call, not the
                        // classic "workspace N" request form.
                        Hyprland.dispatch(`hl.dsp.focus({ workspace = "${target}" })`);
                    }
                }
            }
        }
    }
}
