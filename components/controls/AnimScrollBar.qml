import QtQuick
import QtQuick.Effects
import qs.components
import qs.services
import qs.config

Item {
    id: root

    default property Item contentItem
    onContentItemChanged: {
        if (contentItem) {
            contentItem.parent = contentContainer
            contentItem.anchors.fill = contentContainer
        }
    }

    property Flickable flickable

    property string position: "right"
    property bool viaTop:  true
    property bool viaLeft: true

    property real barThickness: 6
    property real barSpacing:   8
    property real barMargin:    10

    // ── Цвета и радиусы ───────────────────────────────────────────────────────
    property color trackColor:      Colours.alpha(Colours.palette.surface_container, 0.6)
    property color thumbColor:      Colours.alpha(Colours.palette.secondary, 0.55)
    property color thumbMiniColor:  Colours.palette.primary
    property real  trackRadius:     3
    property real  thumbRadius:     999
    property real  thumbMiniRadius: 999

    // ── AutoHide ─────────────────────────────────────────────────────────────
    property bool autoHide:  true
    property int  hideDelay: 1200

    property bool _thumbHovered: false
    property bool _trackHovered: false
    property bool _dragging:     false
    property bool _scrolling:    false
    property bool _animating:    false

    property bool _barVisible: !autoHide || _thumbHovered || _trackHovered || _dragging || _scrolling// || _animating

    Timer {
        id: hideTimer
        interval: root.hideDelay
        onTriggered: root._scrolling = false
    }

    Connections {
        target: root.flickable ?? null
        function onMovingChanged() {
            if (root.flickable.moving) { root._scrolling = true; hideTimer.restart() }
        }
        function onContentYChanged() { root._scrolling = true; hideTimer.restart() }
        function onContentXChanged() { root._scrolling = true; hideTimer.restart() }
    }

    // ── Периметр ─────────────────────────────────────────────────────────────

    readonly property real w: width
    readonly property real h: height
    readonly property real perimeter: (w > 0 && h > 0) ? (2 * w + 2 * h) : 1

    property real headPos: 0
    property real tailPos: 0

    property string _lastPos: position
    property int    _cycle:   0
    property int    _lastDir: 1
    property bool   _ready:   false

    Behavior on headPos {
        NumberAnimation {
            id: headAnim
            duration: 420
            easing.type: Easing.OutCubic
            onRunningChanged: root._animating = headAnim.running || tailAnimObj.running
        }
    }
    Behavior on tailPos {
        NumberAnimation {
            id: tailAnimObj
            duration: 860
            easing.type: Easing.OutCubic
            onRunningChanged: root._animating = headAnim.running || tailAnimObj.running
        }
    }

    onPositionChanged:  Qt.callLater(_updateAnim)
    onViaTopChanged:    Qt.callLater(_updateAnim)
    onViaLeftChanged:   Qt.callLater(_updateAnim)
    onBarMarginChanged: Qt.callLater(_applyLayout)
    onWChanged:         Qt.callLater(_applyLayout)
    onHChanged:         Qt.callLater(_applyLayout)

    Component.onCompleted: {
        _lastPos = position
        _cycle   = 0
        _lastDir = 1
        _ready   = true
        _applyLayout()
        if (contentItem && contentItem.parent !== contentContainer) {
            contentItem.parent = contentContainer
            contentItem.anchors.fill = contentContainer
        }
    }

    // ── Вспомогательные функции ───────────────────────────────────────────────

    function _center(pos) {
        let c = {
            "top":    0.5 * w,
            "right":  w + 0.5 * h,
            "bottom": 1.5 * w + h,
            "left":   2 * w + 1.5 * h
        }
        return c[pos] ?? 0
    }

    function _faceLen(pos) {
        return (pos === "top" || pos === "bottom") ? w : h
    }

    function _applyLayout() {
        if (!_ready || perimeter <= 1) return
        let center = _center(_lastPos) + _cycle * perimeter
        let half   = Math.max(0, _faceLen(_lastPos) / 2 - barMargin)
        if (_lastDir >= 0) {
            headPos = center + half
            tailPos = center - half
        } else {
            headPos = center - half
            tailPos = center + half
        }
    }

    function _updateAnim() {
        if (!_ready || perimeter <= 1) return
        let oldPos = _lastPos
        let newPos = position
        if (oldPos === newPos) return

        let halfP   = perimeter / 2
        let isHoriz = (oldPos === "right" && newPos === "left") || (oldPos === "left" && newPos === "right")
        let isVert  = (oldPos === "top" && newPos === "bottom") || (oldPos === "bottom" && newPos === "top")

        let diff = 0
        if (isHoriz) {
            if (oldPos === "right") diff = viaTop ? -halfP :  halfP
            else                    diff = viaTop ?  halfP : -halfP
        } else if (isVert) {
            if (oldPos === "top") diff = viaLeft ? -halfP :  halfP
            else                  diff = viaLeft ?  halfP : -halfP
        } else {
            diff = _center(newPos) - _center(oldPos)
            if (diff >  halfP) diff -= perimeter
            if (diff < -halfP) diff += perimeter
        }

        let oldCenter = _center(oldPos) + _cycle * perimeter
        let newCenter = oldCenter + diff

        _cycle   = Math.round((newCenter - _center(newPos)) / perimeter)
        _lastDir = diff >= 0 ? 1 : -1
        _lastPos = newPos

        _applyLayout()
    }

    // rawProg = 0 (начало контента) .. 1 (конец контента)
    function _scrollToProgress(rawProg) {
        if (!flickable) return
        let isH = (position === "top" || position === "bottom")
        let p   = Math.max(0, Math.min(1, rawProg))
        if (isH) {
            flickable.contentX = p * Math.max(0, flickable.contentWidth  - flickable.width)
        } else {
            flickable.contentY = p * Math.max(0, flickable.contentHeight - flickable.height)
        }
    }

    function _perimToXY(p) {
        let pp = ((p % perimeter) + perimeter) % perimeter
        let bt = root.barThickness
        if (pp <= w) {
            return { x: pp, y: bt / 2 }
        } else if (pp <= w + h) {
            return { x: w - bt / 2, y: pp - w }
        } else if (pp <= 2*w + h) {
            return { x: (2*w + h) - pp, y: h - bt / 2 }
        } else {
            return { x: bt / 2, y: (2*w + 2*h) - pp }
        }
    }

    // ── Контейнер контента ────────────────────────────────────────────────────
    // Во время анимации (_animating) добавляем отступы со всех сторон,
    // чтобы бар не накладывался на контент при переползании.

    Item {
        id: contentContainer
        anchors.fill: parent

        readonly property real offset: root.barThickness + root.barSpacing

        // Когда анимируется — отступы со всех сторон
        // Когда статично — только со стороны position
        // Когда скрыт — отступов нет (отдаём место)
        anchors.leftMargin:   ((root._animating || root.position === "left")   && root._barVisible) ? offset : 0
        anchors.topMargin:    ((root._animating || root.position === "top")    && root._barVisible) ? offset : 0
        anchors.rightMargin:  ((root._animating || root.position === "right")  && root._barVisible) ? offset : 0
        anchors.bottomMargin: ((root._animating || root.position === "bottom") && root._barVisible) ? offset : 0

        Behavior on anchors.leftMargin   { NumberAnimation { duration: 420; easing.type: Easing.OutCubic } }
        Behavior on anchors.rightMargin  { NumberAnimation { duration: 420; easing.type: Easing.OutCubic } }
        Behavior on anchors.topMargin    { NumberAnimation { duration: 420; easing.type: Easing.OutCubic } }
        Behavior on anchors.bottomMargin { NumberAnimation { duration: 420; easing.type: Easing.OutCubic } }
    }

    // ── PathSegment ───────────────────────────────────────────────────────────

    component PathSegment : Item {
        id: seg

        property real  startP:       0
        property real  endP:         0
        property color segmentColor: "white"
        property real  thickness:    root.barThickness
        property real  edgeOffset:   0
        property real  segRadius:    root.trackRadius

        readonly property real p:    root.perimeter
        readonly property real rawA: Math.min(startP, endP)
        readonly property real rawB: Math.max(startP, endP)
        readonly property int  base: Math.floor(rawA / p)
        readonly property real a:    rawA - base * p
        readonly property real b:    rawB - base * p

        anchors.fill: parent
        z: 10

        Repeater {
            model: [-1, 0, 1, 2]
            delegate: Item {
                anchors.fill: parent
                readonly property real shift: modelData * seg.p
                readonly property real sA:    seg.a - shift
                readonly property real sB:    seg.b - shift

                Rectangle {
                    visible: parent.sA < root.w && parent.sB > 0
                    color: seg.segmentColor; radius: seg.segRadius
                    y: seg.edgeOffset; height: seg.thickness
                    readonly property real s: Math.max(parent.sA, 0)
                    readonly property real e: Math.min(parent.sB, root.w)
                    x: s; width: Math.max(0, e - s)
                }
                Rectangle {
                    visible: parent.sA < root.w + root.h && parent.sB > root.w
                    color: seg.segmentColor; radius: seg.segRadius
                    x: root.w - seg.thickness - seg.edgeOffset; width: seg.thickness
                    readonly property real s: Math.max(parent.sA, root.w)
                    readonly property real e: Math.min(parent.sB, root.w + root.h)
                    y: s - root.w; height: Math.max(0, e - s)
                }
                Rectangle {
                    visible: parent.sA < 2*root.w + root.h && parent.sB > root.w + root.h
                    color: seg.segmentColor; radius: seg.segRadius
                    y: root.h - seg.thickness - seg.edgeOffset; height: seg.thickness
                    readonly property real s: Math.max(parent.sA, root.w + root.h)
                    readonly property real e: Math.min(parent.sB, 2*root.w + root.h)
                    x: (2*root.w + root.h) - e; width: Math.max(0, e - s)
                }
                Rectangle {
                    visible: parent.sA < 2*root.w + 2*root.h && parent.sB > 2*root.w + root.h
                    color: seg.segmentColor; radius: seg.segRadius
                    x: seg.edgeOffset; width: seg.thickness
                    readonly property real s: Math.max(parent.sA, 2*root.w + root.h)
                    readonly property real e: Math.min(parent.sB, 2*root.w + 2*root.h)
                    y: (2*root.w + 2*root.h) - e; height: Math.max(0, e - s)
                }
            }
        }
    }

    // ── Track ──────────────────────────────────────────────────────────────────

    PathSegment {
        startP:       root.tailPos
        endP:         root.headPos
        segmentColor: root.trackColor
        thickness:    root.barThickness
        edgeOffset:   0
        segRadius:    root.trackRadius
        opacity:      root._barVisible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 400 } }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: root._trackHovered = true
            onExited:  root._trackHovered = false
        }
    }

    // ── Thumb ──────────────────────────────────────────────────────────────────

    Item {
        id: thumbItem
        anchors.fill: parent
        z: 12

        opacity: root._barVisible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 400 } }

        readonly property bool isHoriz:  root.position === "top"  || root.position === "bottom"
        // reversed — только для отображения (позиция пилюли на треке)
        readonly property bool reversed: root.position === "bottom" || root.position === "left"

        readonly property real viewRatio: {
            if (!root.flickable) return 1.0
            let r = isHoriz
                ? root.flickable.visibleArea.widthRatio
                : root.flickable.visibleArea.heightRatio
            return Math.min(1.0, Math.max(0.0, r))
        }

        readonly property real scrollPos: root.flickable
            ? (isHoriz ? root.flickable.visibleArea.xPosition
                       : root.flickable.visibleArea.yPosition)
            : 0.0

        readonly property real maxScroll:   Math.max(0.0, 1.0 - viewRatio)
        // rawProgress: 0=начало контента, 1=конец — не зависит от направления оси
        readonly property real rawProgress: maxScroll > 0
            ? Math.max(0.0, Math.min(1.0, scrollPos / maxScroll))
            : 0.0
        // progress: для позиции пилюли на треке (с учётом reversed)
        readonly property real progress: reversed ? (1.0 - rawProgress) : rawProgress

        readonly property real tA:        Math.min(root.headPos, root.tailPos)
        readonly property real tB:        Math.max(root.headPos, root.tailPos)
        readonly property real trackLen:  tB - tA
        readonly property real thumbLen:  trackLen * viewRatio
        readonly property real travelLen: Math.max(0, trackLen - thumbLen)

        readonly property real startP: tA + travelLen * progress
        readonly property real endP:   tA + thumbLen  + travelLen * progress

        property real expandedThickness: root.barThickness * (thumbDrag.active ? 3.2 : (thumbMouse.containsMouse ? 2.0 : 1.0))
        Behavior on expandedThickness { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        readonly property real thumbEdgeOffset: (root.barThickness - expandedThickness) / 2

        PathSegment {
            id: thumbSeg
            startP:       thumbItem.startP
            endP:         thumbItem.endP
            segmentColor: root.thumbColor
            thickness:    thumbItem.expandedThickness
            edgeOffset:   thumbItem.thumbEdgeOffset
            segRadius:    root.thumbRadius

            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur:        0.3
                blurMax:     12
            }
        }

        Item {
            id: miniPill
            opacity: thumbDrag.active ? 0.95 : 0.0
            Behavior on opacity { NumberAnimation { duration: 150 } }

            readonly property var midPt:      root._perimToXY((thumbItem.startP + thumbItem.endP) / 2)
            readonly property real segLen:    Math.max(0, thumbItem.endP - thumbItem.startP)
            readonly property real miniLen:   segLen * 0.4
            readonly property real miniThick: thumbItem.expandedThickness * 0.4

            x: midPt.x - (thumbItem.isHoriz ? miniLen / 2 : miniThick / 2)
            y: midPt.y - (thumbItem.isHoriz ? miniThick / 2 : miniLen / 2)
            width:  thumbItem.isHoriz ? miniLen   : miniThick
            height: thumbItem.isHoriz ? miniThick : miniLen

            Rectangle {
                anchors.fill: parent
                radius: root.thumbMiniRadius
                color:  root.thumbMiniColor
            }
        }

        MouseArea {
            id: thumbMouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: root._thumbHovered = true
            onExited:  root._thumbHovered = thumbDrag.active
        }

        DragHandler {
            id: thumbDrag
            target: null

            property real _startRawProgress: 0
            property real _startY: 0
            property real _startX: 0

            onActiveChanged: {
                root._dragging     = active
                root._thumbHovered = active
                if (active) {
                    _startRawProgress = thumbItem.rawProgress
                    _startY = centroid.position.y
                    _startX = centroid.position.x
                }
            }

            onCentroidChanged: {
                if (!active || thumbItem.travelLen <= 0) return

                // delta в экранных координатах (вниз/вправо = +)
                let delta = thumbItem.isHoriz
                    ? (centroid.position.x - _startX)
                    : (centroid.position.y - _startY)

                // right/left: drag вниз → скролл вниз (не инвертируем)
                // bottom: пилюля reversed, drag вправо → скролл влево (инвертируем)
                let invertDrag = root.position === "bottom"
                let rawProg = _startRawProgress + (invertDrag ? -delta : delta) / thumbItem.travelLen
                root._scrollToProgress(Math.max(0, Math.min(1, rawProg)))
            }
        }
    }
}
