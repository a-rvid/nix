import QtQuick

Rectangle {
  id: osd
  width: 260
  height: 58
  radius: 14
  color: "#0f0f0faa"
  opacity: 0.0

  function showTemporarily() {
    osd.opacity = 1.0
    hideTimer.restart()
  }

  Behavior on opacity {
    NumberAnimation {
      duration: 180
      easing.type: Easing.OutCubic
    }
  }

  Timer {
    id: hideTimer
    interval: 1100
    onTriggered: osd.opacity = 0.0
  }
}
