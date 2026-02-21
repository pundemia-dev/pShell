import qs.config
import qs.services
import qs.components
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    default property alias control: controlContainer.data
    property string label: ""
    property string description: ""
    property bool showSeparator: true

    Layout.fillWidth: true
    implicitHeight: rowLayout.implicitHeight + (showSeparator ? separator.height + Appearance.spacing.small : 0)

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        RowLayout {
            id: rowLayout

            Layout.fillWidth: true
            spacing: Appearance.spacing.normal

            // Label + description column
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                StyledText {
                    visible: root.label !== ""
                    text: root.label
                    font.pointSize: Appearance.font.size.normal
                    color: Colours.palette.on_surface
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                StyledText {
                    visible: root.description !== ""
                    text: root.description
                    font.pointSize: Appearance.font.size.small
                    color: Colours.palette.on_surface_variant
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }
            }

            // Control slot
            Item {
                id: controlContainer

                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                Layout.minimumWidth: implicitWidth
                Layout.preferredWidth: implicitWidth
                Layout.preferredHeight: implicitHeight

                implicitWidth: childrenRect.width
                implicitHeight: childrenRect.height
            }
        }

        // Bottom separator
        StyledRect {
            id: separator

            visible: root.showSeparator
            Layout.fillWidth: true
            Layout.topMargin: Appearance.spacing.small
            implicitHeight: 1
            color: Colours.palette.outline_variant
            opacity: 0.3
        }
    }
}
