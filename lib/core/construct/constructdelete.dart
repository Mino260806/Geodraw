import 'package:geo_draw/core/construct/construct.dart';
import 'package:geo_draw/core/geometry_data/geometryobject.dart';
import 'package:geo_draw/core/geometry_data/geometryset.dart';

class ConstructDelete extends ConstructDirective {
  final GeometryObject object;

  bool removed = false;

  ConstructDelete(this.object);

  @override
  void undo(GeometrySet set) {
    if (removed) {
      set.addObject(object);
      removed = false;
    }
  }

  @override
  ConstructResult execute(GeometrySet set) {
    if (!removed) {
      set.removeObject(object);
      removed = true;
    }
    return ConstructResult.success;
  }
}