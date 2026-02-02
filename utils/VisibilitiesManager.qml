pragma Singleton
pragma ComponentBehavior: Bound

import qs.components.misc
import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    // Глобальный сигнал об изменении visibility (для любого монитора)
    signal visibilityChanged(ShellScreen screen, string name, bool state)

    // Map: Monitor -> PerMonitorVisibilities
    property var screens: new Map()

    // Очередь отложенных запросов (когда visibility запрашивается до регистрации screen)
    property var pendingRequests: []

    // Для хранения созданных шорткатов (чтобы не дублировать)
    property var createdShortcuts: []
    property var registeredShortcuts: ({})

    property Component shortcutComponent: Component {
        CustomShortcut {}
    }

    // Регистрация per-monitor visibilities
    function load(screen: ShellScreen, visibilities): void {
        var monitor = Hyprland.monitorFor(screen);
        screens.set(monitor, visibilities);

        // Обрабатываем отложенные запросы для этого экрана
        processPendingRequests(screen);
    }

    // Обработка отложенных запросов для конкретного экрана
    function processPendingRequests(screen: ShellScreen): void {
        var monitor = Hyprland.monitorFor(screen);
        var vis = screens.get(monitor);
        if (!vis) return;

        var remaining = [];
        for (var i = 0; i < pendingRequests.length; i++) {
            var req = pendingRequests[i];
            var reqMonitor = Hyprland.monitorFor(req.screen);
            if (reqMonitor === monitor) {
                // Выполняем отложенный запрос
                vis.addVisibility(req.name, req.shortcut, req.isolated, req.autostart, req.description);
            } else {
                // Оставляем в очереди для другого экрана
                remaining.push(req);
            }
        }
        pendingRequests = remaining;
    }

    // Добавить visibility (можно вызывать из любого места)
    function addVisibility(screen: ShellScreen, name: string, shortcut: string, isolated: bool, autostart: bool, description: string): void {
        var vis = getForScreen(screen);
        if (vis) {
            vis.addVisibility(name, shortcut, isolated, autostart, description);
        } else {
            // Откладываем запрос до регистрации screen
            pendingRequests.push({
                screen: screen,
                name: name,
                shortcut: shortcut,
                isolated: isolated,
                autostart: autostart,
                description: description
            });
        }
    }

    // Установить visibility state (можно вызывать из любого места)
    function setVisibility(screen: ShellScreen, name: string, state: bool): void {
        var vis = getForScreen(screen);
        if (vis) {
            vis.setVisibility(name, state);
        }
    }

    // Удаление per-monitor visibilities
    function unload(screen: ShellScreen): void {
        screens.delete(Hyprland.monitorFor(screen));
    }

    // Получить visibilities для активного монитора
    function getForActive(): var {
        return screens.get(Hyprland.focusedMonitor);
    }

    // Получить visibilities для конкретного экрана
    function getForScreen(screen: ShellScreen): var {
        return screens.get(Hyprland.monitorFor(screen));
    }

    // Interrupt all visibilities на активном мониторе
    function interruptAllForActive(): void {
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
