import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.widgets
import "components"
import "components/workspaces"

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


    Rectangle {
        id: resizableRect
        width: 20
        height: 20
        color: "lightgreen"
        opacity: 0.5
        radius: 4

        Behavior on width {
            NumberAnimation {
                duration: 200
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: 200
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                resizableRect.width = Config.bar.orientation ? 100 : 20
                resizableRect.height = Config.bar.orientation ? 20 : 100
            }
            onExited: {
                resizableRect.width = 20
                resizableRect.height = 20
            }
        }
    }
}
