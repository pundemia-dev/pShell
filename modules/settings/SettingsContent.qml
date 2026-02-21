pragma ComponentBehavior: Bound

import qs.config
import qs.utils
import qs.services
import qs.components
import qs.components.controls
import Quickshell
import QtQuick
import QtQuick.Layouts
import "pages"

Item {
    id: root

    signal closeRequested()

    property int currentPage: 0
    property bool navExpanded: true

    property var pages: [
        {
            name: qsTr("General"),
            icon: "\uf0e5", // tabler settings
            component: generalPage
        },
        {
            name: qsTr("Bar"),
            icon: "\uea76", // tabler layout-navbar
            component: barPage
        },
        {
            name: qsTr("Backgrounds"),
            icon: "\ued54", // tabler texture
            component: backgroundsPage
        },
        {
            name: qsTr("Borders"),
            icon: "\uea36", // tabler border-all
            component: bordersPage
        },
        {
            name: qsTr("Corners"),
            icon: "\uf09c", // tabler border-corner-rounded
            component: cornersPage
        },
        {
            name: qsTr("Launcher"),
            icon: "\ueb9b", // tabler rocket
            component: launcherPage
        },
        {
            name: qsTr("About"),
            icon: "\uea09", // tabler info-circle
            component: aboutPage
        }
    ]

    // Placeholder page components
    Component {
        id: generalPage
        PlaceholderPage { title: qsTr("General"); description: qsTr("General shell settings") }
    }
    Component {
        id: barPage
        PlaceholderPage { title: qsTr("Bar"); description: qsTr("Configure the status bar") }
    }
    Component {
        id: backgroundsPage
        PlaceholderPage { title: qsTr("Backgrounds"); description: qsTr("Background shape settings") }
    }
    Component {
        id: bordersPage
        PlaceholderPage { title: qsTr("Borders"); description: qsTr("Border settings") }
    }
    Component {
        id: cornersPage
        PlaceholderPage { title: qsTr("Corners"); description: qsTr("Screen corner rounding") }
    }
    Component {
        id: launcherPage
        PlaceholderPage { title: qsTr("Launcher"); description: qsTr("Application launcher settings") }
    }
    Component {
        id: aboutPage
        PlaceholderPage { title: qsTr("About"); description: qsTr("About pShell") }
    }

    implicitWidth: 900
    implicitHeight: 600

    // Keyboard navigation
    Keys.onPressed: (event) => {
        if (event.modifiers === Qt.ControlModifier) {
            if (event.key === Qt.Key_PageDown || event.key === Qt.Key_Tab) {
                root.currentPage = (root.currentPage + 1) % root.pages.length;
                event.accepted = true;
            } else if (event.key === Qt.Key_PageUp || event.key === Qt.Key_Backtab) {
                root.currentPage = (root.currentPage - 1 + root.pages.length) % root.pages.length;
                event.accepted = true;
            }
        }
        if (event.key === Qt.Key_Escape) {
            root.closeRequested();
            event.accepted = true;
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        // === Navigation Rail ===
        ColumnLayout {
            id: navRail

            Layout.fillHeight: true
            Layout.preferredWidth: root.navExpanded ? 170 : 52
            spacing: 4

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: Appearance.anim.durations.small
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.anim.curves.standard
                }
            }

            // Header row: toggle + title
            RowLayout {
                Layout.fillWidth: true
                Layout.bottomMargin: 4
                spacing: 4

                IconButton {
                    type: IconButton.Text
                    icon: root.navExpanded ? "\uea00" : "\uea01" // tabler menu-2 / menu
                    onClicked: root.navExpanded = !root.navExpanded
                }

                StyledText {
                    Layout.fillWidth: true
                    visible: root.navExpanded
                    text: qsTr("Settings")
                    font.pointSize: Appearance.font.size.large
                    font.weight: Font.DemiBold
                    color: Colours.palette.on_surface
                    opacity: root.navExpanded ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Appearance.anim.durations.small
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Appearance.anim.curves.standard
                        }
                    }
                }

                Item { Layout.fillWidth: !root.navExpanded }

                IconButton {
                    visible: root.navExpanded
                    type: IconButton.Text
                    icon: "\ueb55" // tabler x
                    onClicked: root.closeRequested()
                }
            }

            // Separator
            StyledRect {
                Layout.fillWidth: true
                Layout.leftMargin: 4
                Layout.rightMargin: 4
                implicitHeight: 1
                color: Colours.palette.outline_variant
            }

            // Nav items
            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: navColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: navColumn
                    width: parent.width
                    spacing: 2

                    Repeater {
                        model: root.pages

                        delegate: StyledRect {
                            id: navItem

                            required property int index
                            required property var modelData

                            property bool isActive: root.currentPage === index
                            property bool isHovered: navMouse.containsMouse

                            Layout.fillWidth: true
                            implicitHeight: navItemRow.implicitHeight + Appearance.padding.smaller * 2

                            radius: Appearance.rounding.small
                            color: isActive
                                ? Colours.palette.secondary_container
                                : isHovered
                                    ? Qt.alpha(Colours.palette.on_surface, 0.08)
                                    : "transparent"

                            MouseArea {
                                id: navMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.currentPage = navItem.index
                            }

                            RowLayout {
                                id: navItemRow
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: Appearance.padding.smaller
                                anchors.rightMargin: Appearance.padding.smaller
                                spacing: Appearance.spacing.smaller

                                StyledText {
                                    id: navIcon
                                    text: navItem.modelData.icon
                                    font.family: Appearance.font.family.tabler
                                    font.pointSize: Appearance.font.size.larger
                                    color: navItem.isActive
                                        ? Colours.palette.on_secondary_container
                                        : Colours.palette.on_surface_variant
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.preferredWidth: 32
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                StyledText {
                                    id: navLabel
                                    visible: root.navExpanded
                                    text: navItem.modelData.name
                                    font.pointSize: Appearance.font.size.smaller
                                    font.weight: navItem.isActive ? Font.DemiBold : Font.Normal
                                    color: navItem.isActive
                                        ? Colours.palette.on_secondary_container
                                        : Colours.palette.on_surface_variant
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }

            // Bottom spacer
            Item { Layout.preferredHeight: 4 }
        }

        // === Content Area ===
        StyledRect {
            Layout.fillWidth: true
            Layout.fillHeight: true

            radius: Appearance.rounding.normal
            color: Colours.palette.surface_container_low
            clip: true

            Loader {
                id: pageLoader
                anchors.fill: parent
                anchors.margins: Appearance.padding.large
                sourceComponent: root.pages[root.currentPage].component

                opacity: 1.0

                Connections {
                    target: root
                    function onCurrentPageChanged() {
                        switchAnim.restart();
                    }
                }

                SequentialAnimation {
                    id: switchAnim

                    NumberAnimation {
                        target: pageLoader
                        property: "opacity"
                        to: 0
                        duration: 100
                        easing.type: Easing.InQuad
                    }

                    PropertyAction {
                        target: pageLoader
                        property: "sourceComponent"
                        value: root.pages[root.currentPage].component
                    }

                    PropertyAction {
                        target: pageLoader
                        property: "anchors.topMargin"
                        value: Appearance.padding.large + 15
                    }

                    ParallelAnimation {
                        NumberAnimation {
                            target: pageLoader
                            property: "opacity"
                            to: 1
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            target: pageLoader
                            property: "anchors.topMargin"
                            to: Appearance.padding.large
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}
