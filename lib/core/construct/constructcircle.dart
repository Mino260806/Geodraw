import 'package:geo_draw/core/construct/construct.dart';
import 'package:geo_draw/core/geometry_data/circle.dart';
import 'package:geo_draw/core/geometry_data/dot.dart';
import 'package:geo_draw/core/geometry_data/geometryset.dart';
import 'package:geo_draw/core/geometry_data/line.dart';
import 'package:geo_draw/core/geometry_data/segment.dart';
import 'package:geo_draw/core/name/segment.dart';
import 'package:geo_draw/core/prop/point.dart';
import 'package:geo_draw/core/tools/number.dart';

abstract class ConstructCircleDirective extends ConstructDirective {

}

class ConstructCircleCenterRadius extends ConstructCircleDirective {
  String name;
  String centerName;
  String sradius;

  ConstructCircleCenterRadius(this.name, this.centerName, this.sradius);

  @override
  ConstructResult execute(GeometrySet set) {
    Dot? center = set.findDot(centerName);
    double? radius = sradius.interpretDouble();

    if (center == null) {
      return ConstructResult.fail(NoDotFailCause(centerName));
    }

    if (radius == null) {
      var segmentNameMatcher = SegmentNameMatcher(sradius);
      SegmentName? segmentName =  segmentNameMatcher.match();
      if (segmentName != null) {
        Dot? dot1 = set.findDot(segmentName.dot1);
        Dot? dot2 = set.findDot(segmentName.dot2);
        if (dot1 != null && dot2 != null) {
          radius = Segment.getDistance(dot1.point, dot2.point);
        }
      }
    }

    if (radius == null) {
      return ConstructResult.fail(NumberFailCause(sradius));
    }

    Circle circle = Circle(name, center.point, radius);
    addObject(set, circle);

    return ConstructResult.success;
  }
}

class ConstructCircleDiameter extends ConstructCircleDirective {
  String name;
  String diameterName;

  ConstructCircleDiameter(this.name, this.diameterName);

  @override
  ConstructResult execute(GeometrySet set) {
    var segmentNameMatcher = SegmentNameMatcher(diameterName);
    SegmentName? segmentName =  segmentNameMatcher.match();
    if (segmentName != null) {
      Dot? dot1 = set.findDot(segmentName.dot1);
      Dot? dot2 = set.findDot(segmentName.dot2);
      if (dot1 != null && dot2 != null) {
        Circle circle = Circle.fromDiameter(name, dot1.point, dot2.point);
        addObject(set, circle);
      }
    }
    return ConstructResult.success;
  }

}

class ConstructCirclePoints extends ConstructCircleDirective {
  String name;
  String dot1Name;
  String dot2Name;
  String dot3Name;

  ConstructCirclePoints(this.name, this.dot1Name, this.dot2Name, this.dot3Name);

  @override
  ConstructResult execute(GeometrySet set) {
    Dot? dot1 = set.findDot(dot1Name);
    Dot? dot2 = set.findDot(dot2Name);
    Dot? dot3 = set.findDot(dot3Name);

    if (dot1 == null) {
      return ConstructResult.fail(NoDotFailCause(dot1Name));
    }

    if (dot2 == null) {
      return ConstructResult.fail(NoDotFailCause(dot2Name));
    }

    if (dot3 == null) {
      return ConstructResult.fail(NoDotFailCause(dot3Name));
    }

    if (Line.areAligned(dot1.point, dot2.point, dot3.point)) {
      return ConstructResult.fail(DotsAlignedFailCause(dot1Name, dot2Name, dot3Name));
    }

    Circle circle = Circle.fromPoints(name, dot1.point, dot2.point, dot3.point);
    addObject(set, circle);

    return ConstructResult.success;
  }

}
