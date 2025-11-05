import 'dart:math';

import 'package:geo_draw/core/geometry_data/dot.dart';
import 'package:geo_draw/core/geometry_data/geometryobject.dart';
import 'package:geo_draw/core/geometry_data/line.dart';
import 'package:geo_draw/core/geometry_data/segment.dart';
import 'package:geo_draw/core/geometry_data/style/geometrystyle.dart';
import 'package:geo_draw/core/geometry_data/triangle.dart';
import 'package:geo_draw/core/prop/point.dart';
import 'package:geo_draw/core/tools/number.dart';
import 'package:geo_draw/draw/canvas/canvascircle.dart';
import 'package:geo_draw/draw/canvas/canvasdot.dart';
import 'package:geo_draw/draw/canvas/canvasshape.dart';
import 'package:decimal/decimal.dart';
import 'package:geo_draw/draw/canvastransform.dart';
import 'package:geo_draw/ui/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'circle.g.dart';

@JsonSerializable()
class Circle extends GeometryObject {
  final String name;
  final Point center;
  final double radius;

  Circle(this.name, this.center, this.radius);

  factory Circle.fromDiameter(String name, Point p1, Point p2) {
    return Circle(name, Segment.getMidPoint(p1, p2), Segment.getDistance(p1, p2) / 2);
  }

  factory Circle.fromPoints(String name, Point p1, Point p2, Point p3) {
    Line perpBis1 = Segment.fromPoints("", p1, p2).getPerpendicularBisector("");
    Line perpBis2 = Segment.fromPoints("", p1, p3).getPerpendicularBisector("");
    Point center = perpBis1.intersectLine(perpBis2)!;
    double radius = Segment.getDistance(center, p1);
    return Circle(name, center, radius);
  }

  @override
  CanvasShape toCanvasShape() {
    return CanvasCircle(this);
  }

  @override
  bool operator ==(Object other) {
    if (other is Circle) {
      return other.center == center && other.radius.eq(radius);
    } else {
      return super == other;
    }
  }

  Line? tangeantLine(String name, Point p) {
    double dx = p.x - center.x;
    double dy = p.y - center.y;

    // TODO find better way
    // Check p belongs to the circle
    if ((dx * dx + dy * dy).eq(radius * radius)) {
      print("point belongs");
      return Line(name, dx, dy, -dx * p.x - dy * p.y);
    }
    else {
      print("point belongs not");
    }
    return null;
  }

  List<Point?> intersect(Circle c2) {
    double x1 = center.x;
    double x2 = c2.center.x;
    double y1 = center.y;
    double y2 = c2.center.y;

    double r1 = radius;
    double r2 = c2.radius;

    double d = Segment.getDistance(center, c2.center);
    double l = (r1 * r1 - r2 * r2 + d * d) / (2 * d);

    if (r1 * r1 - l * l <= 0) {
      return [null, null];
    }
    double h = sqrt(r1 * r1 - l * l);

    double rx1, ry1, rx2, ry2;
    rx1 = (l/d) * (x2 - x1) - (h/d) * (y2 - y1) + x1;
    ry1 = (l/d) * (y2 - y1) + (h/d) * (x2 - x1) + y1;
    rx2 = (l/d) * (x2 - x1) + (h/d) * (y2 - y1) + x1;
    ry2 = (l/d) * (y2 - y1) - (h/d) * (x2 - x1) + y1;

    return [
      Point(rx1, ry1),
      Point(rx2, ry2),
    ];
  }

  @override
  bool isHovering(Point point, double tolerance) {
    double distance = Segment.getDistance(point, center);
    return distance < radius + tolerance
        && radius - tolerance < distance;
  }

  @override
  String getName() => name;

  @override
  String getRepresentation() => "$center / ${radius.p()}";

  factory Circle.fromJson(Map<String, dynamic> json) => _$CircleFromJson(json);

  Map<String, dynamic> toJson() => _$CircleToJson(this);
}