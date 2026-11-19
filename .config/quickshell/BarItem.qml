import QtQuick

// Pill-styled bar module container:
// 1px border, 6px horizontal padding, 6px radius, right margin between pills.
Item {
    id: root

    default property alias content: contentRow.data
    property real leftMargin: 0
    property real rightMargin: 6
    property real padX: 6
    property real pillHeight: 32
    property alias pillColor: pill.color
    readonly property alias containsMouse: mouse.containsMouse
    readonly property alias hoverItem: mouse
    signal clicked()
    signal wheeled(real delta)

    implicitHeight: 36
    implicitWidth: contentRow.implicitWidth + 2 * padX + 2 + leftMargin + rightMargin

    // Input handler sits below the content row: plain text and rectangles let
    // events fall through to it, while interactive children (workspace buttons)
    // stay on top and receive their own clicks.
    MouseArea {
        id: mouse
        x: root.leftMargin
        width: root.implicitWidth - root.leftMargin - root.rightMargin
        height: root.pillHeight
        anchors.verticalCenter: parent.verticalCenter
        hoverEnabled: true
        onClicked: root.clicked()
        onWheel: w => root.wheeled(w.angleDelta.y)
    }

    Rectangle {
        id: pill
        x: root.leftMargin
        width: root.implicitWidth - root.leftMargin - root.rightMargin
        height: root.pillHeight
        anchors.verticalCenter: parent.verticalCenter
        radius: 6
        color: Theme.pillBg
        border.width: 1
        border.color: Theme.pillBorder

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 6
        }
    }
}
