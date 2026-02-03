// BackgroundsApi.qml
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

QtObject {
    id: root

    property var slots: null
    property var isolatedBackgrounds: []
    property var pendingRequests: []

    property Component bgDataComponent: Component {
        QtObject {
            property var wrapper: null
            property bool excludeBarArea: false
        }
    }

    function registerSlots(slotsArray) {
        root.slots = slotsArray;
        // console.log("BackgroundsApi: Registered", slotsArray.length, "background slots");

        if (root.pendingRequests.length > 0) {
            // console.log("BackgroundsApi: Processing", root.pendingRequests.length, "pending requests");
            for (let i = 0; i < root.pendingRequests.length; i++) {
                const req = root.pendingRequests[i];
                root.requestBackground(req.wrapper, req.isolate, req.excludeBarArea);
            }
            root.pendingRequests = [];
        }
    }

    function determineSlotIndex(wrapper) {
        const left = wrapper.aLeft ?? false;
        const right = wrapper.aRight ?? false;
        const top = wrapper.aTop ?? false;
        const bottom = wrapper.aBottom ?? false;
        const hCenter = wrapper.aHorizontalCenter ?? false;
        const vCenter = wrapper.aVerticalCenter ?? false;

        if (top && !vCenter) {
            if (left && !hCenter)
                return 0;
            if (hCenter)
                return 1;
            if (right && !hCenter)
                return 2;
        }

        if (vCenter || (!top && !bottom)) {
            if (left && !hCenter)
                return 3;
            if (hCenter || (!left && !right))
                return 4;
            if (right && !hCenter)
                return 5;
        }

        if (bottom && !vCenter) {
            if (left && !hCenter)
                return 6;
            if (hCenter)
                return 7;
            if (right && !hCenter)
                return 8;
        }

        return 4;
    }

    function requestBackground(wrapper, isolate = false, excludeBarArea = true) {
        if (!wrapper) {
            // console.error("BackgroundsApi: wrapper is null!");
            return;
        }

        if (!root.slots && !isolate) {
            // console.warn("BackgroundsApi: Slots not registered yet. Queuing request.");
            root.pendingRequests.push({
                wrapper: wrapper,
                isolate: isolate,
                excludeBarArea: excludeBarArea
            });
            return;
        }

        if (isolate) {
            // console.log("BackgroundsApi: Creating isolated background");

            // Create a dynamic QtObject to act as the data model.
            // This allows us to update properties (like setting wrapper to null)
            // without replacing the object in the array, preserving the UI component.
            const bgObject = bgDataComponent.createObject(root, {
                wrapper: wrapper,
                excludeBarArea: excludeBarArea
            });

            root.isolatedBackgrounds = [...root.isolatedBackgrounds, bgObject];
        } else {
            const slotIndex = determineSlotIndex(wrapper);
            const slot = root.slots[slotIndex];

            if (!slot) {
                // console.error("BackgroundsApi: Slot", slotIndex, "not found");
                return;
            }

            // console.log("BackgroundsApi: Assigning wrapper to slot", slotIndex);

            // Просто присваиваем wrapper - биндинги сделают всё остальное
            slot.wrapper = wrapper;
            slot.excludeBarArea = excludeBarArea;

            if (!slot.active) {
                slot.active = true;
            }
        }
    }

    function finalizeIsolatedRemoval(index) {
        if (index >= 0 && index < root.isolatedBackgrounds.length) {
            const newIsolated = [...root.isolatedBackgrounds];
            const itemToRemove = newIsolated[index];

            newIsolated.splice(index, 1);
            root.isolatedBackgrounds = newIsolated;

            // Clean up the dynamic object
            if (itemToRemove) {
                // Delay destruction to allow bindings to clear
                const timer = Qt.createQmlObject("import QtQuick; Timer { interval: 100; running: true; repeat: false }", root);
                timer.triggered.connect(() => {
                    itemToRemove.destroy();
                    timer.destroy();
                });
            }
        }
    }

    function removeBackground(wrapper) {
        if (!wrapper) return;

        // Try removing from isolated backgrounds first
        const isolatedBg = root.isolatedBackgrounds.find(bg => bg.wrapper === wrapper);

        if (isolatedBg) {
            // Trigger closing animation by setting wrapper to null.
            // Since this is a QtObject, bindings in the UI will update automatically.
            isolatedBg.wrapper = null;
            return;
        }

        // If not found in isolated, try removing from slots
        if (root.slots) {
            const slotIndex = determineSlotIndex(wrapper);
            const slot = root.slots[slotIndex];

            if (slot && slot.wrapper === wrapper) {
                slot.wrapper = null;

                if (slot.item) {
                    function onClosed() {
                        if (slot.item) {
                            slot.item.closed.disconnect(onClosed);
                        }
                        slot.active = false;
                    }
                    slot.item.closed.connect(onClosed);
                } else {
                    slot.active = false;
                }
            }
        }
    }
}
