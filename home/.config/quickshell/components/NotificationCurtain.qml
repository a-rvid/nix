import QtQuick
import Quickshell.Services.Notifications

Rectangle {
  id: root
  width: parent.width
  height: parent.height
  radius: 16
  color: "#121212aa"

  property bool expanded: true
  property real curtain: expanded ? 1.0 : 0.0
  property NotificationServer server

  Behavior on curtain {
    NumberAnimation {
      duration: 250
      easing.type: Easing.OutCubic
    }
  }

  clip: true

  Rectangle {
    anchors.fill: parent
    color: "transparent"
    scale: 0.96 + (0.04 * root.curtain)
    opacity: root.curtain
    transformOrigin: Item.TopRight
  }

  ListView {
    id: notificationList
    anchors.fill: parent
    anchors.margins: 10
    spacing: 10
    clip: true
    model: root.server != null ? root.server.trackedNotifications : null

    delegate: Rectangle {
      required property var modelData
      width: notificationList.width
      height: Math.max(70, bodyText.implicitHeight + 42)
      radius: 14
      color: "#1b1b1bcc"

      Behavior on opacity {
        NumberAnimation {
          duration: 160
          easing.type: Easing.OutCubic
        }
      }

      Column {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 6

        Text {
          text: modelData.summary
          color: "#ebdbb2"
          font.family: "JetBrainsMono Nerd Font"
          font.bold: true
          font.pointSize: 10
          wrapMode: Text.Wrap
        }

        Text {
          id: bodyText
          text: modelData.body
          color: "#d5c4a1"
          font.family: "JetBrainsMono Nerd Font"
          font.pointSize: 10
          wrapMode: Text.Wrap
          textFormat: Text.PlainText
        }
      }

      MouseArea {
        anchors.fill: parent
        onClicked: modelData.dismiss()
      }
    }
  }
}
