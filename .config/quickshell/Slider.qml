import QtQuick

// Waybar-style bare slider: slim trough with a fill bar, no handle.
// Drag anywhere on the trough. External value flows in through `initial`;
// user drags come back out via the userChanged signal.
Item {
    id: root

    property real value: initial
    property real initial: 0
    property color accent: Theme.highlight
    property bool expanded: false
    signal userChanged(real value)

    implicitHeight: 36
    implicitWidth: expanded ? 88 : 0
    opacity: expanded ? 1 : 0
    visible: implicitWidth > 0

    onInitialChanged: value = initial

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }

    Rectangle {
        id: troughRect
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 4
        width: parent.width - 8
        height: 5
        radius: 5
        color: Theme.dark7

        Rectangle {
            width: Math.max(parent.width * root.value, root.expanded ? 10 : 0)
            height: parent.height
            radius: parent.radius
            color: root.accent
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onPressed: m => {
                root.value = Math.min(1, Math.max(0, m.x / parent.width));
                root.userChanged(root.value);
            }
            onPositionChanged: m => {
                if (pressed) {
                    root.value = Math.min(1, Math.max(0, m.x / parent.width));
                    root.userChanged(root.value);
                }
            }
        }
    }
}
