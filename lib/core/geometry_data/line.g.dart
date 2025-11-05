// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Line _$LineFromJson(Map<String, dynamic> json) => Line(
      json['name'] as String,
      (json['a'] as num).toDouble(),
      (json['b'] as num).toDouble(),
      (json['c'] as num).toDouble(),
    )..style = GeometryStyle.fromJson(json['style'] as Map<String, dynamic>?);

Map<String, dynamic> _$LineToJson(Line instance) => <String, dynamic>{
      'style': GeometryObject.styleToJson(instance.style),
      'name': instance.name,
      'a': instance.a,
      'b': instance.b,
      'c': instance.c,
    };
