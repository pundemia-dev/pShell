pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    // Active focus requests keyed by name: { "settings": true, "launcher": true, ... }
    property var requests: ({})

    // True when at least one module has requested focus
    property bool focusActive: false

    // Emitted when the Hyprland focus grab is cleared (user clicked outside)
    // Modules should connect to this to clean up their visible state
    signal focusCleared()

    function requestFocus(name: string): void {
        requests[name] = true;
        requests = requests;
        focusActive = Object.keys(requests).length > 0;
    }

    function releaseFocus(name: string): void {
        delete requests[name];
        requests = requests;
        focusActive = Object.keys(requests).length > 0;
    }

    // Called by Drawers when HyprlandFocusGrab.onCleared fires
    function onGrabCleared(): void {
        requests = {};
        focusActive = false;
        focusCleared();
    }
}
