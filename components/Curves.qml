import QtQuick
import QtQuick.Shapes


Shape {
    id:root
    property int radius: 14
    required property color color
    property bool isTop: true
    property bool mirrored: false

    implicitHeight: radius
    implicitWidth:radius

    preferredRendererType: Shape.CurveRenderer

    transform: Scale{
        xScale: root.mirrored?-1:1
        origin.x:root.radius/2
        origin.y:0
    }


    ShapePath{
        fillColor: root.color
        strokeColor: "Transparent"
        startX: root.isTop?root.radius:0
        startY: root.isTop?0:0

        PathLine{
            x:0
            y:root.isTop?0:root.radius
        }

        PathLine{
            x:root.isTop?0:root.radius
            y:root.isTop?root.radius:root.radius
        }

        PathArc{
            x:root.isTop?root.radius:0
            y:root.isTop?0:0
            radiusX: root.radius
            radiusY: root.radius
            // direction: root.isTop? PathArc.Counterclockwise : PathArc.Clockwise
            direction: PathArc.Clockwise
        }
    }

}
