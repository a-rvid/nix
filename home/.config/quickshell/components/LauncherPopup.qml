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
    property int selectedIndex: 0

    readonly property var matchingEntries: {
        const query = searchInput.text.trim().toLocaleLowerCase();
        const entries = DesktopEntries.applications.values.slice();
        entries.sort((left, right) => left.name.localeCompare(right.name));
        if (!query) return entries;

        return entries.filter(entry => {
            const searchable = [
                entry.name,
                entry.genericName,
                entry.comment,
                entry.keywords.join(" ")
            ].join(" ").toLocaleLowerCase();
            return searchable.includes(query);
        });
    }

    implicitWidth: 520
    implicitHeight: 440
    visible: shell.launcherVisible && primaryScreen
    grabFocus: true

    anchor.window: root.anchorWindow
    anchor.rect.x: root.anchorWindow.width / 2 - width / 2
    anchor.rect.y: root.anchorWindow.height / 5

    function launchEntry(entry) {
        if (entry.runInTerminal) {
            Quickshell.execDetached({
                command: ["footclient"].concat(entry.command),
                workingDirectory: entry.workingDirectory
            });
        } else {
            entry.execute();
        }
        root.shell.launcherVisible = false;
    }

    function launchSelected() {
        if (selectedIndex < 0 || selectedIndex >= matchingEntries.length) return;
        launchEntry(matchingEntries[selectedIndex]);
    }

    onVisibleChanged: {
        if (visible) {
            searchInput.text = "";
            selectedIndex = 0;
            searchInput.forceActiveFocus();
        } else if (shell.launcherVisible && primaryScreen) {
            shell.launcherVisible = false;
        }
    }

    onMatchingEntriesChanged: selectedIndex = 0
    onSelectedIndexChanged: {
        if (matchingEntries.length > 0)
            appList.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: root.surface
        border.color: root.accent
        border.width: 1

        Text {
            x: 20
            y: 16
            text: "LAUNCH APPLICATION"
            color: root.foreground
            font.family: root.iconFont
            font.pixelSize: 11
            opacity: 0.72
        }

        Rectangle {
            id: searchBox
            x: 16
            y: 42
            width: parent.width - 32
            height: 44
            radius: 7
            color: Qt.rgba(
                root.foreground.r,
                root.foreground.g,
                root.foreground.b,
                0.08
            )
            border.color: root.accent
            border.width: 1

            Text {
                anchors.fill: parent
                anchors.leftMargin: 12
                verticalAlignment: Text.AlignVCenter
                text: "Search installed apps..."
                color: root.foreground
                opacity: 0.5
                font.family: root.iconFont
                font.pixelSize: 14
                visible: searchInput.text.length === 0
            }

            TextInput {
                id: searchInput
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                verticalAlignment: TextInput.AlignVCenter
                color: root.foreground
                selectionColor: root.accent
                selectedTextColor: root.surface
                font.family: root.iconFont
                font.pixelSize: 14
                clip: true
                selectByMouse: true
                onTextChanged: root.selectedIndex = 0

                Keys.onDownPressed: event => {
                    if (root.matchingEntries.length === 0) return;
                    root.selectedIndex = (root.selectedIndex + 1) % root.matchingEntries.length;
                    event.accepted = true;
                }
                Keys.onUpPressed: event => {
                    if (root.matchingEntries.length === 0) return;
                    root.selectedIndex = (root.selectedIndex - 1
                        + root.matchingEntries.length) % root.matchingEntries.length;
                    event.accepted = true;
                }
                Keys.onReturnPressed: root.launchSelected()
                Keys.onEnterPressed: root.launchSelected()
                Keys.onEscapePressed: root.shell.launcherVisible = false
            }
        }

        ListView {
            id: appList
            anchors.top: searchBox.bottom
            anchors.topMargin: 10
            anchors.bottom: footer.top
            anchors.bottomMargin: 8
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            clip: true
            spacing: 3
            model: root.matchingEntries

            delegate: Rectangle {
                required property var modelData
                required property int index
                width: appList.width
                height: 48
                radius: 7
                color: index === root.selectedIndex ? root.accent : "transparent"

                Rectangle {
                    x: 8
                    y: 7
                    width: 34
                    height: 34
                    radius: 6
                    color: Qt.rgba(
                        (index === root.selectedIndex ? root.surface : root.foreground).r,
                        (index === root.selectedIndex ? root.surface : root.foreground).g,
                        (index === root.selectedIndex ? root.surface : root.foreground).b,
                        0.12
                    )

                    Image {
                        id: appIcon
                        anchors.fill: parent
                        anchors.margins: 5
                        source: modelData.icon ? "image://icon/" + modelData.icon : ""
                        sourceSize.width: 24
                        sourceSize.height: 24
                        fillMode: Image.PreserveAspectFit
                        visible: status === Image.Ready
                        asynchronous: true
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "◆"
                        color: root.accent
                        font.pixelSize: 14
                        visible: appIcon.status !== Image.Ready
                    }
                }

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 52
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        width: parent.width
                        text: modelData.name
                        color: index === root.selectedIndex ? root.surface : root.foreground
                        font.family: root.iconFont
                        font.pixelSize: 13
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: modelData.genericName || modelData.comment
                        color: index === root.selectedIndex ? root.surface : root.foreground
                        font.family: root.iconFont
                        font.pixelSize: 10
                        opacity: 0.72
                        elide: Text.ElideRight
                        visible: text.length > 0
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: root.selectedIndex = index
                    onClicked: root.launchEntry(modelData)
                }
            }
        }

        Text {
            id: emptyMessage
            anchors.centerIn: appList
            text: "No matching applications"
            color: root.foreground
            opacity: 0.65
            font.family: root.iconFont
            font.pixelSize: 12
            visible: root.matchingEntries.length === 0
        }

        Text {
            id: footer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            anchors.bottomMargin: 14
            text: "↑ ↓ navigate     Enter launch     Esc close"
            color: root.foreground
            opacity: 0.55
            font.family: root.iconFont
            font.pixelSize: 10
            horizontalAlignment: Text.AlignRight
        }
    }
}
