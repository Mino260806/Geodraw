import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geo_draw/core/construct/construct.dart';
import 'package:geo_draw/core/construct/constructcircle.dart';
import 'package:geo_draw/core/geometry_data/geometryset.dart';
import 'package:geo_draw/directive/dialog/base.dart';
import 'package:geo_draw/directive/directivelist.dart';
import 'package:geo_draw/ui/controller.dart';

class AddCircleDialog extends BaseDialog {
  @override
  State<StatefulWidget> createState() => _AddCircleDialogState();

}

class _AddCircleDialogState extends BaseDialogState<AddCircleDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _centerController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();
  final TextEditingController _diameterController = TextEditingController();
  final TextEditingController _dot1Controller = TextEditingController();
  final TextEditingController _dot2Controller = TextEditingController();
  final TextEditingController _dot3Controller = TextEditingController();

  AddCircleType _type = AddCircleType.CenterRadius;

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
          items: <DropdownMenuItem<AddCircleType>>[
            DropdownMenuItem(child: Text("Center and Radius"), value: AddCircleType.CenterRadius,),
            DropdownMenuItem(child: Text("Diameter"), value: AddCircleType.Diameter,),
            DropdownMenuItem(child: Text("3 Points"), value: AddCircleType.Points,),
          ],
          underline: const SizedBox(),
        ),
        switch(_type) {
          AddCircleType.CenterRadius =>
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                      controller: _centerController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("Center"),
                      ),
                    ),
                  SizedBox(height: 10,),
                  TextField(
                      controller: _radiusController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("Radius"),
                      ),
                    ),
                ],
              ),
          AddCircleType.Diameter =>
              TextField(
                controller: _diameterController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Diameter"),
                ),
              ),
          AddCircleType.Points =>
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _dot1Controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Point 1"),
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    controller: _dot2Controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Point 2"),
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    controller: _dot3Controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Point 3"),
                    ),
                  ),
                ],
              ),

        }
      ],
    );
  }

  @override
  String getTitle() => "Construct circle";

  @override
  void onAdd(BuildContext context, GeometrySet geometrySet, DirectiveList directiveList) {
    ConstructResult result;

    String name = _nameController.stripped;
    switch (_type) {
      case AddCircleType.CenterRadius:
        String centerName = _centerController.stripped;
        String sradius = _radiusController.stripped;
        result = directiveList.addAndExecute(
            ConstructCircleCenterRadius(name, centerName, sradius)
        );
      case AddCircleType.Diameter:
        String diameterName = _diameterController.stripped;
        result = directiveList.addAndExecute(
          ConstructCircleDiameter(name, diameterName)
        );
      case AddCircleType.Points:
        String dot1Name = _dot1Controller.stripped;
        String dot2Name = _dot2Controller.stripped;
        String dot3Name = _dot3Controller.stripped;
        result = directiveList.addAndExecute(
            ConstructCirclePoints(name, dot1Name, dot2Name, dot3Name)
        );
    }

    treatResult(result);
  }
}

enum AddCircleType {
  CenterRadius,
  Diameter,
  Points,
}