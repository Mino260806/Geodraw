// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dot _$DotFromJson(Map<String, dynamic> json) => Dot(
      json['name'] as String,
      Point.fromJson(json['point'] as Map<String, dynamic>),
    )..style = GeometryStyle.fromJson(json['style'] as Map<String, dynamic>?);

Map<String, dynamic> _$DotToJson(Dot instance) => <String, dynamic>{
      'style': GeometryObject.styleToJson(instance.style),
      'point': instance.point,
      'name': instance.name,
    };
