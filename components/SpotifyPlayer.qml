import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import QtQuick.Effects

import "../config"
import "../services"
import "../components"


// cash img path ->/home/titan/.cache/quickshell/by-shell


Item {
    id: root
    // height: 180
    // width: height * 2
    width: 220
    height: (width-40) * 1.8


    Rectangle {
        anchors.fill: parent
        radius: 20
        color: Colors.spotifyPanelColor
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 20
            
            RowLayout{
                Layout.alignment: Qt.AlignHCenter
                spacing: 10


                LevelBar{
                    id:volumeLevelBar
                    vertical: true
                    value: SpotifyServices.volume*100
                    barWidth: 5
                    barHeight: 100

                    interactive: true
                    onNewUpdateValueChanged: {
                        SpotifyServices.setVolume(Math.round(newUpdateValue)/100)
                        // console.log("volumeLevelBar.value: "+Math.round(newUpdateValue))
                    }
                }


                // ---------------- album art ----------------
                ClippingRectangle {
                    id: albumArt
                    Layout.preferredWidth: Math.min(root.width-40, root.height)
                    Layout.preferredHeight: Layout.preferredWidth
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    radius: Layout.preferredHeight/12
                    border.color: Colors.spotifyAlbumBorder
                    border.width: 3
                    opacity: 0.7
                    color: Colors.spotifyAlbumPlaceholderColor

                    antialiasing: true
                    layer.enabled: true
                    layer.smooth: true
                    layer.samples: 4   // try 8 if it's still visibly rough

                    Image {
                        id: artImage
                        anchors.fill: parent
                        source: SpotifyServices.displayArtSource
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: false
                        antialiasing: true
                        onStatusChanged: {
                            if (status === Image.Error &&
                                source.toString() !== ("file://" + SpotifyServices.artCachePath)) {
                                source = "file://" + SpotifyServices.artCachePath;
                            }
                        }
                    }
                }



                LevelBar{
                    id:positionLevelBar
                    vertical: true
                    value: SpotifyServices.position / SpotifyServices.length * 100
                    barWidth: 5
                    barHeight: 100
                    interactive: true
                    onNewUpdateValueChanged: {
                        SpotifyServices.setPosition(newUpdateValue/100)
                        // console.log("positionLevelBar.value: "+newUpdateValue)
                    }
                }

            }


            //     // placeholder when there's nothing to show yet
            //     Text {
            //         anchors.centerIn: parent
            //         visible: artImage.status !== Image.Ready
            //         text: SpotifyServices.running ? "" : "\u266B"
            //         font.pixelSize: 96
            //     }
            // }

            // ---------------- track info ----------------
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 2

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: Math.min(root.height,root.width)-20
                    text: "2"+SpotifyServices.displayTitle
                    color: Colors.spotifyTitleColor
                    font.family: "Nunito"
                    font.weight: Font.ExtraBold
                    font.pixelSize: 18
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: Math.min(root.height,root.width)-20
                    text: SpotifyServices.displayArtist
                    color: Colors.spotifyArtistColor
                    font.family: "Nunito"
                    font.pixelSize: 15
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    
                }

                // ---------------- controls: prev / play-pause / next ----------------
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 5

                    Rectangle {
                        width: 35; height: width; radius: width / 3
                        color: Colors.spotifyControlColor2
                        scale: prevArea.pressed ? 0.9 : 1
                        Text {
                            anchors.centerIn: parent
                            text: "\u23EE"
                            color: Colors.spotifyControlIconColor
                            font.pixelSize: 22
                        }
                        MouseArea {
                            id: prevArea
                            anchors.fill: parent
                            onClicked: SpotifyServices.previous()
                            cursorShape: Qt.PointingHandCursor
                        }
                    }

                    Rectangle {
                        width: 45; height: width; radius: width / 2
                        color: Colors.spotifyPlayColor
                        scale: playArea.pressed ? 0.9 : 1
                        Text {
                            anchors.centerIn: parent
                            text: SpotifyServices.player && SpotifyServices.player.isPlaying ? "\u23F8" : "\u25B6"
                            anchors.horizontalCenterOffset: text === "\u25B6" ? 2.5 : 0
                            anchors.verticalCenterOffset: text === "\u25B6" ? 0.8 : 0
                            color: Colors.spotifyControlIconColor
                            font.pixelSize: 26
                        }
                        MouseArea {
                            id: playArea
                            anchors.fill: parent
                            onClicked: SpotifyServices.playPause()
                            cursorShape: Qt.PointingHandCursor
                        }
                    }

                    Rectangle {
                        width: 35; height: width; radius: width / 3
                        color: Colors.spotifyControlColor2
                        scale: nextArea.pressed ? 0.9 : 1
                        Text {
                            anchors.centerIn: parent
                            text: "\u23ED"
                            color: Colors.spotifyControlIconColor
                            font.pixelSize: 22
                        }
                        MouseArea {
                            id: nextArea
                            anchors.fill: parent
                            onClicked: SpotifyServices.next()
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }
            }
        }
    }
}
