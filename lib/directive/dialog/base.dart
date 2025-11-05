import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geo_draw/core/construct/construct.dart';
import 'package:geo_draw/core/geometry_data/geometryset.dart';
import 'package:geo_draw/directive/directivelist.dart';
import 'package:provider/provider.dart';

abstract class BaseDialog extends StatefulWidget {
  const BaseDialog({super.key});
}

abstract class BaseDialogState<T extends BaseDialog> extends State<T> {
  String getTitle();
  Widget getContent();
  void onAdd(BuildContext context, GeometrySet geometrySet, DirectiveList directiveList) {}

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(getTitle()),
      content: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          primary: true,
          child: getContent(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            var geometrySet = Provider.of<GeometrySet>(context, listen: false);
            var directiveList = Provider.of<DirectiveList>(context, listen: false);

            Navigator.of(context).pop();
            onAdd(context, geometrySet, directiveList);
          },
          child: Text("Add", textScaleFactor: 1.2,),
        ),
      ],
    );
  }

  void treatResult(ConstructResult result) {
    if (result.isFail) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Not Added"),
            content: Text(result.failCause!.getMessage()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Ok", textScaleFactor: 1.2,),
              )
            ],
          );
        }
      );
    }
  }
}