import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geo_draw/core/construct/construct.dart';
import 'package:geo_draw/core/construct/constructline.dart';
import 'package:geo_draw/core/geometry_data/circle.dart';
import 'package:geo_draw/core/geometry_data/dot.dart';
import 'package:geo_draw/core/geometry_data/geometryset.dart';
import 'package:geo_draw/core/geometry_data/line.dart';
import 'package:geo_draw/core/geometry_data/segment.dart';
import 'package:geo_draw/core/geometry_data/triangle.dart';
import 'package:geo_draw/core/name/segment.dart';
import 'package:geo_draw/core/name/triangle.dart';
import 'package:geo_draw/core/prop/point.dart';
import 'package:geo_draw/directive/dialog/base.dart';
import 'package:geo_draw/directive/directivelist.dart';
import 'package:geo_draw/ui/controller.dart';

import 'package:provider/provider.dart';

class AddLineDialog extends BaseDialog {
  @override
  State<StatefulWidget> createState() => _AddLineDialogState();

}

class _AddLineDialogState extends BaseDialogState<AddLineDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _connectDotsController = TextEditingController();
  final TextEditingController _perpLineController = TextEditingController();
  final TextEditingController _perpDotController = TextEditingController();
  final TextEditingController _parallLineController = TextEditingController();
  final TextEditingController _rotateLineController = TextEditingController();
  final TextEditingController _rotateDotController = TextEditingController();
  final TextEditingController _angleController = TextEditingController();
  final TextEditingController _parallDotController = TextEditingController();
  final TextEditingController _perpBisController = TextEditingController();
  final TextEditingController _tangCircleController = TextEditingController();
  final TextEditingController _tangDotController = TextEditingController();

  bool _endpoint1 = false;
  bool _endpoint2 = false;
  
  AddLineType _type = AddLineType.ConnectDots;

  @override
  Widget getContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("Name", style: TextStyle(fontSize: 18),),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        DropdownButton(
          onChanged: (type) {
            if (type != null) {
              setState(() {
                _type = type;
              });
            }
          },
          value: _type,
          items: <DropdownMenuItem<AddLineType>>[
            DropdownMenuItem(child: Text("Connect Points"), value: AddLineType.ConnectDots,),
            DropdownMenuItem(child: Text("Perpendicular"), value: AddLineType.Perpendicular,),
            DropdownMenuItem(child: Text("Parallel"), value: AddLineType.Parallel,),
            DropdownMenuItem(child: Text("Rotate"), value: AddLineType.Rotate,),
            DropdownMenuItem(child: Text("Perpendicular Bisector"), value: AddLineType.PerpendicularBisector,),
            DropdownMenuItem(child: Text("Tangent"), value: AddLineType.Tangent,),
          ],
          underline: const SizedBox(),
        ),
        switch(_type) {
          AddLineType.ConnectDots =>
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _connectDotsController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Segment"),
                    ),
                  ),
                  CheckboxListTile(
                    title: Text("Endpoint 1"),
                    value: _endpoint1,
                    onChanged: (endpoint1) {
                      setState(() {
                        _endpoint1 = endpoint1 ?? false;
                      });
                    },

                  ),
                  CheckboxListTile(
                    title: Text("Endpoint 2"),
                    value: _endpoint2,
                    onChanged: (endpoint2) {
                      setState(() {
                        _endpoint2 = endpoint2 ?? false;
                      });
                    },
                  ),
                ],
              ),
          AddLineType.Perpendicular =>
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _perpLineController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Line"),
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    controller: _perpDotController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Point"),
                    ),
                  ),
                ],
              ),
          AddLineType.Parallel =>
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _parallLineController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Line"),
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    controller: _parallDotController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Point"),
                    ),
                  ),
                ],
              ),
          AddLineType.Rotate =>
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _rotateLineController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Line"),
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    controller: _rotateDotController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Point"),
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    controller: _angleController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Angle"),
                    ),
                  ),
                ],
              ),
          AddLineType.PerpendicularBisector =>
              TextField(
                controller: _perpBisController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Segment"),
                ),
              ),
          AddLineType.Tangent =>
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _tangCircleController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Circle"),
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    controller: _tangDotController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Point"),
                    ),
                  ),
                ],
              ),
        }
      ],
    );
  }

  @override
  String getTitle() => "Construct line";

  @override
  void onAdd(BuildContext context, GeometrySet geometrySet, DirectiveList directiveList) {
    ConstructResult result;

    String name = _nameController.stripped;
    switch (_type) {
      case AddLineType.ConnectDots:
        String segmentName = _connectDotsController.stripped;
        result = directiveList.addAndExecute(ConstructLineConnect(name, segmentName, endpoint1: _endpoint1, endpoint2: _endpoint2));
      case AddLineType.Perpendicular:
        String lineName = _perpLineController.stripped;
        String dotName = _perpDotController.stripped;
        result = directiveList.addAndExecute(ConstructLinePerpendicular(name, lineName, dotName));
      case AddLineType.Parallel:
        String lineName = _parallLineController.stripped;
        String dotName = _parallDotController.stripped;
        result = directiveList.addAndExecute(ConstructLineParallel(name, lineName, dotName));
      case AddLineType.Rotate:
        String lineName = _rotateLineController.stripped;
        String dotName = _rotateDotController.stripped;
        String angle = _angleController.stripped;
        result = directiveList.addAndExecute(ConstructLineAngle(name, lineName, dotName, angle));
      case AddLineType.PerpendicularBisector:
        String segmentName = _perpBisController.stripped;
        result = directiveList.addAndExecute(ConstructLinePerpendicularBisector(name, segmentName));
      case AddLineType.Tangent:
        String circleName = _tangCircleController.stripped;
        String dotName = _tangDotController.stripped;
        result = directiveList.addAndExecute(ConstructLineTangent(name, circleName, dotName));
    }

    treatResult(result);
  }
}

enum AddLineType {
  ConnectDots,
  Perpendicular,
  Parallel,
  Rotate,
  PerpendicularBisector,
  Tangent,
}