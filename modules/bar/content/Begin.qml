import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.widgets
import "components"
import "components/workspaces"

// modules/bar/content/Center.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import "components"

FlexboxLayout {
    id: root
    // anchors.fill: parent
    required property ShellScreen screen
    direction: Config.bar.orientation ? FlexboxLayout.Row : FlexboxLayout.Column
    alignItems: FlexboxLayout.AlignCenter
    justifyContent: FlexboxLayout.JustifyStart
    gap: 0
    Clock {
        id: clock
    }

    Power {
        id: power
    }
    KeyboardPreview {
        id: keyboardPreview
    }

    Network {
        id: network
    }

    Bluetooth {
        id: bluetooth
    }


    OsIcon {
        id: osIcon
    }

    Tray {
        id: tray
    }

    // Workspaces {
    //     id: workspaces
    //     screen: screen
    // }

    Dinamic {
        id: dinamic
    }
}
