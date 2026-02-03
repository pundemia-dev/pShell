// ```qml /home/pundemia/.config/quickshell/pShell/drawers/backgrounds/components/Background.qml
pragma ComponentBehavior: Bound

import qs.config
import QtQuick
import qs.services
import QtQuick.Shapes
import Quickshell
import qs.widgets
import qs.components

Shape {
    id: root

    // Make wrapper optional so we can detect when it's removed (set to null) to trigger closing animation
    property var wrapper: null

    signal closed()

    property Item contentLoader: null

    // Target sizes (The "True" size)
    readonly property int targetWrapperWidth: {
        if (!wrapper) return 0;

        // If explicitly set
        if (wrapper.wrapperWidth !== undefined && wrapper.wrapperWidth !== null && wrapper.wrapperWidth > 0) {
            return wrapper.wrapperWidth;
        }
        // Otherwise calculate from content
        if (contentLoader && contentLoader.item) {
            return (contentLoader.item.childrenRect.width || contentLoader.item.implicitWidth) + pLeft + pRight;
        }
        return 0;
    }

    readonly property int targetWrapperHeight: {
        if (!wrapper) return 0;

        // If explicitly set
        if (wrapper.wrapperHeight !== undefined && wrapper.wrapperHeight !== null && wrapper.wrapperHeight > 0) {
            return wrapper.wrapperHeight;
        }
        // Otherwise calculate from content
        if (contentLoader && contentLoader.item) {
            return (contentLoader.item.childrenRect.height || contentLoader.item.implicitHeight) + pTop + pBottom;
        }
        return 0;
    }

    // Animating properties
    property int wrapperWidth: targetWrapperWidth
    property int wrapperHeight: targetWrapperHeight

    property int lastTargetWidth: 0
    property int lastTargetHeight: 0

    Binding {
        target: root
        property: "lastTargetWidth"
        value: root.targetWrapperWidth
        when: root.targetWrapperWidth > 0
    }

    Binding {
        target: root
        property: "lastTargetHeight"
        value: root.targetWrapperHeight
        when: root.targetWrapperHeight > 0
    }

    Behavior on wrapperWidth {
        Anim {}
    }

    Behavior on wrapperHeight {
        Anim {}
    }

    onWrapperWidthChanged: {
        if (wrapperWidth === 0 && wrapperHeight === 0 && wrapper === null) {
            root.closed();
        }
    }

    onWrapperHeightChanged: {
        if (wrapperWidth === 0 && wrapperHeight === 0 && wrapper === null) {
            root.closed();
        }
    }

    // Anchors
    required property bool aLeft
    required property bool aRight
    required property bool aTop
    required property bool aBottom
    required property bool aVerticalCenter
    required property bool aHorizontalCenter

    // Margins & offsets
    readonly property int mLeft: wrapper?.mLeft ?? 0
    readonly property int mRight: wrapper?.mRight ?? 0
    readonly property int mTop: wrapper?.mTop ?? 0
    readonly property int mBottom: wrapper?.mBottom ?? 0
    readonly property int vCenterOffset: wrapper?.vCenterOffset ?? 0
    readonly property int hCenterOffset: wrapper?.hCenterOffset ?? 0

    // Base settings
    readonly property int rounding: wrapper?.rounding ?? Config.backgrounds.rounding ?? 0
    readonly property bool invertBaseRounding: wrapper?.invertBaseRounding ?? Config.backgrounds.invertBaseRounding ?? false

    // Access zone
    required property int zWidth
    required property int zHeight

    // Exclusions
    required property int left_area
    required property int top_area
    required property int right_area
    required property int bottom_area

    required property bool excludeBarArea

    readonly property var content: wrapper?.content
    readonly property int pLeft: wrapper?.pLeft ?? Config.backgrounds.paddings.left ?? 0
    readonly property int pTop: wrapper?.pTop ?? Config.backgrounds.paddings.top ?? 0
    readonly property int pRight: wrapper?.pRight ?? Config.backgrounds.paddings.right ?? 0
    readonly property int pBottom: wrapper?.pBottom ?? Config.backgrounds.paddings.bottom ?? 0

    property int edgeRounding: 20

    preferredRendererType: Shape.CurveRenderer
    opacity: Colours.transparency.enabled ? Colours.transparency.base : 1

    function checkAnchors(position) {
        const expectLeft = position.includes("left");
        const expectRight = position.includes("right");
        const expectTop = position.includes("top");
        const expectBottom = position.includes("bottom");

        return (root.aLeft === expectLeft) && (root.aRight === expectRight) && (root.aTop === expectTop) && (root.aBottom === expectBottom);
    }

    Item {
        id: contentContainer
        x: {
            if (root.aLeft)
                return root.mLeft + (root.excludeBarArea ? root.left_area : 0);
            if (root.aHorizontalCenter)
                return (root.zWidth / 2) - (root.wrapperWidth / 2) + root.hCenterOffset;
            if (root.aRight)
                return root.zWidth - root.wrapperWidth - root.mRight - (root.excludeBarArea ? root.right_area : 0);
            return 0;
        }
        y: {
            var yi;
            if (root.aTop) {
                yi = root.mTop + (root.excludeBarArea ? root.top_area : 0);
            } else if (root.aVerticalCenter) {
                yi = (root.zHeight / 2) - (root.wrapperHeight / 2) + root.vCenterOffset;
            } else if (root.aBottom) {
                yi = root.zHeight - root.wrapperHeight - root.mBottom - (root.excludeBarArea ? root.bottom_area : 0);
            } else {
                yi = root.border_area;
            }
            return yi + 0;
        }

        width: root.wrapperWidth
        height: root.wrapperHeight

        StyledRect {
            anchors.fill: parent
            color: "green"
            opacity: 0.5
        }

        // Wrapper for scaling content
        Item {
            id: scalingRoot
            width: root.lastTargetWidth
            height: root.lastTargetHeight
            anchors.centerIn: parent

            transform: Scale {
                xScale: root.lastTargetWidth > 0 ? root.wrapperWidth / root.lastTargetWidth : 0
                yScale: root.lastTargetHeight > 0 ? root.wrapperHeight / root.lastTargetHeight : 0
                origin.x: scalingRoot.width / 2
                origin.y: scalingRoot.height / 2
            }

            Item {
                id: paddingContainer
                anchors.fill: parent
                anchors.leftMargin: root.pLeft
                anchors.topMargin: root.pTop
                anchors.rightMargin: root.pRight
                anchors.bottomMargin: root.pBottom

                StyledRect {
                    anchors.fill: parent
                    color: "red"
                    opacity: 0.5
                }

                Loader {
                    id: loader
                    sourceComponent: root.content

                    x: (parent.width - (item ? (item.childrenRect.width || item.implicitWidth) : 0)) / 2
                    y: (parent.height - (item ? (item.childrenRect.height || item.implicitHeight) : 0)) / 2

                    Component.onCompleted: {
                        root.contentLoader = loader;
                    }
                }
            }
        }
    }

    ShapePath {
        strokeWidth: -1
        fillColor: wrapperWidth > 0 && wrapperHeight > 0 ? Colours.palette.surface : "transparent"
        startX: {
            if (root.aLeft)
                return root.mLeft + (root.excludeBarArea ? root.left_area : 0);
            if (root.aHorizontalCenter)
                return (root.zWidth / 2) - (root.wrapperWidth / 2) + root.hCenterOffset;
            if (root.aRight)
                return root.zWidth - root.wrapperWidth - root.mRight - (root.excludeBarArea ? root.right_area : 0);
            return 0;
        }

        startY: {
            var y;
            if (root.aTop) {
                y = root.mTop + (root.excludeBarArea ? root.top_area : 0);
            } else if (root.aVerticalCenter) {
                y = (root.zHeight / 2) - (root.wrapperHeight / 2) + root.vCenterOffset;
            } else if (root.aBottom) {
                y = root.zHeight - root.wrapperHeight - root.mBottom - (root.excludeBarArea ? root.bottom_area : 0);
            } else {
                y = root.border_area;
            }
            return y + root.rounding * ((root.invertBaseRounding && (checkAnchors("left") || checkAnchors("left&bottom"))) ? -1 : 1);
        }

        // Left top corner
        PathArc {
            relativeX: !root.invertBaseRounding ? root.rounding : (((checkAnchors("top") || checkAnchors("top&right")) ? -1 : 1) * root.rounding)
            relativeY: !root.invertBaseRounding ? -root.rounding : (((checkAnchors("left") || checkAnchors("left&bottom")) ? -1 : 1) * -root.rounding)
            radiusX: Math.min(root.rounding, root.wrapperWidth)
            radiusY: -Math.min(root.rounding, root.wrapperHeight)
            direction: root.invertBaseRounding ? (((root.aTop === true) != (root.aLeft === true)) ? PathArc.Counterclockwise : PathArc.Clockwise) : PathArc.Clockwise
        }
        // Top edge
        PathLine {
            relativeX: root.wrapperWidth - root.rounding * (!root.invertBaseRounding ? 2 : (2 - 2 * ((root.aTop === true) + checkAnchors("top"))))
            relativeY: 0
        }
        // Right top corner
        PathArc {
            relativeX: !root.invertBaseRounding ? root.rounding : (((checkAnchors("top") || checkAnchors("left&top")) ? -1 : 1) * root.rounding)
            relativeY: !root.invertBaseRounding ? root.rounding : (((checkAnchors("right") || checkAnchors("right&bottom")) ? -1 : 1) * root.rounding)
            radiusX: Math.min(root.rounding, root.wrapperWidth)
            radiusY: Math.min(root.rounding, root.wrapperHeight)
            direction: root.invertBaseRounding ? (((root.aTop === true) != (root.aRight === true)) ? PathArc.Counterclockwise : PathArc.Clockwise) : PathArc.Clockwise
        }
        // Right edge
        PathLine {
            relativeX: 0
            relativeY: root.wrapperHeight - root.rounding * (!root.invertBaseRounding ? 2 : (2 - 2 * ((root.aRight === true) + checkAnchors("right"))))
        }
        // Right Bottom corner
        PathArc {
            relativeX: !root.invertBaseRounding ? -root.rounding : (((checkAnchors("bottom") || checkAnchors("left&bottom")) ? -1 : 1) * -root.rounding)
            relativeY: !root.invertBaseRounding ? root.rounding : (((checkAnchors("right") || checkAnchors("right&top")) ? -1 : 1) * root.rounding)
            radiusX: Math.min(root.rounding, root.wrapperWidth)
            radiusY: Math.min(root.rounding, root.wrapperHeight)
            direction: root.invertBaseRounding ? (((root.aBottom === true) != (root.aRight === true)) ? PathArc.Counterclockwise : PathArc.Clockwise) : PathArc.Clockwise
        }
        // Bottom edge
        PathLine {
            relativeX: -(root.wrapperWidth - root.rounding * (!root.invertBaseRounding ? 2 : (2 - 2 * ((root.aBottom === true) + checkAnchors("bottom")))))
            relativeY: 0
        }
        // Left bottom corner
        PathArc {
            relativeX: !root.invertBaseRounding ? -root.rounding : (((checkAnchors("bottom") || checkAnchors("right&bottom")) ? -1 : 1) * -root.rounding)
            relativeY: !root.invertBaseRounding ? -root.rounding : (((checkAnchors("left") || checkAnchors("left&top")) ? -1 : 1) * -root.rounding)
            radiusX: Math.min(root.rounding, root.wrapperWidth)
            radiusY: Math.min(root.rounding, root.wrapperHeight)
            direction: root.invertBaseRounding ? (((root.aBottom === true) != (root.aLeft === true)) ? PathArc.Counterclockwise : PathArc.Clockwise) : PathArc.Clockwise
        }
        // Left edge
        PathLine {
            relativeX: 0
            relativeY: -(root.wrapperHeight - root.rounding * (!root.invertBaseRounding ? 2 : (2 - 2 * ((root.aLeft === true) + checkAnchors("left")))))
        }

        Behavior on fillColor {
            ColorAnimation {
                duration: Appearance.anim.durations.small
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.curves.standard
            }
        }
    }
}
