import Quickshell
import Quickshell.Io
import QtQml
import QtQuick

// Brightness group: pill + hover slider. Writes go through brightnessctl
// (sysfs is root-owned here); slider drags are debounced.
Item {
    id: root

    readonly property string blDir: Quickshell.env("BACKLIGHT_DIR") || "/sys/class/backlight/intel_backlight"
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

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: root.read()
    }

    FileView {
        id: levelView
        path: root.blDir + "/brightness"
        blockLoading: true
    }

    FileView {
        id: maxView
        path: root.blDir + "/max_brightness"
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
            Quickshell.execDetached(["brightnessctl", "set", pct + "%"]);
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

        onClicked: Quickshell.execDetached(["brightnessctl", "set", "+10%"])

        onWheeled: delta => Quickshell.execDetached([
            "brightnessctl", "set", delta > 0 ? "+5%" : "-5%",
        ])
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

    Component.onCompleted: read()
}
