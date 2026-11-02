import Quickshell
import Quickshell.Io
import QtQuick

PopupWindow {
    id: root

    required property var shell
    required property var anchorWindow
    required property real anchorX
    required property color foreground
    required property color accent
    required property color surface
    required property string iconFont
    property bool opened: false
    property string pendingConfirmation: ""

    implicitWidth: 190
    implicitHeight: 142
    visible: opened
    grabFocus: true

    anchor.window: root.anchorWindow
    anchor.rect.x: root.anchorX - width + 18
    anchor.rect.y: root.anchorWindow.height

    onVisibleChanged: {
        if (!visible && opened) {
            opened = false;
            pendingConfirmation = "";
        }
    }

    function run(command) {
        shell.runPowerAction(command);
        opened = false;
        pendingConfirmation = "";
    }

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: root.surface
        border.color: root.accent
        border.width: 1
        focus: true

        Keys.onEscapePressed: event => {
            root.opened = false;
            event.accepted = true;
        }

        Column {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 3

            Repeater {
                model: [
                    { label: "Lock", action: "lock" },
                    { label: "Suspend", action: "suspend" },
                    { label: "Reboot", action: "reboot" },
                    { label: "Shut down", action: "shutdown" }
                ]

                delegate: Rectangle {
                    required property var modelData
                    width: parent.width
                    height: 28
                    radius: 4
                    color: root.pendingConfirmation === modelData.action
                        ? root.accent
                        : "transparent"

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        verticalAlignment: Text.AlignVCenter
                        text: root.pendingConfirmation === modelData.action
                            ? "Confirm " + modelData.label.toLowerCase() + "?"
                            : modelData.label
                        color: root.pendingConfirmation === modelData.action
                            ? root.surface
                            : root.foreground
                        font.family: root.iconFont
                        font.pixelSize: 12
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (modelData.action === "reboot" || modelData.action === "shutdown") {
                                if (root.pendingConfirmation === modelData.action) {
                                    root.run([
                                        "systemctl",
                                        modelData.action === "reboot" ? "reboot" : "poweroff"
                                    ]);
                                } else {
                                    root.pendingConfirmation = modelData.action;
                                }
                            } else if (modelData.action === "lock") {
                                root.run(["hyprlock"]);
                            } else {
                                root.run(["systemctl", "suspend"]);
                            }
                        }
                    }
                }
            }
        }
    }
}
