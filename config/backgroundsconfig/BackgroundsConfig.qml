import Quickshell.Io

JsonObject {
    property int rounding: 30
    property bool invertBaseRounding: true
    property Directions margins: Directions {}
    property Directions paddings: Directions {
        left: 15
        right: 15
        top: 15
        bottom: 15
    }
    property Offsets offsets: Offsets {}

    component Directions: JsonObject {
        property int left: 0
        property int right: 0
        property int top: 0
        property int bottom: 0
    }

    component Offsets: JsonObject {
        property int vCenterOffset: 0
        property int hCenterOffset: 0
    }
}
