import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "bbk.memory"

  property int percentage: 0
  property real usedGb: 0
  property real totalGb: 0

  function refresh() {
    if (!memProc.running) memProc.running = true
  }

  function openMonitor() {
    if (root.bar) root.bar.run("omarchy-launch-or-focus-tui btop")
  }

  Component.onCompleted: refresh()

  Process {
    id: memProc
    command: ["sh", "-c", "free -b | awk '/Mem:/ {printf \"%.0f %.1f %.1f\", $3/$2*100, $3/1073741824, $2/1073741824}'"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        const parts = text.trim().split(" ")
        if (parts.length < 3) return
        root.percentage = parseInt(parts[0], 10) || 0
        root.usedGb = parseFloat(parts[1]) || 0
        root.totalGb = parseFloat(parts[2]) || 0
      }
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  visible: true
  implicitWidth: button.implicitWidth + Style.space(12)
  implicitHeight: button.implicitHeight

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

  WidgetButton {
    id: button
    anchors.fill: parent
    anchors.leftMargin: root.vertical ? 0 : Style.space(6)
    anchors.rightMargin: root.vertical ? 0 : Style.space(6)
    bar: root.bar
    foreground: Color.bar.text
    text: "\u{F061A} " + root.percentage + "%"
    fontSize: Style.font.body
    horizontalMargin: 6
    tooltipText: "Used: " + root.usedGb.toFixed(1) + "G / " + root.totalGb.toFixed(1) + "G"
    onPressed: function() { root.openMonitor() }
  }
}
