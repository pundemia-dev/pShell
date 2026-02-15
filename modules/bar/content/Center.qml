import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.widgets
import "components"
import "components/workspaces"

FlexboxLayout {
    id: root
    required property ShellScreen screen

    direction: Config.bar.orientation ? FlexboxLayout.Row : FlexboxLayout.Column
    alignItems: FlexboxLayout.AlignCenter
    // justifyContent: FlexboxLayout.JustifyCenter
    gap: Appearance.spacing.normal

    Repeater {
        id: widgetRepeater // Обязательно даем ID
        // model: Config.bar.centerLayout || []
        model: ScriptModel {
            values: Config.bar.centerLayout || []
        }

        delegate: WidgetHost {
            // Явно берем данные из модели репитера по индексу.
            // Это игнорирует modelData экрана и берет объект виджета.
            // dataModel: widgetRepeater.model[index]
            required property var modelData
            screen: root.screen

            Component.onCompleted: {
                console.log("--- HOST CHECK ---")
                console.log("Index:", index)
                console.log("Real Name:", dataModel ? dataModel.name : "null")
            }
        }
    }
}
// FlexboxLayout {
//     id: root
//     required property ShellScreen screen

//     direction: Config.bar.orientation ? FlexboxLayout.Row : FlexboxLayout.Column
//     alignItems: FlexboxLayout.AlignCenter
//     gap: Appearance.spacing.normal

//     Repeater {
//         // Защита от undefined, если конфиг еще не загружен
//         model: Config.bar.centerLayout || []

//         delegate: WidgetHost {
//             // modelData — это стандартное имя текущего элемента в Repeater
//             dataModel: modelData
//             screen: root.screen
//         }
//     }
//     Component.onCompleted: {
//             console.log("--- DEBUG CENTER ---")
//             console.log("CenterLayout exists:", !!Config.bar.centerLayout)
//             if (Config.bar.centerLayout) {
//                 console.log("Items count:", Config.bar.centerLayout.length)
//                 console.log("Raw data:", JSON.stringify(Config.bar.centerLayout))
//             }
//         }
// }

// FlexboxLayout {
//     id: root
//     required property ShellScreen screen

//     direction: Config.bar.orientation ? FlexboxLayout.Row : FlexboxLayout.Column
//     alignItems: FlexboxLayout.AlignCenter
//     gap: Appearance.spacing.normal

//     Repeater {
//         // Защита от undefined, если конфиг еще не загружен
//         model: Config.bar.centerLayout || []

//         delegate: WidgetHost {
//             // modelData — это стандартное имя текущего элемента в Repeater
//             dataModel: modelData
//             screen: root.screen
//         }
//     }
//     Component.onCompleted: {
//             console.log("--- DEBUG CENTER ---")
//             console.log("CenterLayout exists:", !!Config.bar.centerLayout)
//             if (Config.bar.centerLayout) {
//                 console.log("Items count:", Config.bar.centerLayout.length)
//                 console.log("Raw data:", JSON.stringify(Config.bar.centerLayout))
//             }
//         }
// }
// FlexboxLayout {
//     id: root
//     required property ShellScreen screen

//     direction: Config.bar.orientation ? FlexboxLayout.Row : FlexboxLayout.Column
//     alignItems: FlexboxLayout.AlignCenter
//     gap: Appearance.spacing.normal

//     Repeater {
//         // Используем модель из конфига
//         model: Config.bar.centerLayout || []

//         // Внутри делегата Quickshell автоматически предоставляет modelData и index
//         delegate: WidgetHost {
//             // Передаем данные явно
//             dataModel: modelData
//             screen: root.screen

//             // Если вы все еще получаете ошибку index, попробуйте так:
//             // dataModel: Config.bar.centerLayout[index]
//         }
//     }
// }
// FlexboxLayout {
//     id: root
//     required property ShellScreen screen

//     direction: Config.bar.orientation ? FlexboxLayout.Row : FlexboxLayout.Column
//     alignItems: FlexboxLayout.AlignCenter
//     gap: Appearance.spacing.normal

//     Repeater {
//         // Явно берем модель из конфига
//         model: Config.bar.centerLayout

//         delegate: WidgetHost {
//             // Вместо modelData используем прямой доступ по индексу
//             // Это гарантирует, что мы берем объект из centerLayout
//             dataModel: Config.bar.centerLayout[index]
//             screen: root.screen

//             Component.onCompleted: {
//                 if (dataModel) {
//                     console.log("Widget initialized:", dataModel.name || "Group");
//                 } else {
//                     console.warn("DataModel is undefined for index:", index);
//                 }
//             }
//         }
//     }
// }
// FlexboxLayout {
//     id: root
//     required property ShellScreen screen
//     direction: Config.bar.orientation ? FlexboxLayout.Row : FlexboxLayout.Column
//     alignItems: FlexboxLayout.AlignCenter
//     justifyContent: FlexboxLayout.JustifyStart
//     gap: Appearance.spacing.medium

//     Repeater {
//         model: Config.bar.centerLayout
//         delegate: WidgetHost {
//             dataModel: modelData
//             screen: root.screen
//             Component.onCompleted: {
//                 console.log("Component completed");
//                 console.log(dataModel);
//             }
//         }
//     }
// }

// FlexboxLayout {
//     id: root
//     // anchors.fill: parent
//     required property ShellScreen screen
//     direction: Config.bar.orientation ? FlexboxLayout.Row : FlexboxLayout.Column
//     alignItems: FlexboxLayout.AlignCenter
//     justifyContent: FlexboxLayout.JustifyStart
//     gap: 0

//     Clock {
//         id: clock
//     }

//     Power {
//         id: power
//     }

//     Network {
//         id: network
//     }

//     Bluetooth {
//         id: bluetooth
//     }

//     KeyboardPreview {
//         id: keyboardPreview
//     }

//     OsIcon {
//         id: osIcon
//     }

//     Tray {
//         id: tray
//     }

//     // Workspaces {
//     //     id: workspaces
//     //     screen: screen
//     // }


//     Rectangle {
//         id: resizableRect
//         width: 20
//         height: 20
//         color: "lightgreen"
//         opacity: 0.5
//         radius: 4

//         Behavior on width {
//             NumberAnimation {
//                 duration: 200
//             }
//         }
//         Behavior on height {
//             NumberAnimation {
//                 duration: 200
//             }
//         }

//         MouseArea {
//             anchors.fill: parent
//             hoverEnabled: true
//             onEntered: {
//                 resizableRect.width = Config.bar.orientation ? 100 : 20
//                 resizableRect.height = Config.bar.orientation ? 20 : 100
//             }
//             onExited: {
//                 resizableRect.width = 20
//                 resizableRect.height = 20
//             }
//         }
//     }
// }
