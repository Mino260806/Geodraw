import 'package:geo_draw/core/construct/construct.dart';
import 'package:geo_draw/core/geometry_data/circle.dart';
import 'package:geo_draw/core/geometry_data/dot.dart';
import 'package:geo_draw/core/geometry_data/geometryset.dart';
import 'package:geo_draw/core/geometry_data/line.dart';
import 'package:geo_draw/core/geometry_data/segment.dart';
import 'package:geo_draw/core/name/segment.dart';
import 'package:geo_draw/core/prop/point.dart';
import 'package:geo_draw/core/tools/number.dart';

abstract class ConstructLineDirective extends ConstructDirective {
}

class ConstructLineConnect extends ConstructLineDirective {
  String name;
  String segmentNameRaw;

  bool endpoint1;
  bool endpoint2;

  ConstructLineConnect(this.name, this.segmentNameRaw, {this.endpoint1=false, this.endpoint2=false});

  @override
  ConstructResult execute(GeometrySet set) {
    var segmentNameMatcher = SegmentNameMatcher(segmentNameRaw);
    SegmentName? segmentName =  segmentNameMatcher.match();

    if (segmentName == null) {
      return ConstructResult.fail(InvalidSegmentNameFailCause(segmentNameRaw));
    }

    Dot? dot1 = set.findDot(segmentName.dot1);
    Dot? dot2 = set.findDot(segmentName.dot2);

    if (dot1 == null) {
      return ConstructResult.fail(NoDotFailCause(segmentName.dot1));
    }

    if (dot2 == null) {
      return ConstructResult.fail(NoDotFailCause(segmentName.dot2));
    }

    if (!endpoint1 && !endpoint2) {
      Line line = Line.fromDots(name, dot1, dot2);
      addObject(set, line);
    }

    else if (endpoint1 && endpoint2) {
      Segment segment = Segment.fromDots(name, dot1, dot2);
      addObject(set, segment);
    }

    else {
      return ConstructResult.fail(OtherFailCause("Rays are not currently supported"));
    }


    return ConstructResult.success;
  }

}

class ConstructLinePerpendicular extends ConstructLineDirective {
  String name;
  String lineName;
  String dotName;

  ConstructLinePerpendicular(this.name, this.lineName, this.dotName);

  @override
  ConstructResult execute(GeometrySet set) {
    Line? baseLine = set.findLine(lineName);
    Dot? dot = set.findDot(dotName);

    if (baseLine == null) {
      return ConstructResult.fail(NoLineFailCause(lineName));
    }

    if (dot == null) {
      return ConstructResult.fail(NoDotFailCause(dotName));
    }

    Line line = baseLine.perpendicular(name, dot.point);
    addObject(set, line);

    return ConstructResult.success;
  }

}

class ConstructLineParallel extends ConstructLineDirective {
  String name;
  String lineName;
  String dotName;

  ConstructLineParallel(this.name, this.lineName, this.dotName);

  @override
  ConstructResult execute(GeometrySet set) {
    Line? baseLine = set.findLine(lineName);
    Dot? dot = set.findDot(dotName);

    if (baseLine == null) {
      return ConstructResult.fail(NoLineFailCause(lineName));
    }

    if (dot == null) {
      return ConstructResult.fail(NoDotFailCause(dotName));
    }

    Line line = baseLine.parallel(name, dot.point);
    addObject(set, line);

    return ConstructResult.success;
  }

}

class ConstructLineAngle extends ConstructLineDirective {
  String name;
  String lineName;
  String dotName;
  String sangle;

  ConstructLineAngle(this.name, this.lineName, this.dotName, this.sangle);

  @override
  ConstructResult execute(GeometrySet set) {
    Line? baseLine = set.findLine(lineName);
    Dot? dot = set.findDot(dotName);
    double? angle = sangle.interpretDouble();

    if (baseLine == null) {
      return ConstructResult.fail(NoLineFailCause(lineName));
    }

    if (dot == null) {
      return ConstructResult.fail(NoDotFailCause(dotName));
    }

    if (angle == null) {
      return ConstructResult.fail(NumberFailCause(sangle));
    }

    Line line = baseLine.rotate(name, dot.point, angle);
    addObject(set, line);

    return ConstructResult.success;
  }

}

class ConstructLinePerpendicularBisector extends ConstructLineDirective {
  String name;
  String segmentName;

  ConstructLinePerpendicularBisector(this.name, this.segmentName);

  @override
  ConstructResult execute(GeometrySet set) {
    Segment? segment = set.findSegment(segmentName);

    if (segment == null) {
      return ConstructResult.fail(NoSegmentFailCause(segmentName));
    }

    Line line = segment.getPerpendicularBisector(name);
    addObject(set, line);

    return ConstructResult.success;
  }

}

class ConstructLineTangent extends ConstructLineDirective {
  String name;
  String circleName;
  String dotName;

  ConstructLineTangent(this.name, this.circleName, this.dotName);

  @override
  ConstructResult execute(GeometrySet set) {
    Circle? circle = set.findCircle(circleName);
    Dot? dot = set.findDot(dotName);

    if (circle == null) {
      return ConstructResult.fail(NoCircleFailCause(circleName));
    }

    if (dot == null) {
      return ConstructResult.fail(NoDotFailCause(dotName));
    }

    Line? line = circle.tangeantLine(name, dot.point);
    if (line != null) {
      addObject(set, line);
    }

    return ConstructResult.success;
  }

}
