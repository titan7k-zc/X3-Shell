import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../../config"
import "../../../components"
import "../bar_comp2"


Scope{
    id:root
    property color borderColor: Colors.barBorderColor
    property int rootRadius: 20  // max 28 min 0
    property int screenCorners: rootRadius/4 
    property int lrBarWid: 15
    property int topCBarWid: 240
    property int bottomCBarWid: 640
    property int tbHei: 40 // main height
    property int hei: 60 // 

    Variants{
        model:Quickshell.screens

        Item{
            id:screenRoot
            required property var modelData


            // ============================================================
            // Top bars
            // ============================================================
            PanelWindow {
                id: topbar

                WlrLayershell.layer: WlrLayer.Top

                anchors {
                    top: true
                    left: true
                    right: true
                    
                }
                
                exclusiveZone: root.tbHei   // handles reserved space

                color: "Transparent"
                

                implicitHeight: root.hei

                

                TopB{
                    id: topB
                    
                    rad:root.rootRadius
                    wid:root.bottomCBarWid*2-(rootRadius*2)
                    hei:root.tbHei

                    anchors {
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                    }
                }


                LeftTopB {
                    id: leftB

                    rad:root.rootRadius
                    se:root.screenCorners
                    wid:root.topCBarWid
                    hei:root.tbHei

                    anchors {
                        left: parent.left
                        top: parent.top
                    }
                }

                RightTopB {
                    id: rightB

                    rad:root.rootRadius
                    se:root.screenCorners
                    wid:root.topCBarWid
                    hei:root.tbHei

                    anchors {
                        right: parent.right
                        top: parent.top
                    }
                }
            }
            // ============================================================
            // Bottom bars
            // ============================================================
            PanelWindow {
                id: bottomBar

                WlrLayershell.layer: WlrLayer.Top

                anchors {
                    bottom: true
                    left: true
                    right: true
                    
                }
                
                exclusiveZone: root.tbHei   // handles reserved space

                color: "Transparent"
                
                // margins.top: -root.tbHei

                implicitHeight: root.hei
                

                LeftBottomB {
                    id: leftBot

                    rad:root.rootRadius
                    se:root.screenCorners
                    wid:root.bottomCBarWid
                    hei:root.tbHei
                    anchors {
                        left: parent.left
                        bottom: parent.bottom
                    }
                }
 
                RightBottomB {
                    id: rightBot

                    rad:root.rootRadius
                    se:root.screenCorners
                    wid:root.bottomCBarWid
                    hei:root.tbHei
                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                    }
                }
            }




            // ============================================================
            // Right Bar
            // ============================================================
            PanelWindow{
                id:rightBarWindow
                property int barWidth: root.lrBarWid
                property int radius: root.rootRadius
                property int borderThickness: 0
                property color borderColor: root.borderColor
                color: "Transparent"
                anchors.top: true
                anchors.bottom: true
                anchors.right: true
                implicitWidth: borderThickness+barWidth+radius
                exclusiveZone: borderThickness+barWidth
                WlrLayershell.layer:WlrLayer.Top

                Item {
                    id: shape
                    anchors.fill: parent

                    Rectangle{
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        width: rightBarWindow.barWidth
                        color: root.borderColor


                        Curves{
                            anchors.top: parent.top
                            anchors.right: parent.left
                            width: root.rootRadius
                            height: root.rootRadius
                            radius: root.rootRadius
                            isTop: true
                            color: root.borderColor
                            mirrored: true
                            z: 10
                        }
                        Curves{
                            anchors.bottom: parent.bottom
                            anchors.right: parent.left
                            width: root.rootRadius
                            height: root.rootRadius
                            radius: root.rootRadius
                            isTop: false
                            mirrored: true
                            color: root.borderColor
                            z: 10
                        }
                    }
                    
                }


                 MultiEffect {
                    opacity: Colors.shadowOpacity
                    shadowColor: Colors.shadowColor
                    anchors.fill: shape
                    source: shape

                    shadowEnabled: true
                    shadowBlur: 0.6
                    shadowScale: 0.998
                    shadowVerticalOffset:0
                    shadowHorizontalOffset: -3
                    
                }
            }
            // ============================================================
            // Left Bar
            // ============================================================
            PanelWindow{
                id:leftBarWindow
                property int barWidth: root.lrBarWid
                property int radius: root.rootRadius
                color: "Transparent"
                anchors.top: true
                anchors.bottom: true
                anchors.left: true
                implicitWidth: barWidth+radius
                exclusiveZone: barWidth

                Item {
                    id: shape2
                    anchors.fill: parent

                    Rectangle{
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        width: leftBarWindow.barWidth
                        color: root.borderColor
                        z:1

                        Curves{
                        anchors.top: parent.top
                        anchors.left: parent.right
                        width: root.rootRadius
                        height: root.rootRadius
                        radius: root.rootRadius
                        isTop: true
                        color: root.borderColor
                        z: 10
                    }
                    Curves{
                        anchors.bottom: parent.bottom
                        anchors.left: parent.right
                        width: root.rootRadius
                        height: root.rootRadius
                        radius: root.rootRadius
                        isTop: false
                        color: root.borderColor
                        z: 10
                    }
                    }

                    
                }

                 MultiEffect {
                    opacity: Colors.shadowOpacity
                    shadowColor: Colors.shadowColor
                    anchors.fill: shape2
                    source: shape2

                    shadowEnabled: true
                    shadowBlur: 0.6
                    shadowScale: 0.998
                    shadowVerticalOffset: 0
                    shadowHorizontalOffset: 3
                    
                }
            }




            
            // ============================================================
            // POPUPS
            // ============================================================
            


            Pop8{
                id:right_power_pop
                show:false
                anchorRight:true
                anchorBottom:true

                rad:root.rootRadius
                
                file:"../modules/powerMenu/PowerMenu.qml"

                
                IpcHandler {
                    target: "power"
                    function toggle() {
                        right_power_pop.show=!right_power_pop.show;
                    }

                }
            }


            Pop8{
                id:left_wall_pop
                show:false
                anchorLeft:true
                
                unloadOnClose:true

                rad:root.rootRadius
                
                file:"../modules/wallTheme/WallpaperAndThemeSwitcher.qml"

                
                IpcHandler {
                    target: "wall"
                    function toggle() {
                        left_wall_pop.show=!left_wall_pop.show;
                    }

                }
            }



            // PanelWindow {
            //     id: midpop

            //     color: "Transparent"

            //     anchors {
            //         top: true
            //         right: true
            //         left: true
            //         bottom: true
            //     }

            //     WlrLayershell.layer:mb.clic?WlrLayer.Overlay: WlrLayer.Top
            //     WlrLayershell.keyboardFocus: mb.clic ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            //     exclusiveZone: 0

            //     margins.top: -root.tbHei

            //     property var midMask: Region {
            //         item: mb
            //     }

            //     mask: midMask

            //     // MidTopB {
            //     //     id: mb

            //     //     anchors.horizontalCenter: parent.horizontalCenter
            //     //     openRad:root.rootRadius+(root.rootRadius/2)
            //     //     closeRed:{
            //     //         if (root.rootRadius<22){
            //     //             return root.rootRadius
            //     //         }else{
            //     //             return 22
            //     //         }
            //     //     }
            //     // }
            // }
        }
    }

}