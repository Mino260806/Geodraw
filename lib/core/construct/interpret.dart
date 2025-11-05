import 'package:geo_draw/core/construct/construct.dart';
import 'package:geo_draw/core/construct/constructcircle.dart';
import 'package:geo_draw/core/construct/constructline.dart';
import 'package:geo_draw/core/construct/constructpoint.dart';

class ConstructInterpreter {
  final String command;

  ConstructInterpreter(this.command);

  ConstructDirective? interpret() {
    for (var signature in CommandSignature.values) {
      RegExp regExp = signature.regExp;
      RegExpMatch? match = regExp.firstMatch(command);
      if (match != null) {
        List<String> args = [];
        int i = 1;
        for (var argType in signature.argTypes) {
          for (int j=i; j<i+argType.groupCount; j++) {
            args.add(match.group(j)!);
          }
          i += argType.groupCount;
        }
        return signature.instantiate(args);
      }
    }

    return null;
  }
}

enum CommandSignature {
  PointCoordinates("point", [ArgumentType.Point, ArgumentType.Coordinates],
      CommandSignature.cPointCoordinates),
  PointMiddle("middle", [ArgumentType.Point, ArgumentType.Segment],
      CommandSignature.cPointMiddle),
  PointIntersectLines("interlineline", [ArgumentType.Point, ArgumentType.Line, ArgumentType.Line],
      CommandSignature.cPointIntersectLines),
  PointIntersectCircles1("intercirclecircle", [ArgumentType.Point, ArgumentType.Circle, ArgumentType.Circle],
      CommandSignature.cPointIntersectCircles1),
  PointIntersectCircles2("intercirclecircle", [ArgumentType.Point, ArgumentType.Point, ArgumentType.Circle, ArgumentType.Circle],
      CommandSignature.cPointIntersectCircles2),
  PointIntersectLineCircle1("interlinecircle", [ArgumentType.Point, ArgumentType.Line, ArgumentType.Circle],
      CommandSignature.cPointIntersectLineCircle1),
  PointIntersectLineCircle2("interlinecircle", [ArgumentType.Point, ArgumentType.Point, ArgumentType.Line, ArgumentType.Circle],
      CommandSignature.cPointIntersectLineCircle2),
  LineConnect("line", [ArgumentType.Line, ArgumentType.Segment],
      CommandSignature.cLineConnect),
  LinePerpendicular("perp", [ArgumentType.Line, ArgumentType.Line, ArgumentType.Point],
      CommandSignature.cLinePerpendicular),
  LineParallel("parall", [ArgumentType.Line, ArgumentType.Line, ArgumentType.Point],
      CommandSignature.cLineParallel),
  LineTangent("tangent", [ArgumentType.Line, ArgumentType.Circle, ArgumentType.Point],
      CommandSignature.cTangeant),
  CircleCenterRadiusReal("circle", [ArgumentType.Circle, ArgumentType.Point, ArgumentType.Real],
      CommandSignature.cCircleCenterRadius),
  CircleCenterRadiusSegment("circle", [ArgumentType.Circle, ArgumentType.Point, ArgumentType.Segment],
      CommandSignature.cCircleCenterRadius),
  CircleDiameter("circle", [ArgumentType.Circle, ArgumentType.Segment],
      CommandSignature.cCircleDiameter),
  CirclePoints("circle", [ArgumentType.Circle, ArgumentType.Point, ArgumentType.Point, ArgumentType.Point],
      CommandSignature.cCirclePoints),
  ;

  static ConstructDirective cPointCoordinates(List<String> args) =>
    ConstructPointCoordinates(args[0], args[1], args[2]);
  static ConstructDirective cPointMiddle(List<String> args) =>
    ConstructPointMiddle(args[0], args[1]);
  static ConstructDirective cPointIntersectLines(List<String> args) =>
    ConstructPointIntersectLines(args[0], args[1], args[2]);
  static ConstructDirective cPointIntersectCircles1(List<String> args) =>
    ConstructPointIntersectCircles(args[0], "", args[1], args[2]);
  static ConstructDirective cPointIntersectCircles2(List<String> args) =>
    ConstructPointIntersectCircles(args[0], args[1], args[2], args[3]);
  static ConstructDirective cPointIntersectLineCircle1(List<String> args) =>
    ConstructPointIntersectLineCircle(args[0], "", args[1], args[2]);
  static ConstructDirective cPointIntersectLineCircle2(List<String> args) =>
    ConstructPointIntersectLineCircle(args[0], args[1], args[2], args[3]);
  static ConstructDirective cLineConnect(List<String> args) =>
    ConstructLineConnect(args[0], args[1]);
  static ConstructDirective cLinePerpendicular(List<String> args) =>
    ConstructLinePerpendicular(args[0], args[1], args[2]);
  static ConstructDirective cLineParallel(List<String> args) =>
    ConstructLineParallel(args[0], args[1], args[2]);
  static ConstructDirective cTangeant(List<String> args) =>
    ConstructLineTangent(args[0], args[1], args[2]);
  static ConstructDirective cCircleCenterRadius(List<String> args) =>
    ConstructCircleCenterRadius(args[0], args[1], args[2]);
  static ConstructDirective cCircleDiameter(List<String> args) =>
    ConstructCircleDiameter(args[0], args[1]);
  static ConstructDirective cCirclePoints(List<String> args) =>
    ConstructCirclePoints(args[0], args[1], args[2], args[3]);

  final String name;
  final List<ArgumentType> argTypes;
  final ConstructDirective Function(List<String>) instantiate;

  const CommandSignature(this.name, this.argTypes, this.instantiate);
  RegExp get regExp => RegExp("^$name *${argTypes.map((e) => e.regex).join(" */ *")}\$");

}

const String _realRegex = r"([^,/]+)"; // r"(-? *\d+(?:\.\d+)?)";
enum ArgumentType {
  Real(1, _realRegex),
  Coordinates(2, r"\( *" + _realRegex + r" *, *" + _realRegex + r" *\)"),
  Point(1, r"(\w+[^/\w]*)"),
  Line(1, r"(\w+[^/\w]*)"),
  Segment(1, r"(\w+[^/\w]*)"),
  Circle(1, r"(\w+[^/\w]*)"),
  ;

  final int groupCount;
  final String regex;
  const ArgumentType(this.groupCount, this.regex);
}
