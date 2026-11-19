import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: bar

    required property ShellScreen modelData
    screen: modelData

    anchors {
        top: true
        left: true
        right: true
    }
    exclusiveZone: 36
    implicitHeight: 36
    color: Theme.barBg

    WlrLayershell.namespace: "quickshell"
    WlrLayershell.layer: WlrLayer.Top

    IdleInhibitor {
        id: caffeine
        window: bar
        enabled: false
    }

    Item {
        anchors.fill: parent

        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            Workspaces {}
            Submap {}
            CpuStats {}
            MemoryStats {}
            IdleInhibitorButton {
                inhibitor: caffeine
            }
        }

        Clock {
            anchors.centerIn: parent
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            Volume {}
            Brightness {}
            Battery {}
            Bluetooth {}
            Network {}
            PowerButton {}
        }
    }
}
