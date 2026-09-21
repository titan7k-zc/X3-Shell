pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real brightness: 1.0
    property bool ready: false
    property real step: 0.05

    readonly property int pct: Math.round(brightness * 100)

    function setBrightness(value) {
        value = Math.max(0, Math.min(1, value));
        setProc.command = ["brightnessctl", "set", Math.round(value * 100) + "%"];
        setProc.running = true;
    }

    function increase() {setBrightness(brightness + step);}
    function decrease() {setBrightness(brightness - step);}
    function toggle() {setBrightness(brightness <= 0.01 ? 1.0 : 0.0);}

    Process {id: setProc}

    FileView {
        id: myFile
        path: "/sys/class/backlight/nvidia_0/brightness"
        watchChanges: true
        onFileChanged: {
            reload();
        }

        onLoaded: {
            const value = parseInt(text());
            if (!isNaN(value)) {
                root.brightness = value / 100;
                root.ready = true;
                // console.log("Brightness:", root.pct + "%");
            }
        }
    }
}
