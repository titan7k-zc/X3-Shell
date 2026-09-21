import QtQuick
import "../config"

Item {
    id: root

    property real value: 100

    property color backgroundColor: Colors.levelBarBackgroundColor
    property color fillColor: Colors.levelBarFillColor

    property real barWidth: 100
    property real barHeight: 10

    property bool interactive: false

    implicitWidth: barWidth
    implicitHeight: barHeight

    // Keep brightness between 0 and 100
    onValueChanged: {
        if (value < 0)
            value = 0
        else if (value > 100)
            value = 100
    }

    Behavior on value {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        id: bg

        anchors.centerIn: parent

        width: root.barWidth
        height: root.barHeight

        radius: height / 2
        color: root.backgroundColor

        clip: true

        Rectangle {
            id: fill

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            width: parent.width * root.value / 100
            height: parent.height

            radius: parent.radius
            color: root.fillColor
        }
    }


    MouseArea {
        anchors.fill: bg
        enabled: root.interactive

        onPressed: function(mouse) {
            root.value = Math.max(
                0,
                Math.min(100, mouse.x / width * 100)
            )
        }

        onPositionChanged: function(mouse) {
            if (pressed) {
                root.value = Math.max(
                    0,
                    Math.min(100, mouse.x / width * 100)
                )
            }
        }
    }
}




