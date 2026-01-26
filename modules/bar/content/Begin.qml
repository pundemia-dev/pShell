import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.widgets
import "components"

FlexboxLayout {
    id: root
    // anchors.fill: parent
    direction: Config.bar.orientation ? FlexboxLayout.Row : FlexboxLayout.Column
    alignItems: FlexboxLayout.AlignCenter
    justifyContent: FlexboxLayout.JustifyStart
    gap: 30

    Clock {
        id: clock
    }

    Clock {
        id: clockkk
    }

    Rectangle {
        id: resizableRect
        width: 20
        height: 50
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
                resizableRect.width = 20
                resizableRect.height = 100
            }
            onExited: {
                resizableRect.width = 20
                resizableRect.height = 50
            }
        }
    }
}
