import 'package:geo_draw/core/construct/construct.dart';
import 'package:geo_draw/core/geometry_data/circle.dart';
import 'package:geo_draw/core/geometry_data/dot.dart';
import 'package:geo_draw/core/geometry_data/geometryset.dart';
import 'package:geo_draw/core/geometry_data/line.dart';
import 'package:geo_draw/core/geometry_data/segment.dart';
import 'package:geo_draw/core/prop/point.dart';
import 'package:geo_draw/core/tools/number.dart';

abstract class ConstructPointDirective extends ConstructDirective {

}

class ConstructPointCoordinates extends ConstructPointDirective {
  String name;
  String sx;
  String sy;

  ConstructPointCoordinates(this.name, this.sx, this.sy);

  @override
  ConstructResult execute(GeometrySet set) {
    if (!Dot.isValidName(name)) {
      return ConstructResult.fail(InvalidDotNameFailCause(name));
    }

    double? x = sx.interpretDouble();
    double? y = sy.interpretDouble();

    if (x == null) {
      return ConstructResult.fail(NumberFailCause(sx));
    }

    if (y == null) {
      return ConstructResult.fail(NumberFailCause(sy));
    }

    Dot dot = Dot(name, Point(x, y));
    addObject(set, dot);

    return ConstructResult.success;
  }


}

class ConstructPointMiddle extends ConstructPointDirective {
  String name;
  String segmentName;

  ConstructPointMiddle(this.name, this.segmentName);

  @override
  ConstructResult execute(GeometrySet set) {
    if (!Dot.isValidName(name)) {
      return ConstructResult.fail(InvalidDotNameFailCause(name));
    }

    Segment? segment = set.findSegment(segmentName);
    if (segment == null) {
      return ConstructResult.fail(NoSegmentFailCause(segmentName));
    }

    Dot dot = Dot(name, segment.midPoint);
    addObject(set, dot);

    return ConstructResult.success;
  }


}

class ConstructPointIntersectLines extends ConstructPointDirective {
  String name;
  String line1Name;
  String line2Name;

  ConstructPointIntersectLines(this.name, this.line1Name, this.line2Name);

  @override
  ConstructResult execute(GeometrySet set) {
    if (!Dot.isValidName(name)) {
      return ConstructResult.fail(InvalidDotNameFailCause(name));
    }

    Line? line1 = set.findLine(line1Name);
    Line? line2 = set.findLine(line2Name);

    if (line1 == null) {
      return ConstructResult.fail(NoLineFailCause(line1Name));
    }

    if (line2 == null) {
      return ConstructResult.fail(NoLineFailCause(line2Name));
    }

    Point? intersection = line1.intersectLine(line2);
    if (intersection != null) {
      Dot dot = Dot(name, intersection);
      addObject(set, dot);
    }

    return ConstructResult.success;
  }
}

class ConstructPointIntersectCircles extends ConstructPointDirective {
  String name1;
  String name2;
  String circle1Name;
  String circle2Name;

  ConstructPointIntersectCircles(this.name1, this.name2, this.circle1Name, this.circle2Name);

  @override
  ConstructResult execute(GeometrySet set) {
    if (!Dot.isValidName(name1)) {
      return ConstructResult.fail(InvalidDotNameFailCause(name1));
    }

    if (!Dot.isValidName(name2)) {
      return ConstructResult.fail(InvalidDotNameFailCause(name2));
    }

    Circle? circle1 = set.findCircle(circle1Name);
    Circle? circle2 = set.findCircle(circle2Name);

    if (circle1 == null) {
      return ConstructResult.fail(NoCircleFailCause(circle1Name));
    }

    if (circle2 == null) {
      return ConstructResult.fail(NoCircleFailCause(circle2Name));
    }

    List<Point?> intersection = circle1.intersect(circle2);
    if (intersection[0] == null && intersection[1] != null) {
      intersection[0] = intersection[1];
      intersection[1] = null;
    }
    if (intersection[0] != null && intersection[1] == null) {
      Dot dot = Dot(name1, intersection[0]!);
      addObject(set, dot);
    }
    else if (intersection[1] != null) {
      Dot? dot1, dot2;
      if (!set.containsName(name1) || !set.containsName(name2)) {
        if (!set.containsName(name1) && !set.containsName(name2)) {
          dot1 = Dot(name1, intersection[0]!);
          dot2 = Dot(name2, intersection[0]!);
        }
        else if (set.containsName(name1)) {
          if (set.findDot(name1)!.point == intersection[0]) {
            intersection[0] = intersection[1];
          }
          dot1 = Dot(name2, intersection[0]!);
        }
        else {
          if (set.findDot(name2)!.point == intersection[0]) {
            intersection[0] = intersection[1];
          }
          dot2 = Dot(name1, intersection[0]!);
        }

        if (dot1 != null) {
          addObject(set, dot1);
        }
        if (dot2 != null) {
          addObject(set, dot2);
        }
      }
    }

    return ConstructResult.success;
  }
}

class ConstructPointIntersectLineCircle extends ConstructPointDirective {
  String name1;
  String name2;
  String circleName;
  String lineName;

  ConstructPointIntersectLineCircle(this.name1, this.name2, this.lineName, this.circleName);

  @override
  ConstructResult execute(GeometrySet set) {
    if (!Dot.isValidName(name1)) {
      return ConstructResult.fail(InvalidDotNameFailCause(name1));
    }

    if (!Dot.isValidName(name2)) {
      return ConstructResult.fail(InvalidDotNameFailCause(name2));
    }

    Circle? circle = set.findCircle(circleName);
    Line? line = set.findLine(lineName);

    if (circle == null) {
      return ConstructResult.fail(NoCircleFailCause(circleName));
    }

    if (line == null) {
      return ConstructResult.fail(NoLineFailCause(lineName));
    }

    List<Point?> intersection = line.intersectCircle(circle);
    print("${intersection[0]?.x}, ${intersection[0]?.y}");
    print("${intersection[1]?.x}, ${intersection[1]?.y}");
    if (intersection[0] == null && intersection[1] != null) {
      intersection[0] = intersection[1];
      intersection[1] = null;
    }
    if (intersection[0] != null && intersection[1] == null) {
      Dot dot = Dot(name1, intersection[0]!);
      addObject(set, dot);
    }
    else if (intersection[1] != null) {
      Dot? dot1, dot2;
      if (!set.containsName(name1) || !set.containsName(name2)) {
        if (!set.containsName(name1) && !set.containsName(name2)) {
          dot1 = Dot(name1, intersection[0]!);
          dot2 = Dot(name2, intersection[1]!);
        }
        else if (set.containsName(name1)) {
          if (set.findDot(name1)!.point == intersection[0]) {
            intersection[0] = intersection[1];
          }
          dot1 = Dot(name2, intersection[0]!);
        }
        else {
          if (set.findDot(name2)!.point == intersection[0]) {
            intersection[0] = intersection[1];
          }
          dot2 = Dot(name1, intersection[0]!);
        }

        if (dot1 != null) {
          addObject(set, dot1);
        }
        if (dot2 != null) {
          addObject(set, dot2);
        }
      }
    }

    return ConstructResult.success;
  }
}