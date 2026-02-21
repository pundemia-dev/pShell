// modules/bar/content/components/WidgetHost.qml
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.components
import Quickshell

Item {
    id: host
    required property ShellScreen screen

    readonly property bool isHorizontal: Config.bar.orientation
    readonly property real groupPadding: Config.bar.group.padding
    readonly property real thickness: Config.bar.group.thickness

    implicitWidth: {
        if (mainLoader.active) return mainLoader.width
        if (modelData.type === "group") {
            return isHorizontal ? (groupLayout.childrenRect.width + groupPadding * 2) : thickness
        }
        return 0
    }

    implicitHeight: {
        if (mainLoader.active) return mainLoader.height
        if (modelData.type === "group") {
            return isHorizontal ? thickness : (groupLayout.childrenRect.height + groupPadding * 2)
        }
        return 0
    }

    // 1. Одиночный виджет
    Loader {
        id: mainLoader
        anchors.centerIn: parent
        active: host.modelData && host.modelData.type === "widget" && !!host.modelData.name
        source: active ? Qt.resolvedUrl("../components/" + host.modelData.name + ".qml") : ""
        onLoaded: if (item && item.hasOwnProperty("screen")) item.screen = host.screen
    }

    // 2. Группа
    StyledRect {
        id: bgRect
        visible: host.modelData && host.modelData.type === "group"
        anchors.fill: parent
        color: Colours.palette.surface_container
        radius: Config.bar.group.rounding

        FlexboxLayout {
            id: groupLayout
            x: isHorizontal ? groupPadding : (parent.width - childrenRect.width) / 2
            y: isHorizontal ? (parent.height - childrenRect.height) / 2 : groupPadding

            direction: host.isHorizontal ? FlexboxLayout.Row : FlexboxLayout.Column
            alignItems: FlexboxLayout.AlignCenter
            gap: Appearance.spacing.normal

            Repeater {
                model: (host.modelData && host.modelData.type === "group") ? host.modelData.children : []
                delegate: Loader {
                    active: !!modelData && !!modelData.name
                    source: active ? Qt.resolvedUrl("../components/" + modelData.name + ".qml") : ""
                    onLoaded: if (item && item.hasOwnProperty("screen")) item.screen = host.screen
                }
            }
        }
    }
}
