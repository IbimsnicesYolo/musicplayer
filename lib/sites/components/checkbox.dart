import 'package:flutter/material.dart';

class CoolerCheckBox extends StatefulWidget {
  CoolerCheckBox(
    this.b,
    this.c,
    this.Info, {
    Key? key,
  }) : super(key: key);

  bool b;
  String Info;
  void Function(bool?) c;

  @override
  State<CoolerCheckBox> createState() =>
      _CoolerCheckBox(text: Info, c: c, isChecked: b);
}

class _CoolerCheckBox extends State<CoolerCheckBox> {
  _CoolerCheckBox(
      {required this.text, required this.c, required this.isChecked});
  bool isChecked;

  final void Function(bool?) c;
  final String text;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          splashRadius: 200,
          checkColor: Colors.white,
          fillColor: MaterialStateProperty.resolveWith(getColor),
          value: isChecked,
          onChanged: (bool? value) {
            setState(() {
              isChecked = value!;
            });
            c(value);
          },
        ),
        Text(text),
      ],
    );
  }
}
