import Quickshell
import Quickshell.Io
import QtQml
import QtQuick

// Brightness group: pill + hover slider. Writes go through brightnessctl
// (sysfs is root-owned here); slider drags are debounced.
Item {
    id: root

    // BACKLIGHT_DIR pins a specific device; otherwise the first sysfs
    // entry with a working max_brightness wins at startup, so the module
    // travels across machines.
    property string blDir: Quickshell.env("BACKLIGHT_DIR") || ""
    property string blName: ""
    property real maxLevel: 1
    property real level: 0
    property real pending: -1
    property bool available: false

    readonly property real percent: maxLevel > 0 ? level * 100 / maxLevel : 0

    implicitHeight: 36
    implicitWidth: pill.width + slider.implicitWidth
    visible: available

    HoverHandler {
        id: hover
    }

    // Poll only while a readable device exists; on machines without one
    // this stays hidden instead of polling a dead sysfs path forever.
    Timer {
        interval: 500
        running: root.available
        repeat: true
        onTriggered: root.read()
    }

    Process {
        id: detect
        command: ["sh", "-c", "for d in /sys/class/backlight/*; do m=$(cat \"$d/max_brightness\" 2>/dev/null) || continue; [ \"$m\" -gt 0 ] 2>/dev/null || continue; printf '%s\\n' \"${d##*/}\"; break; done"]
        stdout: StdioCollector {
            id: collector
            onStreamFinished: {
                const name = collector.text.trim();
                if (name !== "") {
                    root.blDir = "/sys/class/backlight/" + name;
                    root.blName = name;
                }
                root.read();
            }
        }
    }

    FileView {
        id: levelView
        path: root.blDir !== "" ? root.blDir + "/brightness" : ""
        blockLoading: true
    }

    FileView {
        id: maxView
        path: root.blDir !== "" ? root.blDir + "/max_brightness" : ""
        blockLoading: true
    }

    // Debounces the stream of drag updates into single brightnessctl calls.
    Timer {
        id: writeTimer
        interval: 150
        onTriggered: {
            if (root.pending < 0)
                return;
            const pct = Math.round(root.pending * 100);
            root.pending = -1;
            root.writeBrightness(["set", pct + "%"]);
        }
    }

    BarItem {
        id: pill
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        content: Row {
            spacing: 6

            Text {
                text: root.percent > 66 ? "\u{f00e0}" : root.percent > 33 ? "\u{f00dd}" : "\u{f00de}"
                color: Theme.highlight
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }

            Text {
                text: Math.round(root.percent) + "%"
                color: Theme.highlight
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }
        }

        onClicked: root.writeBrightness(["set", "+10%"])

        onWheeled: delta => root.writeBrightness([
            "set", delta > 0 ? "+5%" : "-5%",
        ])

        Tooltip {
            target: pill.hoverItem
            html: `Brightness: <span style="color:${Theme.highlight}">${Math.round(root.percent)}%</span>`
        }
    }

    Slider {
        id: slider
        anchors.left: pill.right
        anchors.verticalCenter: parent.verticalCenter
        expanded: hover.hovered
        initial: root.level / root.maxLevel
        onUserChanged: value => {
            root.pending = value;
            writeTimer.restart();
        }
    }

    function read() {
        if (root.blDir === "")
            return;
        maxView.reload();
        levelView.reload();
        const max = parseInt(maxView.text().trim(), 10);
        const level = parseInt(levelView.text().trim(), 10);
        if (!Number.isNaN(max) && max > 0) {
            root.maxLevel = max;
            root.available = true;
        }
        if (!Number.isNaN(level))
            root.level = Math.min(level, root.maxLevel);
    }

    // Targets the detected device explicitly so displayed and written
    // brightness cannot diverge on multi-backlight machines.
    function writeBrightness(args) {
        if (root.blName !== "")
            Quickshell.execDetached(["brightnessctl", "-d", root.blName, ...args]);
        else
            Quickshell.execDetached(["brightnessctl", ...args]);
    }

    Component.onCompleted: {
        if (root.blDir !== "") {
            root.blName = root.blDir.substring(root.blDir.lastIndexOf("/") + 1);
            root.read();
        } else {
            detect.running = true;
        }
    }
}
