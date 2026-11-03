import QtQuick

Item {
  id: root
  property bool expanded: false
  width: 420
  height: expanded ? 360 : 0

  Behavior on height {
    NumberAnimation {
      duration: 240
      easing.type: Easing.OutExpo
    }
  }

  clip: true

  Rectangle {
    anchors.fill: parent
    radius: 16
    color: "#19191999"
  }
}
