import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

ShellRoot {
  property string osdKind: "volume"
  property int osdValue: 0

  signal refreshTransientUi()

  NotificationServer {
    id: notifyServer
    actionsSupported: true
    bodySupported: true
    bodyMarkupSupported: false
    bodyHyperlinksSupported: false
    imageSupported: true

    onNotification: notif => {
      notif.tracked = true
    }
  }

  onRefreshTransientUi: {
    // Placeholder hook for file-backed state polling in a later pass.
    // Kept explicit so keybind-triggered signals have a known refresh target.
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: topBar
      property var modelData
      screen: modelData
      color: "transparent"

      implicitHeight: 36
      anchors {
        top: true
        left: true
        right: true
      }

      WlrLayershell.layer: WlrLayer.Top
      WlrLayershell.namespace: "qs-bar"

      TopBar {}
    }

    PanelWindow {
      id: osdWindow
      property var modelData
      screen: modelData
      color: "transparent"

      implicitWidth: 280
      implicitHeight: 64
      anchors {
        top: true
        horizontalCenter: true
      }

      margins.top: 48

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "qs-osd"

      Osd {
        anchors.fill: parent
      }
    }

    PanelWindow {
      id: notifyWindow
      property var modelData
      screen: modelData
      color: "transparent"

      implicitWidth: 360
      implicitHeight: 300
      anchors {
        right: true
        top: true
      }

      margins.top: 44
      margins.right: 16

      WlrLayershell.layer: WlrLayer.Top
      WlrLayershell.namespace: "qs-notify"

      NotificationCurtain {
        server: notifyServer
      }
    }
  }
}
