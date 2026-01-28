import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

FlexboxLayout {
    id: root
    direction: Config.bar.orientation ? FlexboxLayout.Row : FlexboxLayout.Column
    alignItems: FlexboxLayout.AlignCenter
    justifyContent: FlexboxLayout.JustifyCenter

    property color colour: Colours.palette.tertiary

    gap: Appearance.spacing.small

    Loader {
        active: !Config.bar.orientation
        visible: active
        asynchronous: true
        width: icon ? icon.implicitWidth : 0
        height: icon ? icon.implicitHeight : 0

        StyledIcon {
            id: icon

            text: "\ufd30"//"calendar_month"
            color: root.colour
            anchors.centerIn: parent
        }
    }

    StyledText {
        id: text

        // horizontalAlignment: StyledText.AlignHCenter
        // verticalAlignment: StyledText.AlignVCenter
        text: Config.bar.orientation ? Time.format("hh:mm") : Time.format("hh\nmm")
        font.pointSize: Appearance.font.size.smaller
        font.family: Appearance.font.family.mono
        color: root.colour

        // Layout.alignment: Qt.AlignVCenter
        transform: Translate { y: -2 }
        // anchors.verticalCenterOffset: -2
    }
}
