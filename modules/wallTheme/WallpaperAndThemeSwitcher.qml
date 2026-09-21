

import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell.Widgets
import Quickshell.Io

import "../../config/"

FocusScope {
    id: wall
    implicitWidth: tab.implicitWidth
    implicitHeight: tab.implicitHeight

    property bool showing: false

    onShowingChanged: {
        if (showing) {
            wallpaperQuery.running = true;
            colorList.currentIndex = Colors.theme
        }
    }

    property string folderpath: "file:///home/titan/disk0/syscustom/wallpapers/"
    property string currentWallpaperPath: ""

    // function setWallpaper(path) {
    //     if (wallpaperSetter.running) {
    //         wallpaperSetter.running = false;
    //     }

    //     wallpaperSetter.command = [
    //         "awww",
    //         "img",
    //         "--transition-type", "any",
    //         "--transition-duration", "2",
    //         "--transition-fps", "60",
    //         path
    //     ];
    //     wall.currentWallpaperPath = path;
    //     wallpaperSetter.running = true;
    // }


    property int setAni: 7

    property var wallpaperAnimations: [
        { type: "wave",   angle: 30,  wave: "20,20", duration: 2,   fps: 60 },         // 0: gentle ripple
        { type: "wave",   angle: 120, wave: "50,60", duration: 2.5, fps: 60 },        // 1: big rolling swell
        { type: "wipe",   angle: 15,  duration: 1.5, fps: 60 },                      // 2: sharp diagonal wipe
        { type: "wipe",   angle: 200, duration: 1.5, fps: 60 },                     // 3: reverse diagonal wipe
        { type: "grow",   pos: "center",       duration: 2,   fps: 60 },           // 4: classic expanding circle
        { type: "grow",   pos: "top",        duration: 1.5, fps: 60 },          // 5: grow from corner
        { type: "outer",  pos: "bottom-right", duration: 2.2, fps: 60 },         // 6: shrinking circle
        { type: "any",    duration: 2,   fps: 60 },                             // 7: random-point grow
        { type: "fade",   duration: 1.5, fps: 60 },                            // 8: smooth bezier crossfade
        { type: "random", duration: 2,   fps: 60 },                           // 9: awww picks a random type
    ]

    function setWallpaper(path) {
        if (wallpaperSetter.running) {
            wallpaperSetter.running = false;
        }

        var anim = wallpaperAnimations[setAni];
        var cmd = ["awww", "img", "--transition-type", anim.type];

        if (anim.angle !== undefined) cmd.push("--transition-angle", String(anim.angle));
        if (anim.wave !== undefined)  cmd.push("--transition-wave", anim.wave);
        if (anim.pos !== undefined)   cmd.push("--transition-pos", anim.pos);

        cmd.push("--transition-duration", String(anim.duration));
        cmd.push("--transition-fps", String(anim.fps));
        cmd.push(path);

        wallpaperSetter.command = cmd;
        wall.currentWallpaperPath = path;
        wallpaperSetter.running = true;
    }




    // Query current wallpaper on load
    Process {
        id: wallpaperQuery
        command: ["awww", "query"]

        stdout: StdioCollector {
            onStreamFinished: {
                const out = text; // full captured stdout
                const match = out.match(/image:\s*(\S+)/);
                if (match) {
                    wall.currentWallpaperPath = match[1].trim();
                    wall.trySelectCurrentWallpaper();
                }
            }
        }
    }

    FolderListModel {
        id: wallpaperFolder
        folder: wall.folderpath
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
        showDirs: false

        onStatusChanged: {
            if (status === FolderListModel.Ready) {
                wall.trySelectCurrentWallpaper();
            }
        }
    }

    function trySelectCurrentWallpaper() {
        if (wall.currentWallpaperPath === "" || wallpaperFolder.status !== FolderListModel.Ready)
            return;

        for (let i = 0; i < wallpaperFolder.count; i++) {
            let entryPath = decodeURIComponent(
                wallpaperFolder.get(i, "fileUrl")
                    .toString()
                    .replace("file://", "")
            );

            if (entryPath === wall.currentWallpaperPath) {
                wallpaperList.currentIndex = i;
                break;
            }
        }
    }

    Process {
        id: wallpaperSetter
        command: []
    }

    Rectangle {
        id: tab // for frame
        implicitHeight: viewArea.implicitHeight + 40
        implicitWidth: viewArea.implicitWidth

        radius: 10
        color: "Transparent"
        // border.color: "Transparent"
        // border.width: 2

        Rectangle {
            id: viewArea
            implicitWidth: gridLayout.implicitWidth+20//640  //1100
            implicitHeight: 518
            color: "Transparent"
            // border.color: "green"
            // border.width: 2
            clip: true
            anchors.centerIn: parent
            


            GridLayout {
                id: gridLayout
                columns: 2
                anchors.fill: parent
                anchors.margins: 10
                columnSpacing: 20


                // wallpaper part
                Rectangle {
                    id:wallpaperBG
                    Layout.preferredWidth: 320
                    Layout.fillHeight: true
                    color: "Transparent"

                    ListView {
                        id: wallpaperList

                        anchors.fill: parent
                        spacing: 10
                        clip: true

                        orientation: ListView.Vertical
                        highlightRangeMode: ListView.StrictlyEnforceRange
                        preferredHighlightBegin: height / 3.15
                        preferredHighlightEnd: preferredHighlightBegin
                        highlightMoveDuration: 320
                        highlightMoveVelocity: -1

                        focus: true

                        Keys.onReturnPressed: handleSelect()
                        Keys.onEnterPressed: handleSelect()

                        function handleSelect() {
                            let path = decodeURIComponent(
                                wallpaperFolder.get(wallpaperList.currentIndex, "fileUrl")
                                    .toString()
                                    .replace("file://", "")
                            );
                            wall.setWallpaper(path);
                        }

                        Keys.onRightPressed: {
                            colorList.forceActiveFocus();
                        }

                        model: wallpaperFolder
                        delegate: Item {
                            width: 320
                            height: wallpaperList.currentIndex === index ? (200 - 20) : (200 - 20) * 0.8

                            Behavior on height {
                                NumberAnimation {
                                    duration: 240
                                    easing.type: Easing.OutQuad
                                }
                            }

                            ClippingRectangle {
                                id: thumb

                                width: wallpaperList.currentIndex === index ? parent.width : parent.width * 0.8
                                height: parent.height

                                Behavior on width {
                                    NumberAnimation {
                                        duration: 240
                                        easing.type: Easing.OutQuad
                                    }
                                }

                                anchors.centerIn:parent

                                radius: 10
                                color: "Transparent"
                                //border.color: wallpaperList.currentIndex === index ? Colors.wallthemeActiveColor : "Transparent"
                                
                                

                                border.color: wallpaperList.currentIndex === index ? Colors.wallthemeActiveColor : wall.currentWallpaperPath === decodeURIComponent(
                                    wallpaperFolder.get(index, "fileUrl")
                                        .toString()
                                        .replace("file://", "")
                                ) ? Colors.wallthemeSelectedColor : "Transparent"

                                Behavior on border.color {
                                    ColorAnimation { duration: 150 }
                                }
                                
                                border.width: 2



                                Text {
                                    id: loadingIcon

                                    text: ""
                                    anchors.centerIn: parent
                                    opacity: 0.2
                                    color: Colors.wallpaperLoadingTextColor
                                    visible: img.status !== Image.Ready
                                    scale: 1.0
                                    SequentialAnimation on scale {
                                        loops: Animation.Infinite

                                        NumberAnimation {
                                            from: 1.0
                                            to: 3.5
                                            duration: 800
                                            easing.type: Easing.InOutQuad
                                        }

                                        NumberAnimation {
                                            from: 3.5
                                            to: 1.0
                                            duration: 800
                                            easing.type: Easing.InOutQuad
                                        }
                                    }
                                }

                                scale: mouseArea.pressed ? 0.92 : 1.0

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: 240
                                        easing.type: Easing.OutQuad
                                    }
                                }

                                Image {
                                    id: img
                                    anchors.fill: parent
                                    source: fileUrl
                                    asynchronous: true
                                    cache: true
                                    fillMode: Image.PreserveAspectCrop

                                    // opacity: status === Image.Ready ? (wallpaperList.currentIndex === index ? 1 : 0.7) : 0
                                    opacity: status === Image.Ready ? (Math.max(0,1 - Math.abs(wallpaperList.currentIndex - index) * 0.25)):0
                                    

                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: 240
                                        }
                                    }
                                }

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onWheel: function(event) {
                                        const step = 1;

                                        if (event.angleDelta.y > 0) {
                                            wallpaperList.currentIndex = Math.max(0, wallpaperList.currentIndex - step);
                                        } else if (event.angleDelta.y < 0) {
                                            wallpaperList.currentIndex = Math.min(wallpaperList.count - 1, wallpaperList.currentIndex + step);
                                        }

                                        event.accepted = true;
                                    }
                                    onClicked: {
                                        if (index !== wallpaperList.currentIndex) {
                                            wallpaperList.highlightMoveDuration = 0
                                            wallpaperList.currentIndex = index
                                            wallpaperList.highlightMoveDuration = 320
                                            return;
                                        }
                                        wallpaperList.highlightMoveDuration = 0
                                        wallpaperList.currentIndex = index
                                        wallpaperList.highlightMoveDuration = 320
                                        let path = decodeURIComponent(
                                            img.source.toString().replace("file://", "")
                                        );
                                        wall.setWallpaper(path);
                                    }


                                    // onClicked: {
                                    //     if (index !== wallpaperList.currentIndex) {
                                    //         wallpaperList.currentIndex = index;
                                    //         return;
                                    //     }
                                    //     wallpaperList.currentIndex = index;
                                    //     let path = decodeURIComponent(
                                    //         img.source.toString().replace("file://", "")
                                    //     );
                                    //     wall.setWallpaper(path);
                                    // }
                                }
                            }
                        }
                    }
                }

                // theme part
                Rectangle {
                    id:themeBG
                    Layout.preferredWidth: 300//360
                    Layout.fillHeight: true
                    color: "Transparent"
                    // border.color: "red"
                    // border.width: 2

                    ListView {
                        id: colorList
                        anchors.fill: parent
                        spacing: 6
                        clip: true

                        orientation: ListView.Vertical
                        highlightRangeMode: ListView.StrictlyEnforceRange
                        preferredHighlightBegin: (height / 2)-30
                        preferredHighlightEnd: preferredHighlightBegin
                        highlightMoveDuration: 320
                        highlightMoveVelocity: -1


                        Keys.onReturnPressed: {
                            Colors.theme = colorList.currentIndex;
                        }
                        Keys.onLeftPressed: {
                            wallpaperList.forceActiveFocus();
                        }

                        model: Colors.themeColors.length
                        delegate: Item {
                            property int parentIndex: index
                            width: themeBG.width
                            height: card.implicitHeight

                            // onParentIndexChanged:{
                            //     console.log("viewArea imw:",viewArea.implicitWidth,"needed total:",themeBG.width + wallpaperBG.width+40,"\n","  themeBG imw:",themeBG.width,"wallpaperBG imw:",wallpaperBG.width)
                            // }
                            

                            Behavior on height {
                                NumberAnimation {
                                    duration: 240
                                    easing.type: Easing.OutQuad
                                }
                            }

                            Rectangle {
                                id: card
                                // anchors.horizontalCenter:parent.horizontalCenter
                                // anchors.horizontalCenterOffset:10
                                anchors.right:parent.right
                                anchors.rightMargin:20

                                implicitHeight: colorRow.implicitHeight + 40
                                implicitWidth: Math.max(colorRow.implicitWidth + 20, nameText.implicitWidth + 20)
                                radius: 10
                                color: Colors.themeBackgroundColor
                                //border.color: colorList.currentIndex === index ? Colors.activeColor : "transparent"
                                border.color: colorList.currentIndex === index ? Colors.wallthemeActiveColor
                                : Colors.theme === index ? Colors.wallthemeSelectedColor
                                : "transparent"
                                
                                border.width: 2
                                // opacity: colorList.currentIndex === index ? 1 : 0.7
                                opacity: Math.max(0,1 - Math.abs(colorList.currentIndex - index) * 0.25)
                                // opacity: colorList.currentIndex === index ? 1 : Math.abs(colorList.currentIndex - index)==4?0.0:0.7


                                Behavior on border.color {
                                    ColorAnimation { duration: 150 }
                                }

                                scale: themeMouseArea.pressed ? 0.92 : 1.0
                                Behavior on scale {
                                    NumberAnimation {
                                        duration: 240
                                        easing.type: Easing.OutQuad
                                    }
                                }
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 240
                                        easing.type: Easing.OutQuad
                                    }
                                }


                               
                                Text {
                                    id: nameText
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.top: parent.top
                                    anchors.topMargin: 5
                                    text: Colors.themeColors[index][0]
                                    font.family: "Nunito"
                                    font.weight: Font.Bold
                                    font.pixelSize: colorList.currentIndex === parentIndex ? 18 : 16
                                    color: Colors.mainTextColor
                                    Behavior on font.pixelSize {
                                        NumberAnimation {
                                            duration: 240
                                            easing.type: Easing.OutQuad
                                        }
                                    }
                                }

                                Row {
                                    id: colorRow
                                    spacing: colorList.currentIndex === parentIndex ? 8 : 4
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 10

                                    Repeater {
                                        model: Colors.themeColors[index].slice(2, 12)
                                        delegate: Rectangle {
                                            width: colorList.currentIndex === parentIndex ? 18 : 16
                                            height: width
                                            radius:  width / 2
                                            color: modelData
                                            border.color: Colors.themeIconColor
                                            border.width: 1

                                            Behavior on width {
                                                NumberAnimation {
                                                    duration: 240
                                                    easing.type: Easing.OutQuad
                                                }
                                            }
                                        }
                                    }
                                }
                                


                                MouseArea {
                                    id: themeMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onWheel: function(event) {
                                        const step = 1;
                                        if (event.angleDelta.y > 0) {
                                            colorList.currentIndex = Math.max(0, colorList.currentIndex - step);
                                        } else if (event.angleDelta.y < 0) {
                                            colorList.currentIndex = Math.min(colorList.count - 1, colorList.currentIndex + step);
                                        }
                                        event.accepted = true;
                                    }

                                    onClicked: {
                                        if (index !== colorList.currentIndex) {
                                            colorList.highlightMoveDuration = 0
                                            colorList.currentIndex = index
                                            colorList.highlightMoveDuration = 320
                                            return;
                                        }
                                        colorList.highlightMoveDuration = 0
                                        colorList.currentIndex = index
                                        colorList.highlightMoveDuration = 320
                                        Colors.theme = index;
                                    }



                                    // onClicked: {
                                    //     if (index !== colorList.currentIndex) {
                                    //         colorList.currentIndex = index;
                                    //         return;
                                    //     }
                                    //     colorList.currentIndex = index;
                                    //     Colors.theme = index;
                                    // }
                                }
                            }
                        }
                    }
                }



            }
        }
    }
}






// //awww img --transition-type grow --transition-duration 2 --transition-fps 160 ~/.config/res/wallpapers/ac1.png