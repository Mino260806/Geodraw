import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geo_draw/core/prop/point.dart';
import 'package:geo_draw/core/tools/number.dart';
import 'package:geo_draw/draw/canvas/canvasshape.dart';
import 'package:geo_draw/draw/canvasprop.dart';

class CanvasGrid extends CanvasObject {
  bool showAxes = false;
  bool showLines = false;

  void draw(Canvas canvas, CanvasProperties prop) {
    if (showAxes == false) {
      return;
    }

    Offset origin = prop.transform.transform(Point(0, 0));

    final Paint axesPaint = Paint()
      ..strokeWidth = 1
      ..color = Colors.black54;
    final Paint linesPaint = Paint()
      ..strokeWidth = 1
      ..color = Colors.black12;
    canvas.drawLine(Offset(0, origin.dy), Offset(prop.size.width, origin.dy), axesPaint);
    canvas.drawLine(Offset(origin.dx, 0), Offset(origin.dx, prop.size.height), axesPaint);

    double coeff = prop.transform.untransformDistance(
        max(prop.size.width, prop.size.height) / 10).roundScale();
    double scaledCoeff = prop.transform.transformDistance(coeff);

    Offset beginOffset;
    beginOffset = Offset(origin.dx % scaledCoeff, origin.dy);
    int ix = (-origin.dx / scaledCoeff).ceil();
    for (Offset offset=beginOffset;offset.dx<=prop.size.width;offset=offset.translate(scaledCoeff, 0)) {
      if (ix != 0) {
        if (showLines) {
          canvas.drawLine(Offset(offset.dx, 0), Offset(offset.dx, prop.size.height), linesPaint);
        }
        canvas.drawLine(offset.translate(0, 5), offset.translate(0, -5), axesPaint);

        final textSpan = TextSpan(text: (ix * coeff).display(), style: TextStyle(fontSize: 16, color: axesPaint.color));
        final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
        textPainter.layout(minWidth: 0, maxWidth: prop.size.width);

        final textOffset = offset.translate(-textPainter.size.width/2, 10);
        textPainter.paint(canvas, textOffset);
      }

      ix++;
    }

    beginOffset = Offset(origin.dx, origin.dy % scaledCoeff);
    int iy = (-origin.dy / scaledCoeff).ceil();
    for (Offset offset=beginOffset;offset.dy<=prop.size.height;offset=offset.translate(0, scaledCoeff)) {
      if (iy != 0) {
        if (showLines) {
          canvas.drawLine(Offset(0, offset.dy), Offset(prop.size.width, offset.dy), linesPaint);
        }
        canvas.drawLine(offset.translate(5, 0), offset.translate(-5, 0), axesPaint);


        final textSpan = TextSpan(text: (-iy * coeff).display(), style: TextStyle(fontSize: 16, color: axesPaint.color));
        final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
        textPainter.layout(minWidth: 0, maxWidth: prop.size.width);

        final textOffset = offset.translate(10, -textPainter.size.height/2);
        textPainter.paint(canvas, textOffset);
      }

      iy++;
    }
  }

}