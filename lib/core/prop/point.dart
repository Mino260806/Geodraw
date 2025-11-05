import 'dart:ui';

import 'package:geo_draw/core/tools/number.dart';
import 'package:json_annotation/json_annotation.dart';

part 'point.g.dart';

@JsonSerializable()
class Point {
  final double x;
  final double y;

  Point(this.x, this.y);

  Offset toOffset() {
    return Offset(x, y);
  }

  Point operator +(Point other) {
    return Point(x + other.x, y + other.y);
  }

  Point operator -(Point other) {
    return Point(x - other.x, y - other.y);
  }

  Point operator *(double other) {
    return Point(x * other, y * other);
  }

  Point operator /(double other) {
    return Point(x / other, y / other);
  }

  @override
  bool operator ==(Object other) {
    if (other is Point) {
      // return x == other.x && y == other.y;
      // overcome floating point error
      return x.eq(other.x) && y.eq(other.y);
    }
    return super == other;
  }

  @override
  String toString() {
    return "(${x.p()},${y.p()})";
  }

  factory Point.fromJson(Map<String, dynamic> json) => _$PointFromJson(json);

  Map<String, dynamic> toJson() => _$PointToJson(this);
}