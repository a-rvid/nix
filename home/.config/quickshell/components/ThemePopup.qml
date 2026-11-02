import Quickshell
import QtQuick

PopupWindow {
    id: root

    required property var shell
    required property var anchorWindow
    required property color foreground
    required property color accent
    required property color surface
    required property bool primaryScreen
    required property string iconFont

    implicitWidth: 220
    implicitHeight: 104
    visible: shell.themePickerVisible && primaryScreen
    grabFocus: true

    anchor.window: root.anchorWindow
    anchor.rect.x: root.anchorWindow.width / 2 - width / 2
    anchor.rect.y: root.anchorWindow.height / 3

    onVisibleChanged: {
        if (!visible && shell.themePickerVisible && primaryScreen)
            shell.themePickerVisible = false;
    }

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: root.surface
        border.color: root.accent
        border.width: 1
        focus: true

        Keys.onEscapePressed: event => {
            root.shell.themePickerVisible = false;
            event.accepted = true;
        }

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 4

            Text {
                text: "Appearance"
                color: root.foreground
                font.family: root.iconFont
                font.pixelSize: 13
            }

            Repeater {
                model: [
                    { name: "Gruvbox Light", value: "gruvbox" },
                    { name: "Nord", value: "nord" }
                ]

                delegate: Rectangle {
                    required property var modelData
                    width: parent.width
                    height: 30
                    radius: 5
                    color: root.shell.themeName === modelData.value
                        ? root.accent
                        : "transparent"

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        verticalAlignment: Text.AlignVCenter
                        text: modelData.name
                        color: root.shell.themeName === modelData.value
                            ? root.surface
                            : root.foreground
                        font.family: root.iconFont
                        font.pixelSize: 12
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.shell.selectTheme(modelData.value);
                            root.shell.themePickerVisible = false;
                        }
                    }
                }
            }
        }
    }
}
