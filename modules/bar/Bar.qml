import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../config"
import "../../components"
import "./bar_comp"






Scope{
    id:root
    property color borderColor: Colors.barBorderColor
    property int shadowSpace: 12   // extra room so the shadow isn't clipped
    property int rootRadius: 20
    property int tBarHei: 40
    property int lBarWid: 15
    property int rBarWid: 15
    property int bBarHei: 15


    Variants{
        model:Quickshell.screens

        Item{
            id:screenRoot
            required property var modelData

            // ============================================================
            // top Bar
            // ============================================================
            PanelWindow{
                id:topBarWindow
                property int barHeight: root.tBarHei
                property int radius: root.rootRadius
                property int borderThickness: 0
                color: "Transparent"
                anchors.top: true
                anchors.left: true
                anchors.right: true
                implicitHeight: borderThickness+barHeight+radius
                exclusiveZone: borderThickness+barHeight
                WlrLayershell.layer:WlrLayer.Top

                Item {
                    id: shape0
                    anchors.fill: parent

                    Rectangle{
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.left: parent.left
                        height: topBarWindow.barHeight
                        color:"black"

                        Rectangle{
                            anchors.fill: parent
                            color: root.borderColor
                            topLeftRadius: root.rootRadius
                            topRightRadius: root.rootRadius

                            TopBar{
                                rad:root.rootRadius
                                anchors.leftMargin:30
                                anchors.rightMargin:30
                                midB_Status:top_main_pop.show
                            }
                        }
                    }

                }


                MultiEffect {
                    anchors.fill: shape0
                    source: shape0

                    shadowEnabled: true
                    shadowBlur: 0.6
                    shadowScale: 1
                    shadowVerticalOffset:3
                    shadowHorizontalOffset:0
                    opacity: 0.7
                }
            }

            // ============================================================
            // bottom Bar
            // ============================================================
            PanelWindow{
                id:bottomBarWindow
                property int barHeight: root.bBarHei
                property int radius: root.rootRadius
                property int borderThickness: 0
                color: "Transparent"
                anchors.bottom: true
                anchors.left: true
                anchors.right: true
                implicitHeight: borderThickness+barHeight+radius
                exclusiveZone: borderThickness+barHeight
                WlrLayershell.layer:WlrLayer.Top

                Item {
                    id: shape01
                    anchors.fill: parent

                    Rectangle{
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.left: parent.left
                        height: bottomBarWindow.barHeight
                        color:"black"
                        
                        Rectangle{
                            anchors.fill: parent
                            color: root.borderColor
                            bottomLeftRadius: root.rootRadius
                            bottomRightRadius: root.rootRadius
                        }
                    }

                }


                MultiEffect {
                    anchors.fill: shape01
                    source: shape01

                    shadowEnabled: true
                    shadowBlur: 0.6
                    shadowScale: 1
                    shadowVerticalOffset:-3
                    shadowHorizontalOffset: 0
                    opacity: 0.7
                }
            }

            // ============================================================
            // Right Bar
            // ============================================================
            PanelWindow{
                id:rightBarWindow
                property int barWidth: root.rBarWid
                property int radius: root.rootRadius
                color: "Transparent"
                anchors.top: true
                anchors.bottom: true
                anchors.right: true
                implicitWidth: barWidth+radius
                exclusiveZone: barWidth

                Item {
                    id: shape1
                    anchors.fill: parent

                    Rectangle{
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.leftMargin: 0
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

                // shadow
                 MultiEffect {
                    anchors.fill: shape1
                    source: shape1

                    shadowEnabled: true
                    shadowBlur: 0.6
                    shadowScale: 0.996
                    shadowVerticalOffset:0
                    shadowHorizontalOffset: -3
                    opacity: 0.7
                }
            }


            // ============================================================
            // Left Bar
            // ============================================================
            PanelWindow{
                id:leftBarWindow
                property int barWidth: root.lBarWid
                property int radius: root.rootRadius
                color: "Transparent"
                anchors.top: true
                anchors.bottom: true
                anchors.left: true
                implicitWidth: barWidth+radius
                exclusiveZone: barWidth
                WlrLayershell.layer:WlrLayer.Top

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

                // shadow
                 MultiEffect {
                    anchors.fill: shape2
                    source: shape2

                    shadowEnabled: true
                    shadowBlur: 0.6
                    shadowScale: 0.996
                    shadowVerticalOffset: 0
                    shadowHorizontalOffset: 3
                    opacity: 0.7
                }
            }


            // ============================================================
            // Popups Handler
            // ============================================================
            Pop8{
                id:right_power_pop
                show:false
                anchorRight:true

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
                id:top_main_pop
                show:false
                anchorTop:true

                rad:root.rootRadius
                
                file:"../modules/overview/Overview.qml"

                
                IpcHandler {
                    target: "main"
                    function toggle() {
                        top_main_pop.show=!top_main_pop.show;
                    }

                }
            }
            Pop8{
                id:left_wall_pop
                show:false
                anchorLeft:true

                rad:root.rootRadius
                
                file:"../modules/wallTheme/WallpaperAndThemeSwitcher.qml"

                
                IpcHandler {
                    target: "wall"
                    function toggle() {
                        left_wall_pop.show=!left_wall_pop.show;
                    }

                }
            }
            Pop8{
                id:buttom_al_pop
                show:false
                anchorBottom:true

                rad:root.rootRadius
                
                file:"../modules/applauncher/AppLauncher.qml"

                
                IpcHandler {
                    target: "app"
                    function toggle() {
                        buttom_al_pop.show=!buttom_al_pop.show;
                    }

                }
            }


            // IpcHandler {
            //     target: "notify"
            //     function toggle() {
            //         root.right=!root.right;
            //     }

            // }




        }
    }


}