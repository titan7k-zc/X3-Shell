import QtQuick
import Quickshell
pragma Singleton


Singleton {
    id: time

    readonly property string date: {
        // Qt.formatDateTime(clock.date, "ddd MMM d hh:mm:ss AP t yyyy");
        Qt.formatDateTime(clock.date, "yyyy MMM d") //"yy/M/d hh:mm"
    }
    readonly property string hour: {
        // Qt.formatDateTime(clock.date, "ddd MMM d hh:mm:ss AP t yyyy");
        Qt.formatDateTime(clock.date, "hh") //"yy/M/d hh:mm"
    }
    readonly property string minute: {
        // Qt.formatDateTime(clock.date, "ddd MMM d hh:mm:ss AP t yyyy");
        Qt.formatDateTime(clock.date, "mm") //"yy/M/d hh:mm"
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
