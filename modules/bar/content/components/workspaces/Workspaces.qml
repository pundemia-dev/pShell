pragma ComponentBehavior: Bound

import qs.services
import qs.config
import qs.components
import qs.components.effects
import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

StyledClippingRect {
    id: root

    property ShellScreen screen

    readonly property bool isHorizontal: Config.bar.orientation
    readonly property bool onSpecial: (Config.bar.workspaces.perMonitorWorkspaces ? Hypr.monitorFor(screen) : Hypr.focusedMonitor)?.lastIpcObject?.specialWorkspace?.name !== ""
    readonly property int activeWsId: Config.bar.workspaces.perMonitorWorkspaces ? (Hypr.monitorFor(screen).activeWorkspace?.id ?? 1) : Hypr.activeWsId

    readonly property var occupied: Hypr.workspaces.values.reduce((acc, curr) => {
        acc[curr.id] = curr.lastIpcObject.windows > 0;
        return acc;
    }, {})
    readonly property int groupOffset: Math.floor((activeWsId - 1) / Config.bar.workspaces.shown) * Config.bar.workspaces.shown
    readonly property real unitSize: Config.bar.group.thickness - Appearance.padding.small * 2

    property real blur: onSpecial ? 1 : 0

    implicitWidth: isHorizontal
        ? layout.implicitWidth + Appearance.padding.small * 2
        : unitSize + Appearance.padding.small * 2
    implicitHeight: isHorizontal
        ? unitSize + Appearance.padding.small * 2
        : layout.implicitHeight + Appearance.padding.small * 2

    color: Colours.palette.surface_container
    radius: Appearance.rounding.full

    Item {
        id: normalContent

        anchors.fill: parent
        scale: root.onSpecial ? 0.8 : 1
        opacity: root.onSpecial ? 0.5 : 1

        layer.enabled: root.blur > 0
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: root.blur
            blurMax: 32
        }

        Loader {
            active: Config.bar.workspaces.occupiedBg

            anchors.fill: parent
            anchors.margins: Appearance.padding.small

            sourceComponent: OccupiedBg {
                isHorizontal: root.isHorizontal
                unitSize: root.unitSize
                workspaces: workspaces
                occupied: root.occupied
                groupOffset: root.groupOffset
            }
        }

        FlexboxLayout {
            id: layout

            anchors.centerIn: parent
            direction: root.isHorizontal ? FlexboxLayout.Row : FlexboxLayout.Column
            alignItems: FlexboxLayout.AlignCenter
            gap: Math.floor(Appearance.spacing.small / 2)

            layer.enabled: true
            layer.smooth: true

            Repeater {
                id: workspaces

                model: Config.bar.workspaces.shown

                Workspace {
                    isHorizontal: root.isHorizontal
                    unitSize: root.unitSize
                    activeWsId: root.activeWsId
                    occupied: root.occupied
                    groupOffset: root.groupOffset
                }
            }
        }

        Loader {
            active: Config.bar.workspaces.activeIndicator

            sourceComponent: ActiveIndicator {
                isHorizontal: root.isHorizontal
                unitSize: root.unitSize
                activeWsId: root.activeWsId
                workspaces: workspaces
                mask: layout
            }
        }

        MouseArea {
            anchors.fill: layout

            onClicked: event => {
                const child = root.isHorizontal
                    ? layout.childAt(event.x, event.y)
                    : layout.childAt(event.x, event.y);
                if (!child || child.ws === undefined)
                    return;
                if (Hypr.activeWsId !== child.ws)
                    Hypr.dispatch(`workspace ${child.ws}`);
                else
                    Hypr.dispatch("togglespecialworkspace special");
            }
        }

        Behavior on scale {
            Anim {}
        }

        Behavior on opacity {
            Anim {}
        }
    }

    Loader {
        id: specialWs

        anchors.fill: parent
        anchors.margins: Appearance.padding.small

        active: opacity > 0

        scale: root.onSpecial ? 1 : 0.5
        opacity: root.onSpecial ? 1 : 0

        sourceComponent: SpecialWorkspaces {
            screen: root.screen
            isHorizontal: root.isHorizontal
            unitSize: root.unitSize
        }

        Behavior on scale {
            Anim {}
        }

        Behavior on opacity {
            Anim {}
        }
    }

    Behavior on blur {
        Anim {
            duration: Appearance.anim.durations.small
        }
    }

    Behavior on implicitWidth {
        Anim {}
    }

    Behavior on implicitHeight {
        Anim {}
    }
}
