import QtQuick
import QtQuick.Layouts
import qs.config
import qs.utils
import qs.components
import qs.components.controls
import qs.services

Item {
    id: root

    required property var moduleManager
    property ListView targetList: null

    implicitHeight: 50

    function forceInputFocus() {
        inputField.forceActiveFocus()
    }

    Connections {
        target: root.moduleManager
        function onModuleActivatedForUI(moduleName) {
            inputField.text = ""
            inputField.forceActiveFocus()
        }
    }

    Timer {
        id: bsTimer
        interval: 400
        repeat: false
    }

    RowLayout {
        anchors.fill: parent
        spacing: Config.launcher.gap ?? 8

        StyledRect {
            id: searchContainer
            Layout.fillWidth: true
            Layout.fillHeight: true

            radius: 15
            color: Colours.alpha(Colours.palette.surface_container, true)

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.IBeamCursor
                onClicked: inputField.forceActiveFocus()
            }

            // --- ИКОНКА ПОИСКА СЛЕВА ---
            StyledIcon {
                id: searchIcon

                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Appearance.padding.normal ?? 12

                text: "\ueb1c"
                font.pointSize: Appearance.font.size.large ?? 16
                color: Colours.palette.on_surface_variant
            }

            // --- КНОПКА ОЧИСТКИ СПРАВА ---
            StyledIcon {
                id: clearIcon

                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Appearance.padding.normal ?? 12

                width: inputField.text ? implicitWidth : implicitWidth / 2
                opacity: {
                    if (!inputField.text) return 0
                    if (clearMouse.pressed) return 0.7
                    if (clearMouse.containsMouse) return 0.8
                    return 1
                }

                text: "\ue5cd"
                color: Colours.palette.on_surface_variant

                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: inputField.text ? Qt.PointingHandCursor : undefined
                    onClicked: {
                        inputField.text = ""
                        root.moduleManager.processInput("")
                        inputField.forceActiveFocus()
                    }
                }

                Behavior on width {
                    NumberAnimation { duration: Appearance.anim.durations.small }
                }
                Behavior on opacity {
                    NumberAnimation { duration: Appearance.anim.durations.small }
                }
            }

            // --- ПИЛЮЛЯ ---
            StyledRect {
                id: pill
                visible: root.moduleManager.currentState === root.moduleManager.stateActive

                anchors.verticalCenter: parent.verticalCenter
                anchors.left: searchIcon.right
                anchors.leftMargin: 8

                height: inputField.implicitHeight + 8
                color: bsTimer.running ? Colours.alpha(Colours.palette.error, 0.2) : Colours.alpha(Colours.palette.primary, 0.15)
                radius: 8
                border.width: 1
                border.color: bsTimer.running ? Colours.palette.error : Colours.palette.primary
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                Row {
                    anchors.centerIn: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 6
                    StyledText {
                        text: root.moduleManager.activeModule?.icon ?? ""
                        font.pointSize: Appearance.font.size.normal
                        visible: text !== ""
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    StyledText {
                        text: root.moduleManager.activeModule?.name ?? ""
                        font.pointSize: Appearance.font.size.normal
                        font.weight: Font.DemiBold
                        color: bsTimer.running ? Colours.palette.error : Colours.palette.primary
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }

                Behavior on opacity { NumberAnimation { duration: 200 } }
                Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                width: visible ? implicitWidth + 20 : 0
                opacity: visible ? 1.0 : 0.0
                clip: true
            }

            // --- ПОЛЕ ВВОДА ---
            StyledTextField {
                id: inputField

                anchors.left: pill.visible ? pill.right : searchIcon.right
                anchors.right: clearIcon.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: Appearance.spacing.small
                anchors.rightMargin: Appearance.spacing.small

                topPadding: Appearance.padding.larger
                bottomPadding: Appearance.padding.larger

                placeholderText: qsTr("Type \"%1\" for commands").arg(root.moduleManager.magicSymbol)

                onTextEdited: {
                    root.moduleManager.processInput(text)
                }

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Backspace) {
                        if (text.length === 0 && root.moduleManager.currentState === root.moduleManager.stateActive) {
                            if (bsTimer.running) {
                                bsTimer.stop()
                                let sym = root.moduleManager.escapeCurrentState()
                                if (sym !== null) {
                                    text = sym
                                    Qt.callLater(() => { cursorPosition = text.length })
                                }
                            } else {
                                bsTimer.start()
                            }
                            event.accepted = true
                        } else if (text === root.moduleManager.magicSymbol && root.moduleManager.currentState === root.moduleManager.stateSelecting) {
                            text = ""
                            root.moduleManager.escapeCurrentState()
                            event.accepted = true
                        } else {
                            bsTimer.stop()
                        }
                    } else {
                        bsTimer.stop()

                        if (event.key === Qt.Key_Up) {
                            if (root.targetList) root.targetList.decrementCurrentIndex()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Down) {
                            if (root.targetList) root.targetList.incrementCurrentIndex()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                            if (root.targetList && root.targetList.currentItem) {
                                if (event.modifiers & Qt.AltModifier) {
                                    if (typeof root.targetList.currentItem.triggerAlt === "function")
                                        root.targetList.currentItem.triggerAlt()
                                } else {
                                    if (typeof root.targetList.currentItem.trigger === "function")
                                        root.targetList.currentItem.trigger()
                                }
                            }
                            event.accepted = true
                        } else if (event.key === Qt.Key_Escape) {
                            root.moduleManager.processInput("")
                            event.accepted = true
                        }
                    }
                }

                Component.onCompleted: forceActiveFocus()
            }
        }

        // --- РАСШИРЕНИЯ МОДУЛЯ ---
        Loader {
            id: extensionLoader
            Layout.fillHeight: true
            sourceComponent: root.moduleManager.activeModule?.inputExtensionComponent ?? null
            visible: status === Loader.Ready
            Layout.preferredWidth: visible ? item.implicitWidth : 0
            Behavior on Layout.preferredWidth { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            clip: true
        }
    }

    onVisibleChanged: {
        if (visible) {
            Qt.callLater(() => inputField.forceActiveFocus())
        } else {
            inputField.text = ""
            if (root.moduleManager.currentState !== root.moduleManager.stateDefault)
                root.moduleManager.processInput("")
        }
    }
}

// import QtQuick
// import QtQuick.Layouts
// import qs.config
// import qs.utils
// import qs.components
// import qs.components.controls
// import qs.services

// Item {
//     id: root

//     required property var moduleManager
//     property ListView targetList: null

//     implicitHeight: 70

//     function forceInputFocus() {
//         inputField.forceActiveFocus()
//     }

//     Connections {
//         target: root.moduleManager
//         function onModuleActivatedForUI(moduleName) {
//             inputField.text = ""
//             inputField.forceActiveFocus()
//         }
//     }

//     Timer {
//         id: bsTimer
//         interval: 400
//         repeat: false
//     }

//     RowLayout {
//         anchors.fill: parent
//         spacing: Config.launcher.gap ?? 8

//         StyledRect {
//             id: searchContainer
//             Layout.fillWidth: true
//             Layout.fillHeight: true

//             radius: 15
//             color: Colours.alpha(Colours.palette.surface_container, true)

//             MouseArea {
//                 anchors.fill: parent
//                 cursorShape: Qt.IBeamCursor
//                 onClicked: inputField.forceActiveFocus()
//             }

//             RowLayout {
//                 anchors.fill: parent
//                 anchors.margins: Appearance.padding.normal ?? 12
//                 spacing: 8

//                 // --- ИКОНКА ПОИСКА СЛЕВА ---
//                 StyledIcon {
//                     text: "\ueb1c"
//                     font.pointSize: Appearance.font.size.large ?? 16
//                     color: Colours.palette.on_surface_variant
//                     Layout.alignment: Qt.AlignVCenter
//                 }

//                 // --- ПИЛЮЛЯ ---
//                 StyledRect {
//                     id: pill
//                     visible: root.moduleManager.currentState === root.moduleManager.stateActive
//                     Layout.alignment: Qt.AlignVCenter
//                     Layout.preferredHeight: inputField.implicitHeight + 8
//                     color: bsTimer.running ? Colours.alpha(Colours.palette.error, 0.2) : Colours.alpha(Colours.palette.primary, 0.15)
//                     radius: 8
//                     border.width: 1
//                     border.color: bsTimer.running ? Colours.palette.error : Colours.palette.primary
//                     Behavior on color { ColorAnimation { duration: 150 } }
//                     Behavior on border.color { ColorAnimation { duration: 150 } }

//                     RowLayout {
//                         anchors.centerIn: parent
//                         anchors.leftMargin: 10
//                         anchors.rightMargin: 10
//                         spacing: 6
//                         StyledText {
//                             text: root.moduleManager.activeModule?.icon ?? ""
//                             font.pointSize: Appearance.font.size.normal
//                             visible: text !== ""
//                         }
//                         StyledText {
//                             text: root.moduleManager.activeModule?.name ?? ""
//                             font.pointSize: Appearance.font.size.normal
//                             font.weight: Font.DemiBold
//                             color: bsTimer.running ? Colours.palette.error : Colours.palette.primary
//                             Behavior on color { ColorAnimation { duration: 150 } }
//                         }
//                     }

//                     Behavior on opacity { NumberAnimation { duration: 200 } }
//                     Behavior on Layout.preferredWidth { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
//                     Layout.preferredWidth: visible ? implicitWidth + 20 : 0
//                     opacity: visible ? 1.0 : 0.0
//                     clip: true
//                 }

//                 // --- ПОЛЕ ВВОДА ---
//                 StyledTextField {
//                     id: inputField
//                     Layout.fillWidth: true
//                     Layout.fillHeight: true

//                     placeholderText: qsTr("Type \"%1\" for commands").arg(root.moduleManager.magicSymbol)
//                     topPadding: 0
//                     bottomPadding: 0

//                     onTextEdited: {
//                         root.moduleManager.processInput(text)
//                     }

//                     Keys.onPressed: (event) => {
//                         if (event.key === Qt.Key_Backspace) {
//                             if (text.length === 0 && root.moduleManager.currentState === root.moduleManager.stateActive) {
//                                 if (bsTimer.running) {
//                                     bsTimer.stop()
//                                     let sym = root.moduleManager.escapeCurrentState()
//                                     if (sym !== null) {
//                                         text = sym
//                                         Qt.callLater(() => { cursorPosition = text.length })
//                                     }
//                                 } else {
//                                     bsTimer.start()
//                                 }
//                                 event.accepted = true
//                             } else if (text === root.moduleManager.magicSymbol && root.moduleManager.currentState === root.moduleManager.stateSelecting) {
//                                 text = ""
//                                 root.moduleManager.escapeCurrentState()
//                                 event.accepted = true
//                             } else {
//                                 bsTimer.stop()
//                             }
//                         } else {
//                             bsTimer.stop()

//                             if (event.key === Qt.Key_Up) {
//                                 if (root.targetList) root.targetList.decrementCurrentIndex()
//                                 event.accepted = true
//                             } else if (event.key === Qt.Key_Down) {
//                                 if (root.targetList) root.targetList.incrementCurrentIndex()
//                                 event.accepted = true
//                             } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
//                                 if (root.targetList && root.targetList.currentItem) {
//                                     if (event.modifiers & Qt.AltModifier) {
//                                         if (typeof root.targetList.currentItem.triggerAlt === "function")
//                                             root.targetList.currentItem.triggerAlt()
//                                     } else {
//                                         if (typeof root.targetList.currentItem.trigger === "function")
//                                             root.targetList.currentItem.trigger()
//                                     }
//                                 }
//                                 event.accepted = true
//                             } else if (event.key === Qt.Key_Escape) {
//                                 root.moduleManager.processInput("")
//                                 event.accepted = true
//                             }
//                         }
//                     }

//                     Component.onCompleted: forceActiveFocus()
//                 }

//                 // --- КНОПКА ОЧИСТКИ ---
//                 StyledIcon {
//                     id: clearIcon

//                     Layout.alignment: Qt.AlignVCenter

//                     width: inputField.text ? implicitWidth : implicitWidth / 2
//                     opacity: {
//                         if (!inputField.text)
//                             return 0
//                         if (clearMouse.pressed)
//                             return 0.7
//                         if (clearMouse.containsMouse)
//                             return 0.8
//                         return 1
//                     }

//                     text: "\ue5cd"
//                     color: Colours.palette.on_surface_variant

//                     MouseArea {
//                         id: clearMouse

//                         anchors.fill: parent
//                         hoverEnabled: true
//                         cursorShape: inputField.text ? Qt.PointingHandCursor : undefined

//                         onClicked: {
//                             inputField.text = ""
//                             root.moduleManager.processInput("")
//                             inputField.forceActiveFocus()
//                         }
//                     }

//                     Behavior on width {
//                         NumberAnimation {
//                             duration: Appearance.anim.durations.small
//                         }
//                     }

//                     Behavior on opacity {
//                         NumberAnimation {
//                             duration: Appearance.anim.durations.small
//                         }
//                     }
//                 }
//             }
//         }

//         // --- РАСШИРЕНИЯ МОДУЛЯ ---
//         Loader {
//             id: extensionLoader
//             Layout.fillHeight: true
//             sourceComponent: root.moduleManager.activeModule?.inputExtensionComponent ?? null
//             visible: status === Loader.Ready
//             Layout.preferredWidth: visible ? item.implicitWidth : 0
//             Behavior on Layout.preferredWidth { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
//             clip: true
//         }
//     }

//     onVisibleChanged: {
//         if (visible) {
//             Qt.callLater(() => inputField.forceActiveFocus())
//         } else {
//             inputField.text = ""
//             if (root.moduleManager.currentState !== root.moduleManager.stateDefault)
//                 root.moduleManager.processInput("")
//         }
//     }
// }

// // import QtQuick
// // import QtQuick.Layouts
// // import qs.config
// // import qs.utils
// // import qs.components
// // import qs.components.controls
// // import qs.services

// // Item {
// //     id: root

// //     required property var moduleManager
// //     property ListView targetList: null

// //     implicitHeight: 70

// //     function forceInputFocus() {
// //         inputField.forceActiveFocus()
// //     }

// //     Connections {
// //         target: root.moduleManager
// //         function onModuleActivatedForUI(moduleName) {
// //             inputField.text = ""
// //             inputField.forceActiveFocus()
// //         }
// //     }

// //     Timer {
// //         id: bsTimer
// //         interval: 400
// //         repeat: false
// //     }

// //     RowLayout {
// //         anchors.fill: parent
// //         spacing: Config.launcher.gap ?? 8

// //         StyledRect {
// //             id: searchContainer
// //             Layout.fillWidth: true
// //             Layout.fillHeight: true

// //             radius: 15
// //             color: Colours.alpha(Colours.palette.surface_container, true)

// //             border.width: inputField.activeFocus ? 1 : 0
// //             border.color: Colours.alpha(Colours.palette.primary, 0.4)
// //             Behavior on border.color { ColorAnimation { duration: 150 } }

// //             MouseArea {
// //                 anchors.fill: parent
// //                 cursorShape: Qt.IBeamCursor
// //                 onClicked: inputField.forceActiveFocus()
// //             }

// //             RowLayout {
// //                 anchors.fill: parent
// //                 anchors.margins: Appearance.padding.normal ?? 12
// //                 spacing: 8

// //                 // --- ПИЛЮЛЯ ---
// //                 StyledRect {
// //                     id: pill
// //                     visible: root.moduleManager.currentState === root.moduleManager.stateActive
// //                     Layout.alignment: Qt.AlignVCenter
// //                     Layout.preferredHeight: inputField.implicitHeight + 8
// //                     color: bsTimer.running ? Colours.alpha(Colours.palette.error, 0.2) : Colours.alpha(Colours.palette.primary, 0.15)
// //                     radius: 8
// //                     border.width: 1
// //                     border.color: bsTimer.running ? Colours.palette.error : Colours.palette.primary
// //                     Behavior on color { ColorAnimation { duration: 150 } }
// //                     Behavior on border.color { ColorAnimation { duration: 150 } }

// //                     RowLayout {
// //                         anchors.centerIn: parent
// //                         anchors.leftMargin: 10
// //                         anchors.rightMargin: 10
// //                         spacing: 6
// //                         StyledText {
// //                             text: root.moduleManager.activeModule?.icon ?? ""
// //                             font.pointSize: Appearance.font.size.normal
// //                             visible: text !== ""
// //                         }
// //                         StyledText {
// //                             text: root.moduleManager.activeModule?.name ?? ""
// //                             font.pointSize: Appearance.font.size.normal
// //                             font.weight: Font.DemiBold
// //                             color: bsTimer.running ? Colours.palette.error : Colours.palette.primary
// //                             Behavior on color { ColorAnimation { duration: 150 } }
// //                         }
// //                     }

// //                     Behavior on opacity { NumberAnimation { duration: 200 } }
// //                     Behavior on Layout.preferredWidth { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
// //                     Layout.preferredWidth: visible ? implicitWidth + 20 : 0
// //                     opacity: visible ? 1.0 : 0.0
// //                     clip: true
// //                 }

// //                 // --- ПОЛЕ ВВОДА ---
// //                 StyledTextField {
// //                     id: inputField
// //                     Layout.fillWidth: true
// //                     Layout.fillHeight: true

// //                     placeholderText: "Search..."
// //                     topPadding: 0
// //                     bottomPadding: 0

// //                     onTextEdited: {
// //                         root.moduleManager.processInput(text)
// //                     }

// //                     Keys.onPressed: (event) => {
// //                         if (event.key === Qt.Key_Backspace) {
// //                             if (text.length === 0 && root.moduleManager.currentState === root.moduleManager.stateActive) {
// //                                 if (bsTimer.running) {
// //                                     bsTimer.stop()
// //                                     let sym = root.moduleManager.escapeCurrentState()
// //                                     if (sym !== null) {
// //                                         text = sym
// //                                         Qt.callLater(() => { cursorPosition = text.length })
// //                                     }
// //                                 } else {
// //                                     bsTimer.start()
// //                                 }
// //                                 event.accepted = true
// //                             } else if (text === root.moduleManager.magicSymbol && root.moduleManager.currentState === root.moduleManager.stateSelecting) {
// //                                 text = ""
// //                                 root.moduleManager.escapeCurrentState()
// //                                 event.accepted = true
// //                             } else {
// //                                 bsTimer.stop()
// //                             }
// //                         } else {
// //                             bsTimer.stop()

// //                             if (event.key === Qt.Key_Up) {
// //                                 if (root.targetList) root.targetList.decrementCurrentIndex()
// //                                 event.accepted = true
// //                             } else if (event.key === Qt.Key_Down) {
// //                                 if (root.targetList) root.targetList.incrementCurrentIndex()
// //                                 event.accepted = true
// //                             } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
// //                                 if (root.targetList && root.targetList.currentItem) {
// //                                     if (event.modifiers & Qt.AltModifier) {
// //                                         if (typeof root.targetList.currentItem.triggerAlt === "function")
// //                                             root.targetList.currentItem.triggerAlt()
// //                                     } else {
// //                                         if (typeof root.targetList.currentItem.trigger === "function")
// //                                             root.targetList.currentItem.trigger()
// //                                     }
// //                                 }
// //                                 event.accepted = true
// //                             } else if (event.key === Qt.Key_Escape) {
// //                                 root.moduleManager.processInput("")
// //                                 event.accepted = true
// //                             }
// //                         }
// //                     }

// //                     Component.onCompleted: forceActiveFocus()
// //                 }

// //                 // --- ИКОНКА СПРАВА ---
// //                 StyledIcon {
// //                     text: "\ueb1c"
// //                     font.pointSize: Appearance.font.size.large ?? 16
// //                     color: Colours.palette.on_surface_variant
// //                     Layout.alignment: Qt.AlignVCenter
// //                 }
// //             }
// //         }

// //         // --- РАСШИРЕНИЯ МОДУЛЯ ---
// //         Loader {
// //             id: extensionLoader
// //             Layout.fillHeight: true
// //             sourceComponent: root.moduleManager.activeModule?.inputExtensionComponent ?? null
// //             visible: status === Loader.Ready
// //             Layout.preferredWidth: visible ? item.implicitWidth : 0
// //             Behavior on Layout.preferredWidth { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
// //             clip: true
// //         }
// //     }

// //     onVisibleChanged: {
// //         if (visible) {
// //             Qt.callLater(() => inputField.forceActiveFocus())
// //         } else {
// //             inputField.text = ""
// //             if (root.moduleManager.currentState !== root.moduleManager.stateDefault)
// //                 root.moduleManager.processInput("")
// //         }
// //     }
// // }

// // // import QtQuick
// // // import QtQuick.Layouts
// // // import qs.config
// // // import qs.utils
// // // import qs.components
// // // import qs.services

// // // Item {
// // //     id: root

// // //     // Ссылки на внешние компоненты, которые нужно передать при создании
// // //     required property var moduleManager
// // //     property ListView targetList: null // Ссылка на StyledListView из LeftPanel (для навигации стрелками)

// // //     implicitHeight: 70

// // //     // Очистка строки при активации модуля из списка или по шорткату
// // //     Connections {
// // //         target: root.moduleManager
// // //         function onModuleActivatedForUI(moduleName) {
// // //             inputField.text = "";
// // //             inputField.forceActiveFocus();
// // //         }
// // //     }

// // //     // Таймер для отслеживания двойного нажатия Backspace
// // //     Timer {
// // //         id: bsTimer
// // //         interval: 400
// // //         repeat: false
// // //     }

// // //     RowLayout {
// // //         anchors.fill: parent
// // //         spacing: Config.launcher.gap ?? 8

// // //         // ==========================================
// // //         // 1. ГЛАВНЫЙ КОНТЕЙНЕР (Строка поиска)
// // //         // ==========================================
// // //         StyledRect {
// // //             id: searchContainer
// // //             Layout.fillWidth: true
// // //             Layout.fillHeight: true

// // //             radius: 15
// // //             color: Colours.alpha(Colours.palette.surface_container, true)

// // //             // Мягкая обводка, если поле в фокусе
// // //             border.width: inputField.activeFocus ? 1 : 0
// // //             border.color: Colours.alpha(Colours.palette.primary, 0.4)
// // //             Behavior on border.color { ColorAnimation { duration: 150 } }

// // //             // Кликаем куда угодно по контейнеру - фокусим поле ввода
// // //             MouseArea {
// // //                 anchors.fill: parent
// // //                 cursorShape: Qt.IBeamCursor
// // //                 onClicked: inputField.forceActiveFocus()
// // //             }

// // //             RowLayout {
// // //                 anchors.fill: parent
// // //                 anchors.margins: Appearance.padding.normal ?? 12
// // //                 spacing: 8

// // //                 // --- ПИЛЮЛЯ (Tag) АКТИВНОГО МОДУЛЯ ---
// // //                 StyledRect {
// // //                     id: pill

// // //                     // Видима только когда модуль активен
// // //                     visible: root.moduleManager.currentState === root.moduleManager.stateActive

// // //                     Layout.alignment: Qt.AlignVCenter
// // //                     Layout.preferredHeight: inputField.implicitHeight + 8

// // //                     // Если таймер Backspace запущен (ожидаем второе нажатие), красим пилюлю в красный (эффект предупреждения)
// // //                     color: bsTimer.running ? Colours.alpha(Colours.palette.error, 0.2) : Colours.alpha(Colours.palette.primary, 0.15)
// // //                     radius: 8

// // //                     border.width: 1
// // //                     border.color: bsTimer.running ? Colours.palette.error : Colours.palette.primary
// // //                     Behavior on color { ColorAnimation { duration: 150 } }
// // //                     Behavior on border.color { ColorAnimation { duration: 150 } }

// // //                     RowLayout {
// // //                         anchors.centerIn: parent
// // //                         anchors.leftMargin: 10
// // //                         anchors.rightMargin: 10
// // //                         spacing: 6

// // //                         StyledText {
// // //                             text: root.moduleManager.activeModule?.icon ?? ""
// // //                             font.pointSize: Appearance.font.size.normal
// // //                             visible: text !== ""
// // //                         }

// // //                         StyledText {
// // //                             text: root.moduleManager.activeModule?.name ?? ""
// // //                             font.pointSize: Appearance.font.size.normal
// // //                             font.weight: Font.DemiBold
// // //                             color: bsTimer.running ? Colours.palette.error : Colours.palette.primary
// // //                             Behavior on color { ColorAnimation { duration: 150 } }
// // //                         }
// // //                     }

// // //                     // Анимация появления/исчезновения пилюли
// // //                     Behavior on opacity { NumberAnimation { duration: 200 } }
// // //                     Behavior on Layout.preferredWidth { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

// // //                     // Хак для плавного схлопывания ширины
// // //                     Layout.preferredWidth: visible ? implicitWidth + 20 : 0
// // //                     opacity: visible ? 1.0 : 0.0
// // //                     clip: true
// // //                 }

// // //                 // --- ПОЛЕ ВВОДА ТЕКСТА ---
// // //                 TextInput {
// // //                     id: inputField
// // //                     Layout.fillWidth: true
// // //                     Layout.fillHeight: true

// // //                     verticalAlignment: TextInput.AlignVCenter
// // //                     font.pointSize: Appearance.font.size.large ?? 14
// // //                     color: Colours.palette.on_surface

// // //                     // Убираем рамку и фон у базового TextInput
// // //                     selectByMouse: true
// // //                     selectionColor: Colours.alpha(Colours.palette.primary, 0.4)

// // //                     // При вводе текста отправляем его в Менеджер
// // //                     onTextEdited: {
// // //                         root.moduleManager.processInput(text)
// // //                     }

// // //                     // ПЕРЕХВАТ КЛАВИАТУРЫ
// // //                     Keys.onPressed: (event) => {
// // //                         // 1. ЛОГИКА BACKSPACE (Выход из модулей)
// // //                         if (event.key === Qt.Key_Backspace) {
// // //                             if (text.length === 0 && root.moduleManager.currentState === root.moduleManager.stateActive) {
// // //                                 if (bsTimer.running) {
// // //                                     // ДВОЙНОЙ BACKSPACE: Выходим в режим выбора
// // //                                     bsTimer.stop();
// // //                                     let sym = root.moduleManager.escapeCurrentState();
// // //                                     if (sym !== null) {
// // //                                         text = sym;
// // //                                         Qt.callLater(() => { cursorPosition = text.length; }); // Возвращаем курсор в конец
// // //                                     }
// // //                                 } else {
// // //                                     // ПЕРВЫЙ BACKSPACE: Запускаем таймер (пилюля краснеет)
// // //                                     bsTimer.start();
// // //                                 }
// // //                                 event.accepted = true;

// // //                             } else if (text === root.moduleManager.magicSymbol && root.moduleManager.currentState === root.moduleManager.stateSelecting) {
// // //                                 // ОДИНАРНЫЙ BACKSPACE (стираем "!"): Выходим в дефолтный режим
// // //                                 text = "";
// // //                                 root.moduleManager.escapeCurrentState();
// // //                                 event.accepted = true;
// // //                             } else {
// // //                                 bsTimer.stop();
// // //                             }

// // //                         // 2. ЛОГИКА НАВИГАЦИИ (Стрелки и Enter)
// // //                         } else {
// // //                             bsTimer.stop(); // Любая другая клавиша сбрасывает таймер выхода

// // //                             if (event.key === Qt.Key_Up) {
// // //                                 if (root.targetList) root.targetList.decrementCurrentIndex();
// // //                                 event.accepted = true;
// // //                             } else if (event.key === Qt.Key_Down) {
// // //                                 if (root.targetList) root.targetList.incrementCurrentIndex();
// // //                                 event.accepted = true;
// // //                             } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
// // //                                 if (root.targetList && root.targetList.currentItem) {
// // //                                     // Проверяем, зажат ли Alt
// // //                                     if (event.modifiers & Qt.AltModifier) {
// // //                                         if (typeof root.targetList.currentItem.triggerAlt === "function") {
// // //                                             root.targetList.currentItem.triggerAlt();
// // //                                         }
// // //                                     } else {
// // //                                         if (typeof root.targetList.currentItem.trigger === "function") {
// // //                                             root.targetList.currentItem.trigger();
// // //                                         }
// // //                                     }
// // //                                 }
// // //                                 event.accepted = true;
// // //                             }
// // //                             // } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
// // //                             //     // Нажатие Enter активирует текущий выбранный элемент в списке
// // //                             //     if (root.targetList && root.targetList.currentItem) {
// // //                             //         if (typeof root.targetList.currentItem.trigger === "function") {
// // //                             //             root.targetList.currentItem.trigger();
// // //                             //         } else {
// // //                             //             // Запасной вариант вызова onClicked напрямую из модели, если trigger() не добавлен
// // //                             //             let modelData = root.targetList.model.get ? root.targetList.model.get(root.targetList.currentIndex) : root.targetList.model[root.targetList.currentIndex];
// // //                             //             if (modelData && typeof modelData.onClicked === "function") {
// // //                             //                 modelData.onClicked(modelData, root.targetList);
// // //                             //             }
// // //                             //         }
// // //                             //     }
// // //                             //     event.accepted = true;
// // //                             // }
// // //                         }
// // //                     }
// // //                 }

// // //                 // --- ИКОНКА СПРАВА ---
// // //                 StyledIcon {
// // //                     text: "\ueb1c"
// // //                     font.pointSize: Appearance.font.size.large ?? 16
// // //                     color: Colours.palette.on_surface_variant
// // //                     Layout.alignment: Qt.AlignVCenter
// // //                 }
// // //             }
// // //         }

// // //         // ==========================================
// // //         // 2. КОНТЕЙНЕР РАСШИРЕНИЙ МОДУЛЯ (Справа)
// // //         // ==========================================
// // //         Loader {
// // //             id: extensionLoader
// // //             Layout.fillHeight: true

// // //             // Загружаем компонент только если он предоставлен модулем
// // //             sourceComponent: root.moduleManager.activeModule?.inputExtensionComponent ?? null

// // //             // Если компонент загрузился, показываем Loader, иначе он схлопывается (width=0)
// // //             visible: status === Loader.Ready
// // //             Layout.preferredWidth: visible ? item.implicitWidth : 0

// // //             Behavior on Layout.preferredWidth { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
// // //             clip: true
// // //         }
// // //     }

// // //     // Автоматически ставим фокус при появлении лаунчера

// // //     onVisibleChanged: {
// // //         if (visible) {
// // //             inputField.forceActiveFocus();
// // //         } else {
// // //             inputField.text = ""; // Очищаем строку при закрытии всего лаунчера
// // //             if (root.moduleManager.currentState !== root.moduleManager.stateDefault) {
// // //                 // Если лаунчер закрыли (через Esc или клик вне окна), сбрасываем его в дефолтное состояние
// // //                 root.moduleManager.processInput("");
// // //             }
// // //         }
// // //     }
// // // }
