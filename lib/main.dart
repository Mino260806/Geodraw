import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geo_draw/core/geometry_data/circle.dart';
import 'package:geo_draw/core/geometry_data/dot.dart';
import 'package:geo_draw/core/geometry_data/geometryset.dart';
import 'package:geo_draw/core/geometry_data/line.dart';
import 'package:geo_draw/core/geometry_data/segment.dart';
import 'package:geo_draw/core/prop/point.dart';
import 'package:geo_draw/geocanvas.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:geo_draw/storage/manager.dart';
import 'package:geo_draw/ui/status.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:admanager_web/admanager_web.dart';

void main() async {
  await StorageManager().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoDraw',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: createGeometrySet, lazy: false),
          ChangeNotifierProvider(create: (context) => UiStatus(), lazy: false),
        ],
        child: const MyHomePage(title: 'GeoDraw')
      ),
    );
  }


  static GeometrySet createGeometrySet(BuildContext context) {
    GeometrySet geometrySet = GeometrySet();

    if (kDebugMode) {
      // _geometrySet.addObject(Dot("A", Point(0, 0)));
      // _geometrySet.addObject(Dot("B", Point(0, 1)));
      // _geometrySet.addObject(Dot("C", Point(1, 1)));
      // _geometrySet.addObject(Dot("D", Point(0.5, 0)));
      // _geometrySet.addObject(Circle.fromDiameter("C", Segment(_geometrySet.dots[0], _geometrySet.dots[2])));

      Dot dotA = Dot("A", Point(0, 0));
      Dot dotB = Dot("B", Point(5, 0));
      Dot dotC = Dot("C", Point(3, 2));
      geometrySet.addObject(dotA);
      geometrySet.addObject(dotB);
      geometrySet.addObject(dotC);
      geometrySet.addObject(Circle("C1", dotC.point, 2));
      geometrySet.addObject(Circle("C2", dotB.point, 2 * sqrt(2)));
      geometrySet.addObject(Line.fromDots(null, dotA, dotC));
      geometrySet.addObject(Segment.fromDots(null, dotB, dotC));

      print(geometrySet.toJson());

      // var interpreter = ConstructInterpreter("point A/(0.5,0)");
      // var interpreter = ConstructInterpreter("line OO'");
      // var interpreter = ConstructInterpreter("point X/(-1,-1)");
      // interpreter.interpret()!.execute(geometrySet);

      geometrySet.name = "Test 2";
      // geometrySet.save();

      // geometrySet.name = null;
      // geometrySet.clear();
    }

    geometrySet.loadLastOpened();

    return geometrySet;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late AnimationController _appBarController;
  late Animation _appBarAnimation;

  @override
  void initState() {
    super.initState();

    _appBarController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
      reverseDuration: Duration(milliseconds: 100),
    );
    _appBarAnimation = Tween(begin: kToolbarHeight, end: 0).animate(_appBarController);
    _appBarAnimation.addListener(() {
      setState(() {});
    });

    var uiStatus = Provider.of<UiStatus>(context, listen: false);
    uiStatus.addListener(uiStatusListener);

    if (kDebugMode) {
      Gemini.init(apiKey: "AIzaSyBry9nsBF1EUoxSIzkFxr6slQjSSg4z3yA");
    }

    if (kIsWeb) {
      // AdManagerWeb.init();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight((_appBarAnimation.value as num).toDouble()),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(widget.title),
          actions: [
            MyMenuAnchor(),
          ],
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: GeoCanvas(),
          ),
        ],
      ),
      drawer: GeoDrawDrawer(),
    );
  }

  void uiStatusListener() {
    var uiStatus = Provider.of<UiStatus>(context, listen: false);
    if (uiStatus.isLocked && _appBarAnimation.value != 0) {
      _appBarController.forward();
    }
    else if (!uiStatus.isLocked && _appBarAnimation.value != kToolbarHeight) {
      _appBarController.reverse();
    }
  }

  @override
  void dispose() {
    var uiStatus = Provider.of<UiStatus>(context, listen: false);
    uiStatus.removeListener(uiStatusListener);

    super.dispose();
  }
}

class MyMenuAnchor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var geometrySet = Provider.of<GeometrySet>(context);

    return MenuAnchor(
      builder: (context, controller, child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.more_vert),
        );
      },
      menuChildren: [
        SubmenuButton(
          menuChildren: <Widget>[
            CheckboxMenuButton(
              onChanged: (showAxes) {
                geometrySet.showAxes = showAxes ?? false;
                geometrySet.invalidate();
              },
              value: geometrySet.showAxes,
              child: const Text('Axes'),
            ),
            CheckboxMenuButton(
              onChanged: (!geometrySet.showAxes) ? null : (showLines) {
                geometrySet.showLines = showLines ?? false;
                geometrySet.invalidate();
              },
              value: geometrySet.showLines,
              child: const Text('Lines'),
            ),
          ],
          child: const Text('Show Grid'),
        ),
      ],
    );
  }
}

class GeoDrawDrawer extends StatefulWidget {
  final drawings = StorageManager().drawings;

  @override
  State<GeoDrawDrawer> createState() => _GeoDrawDrawerState();
}

class _GeoDrawDrawerState extends State<GeoDrawDrawer> {
  List<String> _keys = [];
  bool _isSaved = false;
  bool _isUntitled = false;

  Function? disposeListen;

  @override
  void initState() {
    super.initState();

    disposeListen = widget.drawings.listen(() {
      setState(updateKeys);
    });
    updateKeys();
  }

  void updateKeys() {
    GeometrySet geometrySet = Provider.of<GeometrySet>(context, listen: false);

    _isSaved = geometrySet.isSaved;
    _keys = (widget.drawings.getKeys() as Iterable<String>).toList();
    if (geometrySet.name == null || !_keys.contains(geometrySet.name!)) {
      _isUntitled = true;
      _keys.insert(0, "Untitled");
    }
    else {
      int index = _keys.indexOf(geometrySet.name!);
      if (index == -1) {
        _isUntitled = true;
        geometrySet.name = null;
      }
      else {
        _isUntitled = false;
        String key = _keys[index];
        _keys.removeAt(index);
        _keys.insert(0, key);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(10),
        children: [
          Text("Drawings", style: TextStyle(fontSize: 24)),
          ... List.generate(_keys.length, (index) => ListTile(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            title: index != 0? Text(_keys[index]):
              Text("${_isSaved? '': '*'}${_keys[index]}", style: TextStyle(fontStyle: FontStyle.italic)),
            trailing: index == 0 && _isUntitled? SizedBox(): IconButton(
              icon: Icon(Icons.delete),
              color: Colors.grey,
              onPressed: () {
                var geometrySet = Provider.of<GeometrySet>(context, listen: false);
                if (geometrySet.name == _keys[index]) {
                  geometrySet.reset();
                }
                widget.drawings.remove(_keys[index]);
              },
            ),
            onTap: () {
              Navigator.pop(context);

              var geometrySet = Provider.of<GeometrySet>(context, listen: false);
              geometrySet.load(_keys[index]);
            },
          )),
          ListTile(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.add),
                Text("New"),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
              var geometrySet = Provider.of<GeometrySet>(context, listen: false);
              geometrySet.reset();
            },
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    disposeListen?.call();
    super.dispose();
  }
}
