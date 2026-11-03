import Quickshell.Io
import QtQuick

Item {
    id: root

    width: 0
    height: 0
    visible: false

    property string connectionType: "disconnected"
    property string connectivity: "unknown"
    property int wifiSignal: 0

    function refresh() {
        devicesQuery.exec(["nmcli", "-t", "-f", "TYPE,STATE", "device", "status"]);
        connectivityQuery.exec(["nmcli", "-t", "-f", "CONNECTIVITY", "general", "status"]);
        wifiQuery.exec(["nmcli", "-t", "-f", "IN-USE,SIGNAL", "device", "wifi"]);
    }

    Process {
        id: monitor
        command: ["nmcli", "monitor"]
        running: true

        stdout: SplitParser {
            onRead: root.refresh()
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.connectionType = "disconnected";
                console.warn("Network status monitor stopped with exit code", exitCode);
            }
        }
    }

    Process {
        id: devicesQuery
        stdout: StdioCollector {
            id: devicesOutput
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.connectionType = "disconnected";
                console.warn("Could not query NetworkManager devices; using disconnected icon");
                return;
            }

            const rows = devicesOutput.text.trim().split("\n");
            let connectedType = "disconnected";
            for (let i = 0; i < rows.length; i++) {
                const fields = rows[i].split(":");
                if (fields.length >= 2 && fields[1] === "connected") {
                    if (fields[0] === "wifi") connectedType = "wifi";
                    else if (fields[0] === "ethernet") connectedType = "ethernet";
                }
            }
            root.connectionType = connectedType;
        }
    }

    Process {
        id: connectivityQuery
        stdout: StdioCollector {
            id: connectivityOutput
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.connectivity = "unknown";
                console.warn("Could not query NetworkManager connectivity");
                return;
            }
            root.connectivity = connectivityOutput.text.trim().toLowerCase();
        }
    }

    Process {
        id: wifiQuery
        stdout: StdioCollector {
            id: wifiOutput
        }

        onExited: exitCode => {
            if (exitCode !== 0 || !wifiOutput.text.trim()) {
                root.wifiSignal = 0;
                return;
            }

            const rows = wifiOutput.text.trim().split("\n");
            root.wifiSignal = 0;
            for (let i = 0; i < rows.length; i++) {
                const fields = rows[i].split(":");
                if (fields.length >= 2 && fields[0] === "*") {
                    root.wifiSignal = Number(fields[1]) || 0;
                    return;
                }
            }
        }
    }

    Component.onCompleted: refresh()
}
