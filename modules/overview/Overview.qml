import "../../components"
import "../../services"
import "../../config"
import QtQuick
import QtQuick.Layouts

Item {
    id: ov

    implicitWidth: tab.implicitWidth
    implicitHeight: tab.implicitHeight
    property real rad:10

    

    Rectangle {
        id: tab // for frame

        implicitHeight: dasgArea.implicitHeight + 20
        implicitWidth: dasgArea.implicitWidth + 20
        radius: 10
        color: Colors.overviewSurfaceFillColor
        border.color: Colors.overviewSurfaceFillColor
        border.width: 2

        Rectangle {
            id: dasgArea

            implicitWidth: 1100
            implicitHeight: 400
            color: Colors.overviewSurfaceFillColor
            clip: true
            anchors.centerIn: parent
            radius: 10

            GridLayout {
                anchors.fill: parent
                anchors.margins: 10
                // columns: 4
                // rows: 2
                columnSpacing: 15
                rowSpacing: 15
                

                // date & time
                Rectangle {
                    Layout.column: 0
                    Layout.row: 0
                    Layout.rowSpan: 2
                    Layout.fillWidth: true
                    Layout.fillHeight: true


                    radius: ov.rad
                    color: Colors.overviewSurfaceFillColor
                    

                    ColumnLayout {
                        anchors.centerIn: parent
                        width: parent.width * 0.9

                        spacing: 5


                        Text {
                            text: TimeServices.hour + "\n" + TimeServices.minute

                            color: Colors.overviewIndicatorColor

                            font.family: "Nunito"
                            font.weight: Font.ExtraBold
                            font.letterSpacing:0
                            font.pixelSize: Math.min(
                                parent.parent.width * 0.5,
                                parent.parent.height * 0.6
                            )
                            

                            lineHeight: 0.7

                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            opacity: 0.7

                            text: TimeServices.date
                            color: Colors.overviewSecondaryTextColor

                            font.family: "Nunito"
                            font.weight: Font.Bold
                            font.pixelSize: parent.parent.height * 0.04

                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }


                // user
                Rectangle {
                    Layout.column: 1
                    Layout.row: 0
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: ov.rad
                    color: Colors.overviewSurfaceFillColor


                    Row{
                        anchors.centerIn:parent
                        anchors.verticalCenterOffset:-5
                        spacing:20
                        Rectangle{
                            anchors.verticalCenter:parent.verticalCenter
                            width:150
                            height:150
                            color: Colors.overviewSurfaceFillColor
                            radius:20


                            AnimatedImage {
                                anchors.fill: parent
                                source: "../../assets/gif/cute-cat-kawaii.gif"

                                fillMode: Image.PreserveAspectCrop
                                clip: true
                                opacity:0.7
                            }
                        }
                        Text{
                            anchors.verticalCenter:parent.verticalCenter
                            anchors.verticalCenterOffset:15
                            text:"󰌽  : X2 Shell\n  : Titan"
                            color: Colors.overviewTextColor
                            font.family: "Nunito"
                            font.weight: Font.Bold
                            font.pixelSize:20

                            // lineHeight:0.8

                        }
                    }


                    
                }

                Rectangle {
                    Layout.column: 3
                    Layout.row: 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: ov.rad
                    color: Colors.overviewSurfaceFillColor
                    opacity:0
                    
                }

                Rectangle {
                    Layout.column: 1
                    Layout.row: 1
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: ov.rad
                    color: Colors.overviewSurfaceFillColor
                    opacity:0
                    
                }


                // info 
                Rectangle {
                    Layout.column: 2
                    Layout.row: 1
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: ov.rad
                    color: Colors.overviewSurfaceFillColor

                    Column {
                        id: col

                        anchors.verticalCenter:parent.verticalCenter
                        anchors.left:parent.left
                        anchors.leftMargin:65
                        spacing: 2

                        property real barWidth: 180
                        property real barHeight: 6
                        property real rowSpace: 20
                        property real fSize: 18
                        property real iSize: 20
                        property real iVCO: 3


                        

                        Row {
                            spacing: col.rowSpace
                            anchors.left:parent.left
                            anchors.leftMargin:30
                            Rou_Indicator {
                                height: 40
                                hi_off: -3.8
                                vi_off: 0.2
                                scale:1
                                width: height 
                                value: SystemMonitor.ramUsage
                                ic: ""
                                igColor: Colors.overviewIndicatorColor
                                icColor: Colors.overviewIndicatorIconColor
                                trackColor:Colors.overviewIndicatorTrackColor
                            }
                        }

                        Item{height:5;width:1}

                        Row {
                            spacing: col.rowSpace

                            Item {
                                width: col.iSize
                                height: col.iSize

                                Text {
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset:col.iVCO
                                    color: Colors.overviewTextColor
                                    text: ""
                                    font.pixelSize: col.iSize
                                }
                            }

                            LevelBar {
                                anchors.verticalCenter: parent.verticalCenter
                                value: SystemMonitor.cpuUsage
                                barWidth: col.barWidth
                                barHeight: col.barHeight
                                backgroundColor:Colors.overviewLevelBarBackgroundColor
                                fillColor:Colors.overviewlevelBarFillColor
                            }

                            Text {
                                property real tempVal:SystemMonitor.cpuTemp.toFixed(1)
                                anchors.verticalCenter: parent.verticalCenter
                                text: tempVal + " 󰔄"
                                color: {
                                    if (tempVal>70){
                                        return Colors.overviewWarningColor
                                    }else {
                                        return Colors.overviewNormalColor
                                    }
                                }
                            
                                font.pixelSize: col.fSize
                                font.family: "Nunito"
                                font.weight: Font.Bold
                            }
                        }

                        Row {
                            spacing: col.rowSpace

                            Item {
                                width: col.iSize
                                height: col.iSize

                                Text {
                                    anchors.verticalCenterOffset:col.iVCO
                                    anchors.centerIn: parent
                                    color: Colors.overviewTextColor
                                    text: "󰊹"
                                    font.pixelSize: col.iSize
                                }
                            }

                            LevelBar {
                                anchors.verticalCenter: parent.verticalCenter
                                value: SystemMonitor.gpuUsage
                                barWidth: col.barWidth
                                barHeight: col.barHeight
                                backgroundColor:Colors.overviewLevelBarBackgroundColor
                                fillColor:Colors.overviewlevelBarFillColor
                            }

                            Text {
                                property real tempVal:SystemMonitor.gpuTemp.toFixed(1)
                                anchors.verticalCenter: parent.verticalCenter
                                text: tempVal + " 󰔄"
                                color: {
                                    if (tempVal>70){
                                        return Colors.overviewWarningColor
                                    }else {
                                        return Colors.overviewNormalColor
                                    }
                                }
                            
                                font.pixelSize: col.fSize
                                font.family: "Nunito"
                                font.weight: Font.Bold
                            }
                        }

                        Item{height:5;width:1}


                        Row {
                            spacing: col.rowSpace
                            anchors.left:parent.left
                            anchors.leftMargin:30
                            // anchors.horizontalCenter:parent.horizontalCenter
                            
                            Rou_Indicator {
                                
                                height: 40
                                hi_off: -1.9
                                vi_off: -0.1
                                scale:1
                                i_scl:1.2
                                width: height 
                                value: SystemMonitor.storageUsage
                                ic: ""
                                igColor: Colors.overviewIndicatorColor
                                icColor: Colors.overviewIndicatorIconColor
                                trackColor:Colors.overviewIndicatorTrackColor
                            }
                        }

                        
                    }

                }


                // spotify
                Rectangle {
                    Layout.column: 4
                    Layout.row: 0
                    Layout.rowSpan:2
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: ov.rad
                    color: Colors.overviewSurfaceFillColor
                    
                    SpotifyPlayer{
                        anchors.centerIn:parent
                        // anchors.verticalCenterOffset:-2
                        // anchors.horizontalCenterOffset:-2
                    }
                }
            }

        }

    }

}
