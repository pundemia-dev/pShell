pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.utils
import qs.config
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property int index
    required property bool isHorizontal
    required property real unitSize
    required property int activeWsId
    required property var occupied
    required property int groupOffset

    readonly property bool isWorkspace: true
    readonly property int ws: groupOffset + index + 1
    readonly property bool isOccupied: occupied[ws] ?? false
    readonly property bool isActive: activeWsId === ws
    readonly property bool hasWindows: isOccupied && Config.bar.workspaces.showWindows
    readonly property real size: isHorizontal
        ? childrenRect.width + (hasWindows ? Appearance.padding.smaller : 0)
        : childrenRect.height + (hasWindows ? Appearance.padding.smaller : 0)

    implicitWidth: isHorizontal ? size : unitSize
    implicitHeight: isHorizontal ? unitSize : size

    StyledText {
        id: indicator

        property real centerX: isHorizontal ? 0 : (root.unitSize - width) / 2
        property real centerY: isHorizontal ? (root.unitSize - height) / 2 : 0

        x: centerX
        y: centerY
        width: root.unitSize
        height: root.unitSize

        animate: true
        text: {
            const ws = Hypr.workspaces.values.find(w => w.id === root.ws);
            const wsName = !ws || ws.name == root.ws ? root.ws : ws.name[0];
            let displayName = wsName.toString();
            if (Config.bar.workspaces.capitalisation.toLowerCase() === "upper")
                displayName = displayName.toUpperCase();
            else if (Config.bar.workspaces.capitalisation.toLowerCase() === "lower")
                displayName = displayName.toLowerCase();

            const label = Config.bar.workspaces.label || displayName;
            const occupiedLabel = Config.bar.workspaces.occupiedLabel || label;
            const activeLabel = Config.bar.workspaces.activeLabel || (root.isOccupied ? occupiedLabel : label);
            return root.isActive ? activeLabel : root.isOccupied ? occupiedLabel : label;
        }
        color: Config.bar.workspaces.occupiedBg || root.isOccupied || root.isActive
            ? Colours.palette.on_surface
            : Colours.layer(Colours.palette.outline_variant, 2)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Loader {
        id: windows

        active: root.hasWindows
        visible: active
        asynchronous: true

        anchors {
            left: root.isHorizontal ? indicator.right : undefined
            top: root.isHorizontal ? undefined : indicator.bottom
            horizontalCenter: root.isHorizontal ? undefined : indicator.horizontalCenter
            verticalCenter: root.isHorizontal ? indicator.verticalCenter : undefined
        }

        sourceComponent: root.isHorizontal ? rowWindowsComp : colWindowsComp
    }

    Component {
        id: colWindowsComp

        Column {
            spacing: 0

            add: Transition {
                WsAnim {
                    properties: "scale"
                    from: 0
                    to: 1
                    easing.bezierCurve: Appearance.anim.curves.standardDecel
                }
            }

            move: Transition {
                WsAnim {
                    properties: "scale"
                    to: 1
                    easing.bezierCurve: Appearance.anim.curves.standardDecel
                }
                WsAnim {
                    properties: "x,y"
                }
            }

            Repeater {
                model: ScriptModel {
                    values: Hypr.toplevels.values.filter(c => c.workspace?.id === root.ws)
                }

                StyledIcon {
                    required property var modelData

                    grade: 0
                    text: Icons.getAppCategoryIcon(modelData.lastIpcObject.class, "\uebef")
                    color: Colours.palette.on_surface_variant
                    font.pointSize: Appearance.font.size.small
                }
            }
        }
    }

    Component {
        id: rowWindowsComp

        Row {
            spacing: 0

            add: Transition {
                WsAnim {
                    properties: "scale"
                    from: 0
                    to: 1
                    easing.bezierCurve: Appearance.anim.curves.standardDecel
                }
            }

            move: Transition {
                WsAnim {
                    properties: "scale"
                    to: 1
                    easing.bezierCurve: Appearance.anim.curves.standardDecel
                }
                WsAnim {
                    properties: "x,y"
                }
            }

            Repeater {
                model: ScriptModel {
                    values: Hypr.toplevels.values.filter(c => c.workspace?.id === root.ws)
                }

                StyledIcon {
                    required property var modelData

                    grade: 0
                    text: Icons.getAppCategoryIcon(modelData.lastIpcObject.class, "\uebef")
                    color: Colours.palette.on_surface_variant
                    font.pointSize: Appearance.font.size.small
                }
            }
        }
    }

    Behavior on implicitWidth {
        WsAnim {}
    }

    Behavior on implicitHeight {
        WsAnim {}
    }

    component WsAnim: NumberAnimation {
        duration: Appearance.anim.durations.normal
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.anim.curves.standard
    }
}
