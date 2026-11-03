import QtQuick

Rectangle {
  id: launcher
  width: 720
  height: 420
  radius: 18
  color: "#10101099"

  // Curtain-style reveal for launcher content.
  property bool opened: true
  property real curtain: opened ? 1.0 : 0.0

  Behavior on curtain {
    NumberAnimation {
      duration: 260
      easing.type: Easing.OutCubic
    }
  }

  clip: true

  Rectangle {
    anchors.fill: parent
    color: "transparent"
    scale: 0.96 + (0.04 * launcher.curtain)
    opacity: launcher.curtain
    transformOrigin: Item.Top
  }
}
