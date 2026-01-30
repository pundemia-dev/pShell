import qs.widgets
import qs.services
import qs.config
import QtQuick
import QtQuick.Effects

StyledRect {
    id: root

    required property list<Workspace> workspaces
    required property Item mask
    required property real maskWidth
    required property real maskHeight
    required property int groupOffset

    readonly property int currentWsIdx: Hyprland.activeWsId - 1 - groupOffset
    property real leading: getWsY(currentWsIdx)
    property real trailing: getWsY(currentWsIdx)
    property real currentSize: workspaces[currentWsIdx]?.size ?? 0
    property real offset: Math.min(leading, trailing) + (30 / 2) - (Config.bar.workspaces.active.height / 2)//+7 // y offset
    property real size: {
        const s = Math.abs(leading - trailing) + currentSize;
        if (Config.bar.workspaces.activeTrail && lastWs > currentWsIdx)
            return Math.min(getWsY(lastWs) + (workspaces[lastWs]?.size ?? 0) - offset, s);
        return s;
    }

    property int cWs
    property int lastWs

    function getWsY(idx: int): real {
        let y = 0;
        for (let i = 0; i < idx; i++)
            y += workspaces[i]?.size + Config.bar.workspaces.spacing?? 0;
        return y;
    }

    onCurrentWsIdxChanged: {
        lastWs = cWs;
        cWs = currentWsIdx;
    }

    clip: true
    x: (parent.parent.width / 2) - (Config.bar.workspaces.active.width / 2)// + 1
    y: offset//
    implicitWidth: Config.bar.workspaces.active.width//Config.bar.sizes.innerHeight - 2
    implicitHeight: Config.bar.workspaces.active.height//unitSize//size - 2
    // anchors.centerIn: parent // TODO: ball animation

    // anchors.centerIn: workspaces[0].horizontalCenter//parent.horizontalCenter//parent.root.horizontalCenter
    // anchors.verticalCenter: workspaces.verticalCenter//parent.parent.verticalCenter
    // anchors.left: parent.left
    // anchors.right: parent.right
    radius: Config.bar.workspaces.active.rounding//Config.bar.workspaces.rounded ? Appearance.rounding.full : 0
    color: Config.bar.workspaces.active.bg || Colours.palette.primary

    Colouriser {
        source: root.mask
        colorizationColor: Config.bar.workspaces.active.labelColor || Colours.palette.on_primary

        x: 0
        y: -parent.offset
        implicitWidth: root.maskWidth
        implicitHeight: root.maskHeight

        anchors.horizontalCenter: parent.horizontalCenter
    }

    Behavior on leading {
        enabled: Config.bar.workspaces.activeTrail

        Anim {}
    }

    Behavior on trailing {
        enabled: Config.bar.workspaces.activeTrail

        Anim {
            duration: Appearance.anim.durations.normal * 2
        }
    }

    Behavior on currentSize {
        enabled: Config.bar.workspaces.activeTrail

        Anim {}
    }

    Behavior on offset {
        enabled: !Config.bar.workspaces.activeTrail

        Anim {}
    }

    Behavior on size {
        enabled: !Config.bar.workspaces.activeTrail

        Anim {}
    }

    component Anim: NumberAnimation {
        duration: Appearance.anim.durations.normal
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.anim.curves.emphasized
    }
}
