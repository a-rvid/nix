import Quickshell
import QtQuick

PopupWindow {
    id: root

    required property var player
    required property var anchorWindow
    required property real anchorX
    required property color foreground
    required property color accent
    required property color surface
    required property string iconFont
    property bool opened: false

    implicitWidth: 340
    implicitHeight: 112
    visible: opened && player !== null
    grabFocus: true

    anchor.window: root.anchorWindow
    anchor.rect.x: root.anchorX - width / 2
    anchor.rect.y: root.anchorWindow.height

    onPlayerChanged: {
        if (player === null) opened = false;
    }
    onVisibleChanged: {
        if (!visible && opened) opened = false;
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.visible && root.player !== null && root.player.isPlaying
        onTriggered: root.player.positionChanged()
    }

    Rectangle {
        anchors.fill: parent
        radius: 9
        color: root.surface
        border.color: root.accent
        border.width: 1
        focus: true

        Keys.onEscapePressed: event => {
            root.opened = false;
            event.accepted = true;
        }

        Image {
            id: albumArt
            x: 12
            y: 12
            width: 64
            height: 64
            source: root.player ? root.player.trackArtUrl : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            visible: status === Image.Ready
        }

        Rectangle {
            x: 12
            y: 12
            width: 64
            height: 64
            radius: 5
            color: root.accent
            visible: albumArt.status !== Image.Ready

            Text {
                anchors.centerIn: parent
                text: String.fromCodePoint(0xF0011)
                color: root.surface
                font.family: root.iconFont
                font.pixelSize: 24
            }
        }

        Text {
            x: 88
            y: 13
            width: 238
            text: (root.player?.trackArtist || "Unknown artist")
                + " - "
                + (root.player?.trackTitle || "Unknown title")
            color: root.foreground
            font.family: root.iconFont
            font.pixelSize: 12
            elide: Text.ElideRight
        }

        Rectangle {
            x: 88
            y: 39
            width: 238
            height: 4
            radius: 2
            color: root.foreground
            opacity: 0.18

            Rectangle {
                width: parent.width * Math.max(
                    0,
                    Math.min(1, (root.player?.position ?? 0) / (root.player?.length || 1))
                )
                height: parent.height
                radius: 2
                color: root.accent
            }
        }

        Row {
            x: 88
            y: 52
            spacing: 20

            Repeater {
                model: [
                    { glyph: 0xF04A5, action: "previous" },
                    { glyph: root.player?.isPlaying ? 0xF04C : 0xF040, action: "toggle" },
                    { glyph: 0xF04A, action: "next" }
                ]

                delegate: Text {
                    required property var modelData
                    text: String.fromCodePoint(modelData.glyph)
                    color: root.foreground
                    font.family: root.iconFont
                    font.pixelSize: 18

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        onClicked: {
                            if (modelData.action === "previous" && root.player.canGoPrevious)
                                root.player.previous();
                            else if (modelData.action === "next" && root.player.canGoNext)
                                root.player.next();
                            else if (modelData.action === "toggle" && root.player.canTogglePlaying)
                                root.player.isPlaying = !root.player.isPlaying;
                        }
                    }
                }
            }
        }
    }
}
