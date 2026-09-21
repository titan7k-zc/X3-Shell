import Quickshell.Services.Pipewire
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "../config"

Item {
    id: root

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    property var sink: Pipewire.defaultAudioSink
    property real volumeStep: 0.05
    property string activePort: ""

    readonly property bool ready: sink && sink.ready
    readonly property bool muted: ready && sink.audio.muted
    readonly property real volume: ready ? sink.audio.volume : 0
    readonly property int vol: Math.round(volume * 100)

    readonly property var props: ready ? sink.properties : ({})

    readonly property string deviceKind: {
        if (!ready) return "none"
        const bus = props["device.bus"] || ""
        const form = props["device.form-factor"] || ""
        const isBt = bus === "bluetooth" || !!props["api.bluez5.address"]

        if (isBt) return "bluetooth"
        if (activePort.includes("headphone") || form === "headset" || form === "headphone")
            return "headphone"
        if (activePort.includes("speaker") || form === "speaker")
            return "speaker"
        return "unknown"
    }

    readonly property string icon: {
        if (!ready)
            return String.fromCodePoint(0xf0581)

        if (muted)
            return ""          // muted glyph

        switch (deviceKind) {
        case "bluetooth":
            return "\uf025"          // bluetooth headset glyph
        case "headphone":
            return "\uf025"          // headphones glyph
        case "speaker":
        default:
            if (vol === 0) return ""
            if (vol <= 34) return ""
            if (vol <= 64) return ""
            return String.fromCodePoint(0xf057e)
        }
    }

    // --- live "Active Port" tracking (PipeWire doesn't expose this) ---

    Process {
        id: portProbe
        running: false
        command: ["sh", "-c", "pactl list sinks | awk '/^\\tActive Port:/{print $3}'"]
        stdout: SplitParser {
            onRead: data => root.activePort = data.trim()
        }
    }

    function refreshPort() {
        portProbe.running = false
        portProbe.running = true
    }

    Process {
        id: subscriber
        running: true
        command: ["pactl", "subscribe"]
        stdout: SplitParser {
            onRead: line => {
                if (line.includes("sink"))
                    root.refreshPort()
            }
        }
    }

    Component.onCompleted: refreshPort()
    onSinkChanged: refreshPort()

    // --- interaction ---

    MouseArea {
        anchors.fill: parent

        acceptedButtons: Qt.LeftButton
        hoverEnabled: true

        onClicked: {
            if (!root.ready)
                return

            root.sink.audio.muted = !root.sink.audio.muted
        }

        onWheel: (wheel) => {
            if (!root.ready)
                return

            if (wheel.angleDelta.y > 0) {
                root.sink.audio.volume = Math.min(
                    root.volume + root.volumeStep,
                    1.0
                )
            } else if (wheel.angleDelta.y < 0) {
                root.sink.audio.volume = Math.max(
                    root.volume - root.volumeStep,
                    0.0
                )
            }

            wheel.accepted = true
        }

        cursorShape: Qt.PointingHandCursor
    }

    RowLayout {
        id: row

        anchors.fill: parent
        // spacing: 6

        Text {
            text: root.icon
            color: Colors.volumeIconColor

            font {
                family: "JetBrainsMono Nerd Font Mono"
                pixelSize: 20
                weight: 600
                letterSpacing: 0
            }
        }

        Text {
            text: root.vol + "%"
            color: Colors.volumeTextColor

            font {
                family: "JetBrainsMono Nerd Font Mono"
                pixelSize: 14
                weight: 600
                letterSpacing: 0
            }
        }
    }

    PwObjectTracker {
        objects: [root.sink]
    }
}