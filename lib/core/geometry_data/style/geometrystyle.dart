import 'package:flutter/material.dart';
import 'package:geo_draw/storage/json/color.dart';
import 'package:json_annotation/json_annotation.dart';

part 'geometrystyle.g.dart';

@JsonSerializable()
class GeometryStyle {
  @ColorConverter()
  Color? color;
  @ColorConverter()
  Color? textColor;
  double? strokeWidth;

  GeometryStyle();

  factory GeometryStyle.fromJson(Map<String, dynamic>? json) =>
      json == null? GeometryStyle(): _$GeometryStyleFromJson(json);

  Map<String, dynamic>? toJson() =>
      color == null && textColor == null && strokeWidth == null? null: _$GeometryStyleToJson(this);
}