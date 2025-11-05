// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geometrystyle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeometryStyle _$GeometryStyleFromJson(Map<String, dynamic> json) =>
    GeometryStyle()
      ..color = _$JsonConverterFromJson<int, Color>(
          json['color'], const ColorConverter().fromJson)
      ..textColor = _$JsonConverterFromJson<int, Color>(
          json['textColor'], const ColorConverter().fromJson)
      ..strokeWidth = (json['strokeWidth'] as num?)?.toDouble();

Map<String, dynamic> _$GeometryStyleToJson(GeometryStyle instance) =>
    <String, dynamic>{
      'color': _$JsonConverterToJson<int, Color>(
          instance.color, const ColorConverter().toJson),
      'textColor': _$JsonConverterToJson<int, Color>(
          instance.textColor, const ColorConverter().toJson),
      'strokeWidth': instance.strokeWidth,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
