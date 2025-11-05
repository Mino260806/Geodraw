import 'package:flutter/material.dart';
import 'package:geo_draw/core/geometry_data/geometryobject.dart';
import 'package:geo_draw/draw/canvastransform.dart';

import 'painttheme.dart';

class CanvasProperties {
  final Size size;
  final PaintTheme theme;
  Paint get shadowPaint => theme.shadowPaint;
  Paint get drawPaint => theme.drawPaint;
  TextStyle get textStyle => theme.textStyle;

  final CanvasTransform transform;
  final GeometryObject? hoveredObject;

  CanvasProperties(this.size, this.theme, this.transform, this.hoveredObject);
}