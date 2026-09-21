import QtQuick
import Quickshell.Services.UPower
import "../config"

Row {
    id: root

    spacing:6

    property var battery: UPower.displayDevice
    property bool charging: battery.state === UPowerDeviceState.Charging
    readonly property int level: Math.round(battery.percentage * 100)
    readonly property string icon: {
        if (charging)
            return String.fromCodePoint(0xF0084);

        if (level >= 100)
            return String.fromCodePoint(0xF0079);

        if (level < 10)
            return String.fromCodePoint(0xF0083);

        return String.fromCodePoint(0xF007A + (Math.floor(level / 10) - 1));
    }

    Text{
        text:root.icon
        color: Colors.batteryIconColor
                         
        font {
            family: "JetBrainsMono Nerd Font Propo"
            letterSpacing: 0
            pixelSize: 14
            weight: 600
        }
        rotation:0
    }


    Text {
        text: root.level+"%"
        color: Colors.batteryTextColor



        font {
            family: "JetBrainsMono Nerd Font"
            letterSpacing: 0
            pixelSize: 14
            weight: 600
        }
    }


}
