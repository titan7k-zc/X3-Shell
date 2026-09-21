import Quickshell
import QtQuick

import "../../config"

FocusScope {
    id: root

    property var screen
    property bool show: true

    signal closed



    Component.onCompleted:root.forceActiveFocus()

    // ─────────────────────────────────────────────────────────────
    // State
    // ─────────────────────────────────────────────────────────────

    property string searchQuery: ""
    property int selectedIndex: 0

    readonly property bool isSearching: searchQuery.trim() !== ""

    property var filteredApps: computeFilteredApps()

    // ─────────────────────────────────────────────────────────────
    // Layout
    // ─────────────────────────────────────────────────────────────

    implicitHeight: panelHeight
    implicitWidth: panelWidth

    readonly property int maxVisibleItems: 4
    readonly property int rowHeight: 80
    readonly property int panelWidth: 640
    readonly property int panelPadding: 12
    readonly property int searchBarHeight: 44
    readonly property int panelHeaderHeight: 88

    readonly property int panelHeight: panelHeaderHeight + Math.min(filteredApps.length, maxVisibleItems) * rowHeight

    // ─────────────────────────────────────────────────────────────
    // ─────────────────────────────────────────────────────────────
    // Typography
    // ─────────────────────────────────────────────────────────────

    readonly property string fontFamily: "JetBrainsMono Nerd Font"

    readonly property int fontSizeSearch: 13
    readonly property int fontSizeAppName: 13
    readonly property int fontSizeSubtitle: 11
    readonly property int fontSizeIconFallback: 15

    // =========================================================
    // CLOSE
    // =========================================================

    function closeLauncher() {
        if (!root.show)
            return;
        root.closed();
        searchInput.text = "";
    }

    // ─────────────────────────────────────────────────────────────
    // App filtering
    // ─────────────────────────────────────────────────────────────

    function computeFilteredApps() {
        var query = searchQuery.trim().toLowerCase();
        var apps = DesktopEntries.applications.values;

        // No search → all apps alphabetically
        if (query === "") {
            return apps.slice().sort(function (a, b) {
                return a.name.localeCompare(b.name);
            });
        }

        // Search
        return apps.filter(function (app) {
            if (app.name && app.name.toLowerCase().indexOf(query) !== -1) {
                return true;
            }

            if (app.genericName && app.genericName.toLowerCase().indexOf(query) !== -1) {
                return true;
            }

            if (app.keywords) {
                for (var i = 0; i < app.keywords.length; i++) {
                    if (app.keywords[i].toLowerCase().indexOf(query) !== -1) {
                        return true;
                    }
                }
            }

            return false;
        }).sort(function (a, b) {
            return a.name.localeCompare(b.name);
        });
    }

    onFilteredAppsChanged: {
        selectedIndex = 0;

        if (listView)
            listView.positionViewAtIndex(0, ListView.Beginning);
    }

    // ─────────────────────────────────────────────────────────────
    // Launch
    // ─────────────────────────────────────────────────────────────

    function launchEntry(entry) {
        if (!entry)
            return;
        entry.execute();

        closeLauncher();
    }

    function launchSelected() {
        if (filteredApps.length === 0)
            return;
        if (selectedIndex < 0 || selectedIndex >= filteredApps.length) {
            selectedIndex = 0;
        }

        launchEntry(filteredApps[selectedIndex]);
    }

    // ─────────────────────────────────────────────────────────────
    // Navigation
    // ─────────────────────────────────────────────────────────────

    function navigate(delta) {
        if (filteredApps.length === 0)
            return;
        selectedIndex = (selectedIndex + delta + filteredApps.length) % filteredApps.length;

        listView.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

    // ─────────────────────────────────────────────────────────────
    // Wheel navigation
    // ─────────────────────────────────────────────────────────────

    function navigateOnWheel(wheel) {
        navigate(wheel.angleDelta.y < 0 ? 1 : -1);
    }

    // ─────────────────────────────────────────────────────────────
    // Panel
    // ─────────────────────────────────────────────────────────────

    Rectangle {
        id: panel

        width: root.panelWidth
        height: root.panelHeight
        opacity: root.show ? 1 : 0
        clip: true
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        color: Colors.launcherPanelColor
        border.color: Colors.launcherBorderColor
        border.width: 1

        // ─────────────────────────────────────────────────────────
        // Content
        // ─────────────────────────────────────────────────────────

        Column {
            anchors {
                top: parent.top
                topMargin: root.panelPadding

                left: parent.left
                leftMargin: root.panelPadding

                right: parent.right
                rightMargin: root.panelPadding
            }

            spacing: 0

            // ─────────────────────────────────────────────────────
            // Drag handle
            // ─────────────────────────────────────────────────────

            Rectangle {
                width: 36
                height: 4
                radius: 2
                anchors.horizontalCenter: parent.horizontalCenter
                color: Colors.launcherDragHandleColor
            }

            Item {
                width: 1
                height: 8
            }

            // ─────────────────────────────────────────────────────
            // Search box
            // ─────────────────────────────────────────────────────

            Rectangle {
                width: parent.width
                height: root.searchBarHeight
                radius: 10
                color: Colors.launcherSearchBackgroundColor

                // ONLY animation in the launcher
                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: "Transparent"
                    border.color: Colors.launcherSearchFocusColor
                    border.width: 1
                    opacity: searchInput.activeFocus ? 0.55 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }

                Row {
                    anchors {
                        fill: parent
                        leftMargin: 14
                        rightMargin: 14
                    }

                    spacing: 10

                    Item {
                        width: parent.width - 40
                        height: parent.height

                        // Placeholder
                        Text {
                            anchors.fill: parent
                            text: root.isSearching ? "" : "Search apps…"
                            color: Colors.launcherPrimaryTextColor
                            opacity: 0.28

                            font {
                                pixelSize: root.fontSizeSearch

                                family: root.fontFamily
                            }

                            verticalAlignment: Text.AlignVCenter
                            visible: searchInput.text === ""
                        }

                        // Search input also key input handler
                        TextInput {
                            id: searchInput

                            anchors.fill: parent

                            color: Colors.launcherPrimaryTextColor
                            selectionColor: Colors.launcherAccentColor

                            font {
                                pixelSize: root.fontSizeSearch
                                family: root.fontFamily
                            }

                            verticalAlignment: Text.AlignVCenter
                            clip: true

                            focus: root.show

                            onTextChanged: {
                                root.searchQuery = text;
                            }

                            Keys.onDownPressed: {
                                root.navigate(1);
                                event.accepted = true;
                            }

                            Keys.onUpPressed: {
                                root.navigate(-1);
                                event.accepted = true;
                            }

                            Keys.onReturnPressed: {
                                root.launchSelected();
                                event.accepted = true;
                            }
                        }
                    }
                }
            }

            Item {
                width: 1
                height: 8
            }

            // ─────────────────────────────────────────────────────
            // App list
            // ─────────────────────────────────────────────────────

            ListView {
                id: listView

                width: parent.width
                height: Math.min(root.filteredApps.length, root.maxVisibleItems) * root.rowHeight
                model: root.filteredApps
                clip: true


                // ─────────────────────────────────────────────
                // Empty state
                // ─────────────────────────────────────────────

                Text {
                    anchors.centerIn: parent
                    visible: root.filteredApps.length === 0
                    text: "No apps found"
                    color: Colors.launcherPrimaryTextColor
                    opacity: 0.28

                    font {
                        pixelSize: root.fontSizeSearch

                        family: root.fontFamily
                    }
                }

                // ─────────────────────────────────────────────
                // Delegate
                // ─────────────────────────────────────────────

                delegate: Item {
                    id: delegateRoot

                    width: listView.width
                    height: root.rowHeight

                    readonly property bool isSelected: root.selectedIndex === index

                    // ─────────────────────────────────────────
                    // Selection background
                    // ─────────────────────────────────────────

                    Rectangle {
                        anchors {
                            fill: parent
                            topMargin: 2
                            bottomMargin: 2
                        }

                        radius: 10
                        color: delegateRoot.isSelected ? Colors.launcherAccentColor : "Transparent"
                    }

                    // ─────────────────────────────────────────
                    // App content
                    // ─────────────────────────────────────────

                    Row {
                        anchors {
                            fill: parent
                            leftMargin: 8
                            rightMargin: 8
                        }

                        spacing: 12

                        // ─────────────────────────────────────
                        // Icon
                        // ─────────────────────────────────────

                        Rectangle {
                            width: 36
                            height: 36
                            radius: 9
                            anchors.verticalCenter: parent.verticalCenter

                            color: delegateRoot.isSelected ? Colors.launcherAccentIconColor : Colors.launcherIconBubbleColor

                            Image {
                                id: appIcon
                                anchors.centerIn: parent
                                width: 22
                                height: 22

                                source: modelData.icon !== "" ? "image://icon/" + modelData.icon : ""

                                smooth: true
                                mipmap: true
                                asynchronous: true

                                opacity: status === Image.Ready ? 1 : 0
                            }

                            // Fallback icon
                            Text {
                                anchors.centerIn: parent
                                opacity: appIcon.status !== Image.Ready ? 1 : 0
                                text: modelData.name.charAt(0).toUpperCase()
                                font {
                                    pixelSize: root.fontSizeIconFallback
                                    family: root.fontFamily
                                    weight: Font.Bold
                                }
                                color: delegateRoot.isSelected ? Colors.launcherAccentColor : Colors.launcherPrimaryTextColor
                            }
                        }

                        // ─────────────────────────────────────
                        // App name
                        // ─────────────────────────────────────

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            Text {
                                text: modelData.name
                                font {
                                    pixelSize: root.fontSizeAppName
                                    family: root.fontFamily
                                    weight: delegateRoot.isSelected ? Font.Medium : Font.Normal
                                }
                                color: delegateRoot.isSelected ? Colors.launcherPrimaryTextColor : Colors.launcherDimTextColor
                            }

                            Text {
                                visible: modelData.genericName !== ""
                                text: modelData.genericName
                                font {
                                    pixelSize: root.fontSizeSubtitle
                                    family: root.fontFamily
                                }
                                color: Colors.launcherPrimaryTextColor
                                opacity: 0.35
                            }
                        }
                    }

                    // ─────────────────────────────────────────
                    // Mouse interaction
                    // ─────────────────────────────────────────

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        // Hover selects app
                        onEntered: {
                            root.selectedIndex = index;
                            searchInput.forceActiveFocus();
                        }

                        // Click launches app
                        onClicked: {
                            root.launchEntry(modelData);
                        }

                        // Wheel navigation
                        onWheel: function (wheel) {
                            root.navigateOnWheel(wheel);
                        }
                    }
                }
            }

            Item {
                width: 1
                height: root.panelPadding
            }
        }
    }
}
