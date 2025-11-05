import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geo_draw/core/construct/constructdelete.dart';
import 'package:geo_draw/core/geometry_data/dot.dart';
import 'package:geo_draw/core/geometry_data/geometryobject.dart';
import 'package:geo_draw/core/geometry_data/geometryset.dart';
import 'package:geo_draw/core/prop/point.dart';
import 'package:geo_draw/directive/dialog/addai.dart';
import 'package:geo_draw/directive/dialog/base.dart';
import 'package:geo_draw/directive/directivelist.dart';
import 'package:geo_draw/draw/canvas/canvasset.dart';
import 'package:geo_draw/draw/canvasprop.dart';
import 'package:geo_draw/draw/canvasselection.dart';
import 'package:geo_draw/draw/canvastransform.dart';
import 'package:geo_draw/draw/painttheme.dart';
import 'package:geo_draw/directive/dialog/addcircle.dart';
import 'package:geo_draw/directive/dialog/addline.dart';
import 'package:geo_draw/directive/dialog/addpoint.dart';
import 'package:geo_draw/storage/namedialog.dart';
import 'package:geo_draw/ui/constants.dart';
import 'package:geo_draw/ui/status.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class GeoCanvas extends StatefulWidget {
  @override
  State<GeoCanvas> createState() => _GeoCanvasState();
}

class _GeoCanvasState extends State<GeoCanvas> with SingleTickerProviderStateMixin {

  MouseCursor _cursor = SystemMouseCursors.grab;

  GeometrySet? _geometrySet;
  GeometrySet get geometrySet {
    _geometrySet ??= Provider.of<GeometrySet>(context, listen: false);
    return _geometrySet!;
  }

  UiStatus? _uiStatus;
  UiStatus get uiStatus {
    _uiStatus ??= Provider.of<UiStatus>(context, listen: false);
    return _uiStatus!;
  }

  double _baseScale = 1.0;
  bool _bottomSheetShown = false;

  late DirectiveList _directiveList;
  late AnimatedCanvasTransform _transform;
  late CanvasSelection _selection;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: createDirectiveList, lazy: false),
        ChangeNotifierProvider(create: createCanvasTransform, lazy: false),
        ChangeNotifierProvider(create: createSelection, lazy: false),
      ],
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Consumer<UiStatus>(
              builder: (context, uiStatus, child) => switch(uiStatus.isLoading) {
                true => LinearProgressIndicator(),
                false => Container(),
              },
            )
          ),
          MouseRegion(
            onHover: (PointerHoverEvent? details) {
              if (details != null) {
                GeometryObject? object = getHoveredObject(details.localPosition);
                if (object != null) {
                  setState(() {
                    _cursor = SystemMouseCursors.basic;
                  });
                }
                else {
                  setState(() {
                    _cursor = SystemMouseCursors.grab;
                  });
                }
              }
            },
            cursor: _cursor,
            child: GestureDetector(
              onTapUp: (details) {
                GeometryObject? object = getHoveredObject(details.localPosition);
                if (object != null) {
                  if (!uiStatus.isLocked) {
                    showBottomSheet(context, object);
                  }
                  setState(() {
                    _selection.setObject(object, details.localPosition);
                    _cursor = SystemMouseCursors.basic;
                  });
                }
                else {
                  hideBottomSheet();
                  setState(() {
                    _selection.setObject(null, null);
                    _cursor = SystemMouseCursors.grab;
                  });
                }
              },
              onScaleStart: (details) {
                _baseScale = _transform.scale;
                setState(() {
                  _cursor = SystemMouseCursors.grabbing;
                });
              },
              onScaleUpdate: (details) {
                if (_selection.object != null) {
                  _selection.setObject(null, null);
                }
                setState(() {
                  _transform.setScale(_baseScale * details.scale);
                  _transform.dx += details.focalPointDelta.dx;
                  _transform.dy += details.focalPointDelta.dy;
                });
              },
              onScaleEnd: (details) {
                setState(() {
                  _cursor = SystemMouseCursors.grab;
                });
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Consumer3<GeometrySet, AnimatedCanvasTransform, CanvasSelection>(
                      builder: (context, geometrySet, transform, selection, child) => CustomPaint(
                        painter: MyPainter(
                          geometrySet: geometrySet,
                          selection: _selection,
                          drawPaint: Paint()
                            ..color = Colors.blueGrey
                            ..strokeWidth = 2
                            ..style = PaintingStyle.fill,
                          shadowPaint: Paint()
                            ..color = Colors.grey
                            ..strokeWidth = 6
                            ..style = PaintingStyle.stroke,
                          textStyle: TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          transform: transform,
                        ),
                      ),
                    ),
                  ),

                  Consumer<UiStatus>(
                    builder: (context, uiStatus, widget) {
                      return Positioned(
                        top: 0,
                        bottom: 0,
                        right: 0,
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 100),
                          reverseDuration: Duration(milliseconds: 100),
                          transitionBuilder: (child, animation) =>
                              SizeTransition(
                                sizeFactor: animation,
                                axis: Axis.horizontal,
                                child: child,
                              ),
                          child: uiStatus.isLocked? Container(): Padding(
                            padding: const EdgeInsets.all(10),
                            child: Wrap(
                              direction: Axis.vertical,
                              textDirection: TextDirection.rtl,
                              children: [
                                showAddDialog(context, AddPointDialog(), Icons.scatter_plot, "Draw Point"),
                                const SizedBox(height: 10,),
                                // showAddDialog(context, AddTriangleDialog(), Icons.change_history),
                                // const SizedBox(height: 10,),
                                showAddDialog(context, AddLineDialog(), Icons.shape_line_outlined, "Draw Line"),
                                const SizedBox(height: 10,),
                                showAddDialog(context, AddCircleDialog(), Icons.circle_outlined, "Draw Circle"),
                                const SizedBox(height: 10,),
                                showAddDialog(context, AddAIDialog(), Icons.smart_toy_outlined, "AI Drawer"),
                                const SizedBox(height: 10,),
                                FloatingActionButton.small(
                                  tooltip: "Zoom Out",
                                  child: const Icon(Icons.zoom_out),
                                  onPressed: () {
                                    _transform.animateZoomOut();
                                  }
                                ),
                                const SizedBox(height: 10,),
                                FloatingActionButton.small(
                                  tooltip: "Zoom In",
                                  child: const Icon(Icons.zoom_in),
                                  onPressed: () {
                                    _transform.animateZoomIn();
                                  }
                                ),
                                const SizedBox(height: 10,),
                                FloatingActionButton.small(
                                  tooltip: "Center",
                                  child: const Icon(Icons.center_focus_strong),
                                  onPressed: () {
                                    _transform.animateFit();
                                  }
                                ),
                                const SizedBox(height: 10,),
                                FloatingActionButton.small(
                                  tooltip: "Undo",
                                  child: const Icon(Icons.undo),
                                  onPressed: () {
                                    _directiveList.undo();
                                  }
                                ),
                                const SizedBox(height: 10,),
                                FloatingActionButton.small(
                                  tooltip: "Redo",
                                  child: const Icon(Icons.redo),
                                  onPressed: () {
                                    _directiveList.redo();
                                  }
                                ),
                                const SizedBox(height: 10,),
                                FloatingActionButton.small(
                                  tooltip: "Save",
                                  child: const Icon(Icons.save),
                                  onPressed: save,
                                ),
                                const SizedBox(height: 10,),
                                FloatingActionButton.small(
                                  tooltip: "Save As",
                                  child: const Icon(Icons.save_as),
                                  onPressed: saveAs,
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  ),

                  Consumer<UiStatus>(
                    builder: (context, uiStatus, child) {
                      return Positioned(
                        top: 0,
                        left: 0,
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: IconButton(
                            tooltip: uiStatus.isLocked? "Show All": "Hide All",
                            isSelected: uiStatus.isLocked,
                            selectedIcon: Icon(Icons.lock_outline),
                            icon: Icon(Icons.lock_open_outlined),
                            onPressed: () {
                              uiStatus.isLocked = !uiStatus.isLocked;
                            },
                          ),
                        ),
                      );
                    }
                  ),
                ],
              ),
            ),
          ),
          Consumer<CanvasSelection>(
            builder: (context, selection, child) {
              if (selection.object == null || selection.location == null) {
                return Container();
              }
              return Positioned(
                left: selection.location!.dx + 5,
                top: selection.location!.dy + 5,
                child: Card.outlined(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: Text(selection.object!.repr,
                      style: GoogleFonts.crimsonPro().copyWith(fontSize: 18),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void save({VoidCallback? onSuccess}) {
    if (!geometrySet.save()) {
      saveAs(onSuccess: onSuccess);
    } else {
      onSuccess?.call();
    }
  }

  void saveAs({VoidCallback? onSuccess}) {
    showDialog(context: context, builder: (context) =>
        SetNameDialog(
          onNameSet: (name) {
            geometrySet.name = name;
            geometrySet.save();
            onSuccess?.call();
          },
        ));
  }

  @override
  void initState() {
    super.initState();

    registerGeometrySet();
  }

  GeometrySet registerGeometrySet() {
    geometrySet.addListener(geometrySetListener);
    return geometrySet;
  }

  void geometrySetListener() {
    print(geometrySet.toJson());

    if (geometrySet.objects.length <= 2) {
      _transform.requestFit();
    }

    if (geometrySet.lastAddingError != null) {
      showDialog(context: context, builder: (context) => AlertDialog(
        title: Text("Not Added"),
        content: Text(geometrySet.lastAddingError!),
        actions: [
          TextButton(
            onPressed: () {
              geometrySet.lastAddingError = null;
              Navigator.pop(context);
            },
            child: Text("Ok"),
          )
        ],
      ));
    }

    if (geometrySet.pendingLoad != null) {
      showDialog(context: context, builder: (context) => AlertDialog(
        title: Text("Not Saved"),
        content: Text("Save current project before proceeding ?"),
        actions: [
          TextButton(
            onPressed: () {
              geometrySet.pendingLoad = null;
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              geometrySet.load(geometrySet.pendingLoad!, ignoreUnsaved: true);
            },
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              save(onSuccess: () {
                geometrySet.load(geometrySet.pendingLoad!);
              });
            },
            child: Text("Yes"),
          ),
        ],
      ));
    }
    if (geometrySet.justLoaded) {
      geometrySet.justLoaded = false;
      _transform.requestFit();
    }
  }

  DirectiveList createDirectiveList(BuildContext context) {
    _directiveList = DirectiveList(geometrySet);
    return _directiveList;
  }

  Widget showAddDialog(BuildContext context, BaseDialog dialog, IconData icon, String tooltip) {
    return FloatingActionButton.small(
        tooltip: tooltip,
        child: Icon(icon),
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) => ChangeNotifierProvider<GeometrySet>.value(
                value: geometrySet,
                child: ChangeNotifierProvider<DirectiveList>.value(
                  value: _directiveList,
                  child: ChangeNotifierProvider<UiStatus>.value(
                    value: uiStatus,
                    child: dialog,
                  ),
                ),
              )
          );
        }
    );
  }

  AnimatedCanvasTransform createCanvasTransform(BuildContext context) {
    _transform = AnimatedCanvasTransform(this);
    return _transform;
  }

  CanvasSelection createSelection(BuildContext context) {
    _selection = CanvasSelection();
    return _selection;
  }

  GeometryObject? getHoveredObject(Offset offset) {
    Point point = _transform.untransform(offset);
    double tolerance = UiConstants.hoverTolerance / _transform.scale;
    GeometryObject? object = geometrySet.findHoveredObject(point, tolerance);
    return object;
  }

  void showBottomSheet(BuildContext context, GeometryObject object) {
    _bottomSheetShown = true;
    Scaffold.of(context).showBottomSheet(
        (BuildContext context) => CanvasBottomSheet(object, geometrySet, _directiveList, _selection)
    );
  }

  void hideBottomSheet() {
    if (_bottomSheetShown) {
      Navigator.pop(context);
      _bottomSheetShown = false;
    }
  }

  @override
  void dispose() {
    geometrySet.removeListener(geometrySetListener);

    super.dispose();
  }
}

class CanvasBottomSheet extends StatefulWidget {
  final GeometryObject myObject;
  final GeometrySet geometrySet;
  final DirectiveList directiveList;
  final CanvasSelection selection;

  const CanvasBottomSheet(this.myObject, this.geometrySet, this.directiveList, this.selection, {super.key});

  @override
  State<CanvasBottomSheet> createState() => _CanvasBottomSheetState();
}

class _CanvasBottomSheetState extends State<CanvasBottomSheet> {
  GeometryObject get myObject => widget.myObject;
  GeometrySet get geometrySet => widget.geometrySet;
  DirectiveList get directiveList => widget.directiveList;
  CanvasSelection get selection => widget.selection;

  BottomSheetToggle _toggle = BottomSheetToggle.None;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 100),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SizeTransition(sizeFactor: animation, child: child);
            },
            child: switch(_toggle) {
              BottomSheetToggle.StrokeColor || BottomSheetToggle.TextColor =>
                ColorPicker(
                  // TODO fix selected color won't appear
                  color: switch (_toggle) {
                    BottomSheetToggle.StrokeColor =>
                      myObject.style.color?? Colors.blueGrey,
                    BottomSheetToggle.TextColor =>
                      myObject.style.textColor?? Colors.indigo,
                    _ => Colors.black,
                  },
                  onColorChanged: (Color color) {
                    if (_toggle == BottomSheetToggle.StrokeColor) {
                      myObject.style.color = color;
                    }
                    else if (_toggle == BottomSheetToggle.TextColor) {
                      myObject.style.textColor = color;
                    }
                  },
                  enableShadesSelection: false,
                ),
              BottomSheetToggle.StrokeWidth => Container(
                child: Slider(
                  value: myObject.style.strokeWidth?? 2,
                  min: 1,
                  max: 10,
                  onChanged: (value) {
                    setState(() {
                      myObject.style.strokeWidth = value;
                    });
                  },
                ),
              ),
              _ => Container(),
            }
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.delete),
                iconSize: 30,
                onPressed: () {
                  selection.setObject(null, null);
                  Navigator.pop(context);
                  directiveList.addAndExecute(ConstructDelete(myObject));
                },
              ),
              IconButton(
                icon: Icon(Icons.format_color_fill_rounded),
                iconSize: 30,
                isSelected: _toggle == BottomSheetToggle.StrokeColor,
                onPressed: myObject is Dot ? null : () {
                  setState(() {
                    _toggle = _toggle != BottomSheetToggle.StrokeColor? BottomSheetToggle.StrokeColor
                    : BottomSheetToggle.None;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.format_color_text_rounded),
                iconSize: 30,
                isSelected: _toggle == BottomSheetToggle.TextColor,
                onPressed: () {
                  setState(() {
                    _toggle = _toggle != BottomSheetToggle.TextColor? BottomSheetToggle.TextColor
                        : BottomSheetToggle.None;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.line_weight_rounded),
                iconSize: 30,
                isSelected: _toggle == BottomSheetToggle.StrokeWidth,
                onPressed: myObject is Dot ? null : () {
                  setState(() {
                    _toggle = _toggle != BottomSheetToggle.StrokeWidth? BottomSheetToggle.StrokeWidth
                        : BottomSheetToggle.None;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum BottomSheetToggle {
  None,
  StrokeColor,
  TextColor,
  StrokeWidth,
}

class MyPainter extends CustomPainter {
  final CanvasSet canvasSet = CanvasSet();
  final GeometrySet geometrySet;
  final CanvasSelection selection;

  final CanvasTransform transform;

  late final PaintTheme theme;
  final Paint drawPaint;
  final Paint shadowPaint;
  final TextStyle textStyle;

  MyPainter({
    required this.geometrySet,
    required this.transform,
    required this.selection,
    required this.drawPaint,
    required this.shadowPaint,
    required this.textStyle
  }) {
    theme = PaintTheme(drawPaint, shadowPaint, textStyle);
    canvasSet.addSet(geometrySet);
  }

  @override
  void paint(Canvas canvas, Size size) {
    transform.fit(geometrySet, size);
    var properties = CanvasProperties(size, theme, transform, selection.object);
    canvasSet.draw(canvas, properties);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
