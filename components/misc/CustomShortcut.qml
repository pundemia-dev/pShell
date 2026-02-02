import Quickshell.Hyprland

GlobalShortcut {
    id: shortcut
    appid: "pShell"

    property var onActivated: null

    onPressed: {
        if (onActivated && typeof onActivated === "function") {
            onActivated();
        }
    }
}
