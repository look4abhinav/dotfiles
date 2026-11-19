pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property string fontFamily: "JetBrainsMono Nerd Font Propo"
    readonly property int fontSize: 12

    // Shared Quickshell palette
    readonly property string highlight: "#75f1fa"
    readonly property string good: "#42ff9f"
    readonly property string warn: "#f0a040"
    readonly property string bad: "#e35149"
    readonly property string dark7: "#3f3f46"
    readonly property string white: "#ffffff"
    readonly property string emptyWs: "#66ffffff"

    readonly property color barBg: Qt.rgba(0, 0, 0, 0.3)
    readonly property color pillBg: Qt.rgba(1, 1, 1, 0.04)
    readonly property color pillBorder: Qt.rgba(1, 1, 1, 0.1)
    readonly property color pillHover: Qt.rgba(1, 1, 1, 0.05)
    readonly property color tooltipBg: Qt.rgba(0, 0, 0, 0.6)

    // CPU, memory, swap, and battery thresholds
    readonly property int cpuWarn: 70
    readonly property int cpuCrit: 90
    readonly property int memWarn: 70
    readonly property int memCrit: 90
    readonly property int swapWarn: 50
    readonly property int swapCrit: 80
    readonly property int battWarn: 35
    readonly property int battCrit: 15

    function stateColor(value, warnAt, critAt): string {
        if (value >= critAt)
            return bad;
        if (value >= warnAt)
            return warn;
        return good;
    }

    // External strings (SSID, device and sink names) land in Text.RichText
    // tooltips; escape them so hostile names cannot inject markup.
    function escapeHtml(text): string {
        return String(text)
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;");
    }
}
