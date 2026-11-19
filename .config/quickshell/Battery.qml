import Quickshell
import Quickshell.Services.UPower
import QtQuick

BarItem {
    id: root

    readonly property var batt: UPower.displayDevice
    readonly property int pct: batt == null ? 0 : Math.round(Math.min(1, batt.percentage) * 100)
    readonly property bool present: batt != null && batt.isPresent
    readonly property bool charging: batt != null
        && (batt.state === UPowerDeviceState.Charging
            || batt.state === UPowerDeviceState.PendingCharge)
    readonly property bool discharging: batt != null && batt.state === UPowerDeviceState.Discharging
    readonly property bool full: batt != null && batt.state === UPowerDeviceState.FullyCharged
    readonly property int timeLeft: batt == null ? 0 : (charging ? batt.timeToFull : batt.timeToEmpty)

    readonly property var iconsDefault: [
        "\u{f008e}", "\u{f007a}", "\u{f007b}", "\u{f007c}", "\u{f007d}", "\u{f007e}",
        "\u{f007f}", "\u{f0080}", "\u{f0081}", "\u{f0082}", "\u{f0081}", "\u{f0089}",
    ]
    readonly property var iconsCharging: [
        "\u{f089f}", "\u{f089c}", "\u{f0086}", "\u{f0087}", "\u{f0088}", "\u{f089d}",
        "\u{f0089}", "\u{f089e}", "\u{f008a}", "\u{f008b}", "\u{f0085}",
    ]

    visible: present

    content: Row {
        spacing: 6

        Text {
            text: {
                const charging = root.charging;
                const icons = charging ? root.iconsCharging : root.iconsDefault;
                return icons[Math.min(icons.length - 1, Math.round(root.pct / 100 * (icons.length - 1)))];
            }
            color: root.color
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        Text {
            text: root.pct + "%"
            color: root.color
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }

    readonly property string color: root.charging || root.full ? Theme.good
        : root.discharging && root.pct <= Theme.battCrit ? Theme.bad
        : root.discharging && root.pct <= Theme.battWarn ? Theme.warn
        : Theme.good

    Tooltip {
        target: root.hoverItem
        html: {
            const pctColor = root.pct <= Theme.battCrit ? Theme.bad
                : root.pct <= Theme.battWarn ? Theme.warn
                : Theme.good;
            const status = root.full ? "Full"
                : root.charging ? `Charging  ${formatTime(root.timeLeft)}`
                : root.discharging ? `Discharging  ${formatTime(root.timeLeft)}`
                : "Not Charging";
            return `Battery: <span style="color:${pctColor}">${root.pct}%</span>  ${status}`;
        }
    }

    function formatTime(seconds): string {
        if (seconds <= 0)
            return "";
        const h = Math.floor(seconds / 3600);
        const m = Math.round((seconds % 3600) / 60);
        return `${h}h ${String(m).padStart(2, "0")}m`;
    }
}
