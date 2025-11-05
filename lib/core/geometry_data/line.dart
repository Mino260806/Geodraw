import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:geo_draw/core/geometry_data/circle.dart';
import 'package:geo_draw/core/geometry_data/dot.dart';
import 'package:geo_draw/core/geometry_data/geometryobject.dart';
import 'package:geo_draw/core/geometry_data/style/geometrystyle.dart';
import 'package:geo_draw/core/prop/point.dart';
import 'package:geo_draw/core/tools/number.dart';
import 'package:geo_draw/core/tools/equation.dart';
import 'package:geo_draw/draw/canvas/canvasline.dart';
import 'package:geo_draw/draw/canvas/canvasshape.dart';
import 'package:json_annotation/json_annotation.dart';

part 'line.g.dart';

@JsonSerializable()
class Line extends GeometryObject {
  final String name;

  // ax + by + c = 0
  final double a;
  final double b;
  final double c;

  double get slope => -a/b;
  double get invslope => -b/a;
  double get yintercept => -c/b;
  double get xintercept => -c/a;

  Line(this.name, this.a, this.b, this.c);
  factory Line.fromDots(String? name, Dot dot1, Dot dot2) {
    name ??= "${dot1.name}${dot2.name}";
    return Line.fromPoints(name, dot1.point, dot2.point);
  }

  factory Line.fromPoints(String name, Point point1, Point point2) {
    double x1 = point1.x;
    double x2 = point2.x;
    double y1 = point1.y;
    double y2 = point2.y;
    double a = y1-y2;
    double b = x2-x1;
    double c = x1*y2-x2*y1;
    return Line(name, a, b, c);
  }

  @protected
  static List<double> coeffFromPoints(Point p1, Point p2) {
    return [p1.y-p2.y, p2.x-p1.x, p1.x*p2.y-p2.x*p1.y];
  }

  @override
  bool operator ==(Object other) {
    if (other is Line) {
      return (a * other.b).eq(other.a * b)
          && (a * other.c).eq(other.c * a)
          && (b * other.c).eq(other.b * c);

    }
    return super == other;
  }

  @override
  CanvasShape toCanvasShape() {
    return CanvasLine(this);
  }

  Line perpendicular(String name, Point p) {
    return Line(name, b, -a, -b * p.x + a * p.y);
  }

  Line parallel(String name, Point p) {
    return Line(name, a, b, -a * p.x - b * p.y);
  }

  Line rotate(String name, Point p, double angle) {
    double cost, sint;
    cost = cos(angle);
    sint = sin(angle);
    double na = a * cost + b * sint;
    double nb = b * cost - a * sint;
    double nc = c;
    return Line(name, na, nb, nc);
  }
  
  Point? intersectLine(Line other) {
    if ((a * other.b).eq(b * other.a)) {
      // parallel
      return null;
    }
    return confirmBelongs(Point(
      (b * other.c - c * other.b) / (a * other.b - b * other.a),
      (c * other.a - a * other.c) / (a * other.b - b * other.a),
    ));
  }
  
  List<Point?> intersectCircle(Circle other) {
    https://math.stackexchange.com/a/228855/912859

    List<Point?> result = [];

    double p = other.center.x;
    double q = other.center.y;
    double r = other.radius;
    if (b != 0) {
      double m = slope;
      double c = yintercept;
      double A = m * m + 1;
      double B = 2 * (m * (c - q) - p);
      double C = q * q - r * r + p * p - 2 * c * q + c * c;

      var equation = QuadraticEquation(A, B, C);
      List<double> solutions = equation.solve();

      if (solutions.length >= 2) {
        result.add(Point(solutions[1], m * solutions[1] + c));
      }
      if (solutions.isNotEmpty) {
        result.add(Point(solutions[0], m * solutions[0] + c));
      }
    }
    else {
      double k = xintercept;

      double B = - 2 * q;
      double C = p * p + q * q - r * r - 2 * k * p + k * k;

      var equation = QuadraticEquation(1, B, C);
      List<double> solutions = equation.solve();

      if (solutions.length >= 2) {
        result.add(Point(xintercept, solutions[1]));
      }
      if (solutions.isNotEmpty) {
        result.add(Point(xintercept, solutions[0]));
      }
    }
    while (result.length < 2) {
      result.add(null);
    }
    return confirmBelongsList(result);
  }

  double pointDistance(Point point) {
    return (a * point.x + b * point.y + c).abs() / sqrt(a*a + b*b);
  }

  @override
  bool isHovering(Point point, double tolerance) {
    return pointDistance(point) < tolerance;
  }

  @override
  String getName() => name;

  @override
  String getRepresentation() {
    List<String> reprList = [];
    if (a != 0) {
      reprList.add("${a.p()}x");
    }
    if (b != 0) {
      if (a == 0) {
        reprList.add("${b.p()}y");
      } else {
        reprList.add("${b<0? '- ': '+ '}${b.p().abs()}y");
      }
    }
    if (c != 0) {
      reprList.add("${c<0? '- ': '+ '}${c.p().abs()}");
    }

    return "${reprList.join(" ")} = 0";
  }

  /*
  * The point is guaranteed to be on the line,
  * but we check if it belongs to the ray / segment
  */
  bool pointBelongs(Point p) => true;

  Point? confirmBelongs(Point? p) => p != null && pointBelongs(p) ? p: null;
  
  List<Point?> confirmBelongsList(List<Point?> plist) => plist.map((p) => confirmBelongs(p)).toList();

  static bool areAligned(Point p1, Point p2, Point p3)
      => (p1.x * (p2.y - p3.y) + p2.x * (p3.y - p1.y) + p3.x * (p1.y - p2.y)).eq(0);
  
  factory Line.fromJson(Map<String, dynamic> json) => _$LineFromJson(json);

  Map<String, dynamic> toJson() => _$LineToJson(this);
}
