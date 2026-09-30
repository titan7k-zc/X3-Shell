import QtQuick
import Quickshell

import "../services"
import "../config"

Item {
    id: root

    // =========================
    // Appearance
    // =========================

    property color backgroundColor: "Transparent"//Colors.barBackgroundColor
    property color primaryColor: Colors.weatherPrimaryColor
    property color secondaryColor: Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.4)
    property color iconTempColor: primaryColor


    


    Behavior on primaryColor { ColorAnimation { duration: Colors.themeAnimationDuration; easing.type: Easing.InOutQuad } } 


    Rectangle {
        id: backgroundRect

        height: parent.height
        width: parent.width
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        scale: weatherButtonMouseArea.pressed ? 0.98 : 1.0

        color: "Transparent"

            // =========================
        // Left side
        // =========================

        Column {
            id: weatherInfo

            anchors.left: parent.left
            anchors.leftMargin: 16

            anchors.verticalCenter: parent.verticalCenter

            spacing: 0

            // City
            Text {
                id: cityText
                text: WeatherService.city
                color: root.primaryColor
                font.family: "Quicksand"
                font.pixelSize: 15
                font.weight: Font.Bold
                elide: Text.ElideRight
                // width: 120
            }

            // Weather condition
            Text {
                id: conditionText
                text: WeatherService.condition
                color: root.secondaryColor
                font.pixelSize: 10
                font.weight: Font.Bold
                elide: Text.ElideRight
                // width: 120
            }
        }

        // =========================
        // Right side
        // =========================

        Row {
            id: weatherValue

            anchors.right: parent.right
            anchors.rightMargin: 14

            anchors.verticalCenter: parent.verticalCenter

            spacing: 4

            // Weather icon
            Text {
                id: weatherIcon

                text: WeatherService.icon

                color: root.primaryColor

                font.pixelSize: 30

                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -2
            }

            // Temperature
            Text {
                id: temperatureText

                text: Math.round(WeatherService.temperature) + "°C"

                color: root.primaryColor

                font.family: "Quicksand"
                font.pixelSize: 17
                font.weight: Font.Bold

                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id:weatherButtonMouseArea
            anchors.fill: parent

            onClicked:{
                // console.log("Weather button clicked")
                WeatherService.refresh()
            }
            
            
        }

    }

    // =========================
    // Loading
    // =========================


    // Text {
    //     anchors.centerIn: parent

    //     visible: WeatherService.loading

    //     text: "Loading weather..."

    //     color: root.primaryColor

    //     font.family: "JetBrainsMono Nerd Font"
    //     font.pixelSize: 12
    // }

    // =========================
    // Error
    // =========================

    // Text {
    //     anchors.centerIn: parent

    //     visible: WeatherService.error

    //     text: "Weather unavailable"

    //     color: root.secondaryColor

    //     font.family: "JetBrainsMono Nerd Font"
    //     font.pixelSize: 12
    // }




}