import qs.components
import qs.services
import qs.config
import qs.utils
import Quickshell
import Quickshell.Widgets
import QtQuick

Item {
    id: root

    required property var modelData
    required property var list

    readonly property bool isCurrent: ListView.isCurrentItem
    readonly property bool hasBackground: false

    implicitHeight: Config.launcher.itemHeight
    anchors.left: parent?.left
    anchors.right: parent?.right

    function trigger() {
        if (root.modelData && typeof root.modelData.onClicked === "function")
            root.modelData.onClicked(root.modelData, root.list)
    }

    function triggerAlt() {
        if (root.modelData && typeof root.modelData.onAltClicked === "function")
            root.modelData.onAltClicked(root.modelData, root.list)
        else
            trigger()
    }

    // Фон при наведении/выделении
    StyledRect {
        anchors.fill: parent
        radius: Appearance.rounding.normal
        color: Colours.alpha(Colours.palette.surface_variant, 0.5)
        opacity: hoverArea.containsMouse ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    // Выделение при навигации стрелками
    StyledRect {
        anchors.fill: parent
        radius: Appearance.rounding.normal
        color: Colours.palette.on_surface
        opacity: root.isCurrent ? 0.08 : 0.0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    StateLayer {
        radius: Appearance.rounding.normal
        onClicked: {
            if (root.modelData && typeof root.modelData.onClicked === "function")
                root.modelData.onClicked(root.modelData, root.list)
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: Appearance.padding.larger
        anchors.rightMargin: Appearance.padding.larger
        anchors.margins: Appearance.padding.smaller

        // --- ЛЕВАЯ ИКОНКА ---
        Loader {
            id: leftIconLoader
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: height
            height: parent.height * 0.8

            sourceComponent: root.modelData?.isLeftIconImage ? imageIconComp : fontIconComp

            Component {
                id: imageIconComp
                IconImage {
                    source: root.modelData?.leftIcon ? Quickshell.iconPath(root.modelData.leftIcon, "image-missing") : ""
                    anchors.fill: parent
                }
            }
            Component {
                id: fontIconComp
                StyledText {
                    text: root.modelData?.leftIcon ?? ""
                    font.pointSize: Appearance.font.size.large
                    color: Colours.palette.on_surface
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        // --- ТЕКСТ ---
        Item {
            anchors.left: leftIconLoader.right
            anchors.leftMargin: Appearance.spacing.normal
            anchors.right: rightContentBlock.left
            anchors.rightMargin: Appearance.spacing.normal
            anchors.verticalCenter: parent.verticalCenter
            implicitHeight: headerText.implicitHeight + subText.implicitHeight

            StyledText {
                id: headerText
                text: root.modelData?.header ?? ""
                font.pointSize: Appearance.font.size.normal
                font.weight: Font.DemiBold
                color: Colours.palette.primary
                width: parent.width
                elide: Text.ElideRight
            }

            StyledText {
                id: subText
                text: root.modelData?.text ?? ""
                font.pointSize: Appearance.font.size.small
                color: Colours.alpha(Colours.palette.outline, true)
                width: parent.width
                elide: Text.ElideRight
                anchors.top: headerText.bottom
            }
        }

        // --- ПРАВЫЙ БЛОК ---
        Item {
            id: rightContentBlock
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            width: Math.max(rightIcon.implicitWidth, rightText.implicitWidth)
            height: rightIcon.implicitHeight + rightText.implicitHeight

            StyledIcon {
                id: rightIcon
                text: root.modelData?.rightIcon ?? ""
                font.pointSize: Appearance.font.size.normal
                color: Colours.palette.on_surface_variant
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: (root.isCurrent || hoverArea.containsMouse) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

            StyledText {
                id: rightText
                text: root.modelData?.rightText ?? ""
                font.pointSize: Appearance.font.size.small
                color: Colours.alpha(Colours.palette.outline, true)
                anchors.top: rightIcon.bottom
                anchors.right: parent.right
            }
        }
    }
}

// // import "../services"
// import qs.components
// import qs.services
// import qs.config
// import qs.utils
// import Quickshell
// import Quickshell.Widgets
// import QtQuick

// ClippingRectangle {
//     id: root
//     transformOrigin: Item.Center

//     // Ожидаем, что modelData содержит унифицированные поля:
//     // header, text, leftIcon (путь или юникод), isLeftIconImage (bool),
//     // rightIcon (путь или юникод), rightText, backgroundImage, onClicked (callback)
//     required property var modelData
//     required property var list

//     readonly property bool isCurrent: ListView.isCurrentItem
//     readonly property bool hasBackground: false //root.modelData && root.modelData.backgroundImage && root.modelData.backgroundImage !== ""

//     // Если есть картинка - высота x2.5 (как в твоем примере), иначе обычная
//     implicitHeight: hasBackground ? Config.launcher.itemHeight * 2.5 : Config.launcher.itemHeight
//     anchors.left: parent?.left
//     anchors.right: parent?.right

//     radius: Appearance.rounding.large
//     color: hasBackground ? "black" : (hoverArea.containsMouse || isCurrent ? Colours.alpha(Colours.palette.surface_variant, 0.5) : "transparent")

//     // Обводка при выделении (как в твоем примере)
//     border.width: isCurrent && hasBackground ? 1.5 : 0
//     border.color: Colours.alpha(Colours.palette.primary, 0.4)

//     // Вызывается из RowInput при нажатии Enter
//     function trigger() {
//         if (root.modelData && typeof root.modelData.onClicked === "function") {
//             root.modelData.onClicked(root.modelData, root.list);
//         }
//     }

//     function triggerAlt() {
//             if (root.modelData && typeof root.modelData.onAltClicked === "function") {
//                 root.modelData.onAltClicked(root.modelData, root.list);
//             } else {
//                 // Если модуль не поддерживает Alt+Enter, делаем обычный клик
//                 trigger();
//             }
//         }

//     Behavior on border.width { NumberAnimation { duration: 150 } }
//     Behavior on color { ColorAnimation { duration: 150 } }

//     MouseArea {
//         id: hoverArea
//         anchors.fill: parent
//         hoverEnabled: true
//         acceptedButtons: Qt.NoButton
//     }

//     StateLayer {
//         radius: root.radius
//         z: 10
//         onClicked: {
//             if (root.modelData && typeof root.modelData.onClicked === "function") {
//                 root.modelData.onClicked(root.modelData, root.list);
//             }
//         }
//     }

//     // ==========================================
//     // 1. ФОНОВОЕ ИЗОБРАЖЕНИЕ (Если есть)
//     // ==========================================
//     // Image {
//     //     visible: root.hasBackground
//     //     source: visible ? root.modelData.backgroundImage : ""
//     //     anchors.fill: parent
//     //     fillMode: Image.PreserveAspectCrop
//     //     asynchronous: true
//     //     opacity: isCurrent ? 1.0 : 0.88
//     //     Behavior on opacity { NumberAnimation { duration: 200 } }
//     // }

//     Rectangle {
//         visible: root.hasBackground
//         anchors.fill: parent
//         gradient: Gradient {
//             GradientStop { position: 0.2; color: "transparent" }
//             GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.8) }
//         }
//     }

//     // ==========================================
//     // 2. ОСНОВНОЙ КОНТЕНТ (Иконка слева + Текст)
//     // ==========================================
//     Item {
//         anchors.fill: parent
//         anchors.leftMargin: Appearance.padding.larger
//         anchors.rightMargin: Appearance.padding.larger
//         anchors.margins: Appearance.padding.smaller

//         // --- ЛЕВАЯ ИКОНКА ---
//         Loader {
//             id: leftIconLoader
//             anchors.left: parent.left
//             // Если есть фон, опускаем иконку вниз. Если нет - по центру.
//             anchors.verticalCenter: root.hasBackground ? undefined : parent.verticalCenter
//             anchors.bottom: root.hasBackground ? parent.bottom : undefined
//             anchors.bottomMargin: root.hasBackground ? Appearance.padding.small : 0

//             width: root.hasBackground ? 0 : height // Скрываем левую иконку если это картинка на весь фон (по желанию, можно оставить)
//             height: root.hasBackground ? 0 : parent.height * 0.8

//             sourceComponent: root.modelData?.isLeftIconImage ? imageIconComp : fontIconComp

//             Component {
//                 id: imageIconComp
//                 IconImage {
//                     source: root.modelData?.leftIcon ? Quickshell.iconPath(root.modelData.leftIcon, "image-missing") : ""
//                     anchors.fill: parent
//                 }
//             }
//             Component {
//                 id: fontIconComp
//                 StyledText {
//                     text: root.modelData?.leftIcon ?? ""
//                     font.pointSize: Appearance.font.size.large
//                     color: root.hasBackground ? "white" : Colours.palette.on_surface
//                     verticalAlignment: Text.AlignVCenter
//                     horizontalAlignment: Text.AlignHCenter
//                 }
//             }
//         }

//         // --- БЛОК ТЕКСТА (Заголовок + Описание) ---
//         Column {
//             anchors.left: leftIconLoader.right
//             anchors.leftMargin: root.hasBackground ? 0 : Appearance.spacing.normal
//             anchors.right: rightContentBlock.left // Тянется до правого блока
//             anchors.rightMargin: Appearance.spacing.normal

//             // Если есть фон, прижимаем к низу. Если нет - по центру.
//             anchors.verticalCenter: root.hasBackground ? undefined : parent.verticalCenter
//             anchors.bottom: root.hasBackground ? parent.bottom : undefined
//             anchors.bottomMargin: root.hasBackground ? Appearance.padding.small : 0

//             spacing: 0

//             StyledText {
//                 id: headerText
//                 text: root.modelData?.header ?? ""
//                 // font.pointSize: Appearance.font.size.normal
//                 // font.weight: Font.DemiBold
//                 color: root.hasBackground ? "white" : Colours.palette.primary
//                 width: parent.width
//                 elide: Text.ElideRight
//             }

//             StyledText {
//                 id: subText
//                 text: root.modelData?.text ?? ""
//                 font.pointSize: Appearance.font.size.small
//                 color: root.hasBackground ? Qt.rgba(1, 1, 1, 0.7) : Colours.alpha(Colours.palette.outline, true)
//                 width: parent.width
//                 elide: Text.ElideRight
//             }
//         }

//         // ==========================================
//         // 3. ПРАВЫЙ БЛОК (Иконка сверху + Текст снизу)
//         // ==========================================
//         Item {
//             id: rightContentBlock
//             anchors.right: parent.right
//             // Прижимаем к низу если есть фон, иначе по центру
//             anchors.verticalCenter: root.hasBackground ? undefined : parent.verticalCenter
//             anchors.bottom: root.hasBackground ? parent.bottom : undefined
//             anchors.bottomMargin: root.hasBackground ? Appearance.padding.small : 0

//             width: Math.max(rightIcon.width, rightText.width)
//             height: rightIcon.height + rightText.height

//             // Правая иконка (видна только при выделении/наведении)
//             StyledIcon {
//                 id: rightIcon
//                 text: root.modelData?.rightIcon ?? "\ue14d" // Дефолт - иконка копирования
//                 font.pointSize: Appearance.font.size.normal
//                 color: root.hasBackground ? Qt.rgba(1, 1, 1, 0.8) : Colours.palette.on_surface_variant

//                 anchors.top: parent.top
//                 anchors.horizontalCenter: parent.horizontalCenter

//                 opacity: (root.isCurrent || hoverArea.containsMouse) ? 1.0 : 0.0
//                 Behavior on opacity { NumberAnimation { duration: 150 } }
//             }

//             // Правый текст (снизу, прижат вправо)
//             StyledText {
//                 id: rightText
//                 text: root.modelData?.rightText ?? ""
//                 font.pointSize: Appearance.font.size.small
//                 color: root.hasBackground ? Qt.rgba(1, 1, 1, 0.5) : Colours.alpha(Colours.palette.outline, true)

//                 anchors.top: rightIcon.bottom
//                 anchors.right: parent.right
//             }
//         }
//     }
// }
