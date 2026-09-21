pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

Singleton {
    id: root

    property var windows: []

    function rebuild() {
        const list = [...ToplevelManager.toplevels.values];
        windows = list;

    }

    function activate(toplevel) {
        if (toplevel)
            toplevel.activate();
    }

    Component.onCompleted: rebuild()

    Connections {
        target: ToplevelManager

        function onActiveToplevelChanged() {
            root.rebuild();
        }
    }

    Connections {
        target: ToplevelManager.toplevels

        function onObjectInsertedPost() {
            root.rebuild();
        }

        function onObjectRemovedPost() {
            root.rebuild();
        }
    }
}