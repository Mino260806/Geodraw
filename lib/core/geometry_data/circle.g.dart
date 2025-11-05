// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'circle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Circle _$CircleFromJson(Map<String, dynamic> json) => Circle(
      json['name'] as String,
      Point.fromJson(json['center'] as Map<String, dynamic>),
      (json['radius'] as num).toDouble(),
    )..style = GeometryStyle.fromJson(json['style'] as Map<String, dynamic>?);

Map<String, dynamic> _$CircleToJson(Circle instance) => <String, dynamic>{
      'style': GeometryObject.styleToJson(instance.style),
      'name': instance.name,
      'center': instance.center,
      'radius': instance.radius,
    };
