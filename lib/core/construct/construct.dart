import 'package:geo_draw/core/geometry_data/geometryobject.dart';
import 'package:geo_draw/core/geometry_data/geometryset.dart';

abstract class ConstructDirective {
  List<GeometryObject> objects = [];

  ConstructDirective();

  ConstructResult execute(GeometrySet set);
  void undo(GeometrySet set) {
    for (var object in objects) {
      set.removeObject(object);
    }
    objects.clear();
  }

  void addObject(GeometrySet set, GeometryObject object) {
    if (set.addObject(object)) {
      objects.add(object);
    }
  }
}

class ConstructResult {
  static final success = ConstructResult(ConstructResultStatus.Success, null);

  final ConstructResultStatus status;
  final FailCause? failCause;

  ConstructResult(this.status, this.failCause);

  bool get isFail => status == ConstructResultStatus.Fail;
  bool get isSuccess => status == ConstructResultStatus.Success;

  factory ConstructResult.fail(FailCause cause) =>
      ConstructResult(ConstructResultStatus.Fail, cause);
}

enum ConstructResultStatus {
  Success,
  Fail,
}

abstract class FailCause {
  String getMessage();
}

class UnknownFailCause extends FailCause {
  @override
  String getMessage() => "Unknown reason";
}

class OtherFailCause extends FailCause {
  final String message;

  OtherFailCause(this.message);

  @override
  String getMessage() => message;
}

class NumberFailCause extends FailCause {
  final String raw;

  NumberFailCause(this.raw);

  @override
  String getMessage() => "\"$raw\" is not a valid number";
}

class InvalidDotNameFailCause extends FailCause {
  final String name;

  InvalidDotNameFailCause(this.name);

  @override
  String getMessage() => "\"$name\" is not a valid point name";
}

class InvalidSegmentNameFailCause extends FailCause {
  final String name;

  InvalidSegmentNameFailCause(this.name);

  @override
  String getMessage() => "\"$name\" is not a valid segment name";
}

class DotsAlignedFailCause extends FailCause {
  final String dot1;
  final String dot2;
  final String dot3;

  DotsAlignedFailCause(this.dot1, this.dot2, this.dot3);

  @override
  String getMessage() => "The points \"$dot1\", \"$dot2\" and \"$dot3\" cannot be aligned";
}

class NoDotFailCause extends FailCause {
  final String name;

  NoDotFailCause(this.name);

  @override
  String getMessage() => "No point named \"$name\"";
}

class NoSegmentFailCause extends FailCause {
  final String name;

  NoSegmentFailCause(this.name);

  @override
  String getMessage() => "No segment named \"$name\"";
}

class NoLineFailCause extends FailCause {
  final String name;

  NoLineFailCause(this.name);

  @override
  String getMessage() => "No line named \"$name\"";
}

class NoCircleFailCause extends FailCause {
  final String name;

  NoCircleFailCause(this.name);

  @override
  String getMessage() => "No circle named \"$name\"";
}
