import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "../custom.common"

BarWidget {
  id: root
  moduleName: "omarchy.system-update"

  property bool updateAvailable: false

  function refresh() {
    if (!updateProc.running) updateProc.running = true
  }

  function clear() { updateAvailable = false }

  function runUpdate() {
    if (root.bar) root.bar.run("omarchy-launch-floating-terminal-with-presentation omarchy-update")
  }

  visible: updateAvailable
  implicitWidth: button.implicitWidth + Style.space(12)
  implicitHeight: button.implicitHeight

  IpcHandler {
    target: "omarchy.system-update"

    function refresh(): void {
      root.broadcast("refresh")
    }

    function clear(): void {
      root.broadcast("clear")
    }
  }

  Process {
    id: updateProc
    command: ["omarchy-update-available"]
    onExited: function(exitCode) {
      root.updateAvailable = exitCode === 0
    }
  }

  Timer {
    interval: 21600000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  CustomPill { }

  BarIconButton {
    id: button
    anchors.fill: parent
    anchors.leftMargin: root.vertical ? 0 : Style.space(6)
    anchors.rightMargin: root.vertical ? 0 : Style.space(6)
    bar: root.bar
    foreground: Color.bar.text
    text: "\uf021"
    slotSize: Style.bar.statusSlot
    fontSize: Style.font.body
    tooltipText: "Pending Omarchy Updates"
    onPressed: root.runUpdate()
  }
}
