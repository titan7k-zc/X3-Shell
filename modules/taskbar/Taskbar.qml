import QtQuick
import Quickshell
import Quickshell.Widgets

import "../../services"
import "../../config"

ListView {
    id: root

    width: root.count? Math.min(320, (height+2) * root.count) : desktopText.implicitWidth+30
    height: 40
    
    Behavior on width {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    orientation: ListView.Horizontal

    // spacing: 6

    clip: true

    // boundsBehavior: Flickable.StopAtBounds

    model: TaskbarService.windows

    // Currently hovered window title
    property string hoveredTitle: ""

    // Currently active window title
    readonly property string activeTitle: {
        for (let i = 0; i < model.length; i++) {
            if (model[i].activated)
                return model[i].title;
        }
        return "";
    }

    // both hovered and active title
    readonly property string displayTitle: hoveredTitle !== "" ? hoveredTitle : activeTitle

    Text {
        id: desktopText

        visible: opacity !== 0
        color: Colors.taskbarTextColor
        text: " Desktop "
        anchors.centerIn: parent

        opacity: root.count === 0 ? 1 : 0
        scale: root.count === 0 ? 1 : 0.85

        Behavior on opacity {
            NumberAnimation {
                duration: 320
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 320
                easing.type: Easing.OutBack
            }
        }
    }

    delegate: Item {
        id: entry

        required property var modelData

        width: (root.height-4) + 6
        height: root.height-4

        readonly property bool isActive: modelData.activated

        readonly property var desktopEntry: {
            // re-run whenever DesktopEntries' list changes, not just once
            void DesktopEntries.applications.values.length;
            return DesktopEntries.heuristicLookup(modelData.appId);
        }

        IconImage {
            id: icon

            anchors.fill: parent
            anchors.margins: 4

            asynchronous: true

            source: Quickshell.iconPath(entry.desktopEntry?.icon ?? "", "image-missing")
        }

        Rectangle {
            visible: entry.isActive
            height: 4
            width: height * 4
            radius: 2
            color: Colors.taskbarActiveColor

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -2
        }

        HoverHandler {
            onHoveredChanged: {
                // console.log("root count : " + root.count)
                if (hovered) {
                    root.hoveredTitle = entry.modelData.title;
                } else if (root.hoveredTitle === entry.modelData.title) {
                    root.hoveredTitle = "";
                }
            }
        }

        TapHandler {
            onTapped: {
                clickAnimation.restart();
                TaskbarService.activate(entry.modelData);
            }
        }

        SequentialAnimation {
            id: clickAnimation

            NumberAnimation {
                target: entry
                property: "scale"
                to: 0.82
                duration: 60
                easing.type: Easing.OutQuad
            }

            NumberAnimation {
                target: entry
                property: "scale"
                to: 1.0
                duration: 100
                easing.type: Easing.OutBack
            }
        }
    }
}