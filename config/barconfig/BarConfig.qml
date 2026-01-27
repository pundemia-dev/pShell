import Quickshell.Io
import qs.config

// import "components
//

JsonObject {
    property bool enabled: true
    property bool autoHide: false
    property bool orientation: true// orientation ([false] - vertical / [true] - horizontal)
    property bool position: true//  position ([false] - top or [true] - bottom / [false] - left or [true] - right)
    // property int thickness: 50
    property SeparatedData thickness: SeparatedData {
        all: 44
        // center: 100
    }
    property bool separated: true
    property SeparatedData paddings: SeparatedData {
        all: 15
        center: 25
        begin: 20
    }
    property SeparatedData rounding: SeparatedData {
        all: 12
        center: 30
        // begin: 15
    }
    property SeparatedData invertBaseRounding: SeparatedData {
        all: false
        center: true
    }
    property SeparatedData reusability: SeparatedData {
        all: false
    }

    property SeparatedData longSideMargin: SeparatedData {
        all: 7
        center: 0
    }

    property SeparatedData shortSideMargin: SeparatedData {
        all: 7
        // begin: 100
        // end: 100
    }
}
