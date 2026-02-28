import QtQuick
import QtQuick.Layouts
import qs.config
import qs.utils
import qs.components
import qs.components.controls
import qs.components.images
import qs.services
import Quickshell.Widgets
import Quickshell
// import qs.modules.launcher.content.components
// import "." // Для доступа к BaseModule

LauncherModule {
    id: root

    moduleId: "app_list"
    name: "Applications"
    description: "Search and launch applications"
    icon: "💻"
    trigger: "" // Дефолтный модуль

    hasLeftPanel: true
    hasRightPanel: false
    customRightWidth: 350

    // listModel: internalModel
    // ListModel { id: internalModel }

    // Текущее выбранное приложение для отображения в правой панели
    property var selectedApp: null
    property var _pendingApp: null

    Timer {
        id: debounceTimer
        interval: 80
        onTriggered: selectedApp = _pendingApp
    }

    // В onSelected вместо прямого присвоения:
    onSelected: function() {
        if (root.hasRightPanel) {
            root._pendingApp = app
            debounceTimer.restart()
        }
    }

    // Если панель открыли кнопкой, автоматически выбираем первое приложение
    onHasRightPanelChanged: {
        if (hasRightPanel && !selectedApp && internalModel.count > 0) {
            selectedApp = internalModel.get(0).rawApp;
        }
    }

    function onActivated(initialQuery) {
        hasRightPanel = false
        handleInput(initialQuery)
    }

    // Добавь:
    Connections {
        target: DesktopEntries.applications
        function onValuesChanged() {
            if (root.isActive) handleInput("")
        }
    }

    // Убери эти две строки:
    // listModel: internalModel
    // ListModel { id: internalModel }
    property bool isPinned: false
    property bool isHidden: false

    // Обновляй при смене приложения:
    onSelectedAppChanged: {
        isPinned = false  // TODO: проверять реальное состояние из конфига
        isHidden = false
    }

    function togglePin() {
        if (!selectedApp) return
        isPinned = !isPinned
        console.log("Pinning app:", selectedApp.name, isPinned)
    }

    function toggleHide() {
        if (!selectedApp) return
        isHidden = !isHidden
        console.log("Hiding app:", selectedApp.name, isHidden)
        if (isHidden) {
            hasRightPanel = false
            handleInput("")
        }
    }

    property var callbacks: []

    // ListModel { id: internalModel }
    ScriptModel {
        id: internalModel
    }

    listModel: internalModel

    function handleInput(query) {
        selectedApp = null
        let results = Apps.query(query).slice(0, 50)

        internalModel.values = results.map(app => ({
            header: app.name ?? "Unknown App",
            text: app.comment || app.genericName || "",
            leftIcon: app.icon ?? "",
            isLeftIconImage: true,
            rightIcon: "\ue895",
            rightText: "",
            onClicked: function() {
                Apps.launch(app)
                requestClose(true)
            },
            onAltClicked: function() {
                if (root.selectedApp === app && root.hasRightPanel) {
                    root.hasRightPanel = false
                    root.selectedApp = null
                } else {
                    root.selectedApp = app
                    root.hasRightPanel = true
                }
            },
            onSelected: function() {
                if (root.hasRightPanel) root.selectedApp = app
            }
        }))
    }

    // ==========================================
    // КНОПКА ДЛЯ ROW INPUT
    // ==========================================
    inputExtensionComponent: Component {
        StyledRect {
            implicitWidth: 32
            implicitHeight: 32
            radius: Appearance.rounding.small ?? 8
            color: toggleArea.containsMouse ? Colours.alpha(Colours.palette.on_surface, 0.1) : "transparent"

            StyledIcon {
                anchors.centerIn: parent
                // Иконка сайдбара из Material: view_sidebar / chrome_reader_mode
                text: root.hasRightPanel ? "\ufc3d" : "\ufc3e"
                font.pointSize: Appearance.font.size.large ?? 16
                color: root.hasRightPanel ? Colours.palette.primary : Colours.palette.on_surface_variant
            }

            MouseArea {
                id: toggleArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    root.hasRightPanel = !root.hasRightPanel;
                }
            }
        }
    }

    // ==========================================
    // ГЛОБАЛЬНЫЕ ШОРТКАТЫ (Работают при открытой панели)
    // ==========================================
    shortcutsComponent: Component {
        Item {
            Shortcut {
                sequence: "Ctrl+P"
                onActivated: togglePin()
            }
            Shortcut {
                sequence: "Ctrl+H"
                onActivated: toggleHide()
            }
        }
    }

    // function togglePin() {
    //     if (!selectedApp) return;
    //     console.log("Pinning app:", selectedApp.name);
    // }

    // function toggleHide() {
    //     if (!selectedApp) return;
    //     console.log("Hiding app:", selectedApp.name);
    //     hasRightPanel = false;
    //     handleInput("");
    // }

    // ==========================================
    // ПРАВАЯ ПАНЕЛЬ (Детали приложения)
    // ==========================================
    //
    rightPanelComponent: Component {
        Item {
            id: panelRoot
            anchors.fill: parent

            property var displayedApp: root.selectedApp

            Connections {
                target: root
                function onSelectedAppChanged() { fadeOut.start() }
            }

            SequentialAnimation {
                id: fadeOut
                ParallelAnimation {
                    Anim { target: content; property: "opacity"; to: 0; duration: Appearance.anim.durations.small }
                    Anim { target: content; property: "scale";   to: 0.97; duration: Appearance.anim.durations.small }
                }
                ScriptAction {
                    script: { panelRoot.displayedApp = root.selectedApp; fadeIn.start() }
                }
            }

            ParallelAnimation {
                id: fadeIn
                Anim { target: content; property: "opacity"; to: 1; duration: Appearance.anim.durations.small }
                Anim { target: content; property: "scale";   to: 1; duration: Appearance.anim.durations.small }
            }

            ColumnLayout {
                id: content
                anchors.centerIn: parent
                width: parent.width - Appearance.padding.large * 2
                spacing: 12
                transformOrigin: Item.Center

                // ── Иконка + заголовок ────────────────────────────────────────
                CachingIconImage {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 128
                    Layout.preferredHeight: 128
                    source: panelRoot.displayedApp
                        ? Quickshell.iconPath(panelRoot.displayedApp.icon, "application-x-executable")
                        : ""
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: panelRoot.displayedApp?.name ?? ""
                    font.pointSize: Appearance.font.size.large
                    font.weight: Font.DemiBold
                    color: Colours.palette.primary
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: panelRoot.displayedApp?.comment || panelRoot.displayedApp?.genericName || ""
                    font.pointSize: Appearance.font.size.small
                    color: Colours.alpha(Colours.palette.on_surface, 0.5)
                    visible: text !== ""
                }

                // ── Настройки ─────────────────────────────────────────────────
                SectionContainer {
                    Layout.fillWidth: true

                    SwitchRow {
                        label: "Pin app"
                        checked: root.isPinned
                        onToggled: function() { root.togglePin() }
                        tooltip: "Ctrl+P"
                        // implicitHeight: row.implicitHeight + Appearance.padding.normal
                        icon: root.isPinned ? "\uf68d" : "\uec9c"
                        color: "transparent"
                        paddings: 0
                    }

                    SwitchRow {
                        label: "Hide app"
                        checked: root.isHidden
                        onToggled: function() { root.toggleHide() }
                        tooltip: "Ctrl+H"
                        icon: root.isHidden ? "\uecf0" : "\uea9a"
                        color: "transparent"
                        paddings: 0
                    }
                }
            }
        }
    }
}
