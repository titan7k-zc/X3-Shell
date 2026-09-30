import QtQuick
import QtQuick.Effects

import "../../../config"
import "../../../components"

Item {
    id:root

    required property int rad
    required property int se
    property int hei: 40
    property int wid: 240


    Rectangle {
        id: rightT
        anchors.right: parent.right
        anchors.top: parent.top
        width: root.wid
        height: root.hei + root.rad
        color: "Transparent"
        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            width: root.wid
            height: root.hei
            bottomLeftRadius: root.rad
            color: "black"//Colors.barBorderColor

            Rectangle{
                anchors.fill: parent
                topRightRadius: root.se
                bottomLeftRadius: root.rad
                color: Colors.barBorderColor
                
                Row{
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 0
                    anchors.horizontalCenterOffset: 0

                    spacing: 5

                    Rectangle{
                        width: bat.implicitWidth+20
                        height: 35
                        radius: 6
                        color: "Transparent"//Colors.powerBarTransparentColor
                        Brightness{id:brig;anchors.centerIn: parent}
                    }

                    Rectangle{
                        width: sou.implicitWidth+20
                        height: 35
                        radius: 6
                        color: "Transparent"//Colors.powerBarTransparentColor
                        Volume{id:sou;anchors.centerIn: parent}
                    }

                    Rectangle{
                        width: bat.implicitWidth+20
                        height: 35
                        radius: 6
                        color: "Transparent"//Colors.powerBarTransparentColor
                        Battery{id:bat;anchors.centerIn: parent}
                    }
                }
                
            }


            
            Curves{
                anchors.top: parent.top
                anchors.right: parent.left
                width: root.rad
                height: root.rad
                radius: root.rad
                isTop: true
                color: Colors.barBorderColor
                mirrored: true
                z: 10
            }



        }


    }
    MultiEffect {
        opacity: Colors.shadowOpacity
        shadowColor: Colors.shadowColor
        anchors.fill: rightT
        source: rightT

        shadowEnabled: true
        shadowBlur: 0.6
        shadowScale: 1
        shadowVerticalOffset:3
        shadowHorizontalOffset:-2
        
    }




}