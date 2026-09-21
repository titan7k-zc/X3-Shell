import QtQuick
import Quickshell
import Quickshell.Wayland
import "../config"
import "."
import QtQuick.Effects

Scope {
    id: root

    property bool show: false


    onShowChanged: {
        if (show && load.item) {
            load.item.forceActiveFocus()
        }
        
        if (load.item && load.item.hasOwnProperty("showing"))
            load.item.showing = root.show
    }
    

    property var anchorTop: false
    property var anchorBottom: false
    property var anchorLeft: false
    property var anchorRight: false


    property int menuHeight: maxArea.itemHei+20
    property int menuWidth:  maxArea.itemWid+20
    required property int rad



    property color menuColor: Colors.pop8MenuColor
    //property int animDuration: 400//Math.max(Math.min(load.width,load.height), 350)

    property int animDuration:{
        if (Math.min(load.width,load.height)<350){
            return 300
        }
        return 400
    }
    property int animEasing: Easing.InOutQuad


    default property alias content: load.data
    required property var file




    property int menueLoc: {
        if (anchorTop && anchorLeft)       return 1
        else if (anchorTop && anchorRight) return 3
        else if (anchorTop)                return 2
        else if (anchorBottom && anchorRight) return 5
        else if (anchorBottom && anchorLeft)  return 7
        else if (anchorBottom)             return 6
        else if (anchorRight)              return 4
        else if (anchorLeft)               return 8
        return 2 // default
    }


    property real h_ani:{
        if (anchorTop||anchorBottom){
            return 1.4
        }else{
            return 1
        }
    }
    property real w_ani:{
        if (anchorLeft||anchorRight){
            return 1.4
        }else{
            return 1
        }
    }

    PanelWindow {
        id: menuWindow

        WlrLayershell.layer: WlrLayer.Top//WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.show ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None  // to get keybord input for menu
        exclusiveZone: 0
        color: "Transparent"

        anchors.top: root.anchorTop
        anchors.bottom: root.anchorBottom
        anchors.left: root.anchorLeft
        anchors.right: root.anchorRight


        implicitWidth: root.menuWidth+root.rad*2
        implicitHeight: root.menuHeight+root.rad*2

        // Only actually detach/hide the surface once fully closed
        visible: menu.height!==0

        

        property var midMask: Region {
            item: menu
        }

        mask: root.show ? null : midMask


        Item {
            id: clipper
            anchors.fill: parent
            clip: true

            layer.enabled: true
            layer.effect: MultiEffect{
                shadowEnabled: true
                shadowColor: Colors.pop8ShadowColor
                shadowOpacity: 0.5
                shadowBlur: 0.6
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 2
            }

            Rectangle {
                id: menu

                width: 0
                height: 0

                anchors.top: root.anchorTop ? parent.top : undefined
                anchors.bottom: root.anchorBottom ? parent.bottom : undefined
                anchors.left: root.anchorLeft ? parent.left : undefined
                anchors.right: root.anchorRight ? parent.right : undefined
                anchors.horizontalCenter: (!root.anchorLeft && !root.anchorRight) ? parent.horizontalCenter : undefined
                anchors.verticalCenter: (!root.anchorTop && !root.anchorBottom) ? parent.verticalCenter : undefined

                color: root.menuColor

                property int safeRad: Math.max(0, Math.min(root.rad, width / 2, height / 2))

                topLeftRadius:     (root.menueLoc===4 || root.menueLoc===5 || root.menueLoc===6 ) ? safeRad : 0
                topRightRadius:    (root.menueLoc===6 || root.menueLoc===7 || root.menueLoc===8 ) ? safeRad : 0
                bottomLeftRadius:  (root.menueLoc===2 || root.menueLoc===3 || root.menueLoc===4 ) ? safeRad : 0
                bottomRightRadius: (root.menueLoc===8 || root.menueLoc===1 || root.menueLoc===2 ) ? safeRad : 0

                clip:true

                state: root.show ? "open" : "closed"

                states: [
                    State {
                        name: "open"
                        PropertyChanges { target: menu; width: root.menuWidth; height: root.menuHeight }
                        PropertyChanges { target: maxArea; opacity: 1 }
                        PropertyChanges { target: load; scale: 1 }
                    },
                    State {
                        name: "closed"
                        PropertyChanges { target: menu; width: 0; height: 0 }
                        PropertyChanges { target: maxArea; opacity: 0.2 }
                        PropertyChanges { target: load; scale: 0 }
                    }
                ]

                transitions: [
                    Transition {
                        from: "closed"; to: "open"
                        SequentialAnimation {
                            ParallelAnimation {
                                // container morph (bounce open)
                                NumberAnimation {
                                    target: menu
                                    properties: "width,height"
                                    duration: root.animDuration
                                    easing.type: Easing.OutBack
                                    easing.overshoot: 1.2
                                }
                                // content reveal, staggered slightly behind the container
                                SequentialAnimation {
                                    PauseAnimation { duration: root.animDuration * 0.35 }
                                    ParallelAnimation {
                                        NumberAnimation { target: maxArea; property: "opacity"; duration: root.animDuration/2 }
                                        NumberAnimation {
                                            target: load; property: "scale"
                                            duration: root.animDuration
                                            easing.type: Easing.OutBack
                                            easing.overshoot: 1.2
                                        }
                                    }
                                }
                            }
                        }
                    },
                    Transition {
                        from: "open"; to: "closed"
                        SequentialAnimation {
                            ParallelAnimation {
                                // content collapses first
                                NumberAnimation { target: maxArea; property: "opacity"; duration: root.animDuration/2 }
                                NumberAnimation {
                                    target: load; property: "scale"
                                    duration: root.animDuration/1.3
                                    easing.type: Easing.InBack
                                    easing.overshoot: 1.0
                                }
                                // container starts shrinking slightly after content begins fading
                                SequentialAnimation {
                                    PauseAnimation { duration: root.animDuration * 0.25 }
                                    ParallelAnimation {
                                        NumberAnimation {
                                            target: menu
                                            properties: "height"
                                            duration: root.animDuration
                                            easing.type: Easing.InOutQuad
                                        }
                                        NumberAnimation {
                                            target: menu
                                            properties: "width"
                                            duration: root.animDuration*(root.menuHeight < root.menuWidth ? 1.02 : 0.908)
                                            easing.type: Easing.InOutQuad
                                        }
                                    }
                                }
                            }
                        }
                    }
                ]



                // -------------------------------------------------------------   Real menu   ---------------------------------------------------------------------------------------------------------------------menu itms
                Rectangle {
                    id: maxArea
                    anchors.centerIn: parent

                    height: Math.max(0, menu.height - 20)
                    width: Math.max(0, menu.width - 20)

                    color: "Transparent"
                    radius: menu.safeRad
                    clip: true

                    property real itemHei:load.height
                    property real itemWid:load.width



                    Loader {
                        id: load
                        width: load.item ? load.item.implicitWidth : 0
                        height: load.item ? load.item.implicitHeight : 0
                        anchors.centerIn: parent
                        source: root.file



                        // for menu focus
                        active: true
                        onLoaded: {
                            if (root.show) item.forceActiveFocus();
                        }

                        Keys.onEscapePressed: {
                            root.show = false
                        }

                        onItemChanged: {
                            if (!item)
                                return

                            if (typeof item.closed === "function") {
                                item.closed.connect(function() {
                                    root.show = false
                                })
                            }
                        }
                        

                        



                    }

                }
            }






            // curve 1
            Curves {
                anchors.left: {
                    if (root.menueLoc===1 || root.menueLoc===8){
                        return menu.left
                    }else if (root.menueLoc===6 || root.menueLoc===7){
                        return menu.right
                    }else {
                        return undefined
                    }

                }

                anchors.right: {
                    if (root.menueLoc ===4 ||root.menueLoc ===5){
                        return menu.right
                    }else if (root.menueLoc===2 || root.menueLoc===3){
                        return menu.left
                    }else {
                        return undefined
                    }

                }


                anchors.top: {
                    if (root.menueLoc===2 || root.menueLoc===3){
                        return menu.top
                    }else if (root.menueLoc===1 || root.menueLoc===8){
                        return menu.bottom
                    }else{
                        return undefined
                    }

                }



                anchors.bottom: {
                    if(root.menueLoc===6 || root.menueLoc===7){
                        return menu.bottom
                    }else if (root.menueLoc ===4 ||root.menueLoc ===5){
                        return menu.top
                    }else{
                        return undefined
                    }

                }

                isTop: root.menueLoc===1 ||root.menueLoc===2 ||root.menueLoc===3 ||root.menueLoc===8 
                mirrored: root.menueLoc===2 ||root.menueLoc===3 ||root.menueLoc===4 ||root.menueLoc===5 

                radius: menu.safeRad
                color: root.menuColor
            }
            
        
            // curve 2
            Curves {
                anchors.left: {
                    if (root.menueLoc === 7 || root.menueLoc === 8) {
                        return menu.left
                    } else if (root.menueLoc === 1 || root.menueLoc === 2) {
                        return menu.right
                    } else {
                        return undefined
                    }
                }

                anchors.right: {
                    if (root.menueLoc === 3 || root.menueLoc === 4) {
                        return menu.right
                    } else if (root.menueLoc === 5 || root.menueLoc === 6) {
                        return menu.left
                    } else {
                        return undefined
                    }
                }

                anchors.top: {
                    if (root.menueLoc === 1 || root.menueLoc === 2) {
                        return menu.top
                    } else if (root.menueLoc === 3 || root.menueLoc === 4) {
                        return menu.bottom
                    } else {
                        return undefined
                    }
                }

                anchors.bottom: {
                    if (root.menueLoc === 5 || root.menueLoc === 6) {
                        return menu.bottom
                    } else if (root.menueLoc === 7 || root.menueLoc === 8) {
                        return menu.top
                    } else {
                        return undefined
                    }
                }

                isTop: root.menueLoc === 1 ||
                    root.menueLoc === 2 ||
                    root.menueLoc === 3 ||
                    root.menueLoc === 4

                mirrored: root.menueLoc === 3 ||
                        root.menueLoc === 4 ||
                        root.menueLoc === 5 ||
                        root.menueLoc === 6

                radius: menu.safeRad
                color: root.menuColor
            }

        }

        // shadow
        MultiEffect {
            anchors.fill: clipper
            source: clipper
            opacity: 0.7
            shadowEnabled: true
            shadowBlur: 0.6
            shadowScale: 1.002
            shadowVerticalOffset: {
                if (root.anchorTop) {
                    return 3
                } else if (root.anchorBottom) {
                    return -3
                } else {
                    return 0
                }
            }
            shadowHorizontalOffset: {
                if (root.anchorLeft) {
                    return 3
                } else if (root.anchorRight) {
                    return -3
                } else {
                    return 0
                }
            }
        }



        
    }
}
