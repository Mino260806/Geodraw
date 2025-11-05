import 'package:geo_draw/core/geometry_data/circle.dart';
import 'package:geo_draw/core/geometry_data/dot.dart';
import 'package:geo_draw/core/geometry_data/geometryobject.dart';
import 'package:geo_draw/core/geometry_data/line.dart';
import 'package:geo_draw/core/geometry_data/segment.dart';
import 'package:geo_draw/core/geometry_data/style/geometrystyle.dart';
import 'package:json_annotation/json_annotation.dart';

class GeometryObjectConverter implements JsonConverter<GeometryObject, Map<String, dynamic>> {
  const GeometryObjectConverter();

  @override
  GeometryObject fromJson(Map<String, dynamic> json) =>
    switch (json["type"]) {
      "circle" => Circle.fromJson(json),
      "dot" => Dot.fromJson(json),
      "line" => Line.fromJson(json),
      "segment" => Segment.fromJson(json),
      _ => throw UnimplementedError(json["type"])
    };

  @override
  Map<String, dynamic> toJson(GeometryObject object) =>
    switch (object.runtimeType) {
      Circle => (object as Circle).toJson()..["type"]="circle",
      Dot => (object as Dot).toJson()..["type"]="dot",
      Line => (object as Line).toJson()..["type"]="line",
      Segment => (object as Segment).toJson()..["type"]="segment",
      _ => throw UnimplementedError(object.runtimeType.toString()),
    };
}