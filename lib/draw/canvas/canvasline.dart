import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geo_draw/core/geometry_data/line.dart';
import 'package:geo_draw/core/prop/point.dart';
import 'package:geo_draw/draw/canvas/canvasshape.dart';
import 'package:geo_draw/draw/canvasprop.dart';

class CanvasLine extends CanvasShape {
  final Line line;

  CanvasLine(this.line);

  List<Offset> computeOffsets(CanvasProperties prop) {
    final Offset origin = prop.transform.transform(Point(0, 0));

    double ox = origin.dx;
    double oy = origin.dy;
    double width = prop.size.width;
    double height = prop.size.height;

    double x1=0, x2=0, y1=0, y2=0;
    if (line.a == 0) {
      double yintercept = - line.c / line.b;
      x1 = 0;
      y1 = oy - yintercept * prop.transform.scale;
      x2 = width;
      y2 = y1;
    }

    else if (line.b == 0) {
      double xintercept = - line.c / line.a;
      x1 = ox + xintercept * prop.transform.scale;
      y1 = 0;
      x2 = x1;
      y2 = height;
    }

    else {
      double slope = - line.a / line.b;
      double yintercept = - line.c / line.b;

      oy -= yintercept * prop.transform.scale;

      if (slope > 0) {
        double dx1 = oy / slope;
        double dy1 = (width - ox) * slope;
        double dx2 = (height - oy) / slope;
        double dy2 = ox * slope;
        if (ox + dx1 <= width) {
          x1 = ox + dx1;
          y1 = 0;
        } else {
          x1 = width;
          y1 = oy - dy1;
        }
        if (oy + dy2 <= height) {
          x2 = 0;
          y2 = oy + dy2;
        } else {
          x2 = ox - dx2;
          y2 = height;
        }
      }
      else {
        double dx1 = oy / slope;
        double dy1 = ox * slope;
        double dx2 = (height - oy) / slope;
        double dy2 = (width - ox) * slope;
        if (ox + dx1 >= 0) {
          x1 = ox + dx1;
          y1 = 0;
        } else {
          x1 = 0;
          y1 = oy + dy1;
        }
        if (oy - dy2 <= height) {
          x2 = width;
          y2 = oy - dy2;
        } else {
          x2 = ox - dx2;
          y2 = height;
        }
      }
    }


    List<Offset> offsets;

    if (x1 < x2) {
      offsets = [Offset(x1, y1), Offset(x2, y2)];
    } else if (x1 == x2) {
      if (y1 < y2) {
        offsets = [Offset(x1, y1), Offset(x2, y2)];
      }
      else {
        offsets = [Offset(x2, y2), Offset(x1, y1)];
      }
    } else {
      offsets = [Offset(x2, y2), Offset(x1, y1)];
    }
    return offsets;
  }

  @override
  void draw(Canvas canvas, CanvasProperties prop) {
    Color myColor = line.style.color ?? prop.drawPaint.color;
    Color myTextColor = line.style.textColor ?? prop.textStyle.color!;
    Paint drawPaint = Paint()
      ..color = myColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = line.style.strokeWidth?? prop.drawPaint.strokeWidth;
    Paint shadowPaint = Paint()
      ..color = prop.shadowPaint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = (line.style.strokeWidth?? prop.drawPaint.strokeWidth) + 6;
    TextStyle textStyle = prop.textStyle.copyWith(
      fontSize: prop.textStyle.fontSize! * 1.4,
      color: myTextColor,
    );

    List<Offset> offsets = computeOffsets(prop);
    if (prop.hoveredObject == line) {
      canvas.drawLine(offsets[0], offsets[1], shadowPaint);
    }
    canvas.drawLine(offsets[0], offsets[1], drawPaint);
  }
}