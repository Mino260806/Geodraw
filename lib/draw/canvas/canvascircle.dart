import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geo_draw/core/geometry_data/circle.dart';
import 'package:geo_draw/draw/canvas/canvasshape.dart';
import 'package:geo_draw/draw/canvasprop.dart';
import 'package:google_fonts/google_fonts.dart';

class CanvasCircle extends CanvasShape {
  final Circle circle;

  CanvasCircle(this.circle);

  @override
  void draw(Canvas canvas, CanvasProperties prop) {
    Color myColor = circle.style.color ?? prop.drawPaint.color;
    Color myTextColor = circle.style.textColor ?? prop.textStyle.color!;
    Paint drawPaint = Paint()
      ..color = myColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = circle.style.strokeWidth?? prop.drawPaint.strokeWidth;
    Paint shadowPaint = Paint()
      ..color = prop.shadowPaint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = (circle.style.strokeWidth?? prop.drawPaint.strokeWidth) + 6;
    TextStyle textStyle = prop.textStyle.copyWith(
      fontSize: prop.textStyle.fontSize! * 1.4,
      fontFamily: GoogleFonts.yellowtail().fontFamily,
      color: myTextColor,
    );

    final Offset center = prop.transform.transform(circle.center);
    if (prop.hoveredObject == circle) {
      canvas.drawCircle(center, circle.radius * prop.transform.scale, shadowPaint);
    }
    canvas.drawCircle(center, circle.radius * prop.transform.scale, drawPaint);

    final textSpan = TextSpan(text: circle.name.toUpperCase(), style: textStyle);
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: 0, maxWidth: prop.size.width);

    final offset = Offset(center.dx + circle.radius * prop.transform.scale * sqrt(2) / 2,
        center.dy - circle.radius * prop.transform.scale * sqrt(2) / 2 - prop.textStyle.fontSize! * 1.4 - 5);
    textPainter.paint(canvas, offset);
  }
}