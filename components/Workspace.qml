import QtQuick
import Quickshell.Hyprland

import "../config"

Item {
    // Explicitly size this wrapper container to fit the row's children cleanly
    implicitWidth: rowLayout.implicitWidth
    implicitHeight: rowLayout.implicitHeight

    // Global scroll listener covering the entire component bounds (including spacing gaps)
    MouseArea {
        anchors.fill: parent
        onWheel: (wheel) => {
            let currentId = Hyprland.focusedWorkspace?.id ?? 1;
            if (wheel.angleDelta.y > 0) {
                if (Hyprland.focusedWorkspace?.id<10)
                    Hyprland.dispatch("hl.dsp.focus({ workspace = " + (currentId + 1) + " })");    
            } else if (wheel.angleDelta.y < 0) {
                Hyprland.dispatch("hl.dsp.focus({ workspace = " + (currentId - 1) + " })");
            }
            wheel.accepted = true;
        }
        
    }
    // Text{
    //     text:Hyprland.focusedWorkspace?.id
    // }

    Row {
        id: rowLayout
        spacing: 8

        // 1. Visibility Logic Rule Engine
        function isWorkspaceVisible(id) {
            if (id >= 1 && id <= 10) return true;
            if (Hyprland.focusedWorkspace?.id === id) return true;
            const ws = Hyprland.workspaces.values.find(w => w.id === id);
            if (ws) return true;
            return false;
        }

        // 2. Dynamic Bounds Calculator
        readonly property int maxLoop: {
            let max = 10;
            for (const ws of Hyprland.workspaces.values) {
                max = Math.max(max, ws.id);
            }
            if (Hyprland.focusedWorkspace) {
                max = Math.max(max, Hyprland.focusedWorkspace.id);
            }
            return max + 1;
        }

        // 3. Repeater Generator
        Repeater {
            model: rowLayout.maxLoop

            Rectangle {
                id: wbutton
                required property int index
                
                readonly property int wsId: index + 1
                readonly property bool shouldShow: rowLayout.isWorkspaceVisible(wsId)

                property var ws: Hyprland.workspaces.values.find(w => w.id === wsId)
                property bool isActive: Hyprland.focusedWorkspace?.id === wsId            

                visible: opacity > 0
                opacity: shouldShow ? 1 : 0

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
                Behavior on implicitWidth {
                    NumberAnimation { duration: 150 }
                }

                implicitWidth: shouldShow ? (dummyLabel.implicitWidth) : 0  //(dummyLabel.implicitWidth + 14)  spacing 
                implicitHeight: 22
                radius: 6
                color: "Transparent"

                Text {
                    id: dummyLabel
                    text: ""
                    font.pixelSize: 14
                    visible: false
                }

                Text {
                    id: activeLabel
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset:2.5
                    property var ico:["","󱤌","","󰹻",]
                    text: ico[1]
                    color: Colors.workspaceActiveColor
                    opacity: wbutton.isActive ? 1 : 0
                    scale: wbutton.isActive ? 1.25 : 0
                    // scale: 1.25 
                    font {
                        pixelSize: 14
                        weight: 500
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                    Behavior on scale {
                        NumberAnimation { duration: 150 }
                    }


                    RotationAnimation {
                        target: activeLabel
                        from: 0
                        to: 360
                        duration: 5000
                        loops: Animation.Infinite
                        running: true
                    }
                }

                Text {
                    id: inactiveLabel
                    anchors.centerIn: parent
                    text: ""
                    color: wbutton.ws ? Colors.workspaceAliveColor : Colors.workspaceInactiveColor
                    opacity: wbutton.isActive ? 0 : 1
                    scale:wbutton.ws ? 1.6 : 1
                    font {
                        pixelSize: 14
                        weight: 500
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                    Behavior on scale {
                        NumberAnimation { duration: 150 }
                    }
                }

                // Click Interaction for individual buttons
                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + (wbutton.wsId) + " })") 
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }
}