import QtQuick
import Quickshell
import Quickshell.Widgets
import "../../../config"
import "../../../components"
import "../../../services"
import "../../taskbar"

Item{
    id: topBar
    anchors.fill: parent
    required property real rad // global radius form rootBar (Bar.qml)
    property real colRadius:rad/2  
    required property bool midB_Status

    Rectangle{
        anchors.fill: parent
        color:"Transparent"
        
        // left side row
        Row{
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing:30

            Workspace {
                anchors.verticalCenter: parent.verticalCenter
            }


            Rectangle{
                anchors.verticalCenter: parent.verticalCenter
                width: tb.width
                height: tb.height+3
                color:Colors.powerBarBulletColor
                radius: topBar.colRadius
                Taskbar {
                    id:tb
                    anchors.centerIn: parent
                    // width:300
                    height:32
                    
                }
                Rectangle{
                    anchors.left: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: -0.45
                    topRightRadius: parent.radius
                    bottomRightRadius: parent.radius
                    width:tbTitle.implicitWidth==0?0:tbTitle.implicitWidth+25
                    height:parent.height-parent.height/3
                    color:parent.color
                    clip:true
                    Text{
                        id:tbTitle
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: tb.displayTitle
                        color: Qt.rgba(Colors.powerBarTextColor.r, Colors.powerBarTextColor.g, Colors.powerBarTextColor.b, 0.7)
                        font{
                            family:"Quicksand"
                            letterSpacing:0
                            pixelSize:14
                            weight:Font.Bold
                        }
                    }


                    Behavior on width{
                        NumberAnimation{
                            duration:250
                        }
                    }
                }

            }
        }


        // center row
        Row{
            anchors.centerIn: parent
            spacing:30

            Text {
                id:txt
                text:TimeServices.hour+":"+TimeServices.minute
                opacity: topBar.midB_Status?0:1
                color: Colors.powerBarTextColor
                font {
                    family: "Quicksand"
                    letterSpacing: 0
                    pixelSize: 20
                    weight: Font.Bold
                }
                Behavior on opacity{
                    NumberAnimation{
                        duration: 280
                    }
                }

            }
        }


        // Right side row
        Row{
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing:30


            Cava{
                anchors.verticalCenter: parent.verticalCenter
                height: 32
                width: 250
                radius: topBar.colRadius
            }

            Rectangle{
                anchors.verticalCenter: parent.verticalCenter
                color: Colors.powerBarBulletColor
                width:rightRow.width+15
                height:34
                radius:topBar.colRadius
        
                Row{
                    id: rightRow
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: 5
                    spacing: 5


                    Rectangle{
                        width: bat.implicitWidth+20
                        height: 35
                        color: "Transparent"
                        Brightness{id:brig;anchors.centerIn: parent}
                    }

                    Rectangle{
                        width: sou.implicitWidth+20
                        height: 35
                        color: "Transparent"
                        Volume{id:sou;anchors.centerIn: parent}
                    }

                    Rectangle{
                        width: bat.implicitWidth+20
                        height: 35
                        color: "Transparent"
                        Battery{id:bat;anchors.centerIn: parent}
                    }
                }
                
            }

        }



    }

}