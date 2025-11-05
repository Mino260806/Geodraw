// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'segment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Segment _$SegmentFromJson(Map<String, dynamic> json) => Segment(
      json['name'] as String,
      (json['a'] as num).toDouble(),
      (json['b'] as num).toDouble(),
      (json['c'] as num).toDouble(),
      (json['endpointmin'] as num).toDouble(),
      (json['endpointmax'] as num).toDouble(),
    )..style = GeometryStyle.fromJson(json['style'] as Map<String, dynamic>?);

Map<String, dynamic> _$SegmentToJson(Segment instance) => <String, dynamic>{
      'style': GeometryObject.styleToJson(instance.style),
      'name': instance.name,
      'a': instance.a,
      'b': instance.b,
      'c': instance.c,
      'endpointmin': instance.endpointmin,
      'endpointmax': instance.endpointmax,
    };
