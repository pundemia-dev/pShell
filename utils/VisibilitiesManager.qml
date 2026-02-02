pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    // Map: Monitor -> PerMonitorVisibilities
    property var screens: new Map()

    // Для хранения созданных шорткатов (чтобы не дублировать)
    property var createdShortcuts: []
    property var registeredShortcuts: ({})

    property Component shortcutComponent: Component {
        CustomShortcut {}
    }

    // Регистрация per-monitor visibilities
    function load(screen: ShellScreen, visibilities): void {
        screens.set(Hyprland.monitorFor(screen), visibilities);
    }

    // Удаление per-monitor visibilities
    function unload(screen: ShellScreen): void {
        screens.delete(Hyprland.monitorFor(screen));
    }

    // Получить visibilities для активного монитора
    function getForActive() {
        return screens.get(Hyprland.focusedMonitor);
    }

    // Получить visibilities для конкретного экрана
    function getForScreen(screen: ShellScreen) {
        return screens.get(Hyprland.monitorFor(screen));
    }

    // Interrupt all visibilities на активном мониторе
    function interruptAllForActive() {
        var vis = getForActive();
        if (vis) {
            vis.interruptAll();
        }
    }

    // Регистрация глобального шортката (вызывается один раз)
    function registerShortcut(name: string, shortcut: string, description: string): void {
        // Проверяем, не создан ли уже шорткат
        if (registeredShortcuts[name]) {
            return;
        }

        if (shortcut === "") {
            return;
        }

        // Создаём interrupt шорткат
        var interruptShortcut = shortcutComponent.createObject(root, {
            name: name + "Interrupt",
            description: "Interrupt " + name + " keybind",
            sequence: shortcut
        });
        interruptShortcut.pressed.connect(function() {
            interruptAllForActive();
        });
        createdShortcuts.push(interruptShortcut);

        // Создаём основной шорткат
        var mainShortcut = shortcutComponent.createObject(root, {
            name: name,
            description: description !== "" ? description : name,
            sequence: shortcut
        });
        mainShortcut.pressed.connect(function() {
            var visName = name;
            var vis = getForActive();
            if (vis) {
                vis.setInterrupted(visName, false);
            }
        });
        mainShortcut.released.connect(function() {
            var visName = name;
            var vis = getForActive();
            if (vis) {
                if (!vis.isInterrupted(visName)) {
                    vis.toggleVisibility(visName);
                }
                vis.setInterrupted(visName, false);
            }
        });
        createdShortcuts.push(mainShortcut);

        registeredShortcuts[name] = true;
    }
}
