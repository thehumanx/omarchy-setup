import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons

// Auto-hiding app dock.
//   - Shows every open top-level window, grouped by app. Renders on every
//     connected display, each with its own independent hover/reveal state.
//   - Hidden by default; only a faint sliver hints at the screen edge, and
//     hovering it reveals the full dock. It slides fully away again after
//     the pointer leaves.
//   - Left-click activates/launches, middle-click closes the focused
//     window, right-click opens a context menu (new window, close, pin).
//     Pinned apps stay in the dock (and can be launched) even after every
//     window closes.
//   - Right-click on empty dock space opens a tiny position picker
//     (bottom/top/left/right). Position + pins persist to disk and apply
//     to every display's dock.
Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  readonly property string stateHome: Quickshell.env("HOME") + "/.local/state"
  readonly property string statePath: root.stateHome + "/omarchy/dock.json"

  property string position: "bottom"
  property var pinnedApps: []

  // -------------------------------------------------------------- persistence
  function loadState(raw) {
    var parsed = {}
    try { parsed = JSON.parse(raw || "{}") } catch (e) { parsed = {} }
    var pos = String(parsed.position || "bottom")
    if (["left", "right", "top", "bottom"].indexOf(pos) === -1) pos = "bottom"
    root.position = pos
    var pinned = Array.isArray(parsed.pinned) ? parsed.pinned : []
    var clean = []
    for (var i = 0; i < pinned.length; i++) {
      var p = pinned[i]
      if (p && p.id) clean.push({ id: String(p.id), name: String(p.name || p.id), icon: String(p.icon || "") })
    }
    root.pinnedApps = clean
  }

  function saveState() {
    stateFile.setText(JSON.stringify({ version: 1, position: root.position, pinned: root.pinnedApps }, null, 2) + "\n")
  }

  FileView {
    id: stateFile
    path: root.statePath
    watchChanges: true
    atomicWrites: true
    printErrors: false
    onLoaded: root.loadState(text())
    onLoadFailed: root.loadState("{}")
    onFileChanged: reload()
  }

  function setPosition(pos) {
    root.position = pos
    root.saveState()
  }

  // ---------------------------------------------------------------- sizing
  readonly property bool vertical: root.position === "left" || root.position === "right"
  readonly property int iconSize: Style.space(44)
  readonly property int iconGap: Style.space(10)
  readonly property int dockPadding: Style.space(8)
  readonly property int stripThickness: Math.max(2, Style.space(6))
  readonly property int handleLength: Style.space(28)
  readonly property int pickerButtonCount: 4
  readonly property int dockThickness: root.iconSize + root.dockPadding * 2
  readonly property int hiddenOffset: root.dockThickness - root.stripThickness

  function dockLengthFor(pickerOpen) {
    var count = pickerOpen ? root.pickerButtonCount : Math.max(1, root.dockItems.length)
    return count * root.iconSize + Math.max(0, count - 1) * root.iconGap + root.dockPadding * 2
  }

  // -------------------------------------------------------------- app model
  readonly property var runningToplevels: ToplevelManager.toplevels.values
  readonly property var desktopApps: DesktopEntries.applications.values

  function desktopEntryFor(appId) {
    if (!appId) return null
    var entry = DesktopEntries.heuristicLookup(appId)
    if (entry) return entry
    entry = DesktopEntries.byId(appId)
    return entry || null
  }

  function iconSource(icon, appId) {
    var value = String(icon || "")
    if (value.length === 0) {
      var byApp = Quickshell.iconPath(appId || "", true)
      return byApp.length > 0 ? byApp : Quickshell.iconPath("application-x-executable", true)
    }
    if (value.indexOf("file://") === 0 || value.indexOf("image://") === 0) return value
    if (value.charAt(0) === "/") return Util.fileUrl(value)
    var themed = Quickshell.iconPath(value, true)
    return themed.length > 0 ? themed : Quickshell.iconPath("application-x-executable", true)
  }

  function rebuildDockItems() {
    var _dep = root.desktopApps.length // register dependency; recompute when apps change
    var running = root.runningToplevels || []
    var groups = ({})
    var order = []
    for (var i = 0; i < running.length; i++) {
      var tl = running[i]
      var appId = tl.appId || ""
      var entry = root.desktopEntryFor(appId)
      var identity = entry ? entry.id : appId
      if (!identity) identity = "window-" + i
      if (!groups[identity]) {
        groups[identity] = {
          identity: identity,
          name: entry ? entry.name : (appId || tl.title || "Window"),
          icon: entry ? entry.icon : "",
          appId: appId,
          toplevels: []
        }
        order.push(identity)
      }
      groups[identity].toplevels.push(tl)
    }

    var items = []
    var used = ({})
    for (var p = 0; p < root.pinnedApps.length; p++) {
      var pin = root.pinnedApps[p]
      var g = groups[pin.id]
      items.push({
        identity: pin.id,
        name: g ? g.name : pin.name,
        icon: g ? g.icon : pin.icon,
        appId: g ? g.appId : pin.id,
        toplevels: g ? g.toplevels : [],
        pinned: true
      })
      used[pin.id] = true
    }
    for (var o = 0; o < order.length; o++) {
      var id = order[o]
      if (used[id]) continue
      var gr = groups[id]
      items.push({
        identity: id,
        name: gr.name,
        icon: gr.icon,
        appId: gr.appId,
        toplevels: gr.toplevels,
        pinned: false
      })
    }
    return items
  }

  readonly property var dockItems: root.rebuildDockItems()

  function activateItem(item) {
    if (item.toplevels.length === 0) {
      launchItem(item)
      return
    }
    if (item.toplevels.length === 1) {
      var tl = item.toplevels[0]
      if (tl.activated) tl.minimized = !tl.minimized
      else { tl.minimized = false; tl.activate() }
      return
    }
    var idx = -1
    for (var i = 0; i < item.toplevels.length; i++) {
      if (item.toplevels[i].activated) { idx = i; break }
    }
    var next = item.toplevels[(idx + 1) % item.toplevels.length]
    next.minimized = false
    next.activate()
  }

  function closeItem(item) {
    if (item.toplevels.length === 0) return
    for (var i = 0; i < item.toplevels.length; i++) {
      if (item.toplevels[i].activated) { item.toplevels[i].close(); return }
    }
    item.toplevels[0].close()
  }

  function launchItem(item) {
    var entry = DesktopEntries.byId(item.identity) || DesktopEntries.heuristicLookup(item.identity)
    if (entry) { entry.execute(); return }
    Util.execDetached("uwsm-app -- gtk-launch " + Util.shellQuote(item.identity + ".desktop"))
  }

  function togglePin(item) {
    var list = root.pinnedApps.slice()
    var idx = -1
    for (var i = 0; i < list.length; i++) if (list[i].id === item.identity) { idx = i; break }
    if (idx >= 0) list.splice(idx, 1)
    else list.push({ id: item.identity, name: item.name, icon: item.icon })
    root.pinnedApps = list
    root.saveState()
  }

  function menuActionsFor(item) {
    var actions = []
    if (item.toplevels.length > 0) {
      actions.push({ key: "newWindow", label: "New Window" })
      actions.push({ key: "close", label: "Close Window" })
      if (item.toplevels.length > 1) actions.push({ key: "closeAll", label: "Close All (" + item.toplevels.length + ")" })
    } else {
      actions.push({ key: "open", label: "Open" })
    }
    actions.push({ key: "pin", label: item.pinned ? "Unpin From Dock" : "Pin To Dock" })
    return actions
  }

  function runMenuAction(key, item) {
    if (key === "newWindow" || key === "open") root.launchItem(item)
    else if (key === "close") root.closeItem(item)
    else if (key === "closeAll") { for (var i = 0; i < item.toplevels.length; i++) item.toplevels[i].close() }
    else if (key === "pin") root.togglePin(item)
  }

  // ------------------------------------------------------------------- UI
  // One independent dock per connected display: each screen gets its own
  // PanelWindow with its own hover/reveal/menu state, all reading the same
  // shared position/pins/dockItems above.
  Variants {
    model: Quickshell.screens

    delegate: Component {
      PanelWindow {
        id: dockWindow
        required property var modelData
        screen: modelData

        property bool hovered: false
        property bool positionPickerOpen: false
        property var contextMenuItem: null
        property var contextMenuTarget: null
        property bool contextMenuHovered: false
        // Note: an open context menu does NOT unconditionally force keepOpen —
        // only actually hovering the dock or the menu does. That way,
        // clicking away to some other window (not through our own dismiss
        // handlers) still lets the hide timer run and clean the menu up,
        // instead of leaving the dock stuck open forever.
        readonly property bool keepOpen: hovered || positionPickerOpen || contextMenuHovered
        property bool revealed: false
        property real revealAmount: 0
        readonly property int dockLength: root.dockLengthFor(positionPickerOpen)

        Behavior on revealAmount {
          NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        onKeepOpenChanged: {
          if (keepOpen) {
            hideTimer.stop()
            revealed = true
          } else {
            hideTimer.restart()
          }
        }

        onRevealedChanged: {
          revealAmount = revealed ? 1 : 0
          if (!revealed) {
            positionPickerOpen = false
            contextMenuItem = null
            contextMenuTarget = null
          }
        }

        Timer {
          id: hideTimer
          interval: 400
          onTriggered: dockWindow.revealed = false
        }

        function openContextMenu(targetItem, item) {
          positionPickerOpen = false
          contextMenuTarget = targetItem
          contextMenuItem = item
        }

        function closeContextMenu() {
          contextMenuItem = null
          contextMenuTarget = null
        }

        Connections {
          target: root
          function onDockItemsChanged() { dockWindow.closeContextMenu() }
        }

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "omarchy-dock"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        implicitWidth: root.vertical ? root.dockThickness : dockLength
        implicitHeight: root.vertical ? dockLength : root.dockThickness

        anchors {
          top: root.position === "top"
          bottom: root.position === "bottom"
          left: root.position === "left"
          right: root.position === "right"
        }

        margins {
          top: root.position === "top" ? -Math.round((1 - revealAmount) * root.hiddenOffset) : 0
          bottom: root.position === "bottom" ? -Math.round((1 - revealAmount) * root.hiddenOffset) : 0
          left: root.position === "left" ? -Math.round((1 - revealAmount) * root.hiddenOffset) : 0
          right: root.position === "right" ? -Math.round((1 - revealAmount) * root.hiddenOffset) : 0
        }

        HoverHandler {
          onHoveredChanged: dockWindow.hovered = hovered
        }

        // Subtle always-on hint sitting exactly in the sliver that stays
        // mapped on screen while parked. Fades out as the full dock fades
        // in, so nothing but this small nub shows at rest.
        Rectangle {
          width: root.vertical ? root.stripThickness : root.handleLength
          height: root.vertical ? root.handleLength : root.stripThickness
          radius: height / 2
          color: Util.alpha(Color.foreground, 0.35)
          opacity: 1 - dockWindow.revealAmount
          anchors.horizontalCenter: root.vertical ? undefined : parent.horizontalCenter
          anchors.verticalCenter: root.vertical ? parent.verticalCenter : undefined
          anchors.top: root.position === "bottom" ? parent.top : undefined
          anchors.bottom: root.position === "top" ? parent.bottom : undefined
          anchors.left: root.position === "right" ? parent.left : undefined
          anchors.right: root.position === "left" ? parent.right : undefined
        }

        Rectangle {
          id: dockSurface
          anchors.fill: parent
          radius: Style.cornerRadius
          color: Util.alpha(Color.popups.background, 0.97)
          border.color: Color.popups.border
          border.width: Math.max(1, Style.space(1))
          opacity: dockWindow.revealAmount

          MouseArea {
            // Background catcher for the position picker; sits under the icons.
            anchors.fill: parent
            acceptedButtons: Qt.RightButton | Qt.LeftButton
            onClicked: function(mouse) {
              if (mouse.button === Qt.RightButton) {
                dockWindow.closeContextMenu()
                dockWindow.positionPickerOpen = !dockWindow.positionPickerOpen
              } else if (dockWindow.contextMenuItem !== null) {
                dockWindow.closeContextMenu()
              }
            }
          }

          Loader {
            anchors.centerIn: parent
            sourceComponent: dockWindow.positionPickerOpen ? positionPicker : dockRow
          }
        }

        Component {
          id: dockRow

          Item {
            width: root.vertical ? root.iconSize : dockWindow.dockLength - root.dockPadding * 2
            height: root.vertical ? dockWindow.dockLength - root.dockPadding * 2 : root.iconSize

            Grid {
              anchors.centerIn: parent
              columns: root.vertical ? 1 : Math.max(1, root.dockItems.length)
              rows: root.vertical ? Math.max(1, root.dockItems.length) : 1
              spacing: root.iconGap

              Repeater {
                model: root.dockItems

                Item {
                  id: iconDelegate
                  required property var modelData
                  width: root.iconSize
                  height: root.iconSize

                  readonly property bool running: modelData.toplevels.length > 0
                  readonly property bool focused: {
                    for (var i = 0; i < modelData.toplevels.length; i++) {
                      if (modelData.toplevels[i].activated) return true
                    }
                    return false
                  }

                  Rectangle {
                    anchors.fill: parent
                    radius: Style.cornerRadius
                    color: iconMouse.containsMouse ? Util.alpha(Color.foreground, 0.12) : "transparent"
                  }

                  Image {
                    anchors.centerIn: parent
                    width: parent.width - Style.space(10)
                    height: width
                    sourceSize.width: width
                    sourceSize.height: height
                    fillMode: Image.PreserveAspectFit
                    source: root.iconSource(iconDelegate.modelData.icon, iconDelegate.modelData.appId)
                  }

                  Rectangle {
                    visible: iconDelegate.running
                    width: iconDelegate.focused ? Style.space(14) : Style.space(6)
                    height: Style.space(3)
                    radius: height / 2
                    color: Color.accent
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Style.space(1)
                  }

                  Rectangle {
                    visible: iconDelegate.modelData.pinned
                    width: Style.space(14)
                    height: Style.space(14)
                    radius: Style.space(3)
                    color: Util.alpha(Color.background, 0.85)
                    anchors.top: parent.top
                    anchors.right: parent.right

                    Text {
                      anchors.centerIn: parent
                      text: "📌"
                      font.pixelSize: Style.space(9)
                    }
                  }

                  MouseArea {
                    id: iconMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: function(mouse) {
                      if (mouse.button === Qt.LeftButton) root.activateItem(iconDelegate.modelData)
                      else if (mouse.button === Qt.MiddleButton) root.closeItem(iconDelegate.modelData)
                      else if (mouse.button === Qt.RightButton) dockWindow.openContextMenu(iconDelegate, iconDelegate.modelData)
                    }
                  }
                }
              }
            }
          }
        }

        Component {
          id: positionPicker

          Grid {
            columns: root.vertical ? 1 : 4
            rows: root.vertical ? 4 : 1
            spacing: root.iconGap

            Repeater {
              model: [
                { key: "bottom", label: "⬇" },
                { key: "top", label: "⬆" },
                { key: "left", label: "⬅" },
                { key: "right", label: "➡" }
              ]

              Rectangle {
                required property var modelData
                width: root.iconSize
                height: root.iconSize
                radius: Style.cornerRadius
                color: modelData.key === root.position ? Util.alpha(Color.accent, 0.25) : (pickerMouse.containsMouse ? Util.alpha(Color.foreground, 0.12) : "transparent")
                border.color: modelData.key === root.position ? Color.accent : "transparent"
                border.width: Math.max(1, Style.space(1))

                Text {
                  anchors.centerIn: parent
                  text: modelData.label
                  color: Color.foreground
                  font.family: Style.font.family
                  font.pixelSize: Style.font.title
                }

                MouseArea {
                  id: pickerMouse
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.setPosition(modelData.key)
                }
              }
            }
          }
        }

        PopupWindow {
          id: contextMenuWindow
          visible: dockWindow.contextMenuItem !== null && dockWindow.contextMenuTarget !== null
          color: "transparent"
          implicitWidth: Math.ceil(menuCard.implicitWidth)
          implicitHeight: Math.ceil(menuCard.implicitHeight)

          anchor {
            id: contextMenuAnchor
            window: dockWindow
            adjustment: PopupAdjustment.Slide
            edges: Edges.Top | Edges.Left
            gravity: Edges.Bottom | Edges.Right
            rect.width: 1
            rect.height: 1

            onAnchoring: {
              var target = dockWindow.contextMenuTarget
              if (!target) return
              var popupWidth = contextMenuWindow.implicitWidth
              var popupHeight = contextMenuWindow.implicitHeight
              var localX = target.width + 6
              var localY = target.height / 2 - popupHeight / 2
              if (root.position === "bottom") {
                localX = target.width / 2 - popupWidth / 2
                localY = -popupHeight - 6
              } else if (root.position === "top") {
                localX = target.width / 2 - popupWidth / 2
                localY = target.height + 6
              } else if (root.position === "right") {
                localX = -popupWidth - 6
              }
              var point = dockWindow.contentItem.mapFromItem(target, localX, localY)
              contextMenuAnchor.rect.x = Math.round(point.x)
              contextMenuAnchor.rect.y = Math.round(point.y)
            }
          }

          HoverHandler {
            onHoveredChanged: dockWindow.contextMenuHovered = hovered
          }

          Rectangle {
            id: menuCard
            implicitWidth: menuColumn.implicitWidth + Style.space(12)
            implicitHeight: menuColumn.implicitHeight + Style.space(8)
            radius: Style.cornerRadius
            color: Color.popups.background
            border.color: Color.popups.border
            border.width: Math.max(1, Style.space(1))

            Column {
              id: menuColumn
              anchors.centerIn: parent
              spacing: Style.space(2)

              Repeater {
                model: dockWindow.contextMenuItem ? root.menuActionsFor(dockWindow.contextMenuItem) : []

                Rectangle {
                  required property var modelData
                  width: Math.max(Style.space(150), rowText.implicitWidth + Style.space(28))
                  height: Style.space(30)
                  radius: Style.space(4)
                  color: rowMouse.containsMouse ? Util.alpha(Color.foreground, 0.12) : "transparent"

                  Text {
                    id: rowText
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Style.space(10)
                    text: modelData.label
                    color: Color.popups.text
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                  }

                  MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                      root.runMenuAction(modelData.key, dockWindow.contextMenuItem)
                      dockWindow.closeContextMenu()
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
