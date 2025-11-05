import 'dart:math';

import 'package:geo_draw/core/geometry_data/dot.dart';
import 'package:geo_draw/core/geometry_data/geometryobject.dart';
import 'package:geo_draw/core/geometry_data/line.dart';
import 'package:geo_draw/core/geometry_data/style/geometrystyle.dart';
import 'package:geo_draw/core/prop/point.dart';
import 'package:geo_draw/draw/canvas/canvassegment.dart';
import 'package:geo_draw/draw/canvas/canvasshape.dart';
import 'package:json_annotation/json_annotation.dart';

part 'segment.g.dart';

// @JsonSerializable()
// class Segment extends GeometryObject {
//   final Dot dot1;
//   final Dot dot2;
//
//   Segment(this.dot1, this.dot2);
//
//   @override
//   CanvasShape toCanvasShape() {
//     return CanvasSegment(this);
//   }
//
//   double getLength() => getDistance(dot1.point, dot2.point);
//
//   Point getMidPoint() => (dot1.point + dot2.point) / 2;
//
//   Line getPerpendicularBisector(String name) {
//     return Line.fromDots("", dot1, dot2).perpendicular(name, (dot1.point + dot2.point) / 2);
//   }
//
//   @override
//   bool operator ==(Object other) {
//     if (other is Segment) {
//       return (other.dot1 == dot1 && other.dot2 == dot2) ||
//           (other.dot1 == dot2 && other.dot2 == dot1);
//     } else {
//       return super == other;
//     }
//   }
//
//   static double getDistance(Point point1, Point point2) => sqrt(
//       (point1.x - point2.x) * (point1.x - point2.x)
//           + (point1.y - point2.y) * (point1.y - point2.y)
//   );
//
//   @override
//   String getName() => "$dot1$dot2";
//
//   @override
//   String getRepresentation() => getName();
//
//   factory Segment.fromJson(Map<String, dynamic> json) => _$SegmentFromJson(json);
//
//   Map<String, dynamic> toJson() => _$SegmentToJson(this);
// }

@JsonSerializable()
class Segment extends Line {
  // refer to x coordinates if b != 0 otherwise y coordinates
  final double endpointmin;
  final double endpointmax;

  Point? _endpoint1;
  Point? _endpoint2;
  Point get endpoint1 {
    _endpoint1 ??= b != 0? Point(endpointmin, endpointmin * slope + yintercept): Point(xintercept, endpointmin);
    return _endpoint1!;
  }
  Point get endpoint2 {
    _endpoint2 ??= b != 0? Point(endpointmax, endpointmax * slope + yintercept): Point(xintercept, endpointmax);
    return _endpoint2!;
  }

  double get distance => getDistance(endpoint1, endpoint2);
  Point get midPoint => getMidPoint(endpoint1, endpoint2);

  Segment(super.name, super.a, super.b, super.c, this.endpointmin, this.endpointmax);

  factory Segment.fromDots(String? name, Dot dot1, Dot dot2) {
    name ??= "${dot1.name}${dot2.name}";
    return Segment.fromPoints(name, dot1.point, dot2.point);
  }

  factory Segment.fromPoints(String name, Point p1, Point p2) {
    List<double> coeff = Line.coeffFromPoints(p1, p2);

    double endpointmin;
    double endpointmax;
    Point endpoint1;
    Point endpoint2;
    if (coeff[1] != 0) { // b != 0
      if (p1.x < p2.x) {
        endpointmin = p1.x;
        endpointmax = p2.x;
        endpoint1 = p1;
        endpoint2 = p2;
      }
      else {
        endpointmax = p1.x;
        endpointmin = p2.x;
        endpoint1 = p2;
        endpoint2 = p1;
      }
    }
    else {
      if (p1.y < p2.y) {
        endpointmin = p1.y;
        endpointmax = p2.y;
        endpoint1 = p1;
        endpoint2 = p2;
      }
      else {
        endpointmin = p2.y;
        endpointmax = p1.y;
        endpoint1 = p2;
        endpoint2 = p1;
      }
    }

    Segment segment = Segment(name, coeff[0], coeff[1], coeff[2], endpointmin, endpointmax);
    segment._endpoint1 = endpoint1;
    segment._endpoint2 = endpoint2;
    return segment;
  }

  @override
  bool pointBelongs(Point p) {
    if (!super.pointBelongs(p)) {
      return false;
    }

    if (b != 0) {
      return p.x >= endpointmin && p.x <= endpointmax;
    }
    else {
      return p.y >= endpointmin && p.y <= endpointmax;
    }
  }

  Line getPerpendicularBisector(String name) {
    return perpendicular(name, (endpoint1 + endpoint2) / 2);
  }

  @override
  bool operator ==(Object other) {
    if (other is Segment) {
      return (other.endpoint1 == endpoint1 && other.endpoint2 == endpoint2);
    } else {
      return super == other;
    }
  }

  static Point getMidPoint(Point p1, Point p2) => (p1 + p2) / 2;

  static double getDistance(Point point1, Point point2) => sqrt(
      (point1.x - point2.x) * (point1.x - point2.x)
          + (point1.y - point2.y) * (point1.y - point2.y)
  );

  @override
  bool isHovering(Point point, double tolerance) {
    if (!super.isHovering(point, tolerance)) {
      return false;
    }

    if (b != 0) {
      return endpointmin <= point.x && point.x <= endpointmax;
    }
    else {
      return endpointmin <= point.y && point.y <= endpointmax;
    }
  }

  @override
  CanvasShape toCanvasShape() {
    return CanvasSegment(this);
  }

  factory Segment.fromJson(Map<String, dynamic> json) => _$SegmentFromJson(json);

  Map<String, dynamic> toJson() => _$SegmentToJson(this);
}

