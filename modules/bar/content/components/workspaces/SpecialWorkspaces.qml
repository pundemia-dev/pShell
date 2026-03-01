pragma ComponentBehavior: Bound

import qs.components
import qs.components.effects
import qs.services
import qs.utils
import qs.config
import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property ShellScreen screen
    required property bool isHorizontal
    required property real unitSize

    readonly property HyprlandMonitor monitor: Hypr.monitorFor(screen)
    readonly property string activeSpecial: (Config.bar.workspaces.perMonitorWorkspaces ? monitor : Hypr.focusedMonitor)?.lastIpcObject?.specialWorkspace?.name ?? ""

    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: mask
    }

    Item {
        id: mask

        anchors.fill: parent
        layer.enabled: true
        visible: false

        Rectangle {
            anchors.fill: parent
            radius: Appearance.rounding.full

            gradient: Gradient {
                orientation: root.isHorizontal ? Gradient.Horizontal : Gradient.Vertical

                GradientStop {
                    position: 0
                    color: Qt.rgba(0, 0, 0, 0)
                }
                GradientStop {
                    position: 0.3
                    color: Qt.rgba(0, 0, 0, 1)
                }
                GradientStop {
                    position: 0.7
                    color: Qt.rgba(0, 0, 0, 1)
                }
                GradientStop {
                    position: 1
                    color: Qt.rgba(0, 0, 0, 0)
                }
            }
        }

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: root.isHorizontal ? undefined : parent.right
            anchors.bottom: root.isHorizontal ? parent.bottom : undefined

            radius: Appearance.rounding.full
            implicitWidth: root.isHorizontal ? parent.width / 2 : parent.width
            implicitHeight: root.isHorizontal ? parent.height : parent.height / 2
            opacity: root.isHorizontal
                ? (view.contentX > 0 ? 0 : 1)
                : (view.contentY > 0 ? 0 : 1)

            Behavior on opacity {
                Anim {}
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.left: root.isHorizontal ? undefined : parent.left
            anchors.top: root.isHorizontal ? parent.top : undefined

            radius: Appearance.rounding.full
            implicitWidth: root.isHorizontal ? parent.width / 2 : parent.width
            implicitHeight: root.isHorizontal ? parent.height : parent.height / 2
            opacity: root.isHorizontal
                ? (view.contentX < view.contentWidth - parent.width + Appearance.padding.small ? 0 : 1)
                : (view.contentY < view.contentHeight - parent.height + Appearance.padding.small ? 0 : 1)

            Behavior on opacity {
                Anim {}
            }
        }
    }

    ListView {
        id: view

        anchors.fill: parent
        orientation: root.isHorizontal ? ListView.Horizontal : ListView.Vertical
        spacing: Appearance.spacing.normal
        interactive: false

        currentIndex: model.values.findIndex(w => w.name === root.activeSpecial)
        onCurrentIndexChanged: currentIndex = Qt.binding(() => model.values.findIndex(w => w.name === root.activeSpecial))

        model: ScriptModel {
            values: Hypr.workspaces.values.filter(w => w.name.startsWith("special:") && (!Config.bar.workspaces.perMonitorWorkspaces || w.monitor === root.monitor))
        }

        preferredHighlightBegin: 0
        preferredHighlightEnd: root.isHorizontal ? width : height
        highlightRangeMode: ListView.StrictlyEnforceRange

        highlightFollowsCurrentItem: false
        highlight: Item {
            x: root.isHorizontal ? (view.currentItem?.x ?? 0) : 0
            y: root.isHorizontal ? 0 : (view.currentItem?.y ?? 0)
            implicitWidth: root.isHorizontal ? (view.currentItem?.size ?? 0) : (view.currentItem?.width ?? 0)
            implicitHeight: root.isHorizontal ? (view.currentItem?.height ?? 0) : (view.currentItem?.size ?? 0)

            Behavior on x {
                Anim {}
            }

            Behavior on y {
                Anim {}
            }
        }

        delegate: Item {
            id: ws

            required property HyprlandWorkspace modelData
            readonly property real size: root.isHorizontal
                ? label.width + (hasWindows ? windows.implicitWidth + Appearance.padding.smaller : 0)
                : label.height + (hasWindows ? windows.implicitHeight + Appearance.padding.smaller : 0)
            property int wsId
            property string icon
            property bool hasWindows

            width: root.isHorizontal ? size : view.width
            height: root.isHorizontal ? view.height : size

            Component.onCompleted: {
                wsId = modelData.id;
                icon = Icons.getSpecialWsIcon(modelData.name);
                hasWindows = Config.bar.workspaces.showWindowsOnSpecialWorkspaces && modelData.lastIpcObject.windows > 0;
            }

            Connections {
                target: ws.modelData

                function onIdChanged(): void {
                    if (ws.modelData)
                        ws.wsId = ws.modelData.id;
                }

                function onNameChanged(): void {
                    if (ws.modelData)
                        ws.icon = Icons.getSpecialWsIcon(ws.modelData.name);
                }

                function onLastIpcObjectChanged(): void {
                    if (ws.modelData)
                        ws.hasWindows = Config.bar.workspaces.showWindowsOnSpecialWorkspaces && ws.modelData.lastIpcObject.windows > 0;
                }
            }

            Connections {
                target: Config.bar.workspaces

                function onShowWindowsOnSpecialWorkspacesChanged(): void {
                    if (ws.modelData)
                        ws.hasWindows = Config.bar.workspaces.showWindowsOnSpecialWorkspaces && ws.modelData.lastIpcObject.windows > 0;
                }
            }

            Loader {
                id: label

                anchors.centerIn: root.isHorizontal ? undefined : undefined
                x: root.isHorizontal ? 0 : (parent.width - width) / 2
                y: root.isHorizontal ? (parent.height - height) / 2 : 0
                width: root.unitSize
                height: root.unitSize

                sourceComponent: ws.icon.length === 1 ? letterComp : iconComp

                Component {
                    id: iconComp

                    StyledIcon {
                        fill: 1
                        text: ws.icon
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Component {
                    id: letterComp

                    StyledText {
                        text: ws.icon
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Loader {
                id: windows

                visible: active
                active: ws.hasWindows

                anchors {
                    left: root.isHorizontal ? label.right : undefined
                    top: root.isHorizontal ? undefined : label.bottom
                    horizontalCenter: root.isHorizontal ? undefined : label.horizontalCenter
                    verticalCenter: root.isHorizontal ? label.verticalCenter : undefined
                }

                sourceComponent: root.isHorizontal ? rowWinComp : colWinComp

                Component {
                    id: colWinComp

                    Column {
                        spacing: 0

                        add: Transition {
                            Anim {
                                properties: "scale"
                                from: 0
                                to: 1
                                easing.bezierCurve: Appearance.anim.curves.standardDecel
                            }
                        }

                        move: Transition {
                            Anim {
                                properties: "scale"
                                to: 1
                                easing.bezierCurve: Appearance.anim.curves.standardDecel
                            }
                            Anim {
                                properties: "x,y"
                            }
                        }

                        Repeater {
                            model: ScriptModel {
                                values: Hypr.toplevels.values.filter(c => c.workspace?.id === ws.wsId)
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
                    id: rowWinComp

                    Row {
                        spacing: 0

                        add: Transition {
                            Anim {
                                properties: "scale"
                                from: 0
                                to: 1
                                easing.bezierCurve: Appearance.anim.curves.standardDecel
                            }
                        }

                        move: Transition {
                            Anim {
                                properties: "scale"
                                to: 1
                                easing.bezierCurve: Appearance.anim.curves.standardDecel
                            }
                            Anim {
                                properties: "x,y"
                            }
                        }

                        Repeater {
                            model: ScriptModel {
                                values: Hypr.toplevels.values.filter(c => c.workspace?.id === ws.wsId)
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
            }
        }

        add: Transition {
            Anim {
                properties: "scale"
                from: 0
                to: 1
                easing.bezierCurve: Appearance.anim.curves.standardDecel
            }
        }

        remove: Transition {
            Anim {
                property: "scale"
                to: 0.5
                duration: Appearance.anim.durations.small
            }
            Anim {
                property: "opacity"
                to: 0
                duration: Appearance.anim.durations.small
            }
        }

        move: Transition {
            Anim {
                properties: "scale"
                to: 1
                easing.bezierCurve: Appearance.anim.curves.standardDecel
            }
            Anim {
                properties: "x,y"
            }
        }

        displaced: Transition {
            Anim {
                properties: "scale"
                to: 1
                easing.bezierCurve: Appearance.anim.curves.standardDecel
            }
            Anim {
                properties: "x,y"
            }
        }
    }

    Loader {
        active: Config.bar.workspaces.activeIndicator
        anchors.fill: parent

        sourceComponent: Item {
            StyledClippingRect {
                id: indicator

                x: root.isHorizontal ? (view.currentItem?.x ?? 0) - view.contentX : 0
                y: root.isHorizontal ? 0 : (view.currentItem?.y ?? 0) - view.contentY

                anchors.left: root.isHorizontal ? undefined : parent.left
                anchors.right: root.isHorizontal ? undefined : parent.right
                anchors.top: root.isHorizontal ? parent.top : undefined
                anchors.bottom: root.isHorizontal ? parent.bottom : undefined

                implicitWidth: root.isHorizontal ? (view.currentItem?.size ?? 0) : parent.width
                implicitHeight: root.isHorizontal ? parent.height : (view.currentItem?.size ?? 0)

                color: Colours.palette.tertiary
                radius: Appearance.rounding.full

                Colouriser {
                    source: view
                    sourceColor: Colours.palette.on_surface
                    colorizationColor: Colours.palette.on_tertiary

                    anchors.horizontalCenter: root.isHorizontal ? undefined : parent.horizontalCenter
                    anchors.verticalCenter: root.isHorizontal ? parent.verticalCenter : undefined

                    x: root.isHorizontal ? -indicator.x : 0
                    y: root.isHorizontal ? 0 : -indicator.y
                    implicitWidth: view.width
                    implicitHeight: view.height
                }

                Behavior on x {
                    Anim {
                        easing.bezierCurve: Appearance.anim.curves.emphasized
                    }
                }

                Behavior on y {
                    Anim {
                        easing.bezierCurve: Appearance.anim.curves.emphasized
                    }
                }

                Behavior on implicitWidth {
                    Anim {
                        easing.bezierCurve: Appearance.anim.curves.emphasized
                    }
                }

                Behavior on implicitHeight {
                    Anim {
                        easing.bezierCurve: Appearance.anim.curves.emphasized
                    }
                }
            }
        }
    }

    MouseArea {
        property real startX
        property real startY

        anchors.fill: view

        drag.target: view.contentItem
        drag.axis: root.isHorizontal ? Drag.XAxis : Drag.YAxis
        drag.maximumX: root.isHorizontal ? 0 : undefined
        drag.minimumX: root.isHorizontal ? Math.min(0, view.width - view.contentWidth - Appearance.padding.small) : undefined
        drag.maximumY: root.isHorizontal ? undefined : 0
        drag.minimumY: root.isHorizontal ? undefined : Math.min(0, view.height - view.contentHeight - Appearance.padding.small)

        onPressed: event => {
            startX = event.x;
            startY = event.y;
        }

        onClicked: event => {
            const dist = root.isHorizontal
                ? Math.abs(event.x - startX)
                : Math.abs(event.y - startY);
            if (dist > drag.threshold)
                return;

            const ws = view.itemAt(event.x, event.y);
            if (ws?.modelData)
                Hypr.dispatch(`togglespecialworkspace ${ws.modelData.name.slice(8)}`);
            else
                Hypr.dispatch("togglespecialworkspace special");
        }
    }
}
