import QtQuick
import "../config"

Item {
    id: root

    property int value: 100   // dont use real .. heavy........
    
    property real newUpdateValue: -1

    property int step: 5  

    property color backgroundColor: Colors.levelBarBackgroundColor
    property color fillColor: Colors.levelBarFillColor

    property real barWidth: root.vertical? 10 : 100
    property real barHeight: root.vertical? 100 : 10

    property bool interactive: false

    property bool vertical: false

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

            anchors.left: root.vertical? undefined : parent.left
            anchors.bottom: root.vertical? parent.bottom : undefined
            anchors.verticalCenter: !root.vertical? parent.verticalCenter : undefined
            anchors.horizontalCenter: root.vertical? parent.horizontalCenter : undefined

            width: !root.vertical? parent.width * root.value / 100 : parent.width
            height: !root.vertical? parent.height : parent.height * root.value / 100

            radius: parent.radius
            color: root.fillColor
        }
    }
        
    function setPosition(progress) {
        if (player && length > 0) {
            player.position = Math.max(
                0,
                Math.min(length, progress * length)
            )
        }
    }

    // MouseArea {
    //     anchors.fill: bg
    //     enabled: root.interactive

    //     onPressed: function(mouse) {
    //         root.value = Math.max(0, Math.min(100, mouse.x / width * 100))
    //     }

    //     onPositionChanged: function(mouse) {
    //         if (pressed) {
    //             root.value = Math.max(
    //                 0,
    //                 Math.min(100, mouse.x / width * 100)
    //             )
    //         }
    //     }
    // }


    MouseArea {
        anchors.fill: bg
        enabled: root.interactive
        anchors.margins: -10

        function updateValue(mouseX, mouseY) {
            let newValue

            if (root.vertical) {
                // Top = 100%, bottom = 0%
                newValue = (1 - mouseY / height) * 100
            } else {
                // Left = 0%, right = 100%
                newValue = (mouseX / width) * 100
            }

            root.newUpdateValue = Math.max(0, Math.min(100, newValue))
        }

        onPressed: function(mouse) {
            updateValue(mouse.x, mouse.y)
        }

        onPositionChanged: function(mouse) {
            if (pressed)
                updateValue(mouse.x, mouse.y)
        }

        onReleased: function(mouse) {
            updateValue(mouse.x, mouse.y)
        }

        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) {
                root.newUpdateValue = Math.min(root.value + root.step,100)
            } else if (wheel.angleDelta.y < 0) {
                root.newUpdateValue = Math.max(root.value - root.step,0)
            }

            wheel.accepted = true
        }

        cursorShape: Qt.PointingHandCursor


    }
}




