import 'package:flutter/material.dart';
import 'package:geo_draw/core/construct/construct.dart';
import 'package:geo_draw/core/construct/constructpoint.dart';
import 'package:geo_draw/core/construct/interpret.dart';
import 'package:geo_draw/core/geometry_data/geometryset.dart';
import 'package:geo_draw/directive/dialog/base.dart';
import 'package:geo_draw/directive/directivelist.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:geo_draw/ui/status.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:provider/provider.dart';

class AddAIDialog extends BaseDialog {
  @override
  State<StatefulWidget> createState() => _AddAIDialogState();

}

class _AddAIDialogState extends BaseDialogState<AddAIDialog> {
  final TextEditingController _commandController = TextEditingController();
  final Gemini gemini = Gemini.instance;
  final SpeechToText speech = SpeechToText();

  bool _isListening = false;

  @override
  Widget getContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("Drawing description", style: TextStyle(fontSize: 18),),
        SizedBox(
          width: 400,
          child: TextField(
            controller: _commandController,
            minLines: 1,
            maxLines: 1,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              suffixIcon: Padding(
                padding: EdgeInsets.all(4.0),
                child: IconButton.filledTonal(
                  isSelected: _isListening,
                  icon: Icon(Icons.mic_none),
                  selectedIcon: Icon(Icons.mic),
                  onPressed: () {
                    if (!_isListening) {
                      speech.initialize().then((available) {
                        if (available) {
                          setState(() {
                            _isListening = true;
                          });
                          speech.listen(
                            onResult: onSpeechResult,
                            localeId: "fr",
                          );
                        }
                      });
                    } else {
                      speech.stop();
                      setState(() {
                        _isListening = false;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  String getTitle() => "AI Drawer";

  void onSpeechResult(SpeechRecognitionResult result) {
    _commandController.text = result.recognizedWords;
  }

  @override
  void onAdd(BuildContext context, GeometrySet geometrySet, DirectiveList directiveList) {
    UiStatus uiStatus = Provider.of<UiStatus>(context, listen: false);

    if (_isListening) {
      _isListening = false;
      speech.stop();
    }

    String rawCommand = _commandController.text;

    gemini.text(
      [
        "You are the brain behind a geometric construction program that uses speech recognition to build geometric figures.\n\nYou will receive geometric instructions that you need to classify to a suitable format. Between parentheses you will find the explanation of a previous command\n\n\nline {l1}/{s1}\n(draws a line with name l1 moving through the segment s1)\n\nsegment {s1} \n(draws a segment with name s1)\n\npoint {p1}/{xy1} \n(marks a point p1 with coordinates c1)\n\nmiddle {p1}/{s1}\n(marks the point p1 at the middle of the segment s1)\n\ncircle {c1}/{p1}/{r1}\n(draws a circle c1 with radius r1 and center p1)\ncircle {c1}/{p1}/{s1}\n(draws a circle c1 with radius s1 and center p1)\ncircle {c1}/{s1}\n(draws a circle c1 with diameter s1)\ncircle {c1}/{p1}/{p2}/{p3}\n(draws a circle c1 moving through the point p1, the point p2 and the point p3)\n\ntangent {l1}/{c1}/{p1}\n(draws the line l1 tangent to the circle c1 at point p1)\n\ninterlineline {p1}/{l1}/{l2}\n(marks p1 the intersection point between l1 and l2) \n\ninterlinecircle {p1}/{p2}/{l1}/{c1}\n(marks p1 and p2 the intersection points between l1 and c1) \n\ninterlinecircle {p1}/{l1}/{c1}\n(marks p1 the intersection points between l1 and c1) \n\nintercirclecircle {p1}/{p2}/{l1}/{c1}\n(marks p1 and p2 the intersection points between c1 and c2) \n\nperp {l1}/{l2}/{p1}\n(draws the line l1 perpendicular to the line l2 and passing through p1) \n\nparall {l1}/{l2}/{p1}\n(draws the line l1 parallel to the line l2 and passing through p1) \n\n* {r..} is a real number and does not contain a \"/\"\n* {p..} is a point name and does not contain a \"/\", it can have ' in the name\n* {l..} is a line name  and does not contain a \"/\", it can have ' in the name\n* {s..} is a segment name and does not contain a \"/\", it can have ' in the name\n* {c..} is a circle name and does not contain a \"/\", it can have ' in the name\n* {xy..} is a coordinate in the form (x, y) where x and y can only be numerical values and does not contain a \"/\"\n\nYou must ONLY output ONE line corresponding to the classified and simplified command without any additional explanation or remarks. You MUST follow the commands format matching the number of parameters, and DON'T leave ANY parameter at the form {..}. You MUST always seperate parameters using /.",
        "input: draw a line from A to B",
        "output: line AB/AB",
        "input: mark the point A with coordinates 5 90",
        "output: point A/(5,90)",
        "input: draw a line from A to B called delta",
        "output: line delta/AB",
        "input: $rawCommand",
        "output: ",
      ].join("\n\n"),
      generationConfig: GenerationConfig(
        temperature: 0,
      )
    ).then((value) {
      ConstructResult result = ConstructResult.fail(UnknownFailCause());

      print(value);
      String? command = value?.output;
      print(command);
      if (command != null) {
        var interpreter = ConstructInterpreter(command);
        ConstructDirective? directive = interpreter.interpret();
        print(directive);
        if (directive != null) {
          result = directiveList.addAndExecute(directive);
        }
      }
      uiStatus.isLoading = false;

      treatResult(result);
    });

    uiStatus.isLoading = true;
  }
}
