import Quickshell.Io
import qs.config

import "components"
import "structures"
//

JsonObject {
    // property bool direction: false
    property int gap: 10
    property int rounding: 10
    property int invertBaseRounding: 10
    property bool excludeBareArea: true
    property bool reusability: false
    property AnchorsData anchors: AnchorsData {
        // top: true
        // bottom: true
        verticalCenter: true
        horizontalCenter: true
    }
    property OffsetsData offsets: OffsetsData {
        verticalCenter: 0
        horizontalCenter: 0
    }
    property PaddingsData paddings: PaddingsData {

    }
}
