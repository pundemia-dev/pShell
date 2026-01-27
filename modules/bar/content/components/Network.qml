import qs.components
import qs.services
import qs.utils
import Quickshell
import QtQuick


RadialSliderIcon {
    id: network

    label: Nmcli.active ? Icons.getNetworkIcon(Nmcli.active.strength ?? 0) : "\uecfa"
    labelColor: Colours.palette.secondary
    implicitHeight: 30
    implicitWidth: 40
    progress: 0
}
