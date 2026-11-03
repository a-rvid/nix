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

    implicitWidth: 320
    implicitHeight: 210
    visible: shell.themePickerVisible
    property real popupOpacity: visible ? 1 : 0
    property real popupScale: visible ? 1 : 0.96
    grabFocus: true

    anchor.window: root.anchorWindow
    anchor.rect.x: root.anchorWindow.width / 2 - width / 2
    anchor.rect.y: root.anchorWindow.height / 3

    onVisibleChanged: {
        if (!visible && shell.themePickerVisible)
            shell.themePickerVisible = false;
    }

    Rectangle {
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
        radius: 18
        color: Qt.rgba(root.surface.r, root.surface.g, root.surface.b, 0.9)
        border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.35)
        border.width: 1
        focus: true

        Keys.onEscapePressed: event => {
            root.shell.themePickerVisible = false;
            event.accepted = true;
        }

        Column {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            Text {
                text: "Appearance"
                color: root.foreground
                opacity: 0.72
                font.family: root.iconFont
                font.pixelSize: 12
            }

            Text {
                text: "Choose a system theme"
                color: root.foreground
                opacity: 0.56
                font.family: root.iconFont
                font.pixelSize: 10
            }

            Repeater {
                model: [
                    { name: "Nord", value: "nord" },
                    { name: "Gruvbox Light", value: "gruvbox" }
                ]

                delegate: Rectangle {
                    required property var modelData

                    width: parent.width
                    height: 56
                    radius: 10
                    color: root.shell.themeName === modelData.value
                        ? root.accent
                        : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.06)
                    border.width: 1
                    border.color: root.shell.themeName === modelData.value
                        ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.8)
                        : "transparent"

                    Behavior on color {
                        NumberAnimation { duration: 140 }
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.name
                        color: root.shell.themeName === modelData.value
                            ? root.surface
                            : root.foreground
                        font.family: root.iconFont
                        font.pixelSize: 13
                    }

                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        color: modelData.value === "nord" ? "#2e3440" : "#fbf1c7"
                        border.width: 1
                        border.color: root.shell.themeName === modelData.value
                            ? root.surface
                            : root.foreground
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.opacity = 0.94
                        onExited: parent.opacity = 1.0
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
