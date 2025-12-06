import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.widgets

// Component {
FlexboxLayout {
    id: begin
    anchors.fill: parent
    wrap: FlexboxLayout.Wrap
    direction: Config.bar.orientation ? FlexboxLayout.Row : FlexboxLayout.Column
    justifyContent: FlexboxLayout.JustifyStart

    StyledRect {
        color: "green"
        opacity: 0.3
        implicitWidth: 50
        implicitHeight: 50
    }
    StyledRect {
        color: "red"
        opacity: 0.3
        implicitWidth: 50
        implicitHeight: 50
    }
    StyledRect {
        color: "yellow"
        opacity: 0.3
        implicitWidth: 50
        implicitHeight: 50
    }
    StyledRect {
        color: "blue"
        opacity: 0.3
        implicitWidth: 50
        implicitHeight: 50
    }
    StyledRect {
        color: "pink"
        opacity: 0.3
        implicitWidth: 50
        implicitHeight: 50
    }
}
// }
