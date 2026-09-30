import QtQuick
import QtQuick.Layouts
import Quickshell.Io

import QtQuick.Effects
import "../../../services"
import "../../../config"
import "../../../components"

Item {
    id: root

    implicitWidth: topMid.width
    implicitHeight: topMid.height

    required property int rad
    property int hei: 40
    property int wid: 240

    Rectangle {
        id: topMid

        width: root.wid 
        height: root.hei

        bottomRightRadius: root.rad
        bottomLeftRadius: root.rad
        color: Colors.barBorderColor

        

        // Content
        Item {
            anchors.fill: parent

            Weather {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: top_main_pop.show ? 105 : 20 
                primaryColor: top_main_pop.show? Colors.cavaBarColor2: Colors.weatherPrimaryColor
                width: 200
                height:root.hei

                Behavior on anchors.leftMargin {
                    NumberAnimation {
                        duration: 280
                        easing.type: Easing.InCirc
                    }
                }

            }


            Text {
                id: txt

                anchors.centerIn: parent
                text: TimeServices.hour + ":" + TimeServices.minute
                opacity: !top_main_pop.show ? 1 : 0
                color: Colors.powerBarTextColor
                font {
                    family: "Quicksand"
                    letterSpacing: 0
                    pixelSize: 20
                    weight: Font.Bold
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: 280
                    }
                }
            }

            Cava {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: top_main_pop.show ? 105 : 20
                barColor:  Colors.cavaBarColor

                height: 32
                width: 250

                radius: root.rad
                bgColor: "Transparent"
                

                Behavior on anchors.rightMargin {
                    NumberAnimation {
                        duration: 280
                        easing.type: Easing.InCirc
                    }
                }
            }
        }

        // Left curve
        Curves {
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

        // Right curve
        Curves {
            anchors.top: parent.top
            anchors.left: parent.right

            width: root.rad
            height: root.rad

            radius: root.rad
            isTop: true
            color: Colors.barBorderColor

            z: 10
        }
    }

    // Shadow
    MultiEffect {
        anchors.fill: topMid

        opacity: Colors.shadowOpacity
        shadowColor: Colors.shadowColor

        source: topMid

        shadowEnabled: true
        shadowBlur: 0.6
        shadowScale: 1

        shadowVerticalOffset: 3
        shadowHorizontalOffset: 0
    }

    // Main popup
    Pop8 {
        id: top_main_pop

        show: false
        anchorTop: true

        rad: root.rad

        file: "../modules/overview/Overview.qml"

        IpcHandler {
            target: "main"

            function toggle() {
                top_main_pop.show = !top_main_pop.show
            }
        }
    }
}