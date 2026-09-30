pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // =========================
    // Settings
    // =========================

    property string city: "Batticaloa"

    // Batticaloa coordinates
    property real latitude: 7.7170
    property real longitude: 81.7000

    // =========================
    // Weather data
    // =========================

    property real temperature: 0
    property int weatherCode: -1
    property bool isDay: true

    property string condition: "Loading..."
    property string icon: "󰖐"

    property bool loading: false
    property bool error: false

    // =========================
    // Geocoding
    // =========================

    Process {
        id: geoProcess

        command: [
            "curl",
            "-s",
            "https://geocoding-api.open-meteo.com/v1/search?name="
                + encodeURIComponent(root.city)
                + "&count=1&language=en&format=json"
        ]

        stdout: StdioCollector {
            id: geoOutput

            onStreamFinished: {
                try {
                    const data = JSON.parse(text)

                    if (!data.results || data.results.length === 0) {
                        root.error = true
                        root.loading = false
                        root.condition = "Location error"
                        return
                    }

                    const location = data.results[0]

                    root.latitude = location.latitude
                    root.longitude = location.longitude

                    weatherProcess.running = true

                } catch (e) {
                    root.error = true
                    root.loading = false
                    root.condition = "Weather error"

                    console.log("Weather geocoding error:", e)
                }
            }
        }
    }

    // =========================
    // Weather request
    // =========================

    Process {
        id: weatherProcess

        command: [
            "curl",
            "-s",
            "https://api.open-meteo.com/v1/forecast"
            + "?latitude=" + root.latitude
            + "&longitude=" + root.longitude
            + "&current=temperature_2m,weather_code,is_day"
            + "&temperature_unit=celsius"
            + "&timezone=auto"
        ]

        stdout: StdioCollector {
            id: weatherOutput

            onStreamFinished: {
                try {
                    const data = JSON.parse(text)

                    if (!data.current) {
                        root.error = true
                        root.loading = false
                        return
                    }

                    root.temperature = data.current.temperature_2m
                    root.weatherCode = data.current.weather_code
                    root.isDay = data.current.is_day === 1

                    root.updateWeatherInfo()

                    root.loading = false
                    root.error = false

                } catch (e) {
                    root.error = true
                    root.loading = false
                    root.condition = "Weather error"

                    console.log("Weather JSON error:", e)
                }
            }
        }
    }

    // =========================
    // Refresh timer
    // =========================

    Timer {
        interval: 10 * 60 * 1000
        running: true
        repeat: true

        onTriggered: root.refresh()
    }

    // =========================
    // Weather code → text/icon
    // =========================

    function updateWeatherInfo() {
        switch (root.weatherCode) {

            // Clear
            case 0:
                root.condition = root.isDay ? "Clear" : "Clear night"
                root.icon = root.isDay ? "󰖙" : "󰖔"
                break

            // Mainly clear
            case 1:
                root.condition = "Mainly clear"
                root.icon = root.isDay ? "󰖙" : "󰖔"
                break

            // Partly cloudy
            case 2:
                root.condition = "Partly cloudy"
                root.icon = root.isDay ? "󰖕" : "󰼱"
                break

            // Overcast
            case 3:
                root.condition = "Cloudy"
                root.icon = "󰖐"
                break

            // Fog
            case 45:
            case 48:
                root.condition = "Foggy"
                root.icon = "󰖑"
                break

            // Drizzle
            case 51:
            case 53:
            case 55:
                root.condition = "Drizzle"
                root.icon = "󰖗"
                break

            // Freezing drizzle
            case 56:
            case 57:
                root.condition = "Freezing drizzle"
                root.icon = "󰖝"
                break

            // Rain
            case 61:
            case 63:
            case 65:
                root.condition = "Rainy"
                root.icon = "󰖖"
                break

            // Freezing rain
            case 66:
            case 67:
                root.condition = "Freezing rain"
                root.icon = "󰙿"
                break

            // Snow
            case 71:
            case 73:
            case 75:
            case 77:
                root.condition = "Snowy"
                root.icon = "󰼶"
                break

            // Rain showers
            case 80:
            case 81:
            case 82:
                root.condition = "Showers"
                root.icon = root.isDay ? "" : ""
                break

            // Snow showers
            case 85:
            case 86:
                root.condition = "Snow showers"
                root.icon = ""
                break

            // Thunderstorm
            case 95:
            case 96:
            case 99:
                root.condition = "Thunderstorm"
                root.icon = ""
                break

            default:
                root.condition = "Unknown"
                root.icon = "󰨹"
                break
        }
    }
    // =========================
    // Public refresh function
    // =========================

    function refresh() {
        if (geoProcess.running || weatherProcess.running)
            return

        root.loading = true
        root.error = false

        geoProcess.running = true
        // console.log("Refreshing ")
    }

    Component.onCompleted: {
        root.refresh()
    }
}