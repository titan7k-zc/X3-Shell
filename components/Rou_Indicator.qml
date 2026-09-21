import QtQuick
import "../config"

Item {
    id: root

    required property int value      // 0-100
    property string ic:""      // icon glyph text

    property real hi_off:0
    property real vi_off:0
    property real i_scl:1
    required property color igColor
    required property color icColor
    required property color trackColor

    // Optional extras (sane defaults, override if you like)
    property bool showTrack: true
    property real ringWidth: Math.max(2, Math.min(width, height) * 0.09)
    property string iconFontFamily: "" // set to your icon font name if needed
    property real iconSizeRatio: 0.4   // icon size relative to component size
    property int animationDuration: 250
    property string start: "bottom"




    property var starting_C: {
        if (start==="top"){
            return -Math.PI / 2
        } else if (start==="bottom"){
            return Math.PI / 2
        } else if (start==="right"){
            return 0
        } else if (start==="left"){
            return Math.PI
        }

    }// 0 - right , Math.PI - left , Math.PI/2 - bottom , -Math.PI/2 - top

    width: 100
    height: 100

    // clamp value defensively
    readonly property int clampedValue: Math.max(0, Math.min(100, value))

    // animate percentage changes smoothly
    property real animatedPct: clampedValue / 100
    Behavior on animatedPct {
        NumberAnimation {
            duration: root.animationDuration
            easing.type: Easing.OutCubic
        }
    }
    onClampedValueChanged: animatedPct = clampedValue / 100
    Component.onCompleted: animatedPct = clampedValue / 100

    Canvas {
        id: canvas
        anchors.fill: parent
        renderTarget: Canvas.FramebufferObject
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            var w = width;
            var h = height;
            var cx = w / 2;
            var cy = h / 2;
            var lw = root.ringWidth;
            var radius = Math.min(w, h) / 2 - lw / 2;

            // Start at the bottom of the circle (6 o'clock = 90deg in canvas
            // convention) and sweep clockwise around back to the bottom.
            var startAngle =root.starting_C
            var pct = root.animatedPct;
            var endAngle = startAngle + pct * 2 * Math.PI;

            // background track (full circle, faint)
            if (root.showTrack) {
                ctx.beginPath();
                ctx.lineWidth = lw;
                ctx.strokeStyle = root.trackColor;
                ctx.arc(cx, cy, radius, 0, 2 * Math.PI, false);
                ctx.stroke();
            }

            // progress arc
            if (pct > 0) {
                ctx.beginPath();
                ctx.lineWidth = lw;
                ctx.lineCap = "round";
                ctx.strokeStyle = root.igColor;

                // For very small values, draw at least a minimal visible dot/sliver
                var minSweep = 0.03; // radians, ensures 1% is still visible
                var sweep = Math.max(endAngle - startAngle, pct > 0 ? minSweep : 0);

                ctx.arc(cx, cy, radius, startAngle, startAngle + sweep, false);
                ctx.stroke();
            }
        }
    }

    // repaint whenever anything relevant changes
    onAnimatedPctChanged: canvas.requestPaint()
    onIgColorChanged: canvas.requestPaint()
    onTrackColorChanged: canvas.requestPaint()
    onShowTrackChanged: canvas.requestPaint()
    onRingWidthChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()

    Text {
        id: iconText
        anchors.centerIn: parent
        anchors.horizontalCenterOffset:root.hi_off
        anchors.verticalCenterOffset:root.vi_off
        text: root.ic!==""?root.ic:root.value
        color: root.icColor
        font.pixelSize: Math.min(root.width, root.height) * root.iconSizeRatio
        font.family: root.iconFontFamily.length > 0 ? root.iconFontFamily : iconText.font.family
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        scale:root.i_scl
    }
}
