import Quickshell.Io

JsonObject {
    property int shown: 5
    property bool activeIndicator: true
    property bool occupiedBg: false
    property bool showWindows: true
    property bool showWindowsOnSpecialWorkspaces: showWindows
    property bool activeTrail: false
    property bool perMonitorWorkspaces: true
    property string label: "  " // if empty, will show workspace name's first letter
    property string occupiedLabel: "󰮯"
    property string activeLabel: "󰮯"
    property string capitalisation: "preserve" // upper, lower, or preserve - relevant only if label is empty
    property list<var> specialWorkspaceIcons: []
}
