import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "../config"
import "../services" as Services

Item {
    id: root

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    readonly property bool ready: Services.BrightnessServices.ready
    readonly property int val: Services.BrightnessServices.pct

    // --- interaction ---

    MouseArea {
        anchors.fill: parent

        acceptedButtons: Qt.LeftButton
        hoverEnabled: true

        onClicked: {
            if (!root.ready)
                return

            Services.BrightnessServices.toggle()
        }

        onWheel: (wheel) => {
            if (!root.ready)
                return

            if (wheel.angleDelta.y > 0) {
                Services.BrightnessServices.increase()
            } else if (wheel.angleDelta.y < 0) {
                Services.BrightnessServices.decrease()
            }

            wheel.accepted = true
        }

        cursorShape: Qt.PointingHandCursor
    }

    RowLayout {
        id: row

        anchors.fill: parent
        spacing: 6

        Text {
            text: "󰃟"   // fixed brightness glyph — replace with whichever you like
            color: Colors.brightnessIconColor

            font {
                family: "JetBrainsMono Nerd Font Mono"
                pixelSize: 20
                weight: 600
                letterSpacing: 0
            }
        }

        Text {
            text: root.val + "%  "
            color: Colors.brightnessTextColor

            font {
                family: "JetBrainsMono Nerd Font Mono"
                pixelSize: 14
                weight: 600
                letterSpacing: 0
            }
        }
    }
} 