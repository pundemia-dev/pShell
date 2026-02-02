import QtQuick
import Quickshell

QtObject {
    id: root

    required property ShellScreen screen

    // Структура данных для хранения visibilities с именованным доступом
    property var visibilitiesData: ({})
    property var visibilitiesOrder: []

    Component.onCompleted: {
        VisibilitiesManager.load(screen, this);
    }

    Component.onDestruction: {
        VisibilitiesManager.unload(screen);
    }

    // Добавить visibility (вызывается при инициализации модуля)
    function addVisibility(name: string, shortcut: string, isolated: bool, autostart: bool, description: string): var {
        var entry = {
            name: name,
            shortcut: shortcut,
            isolated: isolated,
            state: autostart,
            interrupted: false
        };
        visibilitiesData[name] = entry;
        visibilitiesOrder.push(name);
        visibilitiesData = visibilitiesData; // trigger binding update
        visibilitiesOrder = visibilitiesOrder;

        // Регистрируем глобальный шорткат (только один раз через менеджер)
        if (shortcut !== "") {
            VisibilitiesManager.registerShortcut(name, shortcut, description);
        }

        return entry;
    }

    // Toggle visibility по имени
    function toggleVisibility(name: string): void {
        if (visibilitiesData[name]) {
            visibilitiesData[name].state = !visibilitiesData[name].state;
            visibilitiesData = visibilitiesData; // trigger binding update
        }
    }

    // Установить state напрямую
    function setVisibility(name: string, state: bool): void {
        if (visibilitiesData[name]) {
            visibilitiesData[name].state = state;
            visibilitiesData = visibilitiesData;
        }
    }

    // Получить state
    function getVisibility(name: string): bool {
        if (visibilitiesData[name]) {
            return visibilitiesData[name].state;
        }
        return false;
    }

    // Interrupt all visibilities на этом мониторе
    function interruptAll(): void {
        for (var key in visibilitiesData) {
            if (visibilitiesData.hasOwnProperty(key)) {
                visibilitiesData[key].interrupted = true;
            }
        }
        visibilitiesData = visibilitiesData;
    }

    // Проверить interrupted
    function isInterrupted(name: string): bool {
        if (visibilitiesData[name]) {
            return visibilitiesData[name].interrupted;
        }
        return false;
    }

    // Установить interrupted
    function setInterrupted(name: string, value: bool): void {
        if (visibilitiesData[name]) {
            visibilitiesData[name].interrupted = value;
            visibilitiesData = visibilitiesData;
        }
    }

    // Получить visibility по имени
    function getVisibilityByName(name: string): var {
        return visibilitiesData[name] || null;
    }

    // Получить visibility по индексу
    function getVisibilityByIndex(index: int): var {
        if (index < 0 || index >= visibilitiesOrder.length) {
            return null;
        }
        var name = visibilitiesOrder[index];
        return visibilitiesData[name];
    }

    // Установить параметр visibility
    function setVisibilityParam(name: string, param: string, value): void {
        if (visibilitiesData[name]) {
            visibilitiesData[name][param] = value;
            visibilitiesData = visibilitiesData;
        }
    }

    // Удалить visibility
    function removeVisibility(name: string): void {
        if (visibilitiesData[name]) {
            delete visibilitiesData[name];
            var idx = visibilitiesOrder.indexOf(name);
            if (idx !== -1) {
                visibilitiesOrder.splice(idx, 1);
            }
            visibilitiesData = visibilitiesData;
            visibilitiesOrder = visibilitiesOrder;
        }
    }
}
