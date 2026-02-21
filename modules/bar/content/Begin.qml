// modules/bar/content/Center.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.components
import qs.widgets
import "components"
import "components/workspaces"

FlexboxLayout {
    id: root
    required property ShellScreen screen

    justifyContent: FlexboxLayout.JustifyStart
    direction: Config.bar.orientation ? FlexboxLayout.Row : FlexboxLayout.Column
    alignItems: FlexboxLayout.AlignCenter
    gap: Appearance.spacing.normal

    Repeater {
        id: widgetRepeater
        model: ScriptModel {
            values: Config.bar.centerLayout || []
        }

        delegate: WidgetHost {
            required property var modelData
            screen: root.screen
        }
    }
}
