import QtQuick
import QtQuick.Layouts
import qs.config
import qs.utils
import qs.components
import qs.components.controls
import qs.services
import Quickshell
import Quickshell.Io // Для объекта Process

LauncherModule {
    id: root

    moduleId: "gif"
    name: "GIF Search"
    description: "Search and copy GIFs from Giphy"
    trigger: "gif"
    icon: "🎞️"

    hasLeftPanel: true
    hasRightPanel: false
    customRightWidth: 380

    // Публичный тестовый ключ Giphy (для продакшена лучше зарегистрировать свой на developers.giphy.com)
    property string apiKey: "" // надо перенести в конфиг

    property var selectedGif: null
    property var _pendingGif: null

    Timer {
        id: uiDebounceTimer
        interval: 80
        onTriggered: selectedGif = _pendingGif
    }

    Timer {
        id: networkDebounceTimer
        interval: 500
        property string currentQuery: ""
        onTriggered: root.fetchGifs(currentQuery)
    }

    ScriptModel {
        id: internalModel
    }

    listModel: internalModel

    function handleInput(query) {
        if (query.trim() === "") {
            internalModel.values =[]
            selectedGif = null
            hasRightPanel = false
            networkDebounceTimer.stop()
            return
        }
        networkDebounceTimer.currentQuery = query
        networkDebounceTimer.restart()
    }

    // --- СЕТЕВОЙ ЗАПРОС К GIPHY API ---
    function fetchGifs(query) {
        let xhr = new XMLHttpRequest()
        let url = `https://api.giphy.com/v1/gifs/search?api_key=${apiKey}&q=${encodeURIComponent(query)}&limit=20`

        xhr.open("GET", url)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                let response = JSON.parse(xhr.responseText)
                let results = response.data ||[]

                let newValues = results.map(gif => {
                    // Giphy отдает разные размеры.
                    // original - полноразмерная для копирования и правой панели
                    // fixed_height_small - легкая превьюшка 100px для левого списка
                    let original = gif.images.original
                    let thumb = gif.images.fixed_height_small

                    return {
                        header: gif.title || "GIF Image",
                        text: "Enter: Copy URL • Alt+Enter: Copy File",
                        leftIcon: thumb.url, // Прямая ссылка на легкую миниатюру
                        isLeftIconImage: true,
                        rightIcon: "\ue14d",
                        rightText: original.width + "x" + original.height,

                        rawGifData: original,

                        onClicked: function() {
                            root.copyGifToClipboard(original.url, false)
                            requestClose(true)
                        },
                        onAltClicked: function() {
                            root.copyGifToClipboard(original.url, true)
                            requestClose(true)
                        },
                        onSelected: function() {
                            root._pendingGif = original
                            root.hasRightPanel = true
                            uiDebounceTimer.restart()
                        }
                    }
                })
                internalModel.values = newValues
            }
        }
        xhr.send()
    }

    function copyGifToClipboard(url, copyAsFile) {
        // Нативный запуск процесса без блокировки UI
        let proc = Qt.createQmlObject('import Quickshell.Io; Process {}', root)

        if (copyAsFile) {
            proc.command =["sh", "-c", `curl -s "${url}" | wl-copy -t image/gif`]
        } else {
            proc.command =["sh", "-c", `printf '%s' "${url}" | wl-copy`]
        }

        // Удаляем из памяти после завершения
        proc.exited.connect(() => {
            console.log("[GifModule] Clipboard process exited.")
            proc.destroy()
        })

        proc.running = true
    }

    // Обработка прямого Enter
    function execute(query, isAlt) {
        if (selectedGif) {
            copyGifToClipboard(selectedGif.url, isAlt)
            requestClose(true)
        }
    }

    rightPanelComponent: Component {
        Item {
            id: panelRoot
            anchors.fill: parent

            property var displayedGif: root.selectedGif

            Connections {
                target: root
                function onSelectedGifChanged() { fadeOut.start() }
            }

            SequentialAnimation {
                id: fadeOut
                Anim { target: content; property: "opacity"; to: 0; duration: 100 }
                ScriptAction { script: { panelRoot.displayedGif = root.selectedGif; fadeIn.start() } }
            }
            Anim { id: fadeIn; target: content; property: "opacity"; to: 1; duration: 150 }

            ColumnLayout {
                id: content
                anchors.fill: parent
                anchors.margins: Appearance.padding.large
                spacing: 12

                StyledRect {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Appearance.rounding.normal
                    color: Colours.alpha(Colours.palette.surface_variant, 0.3)
                    clip: true

                    CircularIndicator {
                        anchors.centerIn: parent
                        running: gifPlayer.status === AnimatedImage.Loading
                        visible: running
                    }

                    AnimatedImage {
                        id: gifPlayer
                        anchors.fill: parent
                        anchors.margins: 4
                        fillMode: Image.PreserveAspectFit
                        source: panelRoot.displayedGif ? panelRoot.displayedGif.url : ""
                        playing: status === AnimatedImage.Ready
                        asynchronous: true
                    }
                }

                SectionContainer {
                    Layout.fillWidth: true

                    PropertyRow {
                        label: "Direct Link"
                        value: "Press Enter to copy"
                    }
                    PropertyRow {
                        label: "Image File"
                        value: "Press Alt+Enter to copy"
                        showTopMargin: true
                    }
                }
            }
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
// import Quickshell
// import Quickshell.Io // Для объекта Process

// LauncherModule {
//     id: root

//     moduleId: "gif"
//     name: "GIF Search"
//     description: "Search and copy GIFs from Tenor"
//     trigger: "gif"
//     icon: "🎞️"

//     hasLeftPanel: true
//     hasRightPanel: false
//     customRightWidth: 380

//     // Тестовый ключ Tenor V2
//     property string apiKey: "LIVDSRZULELA"

//     property var selectedGif: null
//     property var _pendingGif: null

//     Timer {
//         id: uiDebounceTimer
//         interval: 80
//         onTriggered: selectedGif = _pendingGif
//     }

//     Timer {
//         id: networkDebounceTimer
//         interval: 500
//         property string currentQuery: ""
//         onTriggered: root.fetchGifs(currentQuery)
//     }

//     ScriptModel {
//         id: internalModel
//     }

//     listModel: internalModel

//     function onActivated(initialQuery) {
//         handleInput(initialQuery ?? "")
//     }

//     function handleInput(query) {
//         console.log("[GifModule] handleInput:", query)
//         if (query.trim() === "") {
//             internalModel.values =[]
//             selectedGif = null
//             hasRightPanel = false
//             networkDebounceTimer.stop()
//             return
//         }
//         networkDebounceTimer.currentQuery = query
//         networkDebounceTimer.restart()
//     }

//     function fetchGifs(query) {
//         let xhr = new XMLHttpRequest()
//         let url = `https://tenor.googleapis.com/v2/search?q=${encodeURIComponent(query)}&key=${apiKey}&limit=20`

//         xhr.open("GET", url)
//         // xhr.onreadystatechange = function() {
//         //     if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
//         //         let response = JSON.parse(xhr.responseText)
//         //         let results = response.results ||[]

//         //         let newValues = results.map(gif => {
//         //             let media = gif.media_formats.gif
//         //             // Используем nanogif или tinygif для легкой миниатюры в левом списке
//         //             let thumb = gif.media_formats.nanogif || gif.media_formats.tinygif || media

//         //             return {
//         //                 header: gif.content_description || "GIF Image",
//         //                 text: "Enter: Copy URL • Alt+Enter: Copy File",
//         //                 leftIcon: thumb.url, // Прямая ссылка на миниатюру
//         //                 isLeftIconImage: true,
//         //                 rightIcon: "\ue14d",
//         //                 rightText: media.dims[0] + "x" + media.dims[1],

//         //                 rawGifData: media,

//         //                 onClicked: function() {
//         //                     root.copyGifToClipboard(media.url, false)
//         //                     requestClose(true)
//         //                 },
//         //                 onAltClicked: function() {
//         //                     root.copyGifToClipboard(media.url, true)
//         //                     requestClose(true)
//         //                 },
//         //                 onSelected: function() {
//         //                     root._pendingGif = media
//         //                     root.hasRightPanel = true
//         //                     uiDebounceTimer.restart()
//         //                 }
//         //             }
//         //         })
//         //         internalModel.values = newValues
//         //     }
//         // }
//         xhr.onreadystatechange = function() {
//             if (xhr.readyState === XMLHttpRequest.DONE) {
//                 console.log("[GifModule] status:", xhr.status)
//                 if (xhr.status === 200) {
//                     let response = JSON.parse(xhr.responseText)
//                     let results = response.results || []

//                     let newValues = results.map(gif => {
//                         let media = gif.media_formats.gif
//                         let thumb = gif.media_formats.nanogif || gif.media_formats.tinygif || media

//                         return {
//                             header: gif.content_description || "GIF Image",
//                             text: "Enter: Copy URL • Alt+Enter: Copy File",
//                             leftIcon: thumb.url,
//                             isLeftIconImage: true,
//                             rightIcon: "\ue14d",
//                             rightText: media.dims[0] + "x" + media.dims[1],
//                             rawGifData: media,
//                             onClicked: function() {
//                                 root.copyGifToClipboard(media.url, false)
//                                 requestClose(true)
//                             },
//                             onAltClicked: function() {
//                                 root.copyGifToClipboard(media.url, true)
//                                 requestClose(true)
//                             },
//                             onSelected: function() {
//                                 root._pendingGif = media
//                                 root.hasRightPanel = true
//                                 uiDebounceTimer.restart()
//                             }
//                         }
//                     })
//                     internalModel.values = newValues
//                 } else {
//                     console.log("[GifModule] error:", xhr.responseText)
//                 }
//             }
//         }
//         xhr.send()
//     }

//     function copyGifToClipboard(url, copyAsFile) {
//         // Динамически создаем объект Process (чтобы не блокировать UI)
//         let proc = Qt.createQmlObject('import Quickshell.Io; Process {}', root)

//         if (copyAsFile) {
//             proc.command =["sh", "-c", `curl -s "${url}" | wl-copy -t image/gif`]
//         } else {
//             proc.command = ["sh", "-c", `printf '%s' "${url}" | wl-copy`]
//         }

//         // Автоматически удаляем объект из памяти после завершения команды
//         proc.exited.connect(() => {
//             console.log("[GifModule] Clipboard process exited.")
//             proc.destroy()
//         })

//         proc.running = true
//     }

//     // Обработка прямого Enter из строки ввода
//     function execute(query, isAlt) {
//         if (selectedGif) {
//             copyGifToClipboard(selectedGif.url, isAlt)
//             requestClose(true)
//         }
//     }

//     rightPanelComponent: Component {
//         Item {
//             id: panelRoot
//             anchors.fill: parent

//             property var displayedGif: root.selectedGif

//             Connections {
//                 target: root
//                 function onSelectedGifChanged() { fadeOut.start() }
//             }

//             SequentialAnimation {
//                 id: fadeOut
//                 Anim { target: content; property: "opacity"; to: 0; duration: 100 }
//                 ScriptAction { script: { panelRoot.displayedGif = root.selectedGif; fadeIn.start() } }
//             }
//             Anim { id: fadeIn; target: content; property: "opacity"; to: 1; duration: 150 }

//             ColumnLayout {
//                 id: content
//                 anchors.fill: parent
//                 anchors.margins: Appearance.padding.large
//                 spacing: 12

//                 StyledRect {
//                     Layout.fillWidth: true
//                     Layout.fillHeight: true
//                     radius: Appearance.rounding.normal
//                     color: Colours.alpha(Colours.palette.surface_variant, 0.3)
//                     clip: true

//                     CircularIndicator {
//                         anchors.centerIn: parent
//                         running: gifPlayer.status === AnimatedImage.Loading
//                         visible: running
//                     }

//                     // Стандартный QML плеер для воспроизведения GIF из сети
//                     AnimatedImage {
//                         id: gifPlayer
//                         anchors.fill: parent
//                         anchors.margins: 4
//                         fillMode: Image.PreserveAspectFit
//                         source: panelRoot.displayedGif ? panelRoot.displayedGif.url : ""
//                         playing: status === AnimatedImage.Ready
//                         asynchronous: true
//                     }
//                 }

//                 SectionContainer {
//                     Layout.fillWidth: true

//                     PropertyRow {
//                         label: "Direct Link"
//                         value: "Press Enter to copy"
//                     }
//                     PropertyRow {
//                         label: "Image File"
//                         value: "Press Alt+Enter to copy"
//                         showTopMargin: true
//                     }
//                 }
//             }
//         }
//     }
// }
