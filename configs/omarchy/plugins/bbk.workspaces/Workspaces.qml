import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  readonly property var activeToplevel: ToplevelManager.activeToplevel
  readonly property string activeTitle: activeToplevel ? (activeToplevel.title || activeToplevel.appId || "") : ""
  readonly property int maxTitleChars: 40
  function truncatedTitle() {
    return activeTitle.length > maxTitleChars ? activeTitle.substring(0, maxTitleChars) + "…" : activeTitle
  }

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  function workspaceIds() {
    var ids = [1, 2, 3, 4, 5]
    var values = Hyprland.workspaces.values

    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id > 0 && id <= 10 && ids.indexOf(id) === -1) ids.push(id)
    }

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  implicitWidth: grid.implicitWidth + Style.space(32)
  implicitHeight: grid.implicitHeight

  Rectangle {
    visible: !root.vertical
    anchors.fill: parent
    anchors.topMargin: root.vertical ? 0 : 4
    anchors.bottomMargin: root.vertical ? 0 : 4
    anchors.leftMargin: root.vertical ? 0 : Style.space(2)
    anchors.rightMargin: root.vertical ? 0 : Style.space(2)
    radius: 4
    color: Util.alpha(Color.bar.background, 0.55)
  }

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.leftMargin: root.vertical ? 0 : Style.space(16)
    anchors.rightMargin: root.vertical ? 0 : Style.space(16)
    columns: root.vertical ? 1 : root.workspaceIds().length
    columnSpacing: root.vertical ? 0 : Style.space(10)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      WidgetButton {
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData

        readonly property string numberText: modelData === 10 ? "0" : String(modelData)

        bar: root.bar
        foreground: Color.bar.text
        text: focused
          ? (numberText + (root.activeTitle !== "" ? "  " + root.truncatedTitle() : ""))
          : numberText
        opacity: occupied || focused ? 1 : 0.5
        horizontalMargin: focused ? 10 : 6
        verticalPadding: 2
        fixedWidth: root.vertical ? root.barSize : (focused ? -1 : Style.space(2))
        fixedHeight: root.barSize
        onPressed: function() { root.focusWorkspace(modelData) }
      }
    }
  }
}
