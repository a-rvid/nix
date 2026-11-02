import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls

Scope {
    id: root

    required property var screen
    required property var shell
    required property var clock
    required property var network
    readonly property color foreground: shell.themeName === "gruvbox" ? "#3c3836" : "#d8dee9"
    readonly property color secondary: shell.themeName === "gruvbox" ? "#665c54" : "#aeb9ca"
    readonly property color accent: shell.themeName === "gruvbox" ? "#b57614" : "#88c0d0"
    readonly property color surface: shell.themeName === "gruvbox" ? "#fbf1c7" : "#2e3440"
    readonly property color danger: "#bf616a"
    readonly property bool primaryScreen: Quickshell.screens.values.length > 0
        && screen.name === Quickshell.screens.values[0].name

    function workspaceHasWindows(id) {
        const workspaces = Hyprland.workspaces.values;
        for (let i = 0; i < workspaces.length; i++) {
            if (workspaces[i].id === id)
                return workspaces[i].toplevels.values.length > 0;
        }
        return false;
    }

    function workspaceIcon(id) {
        if (id === 1) return String.fromCodePoint(0xF120);
        if (id === 2) return String.fromCodePoint(0xF269);
        if (id === 3) return String.fromCodePoint(0xE632);
        return String.fromCodePoint(0xF1BC);
    }

    PanelWindow {
        id: wallpaper
        screen: root.screen
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        exclusionMode: ExclusionMode.Ignore
        color: root.shell.themeName === "gruvbox" ? "#fbf1c7" : "#2e3440"
        WlrLayershell.layer: WlrLayer.Background
    }

    PanelWindow {
        id: bar
        screen: root.screen
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: 28
        exclusiveZone: visible ? 28 : 0
        visible: !root.shell.hasWindows || root.shell.temporarilyRevealed
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Top

        Item {
            anchors.fill: parent

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                text: Qt.formatDateTime(root.clock.date, "MMMM d, HH:mm")
                color: root.foreground
                font.family: root.shell.iconFont
                font.pixelSize: 12
                verticalAlignment: Text.AlignVCenter
            }

            Row {
                anchors.centerIn: parent
                spacing: 4

                Repeater {
                    model: [1, 2, 3, 4, 5, 6, 7, 8, 9]

                    delegate: Item {
                        required property int modelData
                        readonly property int focusedId: Hyprland.focusedWorkspace?.id ?? 1
                        readonly property bool active: focusedId === modelData
                        readonly property bool shown: modelData <= 4
                            || active
                            || root.workspaceHasWindows(modelData)

                        width: shown ? 28 : 0
                        height: 24
                        visible: shown

                        Rectangle {
                            anchors.fill: parent
                            radius: 5
                            color: parent.active ? root.accent : "transparent"
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData <= 4
                                ? root.workspaceIcon(modelData)
                                : modelData.toString()
                            color: parent.active ? root.surface : root.foreground
                            opacity: parent.active ? 1 : 0.72
                            font.family: root.shell.iconFont
                            font.pixelSize: modelData <= 4 ? 14 : 12
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Hyprland.dispatch("workspace " + modelData)
                        }
                    }
                }
            }

            Row {
                id: rightSide
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Item {
                    id: mediaButton
                    width: root.shell.mediaPlayer ? 16 : 0
                    height: 24
                    visible: root.shell.mediaPlayer !== null

                    Text {
                        anchors.centerIn: parent
                        text: String.fromCodePoint(0x2022)
                        color: root.foreground
                        opacity: root.shell.mediaPlayer?.isPlaying ? 1 : 0.38
                        font.pixelSize: 13
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: mediaPopup.opened = !mediaPopup.opened
                    }

                    ToolTip.visible: mediaHover.hovered
                    ToolTip.text: root.shell.mediaPlayer
                        ? (root.shell.mediaPlayer.trackArtist || "Unknown artist")
                            + " - "
                            + (root.shell.mediaPlayer.trackTitle || "Unknown title")
                        : ""

                    HoverHandler {
                        id: mediaHover
                    }
                }

                Item {
                    id: volumeWidget
                    width: 18
                    height: 24

                    readonly property var sink: Pipewire.defaultAudioSink
                    readonly property var audio: sink?.audio ?? null
                    readonly property real volume: audio?.volume ?? 0
                    readonly property bool muted: audio?.muted ?? false

                    PwObjectTracker {
                        objects: volumeWidget.sink ? [volumeWidget.sink] : []
                    }

                    Text {
                        anchors.centerIn: parent
                        text: !volumeWidget.audio || volumeWidget.muted
                            ? String.fromCodePoint(0xF026)
                            : volumeWidget.volume < 0.34
                                ? String.fromCodePoint(0xF027)
                                : String.fromCodePoint(0xF028)
                        color: root.foreground
                        font.family: root.shell.iconFont
                        font.pixelSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        onClicked: {
                            if (volumeWidget.audio)
                                volumeWidget.audio.muted = !volumeWidget.muted;
                        }
                        onWheel: wheel => {
                            if (volumeWidget.audio)
                                volumeWidget.audio.volume = Math.max(
                                    0,
                                    Math.min(1, volumeWidget.volume + wheel.angleDelta.y / 1200)
                                );
                        }
                    }
                }

                Item {
                    id: networkWidget
                    width: 18
                    height: 24

                    function icon() {
                        if (root.network.connectionType === "wifi"
                            && root.network.connectivity === "full") {
                            if (root.network.wifiSignal >= 75) return 0xF0938;
                            if (root.network.wifiSignal >= 50) return 0xF0935;
                            if (root.network.wifiSignal >= 25) return 0xF0932;
                            return 0xF092F;
                        }
                        if (root.network.connectionType === "ethernet"
                            && root.network.connectivity === "full")
                            return 0xF0200;
                        if (root.network.connectionType !== "disconnected")
                            return 0xF059F;
                        return 0xF17C2;
                    }

                    Text {
                        anchors.centerIn: parent
                        text: String.fromCodePoint(networkWidget.icon())
                        color: root.foreground
                        font.family: root.shell.iconFont
                        font.pixelSize: 14
                    }
                }

                Item {
                    id: batteryWidget
                    width: 20
                    height: 24

                    readonly property var battery: UPower.displayDevice
                    readonly property int percentage: Math.round(battery?.percentage ?? 0)
                    readonly property bool charging: battery?.state === UPowerDeviceState.Charging

                    function glyph() {
                        if (charging) return 0xF0084;
                        if (percentage < 10) return 0xF007A;
                        if (percentage < 20) return 0xF007B;
                        if (percentage < 30) return 0xF007C;
                        if (percentage < 40) return 0xF007D;
                        if (percentage < 50) return 0xF007E;
                        if (percentage < 60) return 0xF007F;
                        if (percentage < 70) return 0xF0080;
                        if (percentage < 80) return 0xF0081;
                        if (percentage < 90) return 0xF0082;
                        return 0xF0079;
                    }

                    function remaining() {
                        const seconds = charging
                            ? (battery?.timeToFull ?? 0)
                            : (battery?.timeToEmpty ?? 0);
                        if (seconds <= 0) return "Time remaining unavailable";
                        const minutes = Math.round(seconds / 60);
                        return Math.floor(minutes / 60) + "h " + (minutes % 60) + "m remaining";
                    }

                    Text {
                        anchors.centerIn: parent
                        text: String.fromCodePoint(batteryWidget.glyph())
                        color: batteryWidget.charging
                            ? "#a3be8c"
                            : batteryWidget.percentage < 15 ? root.danger : root.foreground
                        font.family: root.shell.iconFont
                        font.pixelSize: 15
                    }

                    HoverHandler {
                        id: batteryHover
                    }

                    ToolTip.visible: batteryHover.hovered
                    ToolTip.text: batteryWidget.percentage + "% · " + batteryWidget.remaining()
                }

                Row {
                    spacing: 5

                    Repeater {
                        model: SystemTray.items

                        delegate: Item {
                            id: trayItem
                            required property var modelData
                            width: 20
                            height: 22

                            Image {
                                anchors.centerIn: parent
                                width: 17
                                height: 17
                                source: trayItem.modelData.icon
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: mouse => {
                                    if (mouse.button === Qt.LeftButton) {
                                        trayItem.modelData.activate();
                                    } else if (mouse.button === Qt.RightButton) {
                                        const point = trayItem.mapToItem(
                                            bar.contentItem,
                                            mouse.x,
                                            mouse.y
                                        );
                                        trayItem.modelData.display(
                                            bar,
                                            Math.round(point.x),
                                            Math.round(point.y)
                                        );
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    id: powerButton
                    width: 18
                    height: 24

                    Text {
                        anchors.centerIn: parent
                        text: String.fromCodePoint(0xF011)
                        color: root.secondary
                        font.family: root.shell.iconFont
                        font.pixelSize: 13
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: powerPopup.opened = !powerPopup.opened
                    }
                }
            }
        }

        MediaPopup {
            id: mediaPopup
            player: root.shell.mediaPlayer
            anchorWindow: bar
            anchorX: rightSide.x + mediaButton.x + mediaButton.width / 2
            foreground: root.foreground
            accent: root.accent
            surface: root.surface
            iconFont: root.shell.iconFont
        }

        PowerPopup {
            id: powerPopup
            shell: root.shell
            anchorWindow: bar
            anchorX: rightSide.x + powerButton.x + powerButton.width / 2
            foreground: root.foreground
            accent: root.accent
            surface: root.surface
            iconFont: root.shell.iconFont
        }
    }

    ThemePopup {
        shell: root.shell
        anchorWindow: wallpaper
        foreground: root.foreground
        accent: root.accent
        surface: root.surface
        primaryScreen: root.primaryScreen
        iconFont: root.shell.iconFont
    }

    LauncherPopup {
        shell: root.shell
        anchorWindow: wallpaper
        foreground: root.foreground
        accent: root.accent
        surface: root.surface
        primaryScreen: root.primaryScreen
        iconFont: root.shell.iconFont
    }
}
