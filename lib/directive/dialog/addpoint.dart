import 'package:flutter/material.dart';
import 'package:geo_draw/core/construct/construct.dart';
import 'package:geo_draw/core/construct/constructpoint.dart';
import 'package:geo_draw/core/geometry_data/geometryset.dart';
import 'package:geo_draw/directive/dialog/base.dart';
import 'package:geo_draw/directive/directivelist.dart';
import 'package:geo_draw/ui/controller.dart';


class AddPointDialog extends BaseDialog {
  @override
  State<StatefulWidget> createState() => _AddPointDialogState();

}

class _AddPointDialogState extends BaseDialogState<AddPointDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _name2Controller = TextEditingController();
  final TextEditingController _xController = TextEditingController();
  final TextEditingController _yController = TextEditingController();
  final TextEditingController _middleSegmentController = TextEditingController();
  final TextEditingController _interLine1Controller = TextEditingController();
  final TextEditingController _interLine2Controller = TextEditingController();
  final TextEditingController _interCircle1Controller = TextEditingController();
  final TextEditingController _interCircle2Controller = TextEditingController();
  final TextEditingController _interCircleController = TextEditingController();
  final TextEditingController _interLineController = TextEditingController();

  AddPointType _type = AddPointType.Coordinates;

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
        switch(_type) {
          AddPointType.IntersectCircles || AddPointType.IntersectLineCircle => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name 2", style: TextStyle(fontSize: 18),),
              TextField(
                controller: _name2Controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          _ => Container()
        },
        DropdownButton(
          onChanged: (type) {
            if (type != null) {
              setState(() {
                _type = type;
              });
            }
          },
          value: _type,
          items: <DropdownMenuItem<AddPointType>>[
            DropdownMenuItem(child: Text("Coordinates"), value: AddPointType.Coordinates,),
            DropdownMenuItem(child: Text("Middle"), value: AddPointType.Middle,),
            DropdownMenuItem(child: Text("Intersect Lines"), value: AddPointType.IntersectLines,),
            DropdownMenuItem(child: Text("Intersect Circles"), value: AddPointType.IntersectCircles,),
            DropdownMenuItem(child: Text("Intersect Line Circle"), value: AddPointType.IntersectLineCircle,),
          ],
          underline: const SizedBox(),
        ),
        switch(_type) {
          AddPointType.Coordinates =>
              Flex(
                direction: Axis.horizontal,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _xController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("X"),
                      ),
                    ),
                  ),
                  SizedBox(width: 5,),
                  Expanded(
                    child: TextField(
                      controller: _yController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("Y"),
                      ),
                    ),
                  ),
                ],
              ),

          AddPointType.Middle =>
              TextField(
                controller: _middleSegmentController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Segment"),
                ),
              ),
          AddPointType.IntersectLines =>
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _interLine1Controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Line 1"),
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    controller: _interLine2Controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Line 2"),
                    ),
                  ),
                ],
              ),
          AddPointType.IntersectCircles =>
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _interCircle1Controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Circle 1"),
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    controller: _interCircle2Controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Circle 2"),
                    ),
                  ),
                ],
              ),
          AddPointType.IntersectLineCircle =>
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _interLineController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Line"),
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    controller: _interCircleController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Circle"),
                    ),
                  ),
                ],
              ),
        }
      ],
    );
  }

  @override
  String getTitle() => "Add a point";

  @override
  void onAdd(BuildContext context, GeometrySet geometrySet, DirectiveList directiveList) {
    ConstructResult result;

    String name = _nameController.stripped;
    String name2 = _name2Controller.stripped;
    switch (_type) {
      case AddPointType.Coordinates:
        String sx = _xController.stripped;
        String sy = _yController.stripped;
        result = directiveList.addAndExecute(
            ConstructPointCoordinates(name, sx, sy)
        );
      case AddPointType.Middle:
        String segmentName = _middleSegmentController.stripped;
        result = directiveList.addAndExecute(
            ConstructPointMiddle(name, segmentName)
        );
      case AddPointType.IntersectLines:
        String line1Name = _interLine1Controller.stripped;
        String line2Name = _interLine2Controller.stripped;
        result = directiveList.addAndExecute(
            ConstructPointIntersectLines(name, line1Name, line2Name)
        );
      case AddPointType.IntersectCircles:
        String circle1Name = _interCircle1Controller.stripped;
        String circle2Name = _interCircle2Controller.stripped;
        result = directiveList.addAndExecute(
            ConstructPointIntersectCircles(name, name2, circle1Name, circle2Name)
        );
      case AddPointType.IntersectLineCircle:
        String lineName = _interLineController.stripped;
        String circleName = _interCircleController.stripped;
        result = directiveList.addAndExecute(
            ConstructPointIntersectLineCircle(name, name2, lineName, circleName)
        );

    }

    treatResult(result);
  }
}

enum AddPointType {
  Coordinates,
  Middle,
  IntersectLines,
  IntersectCircles,
  IntersectLineCircle,
}