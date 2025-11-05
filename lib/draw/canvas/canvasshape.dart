import 'dart:ui';

import 'package:geo_draw/draw/canvasprop.dart';

abstract class CanvasObject {
  void draw(Canvas canvas, CanvasProperties properties);
}

abstract class CanvasShape extends CanvasObject {
  bool isHovered = false;
  void setHovered(bool hovered) {
    isHovered = hovered;
  }

}