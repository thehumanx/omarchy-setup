import QtQuick
import qs.Commons

// Shared boxed-pill background for all custom.* bar widgets.
//
// This is the single place to tune the pill look — every widget that
// imports ../custom.common picks up changes here on next shell restart.
//
// Usage inside a widget:
//   import "../custom.common"
//   CustomPill { }
//   // optional overrides:
//   CustomPill { visible: !root.vertical && root.batteryPresent }
Rectangle {
  id: pill

  // ── Pill tunables (single source of truth) ──────────────────────────
  property real vInset: 4               // vertical inset from widget bounds (px)
  property real hInset: Style.space(2)  // horizontal inset
  property real cornerRadius: 4         // pill corner rounding (px)
  property real backgroundAlpha: 0.55   // pill fill opacity over the bar

  anchors.fill: parent
  visible: !parent.vertical
  anchors.topMargin: parent.vertical ? 0 : vInset
  anchors.bottomMargin: parent.vertical ? 0 : vInset
  anchors.leftMargin: parent.vertical ? 0 : hInset
  anchors.rightMargin: parent.vertical ? 0 : hInset
  radius: cornerRadius
  color: Util.alpha(Color.bar.background, backgroundAlpha)
}
