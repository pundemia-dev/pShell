// modules/bar/content/components/Dinamic.qml
import qs.components
import QtQuick
import Quickshell
import qs.config

StyledRect {
    id: resizableRect
    width: 20
    height: 20
    color: "lightgreen"
    opacity: 0.5
    radius: 4

    implicitWidth: width
        implicitHeight: height
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
