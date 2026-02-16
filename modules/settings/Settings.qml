import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../../services"
import "../../config"
// Импортируем ваши локальные модули
import "../../components/containers"
import "../../components/controls"
import "../../components/effects"
import "../../components/misc"
import "../../components"

StyledWindow {
    id: root
    name: "settings" // Требуется для StyledWindow (PanelWindow)

    // Размеры и позиционирование
    width: 1100
    height: 750
    // minimumWidth: 750
    // minimumHeight: 500

    // Свойства логики
    property real contentPadding: 8
    property bool showNextTime: false
    property var pages: [
        {
            name: qsTr("Quick"),
            icon: "instant_mix",
            component: "modules/settings/QuickConfig.qml"
        },
        {
            name: qsTr("General"),
            icon: "browse",
            component: "modules/settings/GeneralConfig.qml"
        },
        {
            name: qsTr("Bar"),
            icon: "toast",
            component: "modules/settings/BarConfig.qml",
            iconRotation: 180
        },
        {
            name: qsTr("Background"),
            icon: "texture",
            component: "modules/settings/BackgroundConfig.qml"
        },
        {
            name: qsTr("Interface"),
            icon: "bottom_app_bar",
            component: "modules/settings/InterfaceConfig.qml"
        },
        {
            name: qsTr("Services"),
            icon: "settings",
            component: "modules/settings/ServicesConfig.qml"
        },
        {
            name: qsTr("Advanced"),
            icon: "construction",
            component: "modules/settings/AdvancedConfig.qml"
        },
        {
            name: qsTr("About"),
            icon: "info",
            component: "modules/settings/About.qml"
        }
    ]
    property int currentPage: 0
    property bool navExpanded: width > 900

    Component.onCompleted: {
        // MaterialThemeLoader.reapplyTheme() // Раскомментировать если этот синглтон доступен
        // Config.readWriteDelay = 0
    }

    // Основной фон окна (т.к. StyledWindow прозрачный)
    StyledRect {
        anchors.fill: parent
        color: Colours.palette.background // Используем Colours из вашей библиотеки
        radius: 15//Appearance.rounding.windowRounding

        // Обработка клавиш
        focus: true
        Keys.onPressed: (event) => {
            if (event.modifiers === Qt.ControlModifier) {
                if (event.key === Qt.Key_PageDown) {
                    root.currentPage = Math.min(root.currentPage + 1, root.pages.length - 1)
                    event.accepted = true;
                }
                else if (event.key === Qt.Key_PageUp) {
                    root.currentPage = Math.max(root.currentPage - 1, 0)
                    event.accepted = true;
                }
                else if (event.key === Qt.Key_Tab) {
                    root.currentPage = (root.currentPage + 1) % root.pages.length;
                    event.accepted = true;
                }
                else if (event.key === Qt.Key_Backtab) {
                    root.currentPage = (root.currentPage - 1 + root.pages.length) % root.pages.length;
                    event.accepted = true;
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: root.contentPadding
            spacing: 0

            // --- Titlebar ---
            Item {
                // visible: Config.options?.windows.showTitlebar // Раскомментировать при наличии конфига
                Layout.fillWidth: true
                Layout.preferredHeight: 40 // Фиксируем высоту заголовка

                StyledText {
                    id: titleText
                    anchors {
                        left: parent.left // Config.options.windows.centerTitle ? undefined : parent.left
                        // horizontalCenter: Config.options.windows.centerTitle ? parent.horizontalCenter : undefined
                        verticalCenter: parent.verticalCenter
                        leftMargin: 12
                    }
                    color: Colours.palette.on_surface
                    text: qsTr("Settings")
                    // font.family: Appearance.font.family.title
                    // font.pixelSize: //Appearance.font.size.title
                }

                RowLayout {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right

                    IconButton {
                        type: IconButton.Text
                        icon: "close"
                        onClicked: Qt.quit()
                    }
                }
            }

            // --- Main Content Area ---
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: root.contentPadding

                // --- Navigation Rail ---
                ColumnLayout {
                    id: navRail
                    Layout.fillHeight: true
                    Layout.preferredWidth: root.navExpanded ? 180 : 60 // Анимацию ширины можно добавить через Behavior
                    spacing: 10

                    Behavior on Layout.preferredWidth {
                        NumberAnimation {
                            duration: Appearance.anim.durations.expressiveFastSpatial
                            easing.bezierCurve: Appearance.anim.curves.expressiveFastSpatial
                        }
                    }

                    // Кнопка разворачивания меню
                    IconButton {
                        Layout.alignment: Qt.AlignLeft
                        icon: root.navExpanded ? "menu_open" : "menu"
                        type: IconButton.Text
                        toggle: true
                        checked: root.navExpanded
                        onClicked: root.navExpanded = !root.navExpanded
                    }

                    // FAB (Config Button)
                    IconTextButton {
                        id: fab
                        Layout.alignment: Qt.AlignLeft
                        Layout.fillWidth: root.navExpanded

                        property bool justCopied: false

                        type: IconTextButton.Filled
                        icon: justCopied ? "check" : "edit"
                        text: root.navExpanded ? (justCopied ? qsTr("Copied") : qsTr("Config")) : ""

                        // Скрываем текст визуально если свернуто, чтобы иконка была по центру
                        // В IconTextButton логика: implicitWidth зависит от row. Если text пустой,
                        // он должен схлопнуться до иконки + паддингов.

                        onClicked: {
                            Qt.openUrlExternally(`${Directories.config}/illogical-impulse/config.json`);
                        }

                        // Правый клик (придется использовать MouseArea поверх, если IconTextButton не поддерживает rightClick)
                        // Но если использовать onClicked для копирования при modifier:
                        // Реализуем через MouseArea внутри кнопки, если сам компонент не дает altAction
                        CustomMouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.RightButton
                            onClicked: {
                                Quickshell.clipboardText = `${Directories.config}/illogical-impulse/config.json` // Упрощено
                                fab.justCopied = true;
                                revertTextTimer.restart()
                            }
                        }

                        Timer {
                            id: revertTextTimer
                            interval: 1500
                            onTriggered: fab.justCopied = false;
                        }

                        Tooltip {
                            target: parent
                            text: qsTr("Open config\nRight-click to copy path")
                            delay: 500
                        }
                    }

                    // Список страниц
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        // Скрываем полосы прокрутки для чистоты
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                        ColumnLayout {
                            width: parent.width
                            spacing: 4

                            Repeater {
                                model: root.pages
                                delegate: IconTextButton {
                                    required property int index
                                    required property var modelData

                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 50

                                    // Логика отображения: TextButton если развернуто, иначе IconButton (эмуляция)
                                    // Используем IconTextButton но убираем текст
                                    type: IconTextButton.Text

                                    icon: modelData.icon
                                    text: root.navExpanded ? modelData.name : ""

                                    // Состояние
                                    checked: root.currentPage === index
                                    toggle: false

                                    // Если есть вращение иконки
                                    // (Придется модифицировать IconTextButton или добавить сюда свойство вращения,
                                    // если компонент не поддерживает rotation для иконки напрямую.
                                    // Допустим, игнорируем rotation или добавляем хак)

                                    onClicked: root.currentPage = index
                                }
                            }
                        }
                    }
                }

                // --- Page Content Container ---
                StyledRect {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Colours.palette.surface_container_low
                    radius: 15//Appearance.rounding.windowRounding - root.contentPadding
                    clip: true

                    Loader {
                        id: pageLoader
                        anchors.fill: parent
                        // Добавляем отступы внутри контента
                        anchors.margins: 20

                        source: root.pages[0].component
                        opacity: 1.0

                        // Анимация смены страниц
                        Connections {
                            target: root
                            function onCurrentPageChanged() {
                                switchAnim.restart();
                            }
                        }

                        SequentialAnimation {
                            id: switchAnim

                            // Исчезновение
                            NumberAnimation {
                                target: pageLoader
                                property: "opacity"
                                to: 0
                                duration: 150
                                easing.type: Easing.InQuad
                            }

                            // Смена источника
                            ScriptAction {
                                script: {
                                    pageLoader.source = root.pages[root.currentPage].component
                                    pageLoader.anchors.topMargin = 20 // Сброс позиции для эффекта скольжения
                                }
                            }

                            // Появление
                            ParallelAnimation {
                                NumberAnimation {
                                    target: pageLoader
                                    property: "opacity"
                                    to: 1
                                    duration: 250
                                    easing.type: Easing.OutCubic
                                }
                                NumberAnimation {
                                    target: pageLoader
                                    property: "anchors.topMargin"
                                    to: 0 // Возврат на место
                                    duration: 250
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
