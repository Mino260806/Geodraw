import 'package:flutter/cupertino.dart';
import 'package:geo_draw/core/construct/construct.dart';
import 'package:geo_draw/core/geometry_data/geometryset.dart';

class DirectiveList extends ChangeNotifier {
  final GeometrySet set;

  List<ConstructDirective> directives = [];
  List<ConstructDirective> redoList = [];

  DirectiveList(this.set);

  ConstructResult addAndExecute(ConstructDirective directive) {
    redoList.clear();
    directives.add(directive);
    ConstructResult result = directive.execute(set);
    set.invalidate();
    notifyListeners();

    return result;
  }

  void undo() {
    if (directives.isNotEmpty) {
      redoList.add(directives.last);

      directives.last.undo(set);
      set.invalidate();
      directives.removeAt(directives.length - 1);
    }
    notifyListeners();
  }

  void redo() {
    if (redoList.isNotEmpty) {
      directives.add(redoList.last);

      redoList.last.execute(set);
      set.invalidate();
      redoList.removeAt(redoList.length - 1);
    }
    notifyListeners();
  }
}