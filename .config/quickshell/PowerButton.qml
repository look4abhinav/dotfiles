import Quickshell
import QtQuick

BarItem {
    id: root

    rightMargin: 4
    padX: 10

    pillColor: containsMouse ? Theme.bad : Theme.pillBg

    content: Text {
        text: "\u{f011}"
        color: root.containsMouse ? "black" : Theme.bad
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    onClicked: Quickshell.execDetached([
        "wlogout",
        "-b", "3",
        "-T", "300",
        "-B", "300",
        "-L", "150",
        "-R", "150",
    ])
}
