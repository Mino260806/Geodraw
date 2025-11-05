import 'dart:ui';

import 'package:geo_draw/core/geometry_data/geometryobject.dart';
import 'package:geo_draw/core/geometry_data/geometryset.dart';
import 'package:geo_draw/draw/canvas/canvasdot.dart';
import 'package:geo_draw/draw/canvas/canvasshape.dart';
import 'package:geo_draw/draw/canvas/visual/grid.dart';
import 'package:geo_draw/draw/canvasprop.dart';

class CanvasSet extends CanvasShape {
  List<CanvasShape> shapes = [];

  CanvasGrid grid = CanvasGrid();

  void addShape(CanvasShape shape) {
    shapes.add(shape);
  }

  void addSet(GeometrySet set) {
    for (var object in set.objects) {
      addShape(object.toCanvasShape());
    }
    grid.showAxes = set.showAxes;
    grid.showLines = set.showLines;
  }
  
  @override
  void draw(Canvas canvas, CanvasProperties properties) {
    grid.draw(canvas, properties);

    for (var shape in shapes) {
      if (shape is! CanvasDot) {
        shape.draw(canvas, properties);
      }
    }
    for (var shape in shapes) {
      if (shape is CanvasDot) {
        shape.draw(canvas, properties);
      }
    }
  }
  
}