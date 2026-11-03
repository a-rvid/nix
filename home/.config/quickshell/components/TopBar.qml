import QtQuick
import QtQuick.Controls

Rectangle {
  width: parent.width
  height: parent.height
  radius: 14
  color: "#11111166"

  Row {
    anchors.centerIn: parent
    spacing: 12

    Label {
      text: "qs"
      color: "#ebdbb2"
      font.family: "JetBrainsMono Nerd Font"
      font.pointSize: 11
    }

    Button {
      text: "Launch"
      onClicked: {
        // Controlled by sway bindings; this button is a visible state anchor.
      }
    }
  }
}
