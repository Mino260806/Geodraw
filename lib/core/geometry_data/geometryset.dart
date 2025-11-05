import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:geo_draw/core/geometry_data/circle.dart';
import 'package:geo_draw/core/geometry_data/dot.dart';
import 'package:geo_draw/core/geometry_data/geometryobject.dart';
import 'package:geo_draw/core/geometry_data/line.dart';
import 'package:geo_draw/core/geometry_data/segment.dart';
import 'package:geo_draw/core/name/segment.dart';
import 'package:geo_draw/core/prop/point.dart';
import 'package:geo_draw/storage/json/geometryobject.dart';
import 'package:geo_draw/storage/manager.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:get_storage/get_storage.dart';

part 'geometryset.g.dart';

@JsonSerializable()
@GeometryObjectConverter()
class GeometrySet extends ChangeNotifier {
  bool showAxes = true;
  bool showLines = true;
  List<GeometryObject> objects = [];

  GeometrySet();

  String? _name;
  @JsonKey(includeToJson: false, includeFromJson: false)
  String? get name => _name;
  set name(String? newName) {
    _name = newName;
    isSaved = false;
  }

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool isSaved = false;

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool justLoaded = false;
  @JsonKey(includeToJson: false, includeFromJson: false)
  String? pendingLoad;
  @JsonKey(includeToJson: false, includeFromJson: false)
  String? lastAddingError;
  bool addObject(GeometryObject object) {
    if (objects.contains(object)) {
      lastAddingError = "Object already present";
      return false;
    }
    if (object.name.isEmpty) {
      lastAddingError = "Object name cannot be empty";
      return false;
    }
    if (containsName(object.name)) {
      lastAddingError = "Another object has the same name";
      return false;
    }
    objects.add(object);

    lastAddingError = null;
    isSaved = false;
    return true;
  }

  void removeObject(GeometryObject object) {
    objects.remove(object);
    isSaved = false;
  }

  void invalidate() {
    notifyListeners();
  }

  Dot? findDot(String name) {
    try {
      Dot dot = objects.firstWhere((object) => object is Dot && object.name.toUpperCase() == name.toUpperCase()) as Dot;
      return dot;
    } on StateError catch (e) {
      return null;
    }
  }

  Line? findLine(String name) {
    if (name.isEmpty) return null;

    var segmentNameMatcher = SegmentNameMatcher(name);
    SegmentName? segmentName = segmentNameMatcher.match();
    if (segmentName != null) {
      Dot? dot1 = findDot(segmentName.dot1);
      Dot? dot2 = findDot(segmentName.dot2);
      if (dot1 != null && dot2 != null) {
        return Line.fromDots(name, dot1, dot2);
      }
    }

    try {
      Line line = objects.firstWhere((object) => object is Line && object.name.toUpperCase() == name.toUpperCase()) as Line;
      return line;
    } on StateError catch (e) {
      return null;
    }
  }

  Segment? findSegment(String name) {
    if (name.isEmpty) return null;

    var segmentNameMatcher = SegmentNameMatcher(name);
    SegmentName? segmentName = segmentNameMatcher.match();
    if (segmentName != null) {
      Dot? dot1 = findDot(segmentName.dot1);
      Dot? dot2 = findDot(segmentName.dot2);
      if (dot1 != null && dot2 != null) {
        return Segment.fromDots(name, dot1, dot2);
      }
    }

    return null;
  }

  Circle? findCircle(String name) {
    if (name.isEmpty) return null;

    try {
      Circle circle = objects.firstWhere((object) => object is Circle && object.name.toUpperCase() == name.toUpperCase()) as Circle;
      return circle;
    } on StateError catch (e) {
      return null;
    }
  }

  bool containsName(String name) {
    return objects.any((object) => object.name == name);
  }

  void reset({bool ignoreUnsaved = false}) {
    load("", ignoreUnsaved: ignoreUnsaved);
  }

  void clear() {
    objects.clear();
  }
  
  GeometryObject? findHoveredObject(Point point, double tolerance) {
    for (GeometryObject object in objects) {
      if (object is Dot) {
        if (object.isHovering(point, tolerance)) {
          return object;
        }
      }
    }
    for (GeometryObject object in objects) {
      if (object is! Dot) {
        if (object.isHovering(point, tolerance)) {
          return object;
        }
      }
    }
    return null;
  }

  factory GeometrySet.fromJson(Map<String, dynamic> json) => _$GeometrySetFromJson(json);

  Map<String, dynamic> toJson() => _$GeometrySetToJson(this);

  bool save() {
    if (name == null) {
      return false;
    }
    StorageManager().drawings.write(name!, json.encode(toJson()));
    StorageManager().setLastOpened(name!);
    isSaved = true;
    return true;
  }

  bool load(String name, {bool ignoreUnsaved = false}) {
    if (!ignoreUnsaved && !isSaved) {
      pendingLoad = name;

      notifyListeners();
      return false;
    }

    objects.clear();
    if (name.isNotEmpty) {
      GeometrySet newSet = GeometrySet.fromJson(json.decode(StorageManager().drawings.read(name)));
      objects.addAll(newSet.objects);
      this.name = name;

      StorageManager().setLastOpened(name);
    }
    else {
      // reset
      this.name = null;
      // Keep the same showAxes and showGrid
      StorageManager().setLastOpened("");
    }
    pendingLoad = null;
    isSaved = true;
    justLoaded = true;
    invalidate();

    return true;
  }

  bool loadLastOpened() {
    String? name = StorageManager().getLastOpened();
    if (name == null) {
      return false;
    }

    return load(name, ignoreUnsaved: true);
  }

}
