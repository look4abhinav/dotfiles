//@ pragma Env QS_NO_RELOAD_POPUP=1
import Quickshell
import QtQuick

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {}
    }
}
