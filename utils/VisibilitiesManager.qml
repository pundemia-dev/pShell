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

    // Регистрация глобального шортката (вызывается один раз)
    function registerShortcut(name: string, shortcut: string, description: string): void {
        // Проверяем, не создан ли уже шорткат
        if (registeredShortcuts[name]) {
            return;
        }

        if (shortcut === "") {
            return;
        }

        // Создаём основной шорткат
        var visName = name;
        var mainShortcut = shortcutComponent.createObject(root, {
            name: shortcut,
            description: description !== "" ? description : name,
            onActivated: function() {
                var vis = getForActive();
                if (vis) {
                    vis.toggleVisibility(visName);
                }
            }
        });
        createdShortcuts.push(mainShortcut);

        registeredShortcuts[name] = true;
    }
}
