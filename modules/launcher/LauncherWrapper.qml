pragma ComponentBehavior: Bound

import qs.config
import qs.utils
import Quickshell
import QtQuick
import qs.components
import QtQuick.Layouts
// import "content"

Item {
    id: root
    // required property int screenHeight
    // required property int screenWidth
    required property var manager
    required property ShellScreen screen

    // Visibility state
    property bool launcherVisible: false


    // Регистрация visibility через менеджер (с поддержкой pendingRequests)
    Component.onCompleted: {
        VisibilitiesManager.addVisibility(root.screen, "launcher", "launcher", false, false, "Toggle Launcher");
    }

    // Слушаем изменения visibility от глобального менеджера
    Connections {
        target: VisibilitiesManager
        function onVisibilityChanged(screen: ShellScreen, name: string, state: bool) {
            if (screen === root.screen && name === "launcher") {
                root.launcherVisible = state;
            }
        }
    }

    property QtObject content: QtObject {
        // Content size
        property int wrapperWidth: 0
        property int wrapperHeight: 0
        // Anchors
        property bool aLeft: Config.launcher.anchors.left ?? undefined
        property bool aRight: Config.launcher.anchors.right ?? undefined
        property bool aTop: Config.launcher.anchors.top ?? undefined
        property bool aBottom: Config.launcher.anchors.bottom ?? undefined
        property bool aHorizontalCenter: Config.launcher.anchors.horizontalCenter ?? undefined
        property bool aVerticalCenter: Config.launcher.anchors.verticalCenter ?? undefined
        // Margins & offsets
        property var mLeft: Config.launcher.offsets.left ?? Config.launcher.offsets.all
        property var mRight: Config.launcher.offsets.right ?? Config.launcher.offsets.all
        property var mTop: Config.launcher.offsets.top ?? Config.launcher.offsets.all
        property var mBottom: Config.launcher.offsets.bottom ?? Config.launcher.offsets.all
        property var mHorizontalCenter: Config.launcher.offsets.horizontalCenter ?? Config.launcher.offsets.all
        property var mVerticalCenter: Config.launcher.offsets.verticalCenter ?? Config.launcher.offsets.all
        // Paddings
        property var pLeft: Config.launcher.paddings.left ?? Config.launcher.paddings.all
        property var pRight: Config.launcher.paddings.right ?? Config.launcher.paddings.all// ?? 0
        property var pTop: Config.launcher.paddings.top ?? Config.launcher.paddings.all// ?? 0
        property var pBottom: Config.launcher.paddings.bottom ?? Config.launcher.paddings.all// ?? 0
        // Base settings
        property int rounding: Config.launcher.rounding ?? undefined
        property bool invertBaseRounding: Config.launcher.invertBaseRounding ?? undefined
        // Bar exclusion
        property bool excludeBarArea: true
        // Reusability
        property bool reusable: Config.launcher.reusability ?? undefined

        property Component content: FlexboxLayout {
            // required property ShellScreen screen
            direction: (Config.launcher.direction ?? (Config.launcher.anchors.top || Config.launcher.anchors.verticalCenter)) ? FlexboxLayout.Column : FlexboxLayout.ColumnReverse
            alignItems: FlexboxLayout.AlignCenter
            justifyContent: (Config.launcher.direction ?? (Config.launcher.anchors.top || Config.launcher.anchors.verticalCenter)) ? FlexboxLayout.JustifyStart : FlexboxLayout.JustifyEnd
            gap: Config.launcher.gap ?? 0

            StyledRect {
                color: "gray"
                opacity: 0.5
                implicitWidth: 600
                implicitHeight: 70
            }
            StyledRect {
                color: "gray"
                opacity: 0.5
                implicitWidth: 600
                implicitHeight: 400
            }
        }
    }

    // anchors.leftMargin: Config.bar.orientation ? Config.bar.shortSideMargin : Config.bar.longSideMargin
    // anchors.topMargin: Config.bar.orientation ? Config.bar.longSideMargin : Config.bar.shortSideMargin
    // anchors.rightMargin: Config.bar.orientation ? Config.bar.shortSideMargin : Config.bar.longSideMargin
    // anchors.bottomMargin: Config.bar.orientation ? Config.bar.longSideMargin : Config.bar.shortSideMargin

    Loader {
        id: launcherLoader
        active: root.launcherVisible
        // anchors.fill: parent

        sourceComponent: Item {
            // anchors.fill: parent

            Component.onCompleted: {
                root.manager.requestBackground(root.content, false, false);
            }

            Component.onDestruction: {
                root.manager.removeBackground(root.content);
            }
        }
    }
}
