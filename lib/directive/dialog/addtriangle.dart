import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geo_draw/core/geometry_data/dot.dart';
import 'package:geo_draw/core/geometry_data/geometryset.dart';
import 'package:geo_draw/core/geometry_data/line.dart';
import 'package:geo_draw/core/geometry_data/segment.dart';
import 'package:geo_draw/core/geometry_data/triangle.dart';
import 'package:geo_draw/core/name/triangle.dart';
import 'package:geo_draw/core/prop/point.dart';
import 'package:geo_draw/directive/dialog/base.dart';
import 'package:geo_draw/directive/directivelist.dart';
import 'package:geo_draw/ui/controller.dart';

import 'package:provider/provider.dart';

class AddTriangleDialog extends BaseDialog {
  @override
  State<StatefulWidget> createState() => _AddTriangleDialogState();

}

class _AddTriangleDialogState extends BaseDialogState<AddTriangleDialog> {
  final TextEditingController _nameController = TextEditingController();

  AddTriangleType _type = AddTriangleType.Equilateral;

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
          items: <DropdownMenuItem<AddTriangleType>>[
            DropdownMenuItem(child: Text("Equilateral"), value: AddTriangleType.Equilateral,),
          ],
          underline: const SizedBox(),
        ),
        switch(_type) {
          AddTriangleType.Equilateral => SizedBox(),
              // Flex(
              //   direction: Axis.horizontal,
              //   mainAxisSize: MainAxisSize.max,
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Expanded(
              //       child: TextField(
              //         controller: _xController,
              //         decoration: InputDecoration(
              //           border: OutlineInputBorder(),
              //           label: Text("X"),
              //         ),
              //       ),
              //     ),
              //     SizedBox(width: 5,),
              //     Expanded(
              //       child: TextField(
              //         controller: _yController,
              //         decoration: InputDecoration(
              //           border: OutlineInputBorder(),
              //           label: Text("Y"),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
        }
      ],
    );
  }

  @override
  String getTitle() => "Construct triangle";

  @override
  void onAdd(BuildContext context, GeometrySet geometrySet, DirectiveList directiveList) {
    TriangleNameMatcher nameMatcher = TriangleNameMatcher(_nameController.stripped);
    TriangleName? name = nameMatcher.match();
    if (name == null) {
      // TODO error
      return;
    }
    List<String> dotNames = [name.dot1, name.dot2, name.dot3];

    switch (_type) {
      case AddTriangleType.Equilateral:
        List<String> toRemove = [];
        List<Dot> presentDots = dotNames
            .map((name) {
              Dot? dot = geometrySet.findDot(name);
              if (dot != null) toRemove.add(name);
              return dot;
            })
            .whereType<Dot>()
            .toList();
        for (var dotName in toRemove) {
          dotNames.remove(dotName);
        }
        Dot dot1, dot2, dot3;
        if (presentDots.isEmpty) {
          dot1 = Dot(dotNames[0], Point(0, 0));
          dot2 = Dot(dotNames[1], Point(1, 0));
          dot3 = Dot(dotNames[2], Point(0.5, sqrt(3) / 2));
          geometrySet.addObject(dot1);
          geometrySet.addObject(dot2);
          geometrySet.addObject(dot3);
          geometrySet.addObject(Segment.fromDots(null, dot1, dot2));
          geometrySet.addObject(Segment.fromDots(null, dot1, dot3));
          geometrySet.addObject(Segment.fromDots(null, dot2, dot3));
        } else if (presentDots.length == 1) {
          dot1 = presentDots[0];
          dot2 = Dot(dotNames[0], Point(dot1.point.x + 1, dot1.point.y));
          dot3 = Dot(dotNames[1], Point(dot1.point.x + 0.5, dot1.point.y + sqrt(3) / 2));
          geometrySet.addObject(dot2);
          geometrySet.addObject(dot3);
          geometrySet.addObject(Segment.fromDots(null, dot1, dot3));
          geometrySet.addObject(Segment.fromDots(null, dot1, dot2));
          geometrySet.addObject(Segment.fromDots(null, dot3, dot2));
        } else if (presentDots.length == 2) {
          dot1 = presentDots[0];
          dot2 = presentDots[1];
          double side = Segment.getDistance(dot1.point, dot2.point);
          dot3 = Dot.completeTriangle(dotNames[0], dot1, dot2,
              Triangle(side1: side, side2: side, side3: side));
          geometrySet.addObject(dot3);
          geometrySet.addObject(Segment.fromDots(null, dot1, dot3));
          geometrySet.addObject(Segment.fromDots(null, dot1, dot2));
          geometrySet.addObject(Segment.fromDots(null, dot3, dot2));
        }
    }
    geometrySet.invalidate();
  }
}

enum AddTriangleType {
  Equilateral
}