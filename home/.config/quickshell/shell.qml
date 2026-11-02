import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick
import "components"

Scope {
    id: shellRoot

    readonly property string iconFont: "JetBrainsMono Nerd Font"
    readonly property string themeName: themeSettings.theme
    readonly property bool hasWindows: Hyprland.workspaces.values.some(
        workspace => workspace.toplevels.values.length > 0
    )
    property bool temporarilyRevealed: false
    property bool themePickerVisible: false
    property bool launcherVisible: false
    readonly property var mediaPlayer: {
        const players = Mpris.players.values;
        for (let i = 0; i < players.length; i++) {
            if (players[i].isPlaying) return players[i];
        }
        for (let i = 0; i < players.length; i++) {
            if (players[i].playbackState === MprisPlaybackState.Paused) return players[i];
        }
        return null;
    }

    function selectTheme(name) {
        if (name !== "nord" && name !== "gruvbox") {
            console.warn("Ignoring unsupported theme:", name);
            return;
        }
        themeSettings.theme = name;
        setSystemColorScheme(name);
    }

    function setSystemColorScheme(name) {
        const scheme = name === "gruvbox" ? "prefer-light" : "prefer-dark";
        colorSchemeProcess.exec([
            "gsettings",
            "set",
            "org.gnome.desktop.interface",
            "color-scheme",
            scheme
        ]);
    }

    onThemeNameChanged: shellRoot.setSystemColorScheme(themeName)

    function runPowerAction(command) {
        powerActionProcess.exec(command);
    }

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    FileView {
        id: themeFile
        path: (Quickshell.env("XDG_STATE_HOME")
            || (Quickshell.env("HOME") + "/.local/state"))
            + "/quickshell/theme.json"
        preload: true
        blockLoading: true
        printErrors: false
        onAdapterUpdated: writeAdapter()
        onLoadFailed: error => console.warn("Could not load Quickshell theme state:", error)
        onSaveFailed: error => console.warn("Could not save Quickshell theme state:", error)

        JsonAdapter {
            id: themeSettings
            property string theme: "nord"
        }
    }

    Process {
        id: colorSchemeProcess
        onExited: exitCode => {
            if (exitCode !== 0)
                console.warn("Could not update the system color scheme; gsettings exited with", exitCode);
        }
    }

    Component.onCompleted: shellRoot.setSystemColorScheme(themeSettings.theme)

    NetworkStatus {
        id: networkStatus
    }

    Process {
        id: powerActionProcess
        onExited: exitCode => {
            if (exitCode !== 0)
                console.warn("Power action failed with exit code", exitCode);
        }
    }

    Timer {
        id: revealTimer
        interval: 5000
        onTriggered: shellRoot.temporarilyRevealed = false
    }

    IpcHandler {
        target: "shell"

        function reveal(): void {
            shellRoot.temporarilyRevealed = true;
            revealTimer.restart();
        }

        function toggleThemePicker(): void {
            shellRoot.launcherVisible = false;
            shellRoot.themePickerVisible = !shellRoot.themePickerVisible;
        }

        function toggleLauncher(): void {
            shellRoot.themePickerVisible = false;
            shellRoot.launcherVisible = !shellRoot.launcherVisible;
        }
    }

    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
            shell: shellRoot
            clock: systemClock
            network: networkStatus
        }
    }
}
