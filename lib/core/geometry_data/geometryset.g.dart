// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geometryset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeometrySet _$GeometrySetFromJson(Map<String, dynamic> json) => GeometrySet()
  ..showAxes = json['showAxes'] as bool
  ..showLines = json['showLines'] as bool
  ..objects = (json['objects'] as List<dynamic>)
      .map((e) =>
          const GeometryObjectConverter().fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$GeometrySetToJson(GeometrySet instance) =>
    <String, dynamic>{
      'showAxes': instance.showAxes,
      'showLines': instance.showLines,
      'objects':
          instance.objects.map(const GeometryObjectConverter().toJson).toList(),
    };
