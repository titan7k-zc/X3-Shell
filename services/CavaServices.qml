pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// need cava

Singleton {
    id:root
    property int barCount: 32

    property var barLevels:{
        let initialLevels = []
        for (var i = 0; i < barCount; i++){
            initialLevels.push(0.0)
        }
        return initialLevels
    }

    readonly property string cavaConfig:[
        "[general]",
        "bars = " + root.barCount,
        "framerate = 60",
        "[output]",
        "method = raw",
        "raw_target = /dev/stdout",
        "data_format = ascii",
        "ascii_max_range = 1000",
        "bar_delimiter = 59"
    ].join("\\n")

    Process{
        id: cavaProcess
        running: false
        command: [
            "bash","-c", "cava -p <(printf  '" + root.cavaConfig + "\\n')"
        ]
        stdout:SplitParser{
            onRead: data => {
                let cleanData = data.trim()
                if (cleanData.length === 0) return;

                let tokens = cleanData.split(";")
                let availableTokens = Math.min(tokens.length, root.barCount)
                let newLevels = []
                for (var i = 0; i < root.barCount; i++){
                    let rowAmplitude = i < availableTokens ? parseFloat(tokens[i] || 0): 0;
                    let normalizedLevel = Math.max(0, Math.min(1.0, rowAmplitude / 1000.0));
                    newLevels.push(normalizedLevel);
                }
                root.barLevels = newLevels;

            }
        }
    }
    Component.onCompleted: {
        cavaProcess.running = true
        // console.log("started")
    }
}