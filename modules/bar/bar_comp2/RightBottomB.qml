import QtQuick
import Quickshell
import QtQuick.Shapes
import QtQuick.Effects
import "../../../config"
import "../../../components"

Item {
    id: root
    required property int rad
    required property int se
    property int hei: 40
    property int wid: 640


    Rectangle {
        id: rightB
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: root.wid
        height: root.hei + root.rad
        color: "Transparent"
        Rectangle {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            width: root.wid
            height: root.hei
            topLeftRadius: root.rad
            color: "black"//Colors.barBorderColor

            Rectangle{
                anchors.fill: parent
                bottomRightRadius: root.se
                topLeftRadius: root.rad
                color: Colors.barBorderColor
                
            }


            Curves{
                anchors.bottom: parent.bottom
                anchors.right: parent.left
                width: root.rad
                height: root.rad
                radius: root.rad
                isTop: false
                mirrored: true
                color: Colors.barBorderColor
                z: 10
            }    
        }
    }


    MultiEffect {
        opacity: Colors.shadowOpacity
        shadowColor: Colors.shadowColor
        anchors.fill: rightB
        source: rightB

        shadowEnabled: true
        shadowBlur: 0.6
        shadowScale: 1
        shadowVerticalOffset:-3
        shadowHorizontalOffset:-2
        
    }




    // Row{
    //     anchors.centerIn:parent
    //     anchors.verticalCenterOffset:12
    //     spacing:20


    //     Rectangle{
    //         implicitHeight:row_net.implicitHeight+(row_net.implicitHeight/5)
    //         implicitWidth:row_net.implicitWidth+(row_net.implicitWidth/5)
    //         anchors.verticalCenter:parent.verticalCenter
    //         color: "Transparent"//Colors.powerBarTransparentColor
    //         radius:8
    //         Row{
    //             id:row_net
    //             spacing:10
    //             anchors.centerIn:parent
    //             anchors.verticalCenterOffset:-1

    //             Text {
    //                 text: {
    //                     const speed = SystemMonitor.downloadSpeed

    //                     if (speed < 1024 * 1024)
    //                         return "  " + (speed / 1024).toFixed(1) + " KB/s"
    //                     else
    //                         return "  " + (speed / (1024 * 1024)).toFixed(2) + " MB/s"
    //                 }
    //                 color: Colors.powerBarIconColor
    //                 font.pixelSize:15
    //             }

    //             Text {
    //                 text: {
    //                     const speed = SystemMonitor.uploadSpeed

    //                     if (speed < 1024 * 1024)
    //                         return "  " + (speed / 1024).toFixed(1) + " KB/s"
    //                     else
    //                         return "  " + (speed / (1024 * 1024)).toFixed(2) + " MB/s"
    //                 }
    //                 color: Colors.powerBarIconColor
    //                 font.pixelSize:15
    //             }
    //         }



    //         MouseArea {
    //             id: netMouseArea
    //             anchors.fill: parent
    //             cursorShape: Qt.PointingHandCursor

    //             onClicked: {
    //                 Quickshell.execDetached(["kitty", "-e", "nethogs"]) 
    //             }
    //         }
    //         scale: netMouseArea.pressed ? 0.92 : 1.0

    //         Behavior on scale {
    //             NumberAnimation {
    //                 duration: 100
    //                 easing.type: Easing.OutQuad
    //             }
    //         }
    //     }
    //     Rectangle{
    //         implicitHeight:row_up.implicitHeight+(row_up.implicitHeight/5)
    //         implicitWidth:row_up.implicitWidth+(row_up.implicitWidth/5)
    //         anchors.verticalCenter:parent.verticalCenter
    //         color: "Transparent"//Colors.powerBarTransparentColor
    //         radius:8
    //         Row {
    //             id: row_up
    //             spacing: 10
    //             anchors.centerIn: parent
    //             anchors.verticalCenterOffset: -1

    //             Text {
    //                 id: uptimeIcon
    //                 property var ico:["","󱤌","","󰹻",]
    //                 text: ico[1]
    //                 color: Colors.powerBarActiveColor
    //                 font.pixelSize:20

    //                 RotationAnimation {
    //                     target: uptimeIcon
    //                     from: 0
    //                     to: 360
    //                     duration: 5000
    //                     loops: Animation.Infinite
    //                     running: true
    //                 }
    //             }

    //             Text {
    //                 anchors.verticalCenter: uptimeIcon.verticalCenter
    //                 anchors.verticalCenterOffset:1
    //                 text: SystemMonitor.uptimeString
    //                 color: Colors.powerBarIconColor
    //             }

    //         }



    //     }

        

    // }


}


