import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geo_draw/core/geometry_data/dot.dart';
import 'package:geo_draw/draw/canvas/canvasshape.dart';
import 'package:geo_draw/draw/canvasprop.dart';

class CanvasDot extends CanvasShape {
  final Dot dot;

  CanvasDot(this.dot);

  @override
  void draw(Canvas canvas, CanvasProperties prop) {
    Color myColor = dot.style.textColor ?? prop.textStyle.color!;
    Paint drawPaint = Paint()
      ..color = myColor
      ..style = PaintingStyle.fill;
    Paint strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    TextStyle textStyle = prop.textStyle.copyWith(color: myColor);

    final Offset center = prop.transform.transform(dot.point);
    if (prop.hoveredObject == dot) {
      canvas.drawCircle(center, 8, prop.shadowPaint);
    }
    canvas.drawCircle(center, 6, strokePaint);
    canvas.drawCircle(center, 5, drawPaint);

    final textSpan = TextSpan(text: dot.name.toUpperCase(), style: textStyle);
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: 0, maxWidth: prop.size.width);

    final offset = Offset(center.dx + 5, center.dy - 30);
    textPainter.paint(canvas, offset);
  }
}