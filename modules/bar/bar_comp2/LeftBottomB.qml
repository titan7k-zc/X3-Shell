import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import Quickshell.Io

import "../../../config"
import "../../../components"
import "../../taskbar"


Item {
    id: root
    required property int rad
    required property int se
    property int hei: 40
    property int wid: 640


    Rectangle {
        id: leftB
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: root.wid
        height: root.hei + root.rad
        color: "Transparent"
        Rectangle {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: root.wid
            height: root.hei
            topRightRadius: root.rad
            color: "black"//Colors.barBorderColor

            Rectangle{
                anchors.fill: parent
                topRightRadius: root.rad
                bottomLeftRadius: root.se
                color: Colors.barBorderColor
                
                Taskbar {
                    id:tb
                    maxWidth:root.wid-40
                    height:root.hei
                    anchors.centerIn: parent
                }
            }


            Curves{
                anchors.bottom: parent.bottom
                anchors.left: parent.right
                width: root.rad
                height: root.rad
                radius: root.rad
                isTop: false
                color: Colors.barBorderColor
                z: 10
            }    
   
        }
    }

    MultiEffect {
        opacity: Colors.shadowOpacity
        shadowColor: Colors.shadowColor
        anchors.fill: leftB
        source: leftB

        shadowEnabled: true
        shadowBlur: 0.6
        shadowScale: 1
        shadowVerticalOffset:-3
        shadowHorizontalOffset:2
        
    }

    Pop8{
        id:buttom_al_pop
        show:false
        anchorLeft:true
        anchorBottom:true

        rad:root.rad
        
        file:"../modules/applauncher/AppLauncher.qml"

        
        IpcHandler {
            target: "app"
            function toggle() {
                buttom_al_pop.show=!buttom_al_pop.show;
            }

        }
    }



}