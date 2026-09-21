import QtQuick
import Quickshell

import "../config"
import "../services"

Item{
    id:root
    property real radius:10
    property color bgColor:Colors.cavaBackgroundColor
    property color barColor:Colors.cavaBarColor


    width:360
    height:50

    Rectangle{
        anchors.fill: parent
        radius: root.radius
        color: root.bgColor

        Row{
            anchors.fill: parent
            anchors.margins: 8
            spacing: 4

            Repeater{
                model: CavaServices.barLevels
                Item{
                    anchors.verticalCenter: parent.verticalCenter
                    // anchors.verticalCenterOffset:0.5  // need to fix hardcoded value
                    id:barContainer
                    width: (parent.width - (parent.spacing * (CavaServices.barCount - 1))) / CavaServices.barCount
                    height: parent.height

                    Rectangle{
                        anchors.centerIn: parent
                        width: parent.width
                        height: Math.max(width, parent.height * modelData)
                        radius: width / 2
                        color: Qt.rgba(root.barColor.r,root.barColor.g,root.barColor.b, 0.4 + (0.6 * modelData))
                        // color: {
                        //     if (modelData==0.0){
                        //         return Qt.rgba(root.barColor.r,root.barColor.g,root.barColor.b, 1.0)
                        //     } else {
                        //         return Qt.rgba(root.barColor.r,root.barColor.g,root.barColor.b, 0.4 + (0.6 * modelData))
                        //     }
                        // }
                        

                        Behavior on height{
                            NumberAnimation{
                                duration: 50
                                easing.type: Easing.InOutQuad
                            }
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: 50
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                }
            }
        }
    }
}