import 'package:flutter/cupertino.dart';
import 'package:geo_draw/core/geometry_data/geometryobject.dart';

class CanvasSelection extends ChangeNotifier {
  GeometryObject? object;
  Offset? location;

  void setObject(GeometryObject? object, Offset? location) {
    this.object = object;
    this.location = location;
    notifyListeners();
  }
}