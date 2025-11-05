import 'dart:math';

import 'package:geo_draw/core/geometry_data/geometryobject.dart';
import 'package:geo_draw/core/geometry_data/line.dart';
import 'package:geo_draw/core/geometry_data/segment.dart';
import 'package:geo_draw/core/geometry_data/style/geometrystyle.dart';
import 'package:geo_draw/core/geometry_data/triangle.dart';
import 'package:geo_draw/core/prop/point.dart';
import 'package:geo_draw/draw/canvas/canvasdot.dart';
import 'package:geo_draw/draw/canvas/canvasshape.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dot.g.dart';

@JsonSerializable()
class Dot extends GeometryObject {
  static final RegExp nameRegex = RegExp(r"^\w([^\\\w]|\d)*$");

  final Point point;
  final String name;

  Dot(this.name, this.point);

  @override
  CanvasShape toCanvasShape() {
    return CanvasDot(this);
  }

  static Dot completeTriangle(String name, Dot dot1, Dot dot2, Triangle triangle,
      { bool direct=true }) {
    double x1 = dot1.point.x;
    double x2 = dot2.point.x;
    double y1 = dot1.point.y;
    double y2 = dot2.point.y;

    double r1 = triangle.side2!;
    double r2 = triangle.side3!;

    double d = Segment.getDistance(dot1.point, dot2.point);
    double l = (r1 * r1 - r2 * r2 + d * d) / (2 * d);
    double h = sqrt(r1 * r1 - l * l);

    double x, y;
    if (direct) {
      x = (l/d) * (x2 - x1) - (h/d) * (y2 - y1) + x1;
      y = (l/d) * (y2 - y1) + (h/d) * (x2 - x1) + y1;
    } else {
      x = (l/d) * (x2 - x1) + (h/d) * (y2 - y1) + x1;
      y = (l/d) * (y2 - y1) - (h/d) * (x2 - x1) + y1;
    }

    return Dot(name, Point(x, y));
  }

  @override
  bool operator ==(Object other) {
    if (other is Dot) {
      return other.point == point;
    } else {
      return super == other;
    }
  }

  @override
  bool isHovering(Point point, double tolerance) {
    double distance = Segment.getDistance(point, this.point);
    return distance < tolerance;
  }

  @override
  String getName() => name;

  @override
  String getRepresentation() => point.toString();

  static bool isValidName(String name) {
    return nameRegex.hasMatch(name);
  }

  factory Dot.fromJson(Map<String, dynamic> json) => _$DotFromJson(json);

  Map<String, dynamic> toJson() => _$DotToJson(this);
}