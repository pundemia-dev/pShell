import qs.components
import qs.components.effects
import qs.services
import qs.config
import QtQuick

StyledRect {
    id: root

    required property bool isHorizontal
    required property real unitSize
    required property int activeWsId
    required property Repeater workspaces
    required property Item mask

    readonly property int currentWsIdx: {
        let i = activeWsId - 1;
        while (i < 0)
            i += Config.bar.workspaces.shown;
        return i % Config.bar.workspaces.shown;
    }

    // Primary axis position (x for horizontal, y for vertical)
    property real leading: workspaces.count > 0
        ? (isHorizontal ? workspaces.itemAt(currentWsIdx)?.x ?? 0 : workspaces.itemAt(currentWsIdx)?.y ?? 0)
        : 0
    property real trailing: workspaces.count > 0
        ? (isHorizontal ? workspaces.itemAt(currentWsIdx)?.x ?? 0 : workspaces.itemAt(currentWsIdx)?.y ?? 0)
        : 0
    property real currentSize: workspaces.count > 0
        ? (isHorizontal ? workspaces.itemAt(currentWsIdx)?.size ?? 0 : workspaces.itemAt(currentWsIdx)?.size ?? 0)
        : 0
    property real offset: Math.min(leading, trailing)
    property real size: {
        const s = Math.abs(leading - trailing) + currentSize;
        if (Config.bar.workspaces.activeTrail && lastWs > currentWsIdx) {
            const ws = workspaces.itemAt(lastWs);
            if (!ws) return 0;
            const wsEnd = isHorizontal ? ws.x + ws.size : ws.y + ws.size;
            return Math.min(wsEnd - offset, s);
        }
        return s;
    }

    property int cWs
    property int lastWs

    onCurrentWsIdxChanged: {
        lastWs = cWs;
        cWs = currentWsIdx;
    }

    clip: true

    // Position on primary axis
    x: isHorizontal ? offset + mask.x : mask.x
    y: isHorizontal ? mask.y : offset + mask.y

    // Size: primary axis = animated size, cross axis = unitSize
    implicitWidth: isHorizontal ? size : unitSize
    implicitHeight: isHorizontal ? unitSize : size

    radius: Appearance.rounding.full
    color: Colours.palette.primary

    Colouriser {
        source: root.mask
        sourceColor: Colours.palette.on_surface
        colorizationColor: Colours.palette.on_primary

        x: root.isHorizontal ? -root.offset : 0
        y: root.isHorizontal ? 0 : -root.offset
        implicitWidth: root.mask.implicitWidth
        implicitHeight: root.mask.implicitHeight

        anchors.verticalCenter: root.isHorizontal ? parent.verticalCenter : undefined
        anchors.horizontalCenter: root.isHorizontal ? undefined : parent.horizontalCenter
    }

    Behavior on leading {
        enabled: Config.bar.workspaces.activeTrail

        EAnim {}
    }

    Behavior on trailing {
        enabled: Config.bar.workspaces.activeTrail

        EAnim {
            duration: Appearance.anim.durations.normal * 2
        }
    }

    Behavior on currentSize {
        enabled: Config.bar.workspaces.activeTrail

        EAnim {}
    }

    Behavior on offset {
        enabled: !Config.bar.workspaces.activeTrail

        EAnim {}
    }

    Behavior on size {
        enabled: !Config.bar.workspaces.activeTrail

        EAnim {}
    }

    component EAnim: Anim {
        easing.bezierCurve: Appearance.anim.curves.emphasized
    }
}
