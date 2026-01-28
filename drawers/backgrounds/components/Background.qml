pragma ComponentBehavior: Bound

import qs.config
import QtQuick
import qs.services
import QtQuick.Shapes
import Quickshell
import qs.widgets

Shape {
    id: root

    required property var wrapper

    // Content size
    // readonly property int wrapperWidth: wrapper?.wrapperWidth ?? wrapper. ?? 0
    // readonly property int wrapperHeight: wrapper?.wrapperHeight ?? ?? 0
    property Item contentLoader: null

    property int cachedContentWidth: 0
    property int cachedContentHeight: 0

    readonly property int wrapperWidth: {
        // Если явно задана ширина - используем её
        if (wrapper?.wrapperWidth !== undefined && wrapper.wrapperWidth !== null && wrapper.wrapperWidth > 0) {
            return wrapper.wrapperWidth;
        }
        // Иначе берём кэшированный размер контента + padding
        return cachedContentWidth + pLeft + pRight;
    }

    readonly property int wrapperHeight: {
        // Если явно задана высота - используем её
        if (wrapper?.wrapperHeight !== undefined && wrapper.wrapperHeight !== null && wrapper.wrapperHeight > 0) {
            return wrapper.wrapperHeight;
        }
        // Иначе берём кэшированный размер контента + padding
        return cachedContentHeight + pTop + pBottom;
    }
    // Component.onCompleted: {
    //     console.warn("hell", wrapperWidth);
    // }

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
            return y;// + root.rounding * ((root.invertBaseRounding && (checkAnchors("left") || checkAnchors("left&bottom"))) ? -1 : 1);
        }
        // implicitWidth: root.wrapperWidth
        // implicitHeight: root.wrapperHeight
        width: root.wrapperWidth
        height: root.wrapperHeight
        // color: "green"
        // opacity:0.5
        Item {
            id: paddingContainer
            anchors.fill: parent
            anchors.leftMargin: root.pLeft
            anchors.topMargin: root.pTop
            anchors.rightMargin: root.pRight
            anchors.bottomMargin: root.pBottom

            Loader {
                id: loader

                sourceComponent: root.content  // Загружаем Component

                function updatePosition() {
                    if (item) {
                        var w = item.childrenRect.width || item.implicitWidth || 0;
                        var h = item.childrenRect.height || item.implicitHeight || 0;
                        root.cachedContentWidth = w;
                        root.cachedContentHeight = h;
                        x = (parent.width - w) / 2;
                        y = (parent.height - h) / 2;
                    }
                }

                Connections {
                    target: loader.item
                    function onChildrenRectChanged() { Qt.callLater(loader.updatePosition) }
                    function onImplicitWidthChanged() { Qt.callLater(loader.updatePosition) }
                    function onImplicitHeightChanged() { Qt.callLater(loader.updatePosition) }
                }

                onItemChanged: Qt.callLater(updatePosition)

                Component.onCompleted: {
                    root.contentLoader = loader;
                    Qt.callLater(updatePosition);
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
            direction: root.invertBaseRounding ? (((root.aBottom === true) != (aLeft === true)) ? PathArc.Counterclockwise : PathArc.Clockwise) : PathArc.Clockwise
        }
        // Left edge
        PathLine {
            relativeX: 0
            relativeY: -(root.wrapperHeight - root.rounding * (!root.invertBaseRounding ? 2 : (2 - 2 * ((root.aLeft === true) + checkAnchors("left")))))
        }
        // fillGradient: RadialGradient {
        //         centerX: 100; centerY: 100
        //         // radius: 50
        //         centerRadius: 150
        // focalX: centerX; focalY: centerY
        //         GradientStop { position: 0.0; color: "blue" }
        //         GradientStop { position: 0.2; color: "green" }
        //         GradientStop { position: 0.4; color: "red" }
        //         GradientStop { position: 0.6; color: "yellow" }
        //         GradientStop { position: 1.0; color: "cyan" }
        //     }
        // fillGradient: RadialGradient {
        //     // x1: 0
        //     // y1: 0
        //     // x2: p.fieldWidth
        //     // y2: p.fieldHeight
        //     centerX: 100
        //     centerY: 100
        //     centerRadius: 50

        //     GradientStop {
        //         position: 0.0
        //         color: "#287384"
        //     }
        //     GradientStop {
        //         position: 1.0
        //         color: "#000000"
        //     }
        // }
        Behavior on fillColor {
            ColorAnimation {
                duration: Appearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.curves.standard
            }
        }

        // Behavior on ibr {
        //     NumberAnimation {
        //         duration: Appearance.anim.durations.normal
        //         easing.type: Easing.BezierSpline
        //         easing.bezierCurve: Appearance.anim.curves.standard
        //     }
        // }
    }
}
