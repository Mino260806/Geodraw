import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geo_draw/core/geometry_data/dot.dart';
import 'package:geo_draw/core/geometry_data/segment.dart';
import 'package:geo_draw/draw/canvas/canvasshape.dart';
import 'package:geo_draw/draw/canvasprop.dart';

class CanvasSegment extends CanvasShape {
  final Segment segment;

  CanvasSegment(this.segment);

  @override
  void draw(Canvas canvas, CanvasProperties prop) {
    Color myColor = segment.style.color ?? prop.drawPaint.color;
    Color myTextColor = segment.style.textColor ?? prop.textStyle.color!;
    Paint drawPaint = Paint()
      ..color = myColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = segment.style.strokeWidth?? prop.drawPaint.strokeWidth;
    Paint shadowPaint = Paint()
      ..color = prop.shadowPaint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = (segment.style.strokeWidth?? prop.drawPaint.strokeWidth) + 6;

    final Offset p1 = prop.transform.transform(segment.endpoint1);
    final Offset p2 = prop.transform.transform(segment.endpoint2);
    if (prop.hoveredObject == segment) {
      canvas.drawLine(p1, p2, shadowPaint);
    }
    canvas.drawLine(p1, p2, drawPaint);
  }
}