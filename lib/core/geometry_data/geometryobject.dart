import 'package:geo_draw/core/geometry_data/style/geometrystyle.dart';
import 'package:geo_draw/core/prop/point.dart';
import 'package:geo_draw/draw/canvas/canvasshape.dart';
import 'package:json_annotation/json_annotation.dart';

abstract class GeometryObject {
  GeometryStyle? _style;
  @JsonKey(toJson: styleToJson)
  GeometryStyle get style {
    _style ??= GeometryStyle();
    return _style!;
  }
  set style(newStyle) {
    _style = newStyle;
  }
  String get name => getName();
  String get repr => getRepresentation();

  GeometryObject();

  CanvasShape toCanvasShape();
  bool isHovering(Point point, double tolerance) => false;
  String getName();
  String getRepresentation() {
    return toString();
  }

  static Map<String, dynamic>? styleToJson(GeometryStyle style) => style.toJson();
}
