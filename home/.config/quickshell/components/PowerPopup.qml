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

    implicitWidth: Math.min(420, root.anchorWindow.width - 80)
    implicitHeight: Math.min(520, root.anchorWindow.height - 80)
    visible: opened
    property real popupOpacity: visible ? 1 : 0
    property real popupScale: visible ? 1 : 0.96
    grabFocus: true

    anchor.window: root.anchorWindow
    anchor.rect.x: (root.anchorWindow.width - width) / 2
    anchor.rect.y: (root.anchorWindow.height - height) / 2

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
        id: panel
        anchors.fill: parent
        opacity: root.popupOpacity
        scale: root.popupScale
        transformOrigin: Item.Center
        Behavior on opacity {
            NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: 190; easing.type: Easing.OutCubic }
        }
        radius: 20
        color: Qt.rgba(root.surface.r, root.surface.g, root.surface.b, 0.9)
        border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.35)
        border.width: 1
        focus: true

        Keys.onEscapePressed: event => {
            root.opened = false;
            event.accepted = true;
        }

        Column {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 10

            Text {
                width: parent.width
                text: "Power"
                color: root.foreground
                font.family: root.iconFont
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                width: parent.width
                text: "Choose an action"
                color: root.foreground
                opacity: 0.58
                font.family: root.iconFont
                font.pixelSize: 11
                horizontalAlignment: Text.AlignHCenter
            }

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
                    height: 58
                    radius: 12
                    color: root.pendingConfirmation === modelData.action
                        ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.92)
                        : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.06)
                    border.width: root.pendingConfirmation === modelData.action ? 1 : 0
                    border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.95)

                    Behavior on color {
                        NumberAnimation { duration: 120 }
                    }

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 18
                        verticalAlignment: Text.AlignVCenter
                        text: root.pendingConfirmation === modelData.action
                            ? "Confirm " + modelData.label.toLowerCase() + "?"
                            : modelData.label
                        color: root.pendingConfirmation === modelData.action
                            ? root.surface
                            : root.foreground
                        font.family: root.iconFont
                        font.pixelSize: 15
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
