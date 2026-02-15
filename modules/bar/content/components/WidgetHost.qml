// modules/bar/content/components/WidgetHost.qml
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.components
import Quickshell

Item {
    id: host
    // required property var modelData
    required property ShellScreen screen

    readonly property bool isHorizontal: Config.bar.orientation
    readonly property real groupPadding: Config.bar.group.padding
    readonly property real thickness: Config.bar.group.thickness

    // --- РАСЧЕТ РАЗМЕРОВ HOST ---
    implicitWidth: {
        if (mainLoader.active) return mainLoader.implicitWidth
        if (modelData.type === "group") {
            return isHorizontal ? (groupLayout.childrenRect.width + groupPadding * 2) : thickness
        }
        return 0
    }

    implicitHeight: {
        if (mainLoader.active) return mainLoader.implicitHeight
        if (modelData.type === "group") {
            return isHorizontal ? thickness : (groupLayout.childrenRect.height + groupPadding * 2)
        }
        return 0
    }

    // 1. Одиночный виджет
    Loader {
        id: mainLoader
        anchors.centerIn: parent
        active: host.modelData && host.modelData.type === "widget" && !!host.modelData.name
        source: active ? Qt.resolvedUrl("../components/" + host.modelData.name + ".qml") : ""
        onLoaded: if (item && item.hasOwnProperty("screen")) item.screen = host.screen
    }

    // 2. Группа
    StyledRect {
        id: bgRect
        visible: host.modelData && host.modelData.type === "group"
        anchors.fill: parent
        color: Colours.palette.surface_container
        radius: Config.bar.group.rounding

        FlexboxLayout {
            id: groupLayout

            // ВАЖНО: Никаких anchors!
            // Позиционируем вручную, чтобы не ломать расчет childrenRect
            x: isHorizontal ? groupPadding : (parent.width - childrenRect.width) / 2
            y: isHorizontal ? (parent.height - childrenRect.height) / 2 : groupPadding

            direction: host.isHorizontal ? FlexboxLayout.Row : FlexboxLayout.Column
            alignItems: FlexboxLayout.AlignCenter
            gap: Appearance.spacing.normal

            Repeater {
                model: (host.modelData && host.modelData.type === "group") ? host.modelData.children : []
                delegate: Loader {
                    active: !!modelData && !!modelData.name
                    source: active ? Qt.resolvedUrl("../components/" + modelData.name + ".qml") : ""
                    onLoaded: if (item && item.hasOwnProperty("screen")) item.screen = host.screen
                }
            }
        }
    }
}
// Item {
//     id: host
//     // required property var modelData
//     required property ShellScreen screen

//     // Используем значение из конфига для отступов внутри StyledRect
//     readonly property real groupPadding: Config.bar.group.padding

//     // --- РАСЧЕТ РАЗМЕРОВ HOST ---
//     // FlexboxLayout в Center.qml смотрит на эти свойства, чтобы выделить место.
//     implicitWidth: {
//         if (mainLoader.active) return mainLoader.implicitWidth
//         if (modelData.type === "group") {
//             // Если горизонтально: ширина = геометрия детей + падинги слева и справа
//             if (Config.bar.orientation) return groupLayout.childrenRect.width + (groupPadding * 2)
//             // Если вертикально: ширина фиксирована толщиной бара
//             return Config.bar.group.thickness
//         }
//         return 0
//     }

//     implicitHeight: {
//         if (mainLoader.active) return mainLoader.implicitHeight
//         if (modelData.type === "group") {
//             // Если горизонтально: высота фиксирована толщиной бара
//             if (Config.bar.orientation) return Config.bar.group.thickness
//             // Если вертикально: высота = геометрия детей + падинги сверху и снизу
//             return groupLayout.childrenRect.height + (groupPadding * 2)
//         }
//         return 0
//     }

//     // 1. Одиночный виджет (без фона)
//     Loader {
//         id: mainLoader
//         anchors.centerIn: parent
//         active: host.modelData && host.modelData.type === "widget" && !!host.modelData.name
//         source: active ? Qt.resolvedUrl("../components/" + host.modelData.name + ".qml") : ""
//         onLoaded: if (item && item.hasOwnProperty("screen")) item.screen = host.screen
//     }

//     // 2. Группа (с фоном StyledRect)
//     StyledRect {
//         id: bgRect
//         visible: host.modelData && host.modelData.type === "group"
//         anchors.fill: parent // Растягивается точно по размерам, вычисленным в host

//         color: Colours.palette.surface_container
//         radius: Appearance.radius.medium

//         FlexboxLayout {
//             id: groupLayout
//             // Центрируем контент внутри StyledRect
//             // anchors.centerIn: parent
//             // anchors.fill: parent
//             // anchors.horizontalCenter: parent.horizontalCenter
//             // anchors.verticalCenter: parent.verticalCenter
//             x: isHorizontal ? groupPadding : (parent.width - childrenRect.width) / 2
//             y: isHorizontal ? (parent.height - childrenRect.height) / 2 : groupPadding

//             direction: Config.bar.orientation ? FlexboxLayout.Row : FlexboxLayout.Column
//             alignItems: FlexboxLayout.AlignCenter

//             // Gap теперь будет корректно учтен через childrenRect родителя
//             gap: Appearance.spacing.normal

//             Repeater {
//                 model: (host.modelData && host.modelData.type === "group") ? host.modelData.children : []
//                 delegate: Loader {
//                     active: !!modelData && !!modelData.name
//                     source: active ? Qt.resolvedUrl("../components/" + modelData.name + ".qml") : ""
//                     onLoaded: if (item && item.hasOwnProperty("screen")) item.screen = host.screen
//                 }
//             }
//         }
//     }

//     // Отладка
//     Component.onCompleted: {
//         if (modelData && modelData.type === "group") {
//             console.log("Group initialized:", modelData.name, "Padding:", groupPadding)
//         }
//     }
// }
// Item {
//     id: host
//     // required property var modelData
//     required property ShellScreen screen

//     // Локальная переменная для удобства (предполагаем, что в конфиг ты это добавил)
//     // Если в конфиге пока нет padding, замени на фиксированное число, например 5
//     property real groupPadding: Config.bar.group.padding

//     // --- ЛОГИКА РАЗМЕРОВ ---
//     // Если Widget -> берем его размер.
//     // Если Group и Бар Горизонтальный -> Ширина = контент + отступы, Высота = толщина бара.
//     // Если Group и Бар Вертикальный -> Ширина = толщина бара, Высота = контент + отступы.

//     implicitWidth: {
//         if (mainLoader.active) return mainLoader.implicitWidth

//         if (Config.bar.orientation) {
//             // Горизонтальный бар: ширина зависит от содержимого + отступы слева/справа
//             return groupLayout.childrenRect.width + (groupPadding * 2)
//         } else {
//             // Вертикальный бар: ширина фиксирована конфигом
//             return Config.bar.group.thickness
//         }
//     }

//     implicitHeight: {
//         if (mainLoader.active) return mainLoader.implicitHeight

//         if (Config.bar.orientation) {
//             // Горизонтальный бар: высота фиксирована конфигом
//             return Config.bar.group.thickness
//         } else {
//             // Вертикальный бар: высота зависит от содержимого + отступы сверху/снизу
//             return groupLayout.childrenRect.height + (groupPadding * 2)
//         }
//     }

//     // 1. Одиночный виджет
//     Loader {
//         id: mainLoader
//         anchors.centerIn: parent
//         active: host.modelData && host.modelData.type === "widget" && !!host.modelData.name
//         source: active ? Qt.resolvedUrl("../components/" + host.modelData.name + ".qml") : ""

//         onLoaded: {
//             if (item && item.hasOwnProperty("screen")) item.screen = host.screen
//         }
//     }

//     // 2. Группа (Фон)
//     StyledRect {
//         id: bgRect
//         // Показываем только если это группа
//         visible: host.modelData && host.modelData.type === "group"

//         // Фон просто заполняет Host, размеры которого мы рассчитали выше
//         anchors.fill: parent

//         color: Colours.palette.surface_container
//         radius: Appearance.radius.medium

//         // 3. Контент группы
//         FlexboxLayout {
//             id: groupLayout
//             // Центруем контент внутри фона.
//             // НЕ используй anchors.fill, иначе Layout не сможет посчитать свой implicit size.
//             anchors.centerIn: parent

//             direction: Config.bar.orientation ? FlexboxLayout.Row : FlexboxLayout.Column
//             alignItems: FlexboxLayout.AlignCenter
//             gap: Appearance.spacing.normal

//             // Важно: visible управляется родителем (bgRect), тут дублировать не обязательно, но можно

//             Repeater {
//                 model: (host.modelData && host.modelData.type === "group") ? host.modelData.children : []
//                 delegate: Loader {
//                     active: !!modelData && !!modelData.name
//                     source: active ? Qt.resolvedUrl("../components/" + modelData.name + ".qml") : ""

//                     onLoaded: {
//                         if (item && item.hasOwnProperty("screen")) item.screen = host.screen
//                         console.log("Group Widget loaded:", modelData.name)
//                     }
//                 }
//             }
//         }
//     }

//     // Debug
//     Component.onCompleted: {
//         if (!modelData) console.log("CRITICAL: modelData is NULL")
//     }
// }
// // Item {
// StyledRect {
//     color: "red"
//     opacity: 0.5
//     id: host
//     Component.onCompleted: {
//             console.log("--- DEBUG HOST ---")
//             if (!modelData) {
//                 console.log("CRITICAL: modelData is NULL")
//             } else {
//                 console.log("modelData type:", modelData.type)
//                 console.log("modelData name:", modelData.name)
//                 if (modelData.type === "group") {
//                     console.log("Group children count:", modelData.children ? modelData.children.length : 0)
//                 }
//             }
//         }
//     // property var modelData: null
//     required property ShellScreen screen

//     // Пробрасываем размеры контента, чтобы FlexboxLayout в Center.qml их видел
//     // implicitWidth: mainLoader.active ? mainLoader.implicitWidth : groupLayout.implicitWidth
//     // implicitHeight: mainLoader.active ? mainLoader.implicitHeight : groupLayout.implicitHeight
//     implicitWidth: mainLoader.active ? mainLoader.implicitWidth : groupLayout.childrenRect.width
//     implicitHeight: mainLoader.active ? mainLoader.implicitHeight : groupLayout.childrenRect.height

//     // 1. Одиночный виджет
//     Loader {
//         id: mainLoader
//         anchors.centerIn: parent
//         // Проверяем тип и наличие имени
//         active: host.modelData && host.modelData.type === "widget" && !!host.modelData.name
//         source: active ? Qt.resolvedUrl("../components/" + host.modelData.name + ".qml") : ""

//         onLoaded: {
//             if (item && item.hasOwnProperty("screen")) item.screen = host.screen
//         }
//     }

//     // 2. Группа виджетов (теперь без ошибки с 'active')
//     // RowLayout {
//     StyledRect {
//         visible: host.modelData && host.modelData.type === "group"
//         // color: Colours.palette.surface_container
//         color: "green"
//         opacity: 0.5;
//         // anchors.centerIn: parent
//         // anchors.fill: parent
//         anchors.verticalCenter: parent.verticalCenter
//         // anchors.horizontalCenter: parent.horizontalCenter
//         anchors.left: Config.bar.orientation ? parent.left : undefined
//         anchors.top: Config.bar.orientation ? undefined : parent.top
//         anchors.right: Config.bar.orientation ? parent.right : undefined
//         anchors.bottom: Config.bar.orientation ? undefined : parent.bottom
//         // anchors.horizontalCenter: Config.bar.orientation ? parent.horizontalCenter : undefined
//         // anchors.verticalCenter: Config.bar.orientation ? undefined : parent.verticalCenter
//         // anchors.horizontalCenter: Config.bar.orientation ? undefined : parent.horizontalCenter
//         // anchors.verticalCenter: Config.bar.orientation ? parent.verticalCenter : undefined
//         // anchors.horizontalCenter: Config.bar.orientation ? undefined : parent.horizontalCenter
//         // anchors.verticalCenter: Config.bar.orientation ? parent : undefined
//         // implicitHeight: Config.bar.orientation ? Config.bar.group.thickness : undefined
//         // implicitWidth: Config.bar.orientation ? undefined : Config.bar.group.thickness
//         // implicitHeight: Config.bar.orientation ? Config.bar.group.thickness : 10 //groupLayout.height
//         // implicitWidth: Config.bar.orientation ? groupLayout.implicitWidth : Config.bar.group.thickness
//         // height: Config.bar.orientation ? Config.bar.group.thickness : undefined
//         // width: Config.bar.orientation ? undefined : Config.bar.group.thickness
//         implicitHeight: Config.bar.group.thickness
//         // implicitHeight: childrenRect.height
//         // implicitWidth: childrenRect.width
//         // height: childrenRect.height
//         // width: childrenRect.width
//         FlexboxLayout {
//             // id: root
//             // required property ShellScreen screen

//             direction: Config.bar.orientation ? FlexboxLayout.Row : FlexboxLayout.Column
//             alignItems: FlexboxLayout.AlignCenter
//             gap: Appearance.spacing.normal
//             id: groupLayout
//             anchors.verticalCenter: parent.verticalCenter
//             // anchors.horizontalCenter: parent.horizontalCenter
//             // anchors.centerIn: parent
//             // Используем visible вместо active
//             visible: host.modelData && host.modelData.type === "group"
//             // spacing: Appearance.spacing.small
//             // implicitHeight: childrenRect.height
//             // implicitWidth: childrenRect.width

//             Repeater {
//                 // Если это не группа, скармливаем пустой массив
//                 model: (host.modelData && host.modelData.type === "group") ? host.modelData.children : []
//                 delegate: Loader {
//                     // Внутри Repeater используем modelData (это элемент массива children)
//                     active: !!modelData && !!modelData.name
//                     // source: active ? Qt.resolvedUrl("../widgets/" + modelData.name + ".qml") : ""
//                     // source: active ? "/home/pundemia/.config/quickshell/pShell/modules/bar/content/components/" + modelData.name + ".qml" : ""
//                     source: active ? Qt.resolvedUrl("../components/" + modelData.name + ".qml") : ""
//                     onLoaded: {
//                         console.log("Widget loaded")
//                         console.log("Widget name:", modelData.name)
//                         console.log("Widget source:", source)
//                     }
//                     // onLoaded: if (item && item.hasOwnProperty("screen")) item.screen = host.screen
//                 }
//             }
//         }
//     }
// }
