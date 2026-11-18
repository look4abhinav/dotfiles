import Quickshell
import Quickshell.Wayland
import QtQuick

BarItem {
    id: root

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    content: Text {
        text: Qt.formatDateTime(clock.date, "dddd | dd MMM yyyy | HH:mm")
        color: Theme.white
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.bold: true
    }

    onClicked: Quickshell.execDetached(["xdg-open", "https://calendar.google.com"])

    PanelWindow {
        id: calendar

        readonly property date ref: clock.date
        readonly property int firstOffset: {
            const first = new Date(ref.getFullYear(), ref.getMonth(), 1);
            return (first.getDay() + 6) % 7;
        }
        readonly property int daysInMonth: new Date(ref.getFullYear(), ref.getMonth() + 1, 0).getDate()

        anchors {
            top: true
            left: true
        }
        margins.top: 44
        exclusiveZone: -1
        color: "transparent"
        visible: root.containsMouse

        onVisibleChanged: {
            if (visible)
                margins.left = Math.max(4, Math.round(
                    root.mapToItem(null, 0, 0).x + root.width / 2 - implicitWidth / 2));
        }

        WlrLayershell.namespace: "quickshell"
        WlrLayershell.layer: WlrLayer.Overlay

        implicitWidth: 7 * 24 + 16
        implicitHeight: 176

        Rectangle {
            anchors.fill: parent
            color: Theme.tooltipBg
            border.color: Theme.pillBorder
            border.width: 1
            radius: 8

            Column {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(calendar.ref, "MMMM yyyy")
                    color: Theme.white
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.bold: true
                }

                Grid {
                    columns: 7
                    spacing: 2
                    horizontalItemAlignment: Grid.AlignHCenter

                    Repeater {
                        model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

                        Text {
                            required property string modelData
                            text: modelData
                            color: Theme.highlight
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                        }
                    }

                    Repeater {
                        model: 42

                        Text {
                            required property int index
                            readonly property int day: index - calendar.firstOffset + 1
                            readonly property bool inMonth: day >= 1 && day <= calendar.daysInMonth
                            readonly property bool isToday: inMonth
                                && day === calendar.ref.getDate()
                            readonly property string label: {
                                const other = day < 1
                                    ? new Date(calendar.ref.getFullYear(), calendar.ref.getMonth(), 1 + day)
                                    : new Date(calendar.ref.getFullYear(), calendar.ref.getMonth() + 1, day - calendar.daysInMonth);
                                return String(inMonth ? day : other.getDate());
                            }

                            text: label
                            color: isToday ? Theme.highlight : inMonth ? Theme.white : "#66ffffff"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            font.bold: isToday
                            horizontalAlignment: Text.AlignHCenter
                            width: 24
                        }
                    }
                }
            }
        }
    }
}
