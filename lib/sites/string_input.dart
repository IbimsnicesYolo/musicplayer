import 'package:flutter/material.dart';
import "../settings.dart" as CFG;

class StringInput extends StatelessWidget {
  StringInput({
    Key? key,
    required this.Title,
    required this.TitlePopup,
    required this.Button1,
    required this.Button2,
    required this.OnPressed1,
    required this.OnPressed2,
    required this.context,
  }) : super(key: key);

  @override
  void dispose() {
    _textFieldController.dispose();
  }

  final TextEditingController _textFieldController = TextEditingController();
  final String Title;
  final String TitlePopup;
  final String Button1;
  final String Button2;
  final void Function(dynamic) OnPressed1;
  final void Function(dynamic) OnPressed2;
  final context;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AlertDialog(
              title: Text(TitlePopup),
              content: TextField(
                onChanged: (value) {},
                controller: _textFieldController,
                decoration: InputDecoration(hintText: "Tag Name"),
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.red,
                  ),
                  child: Text(Button2),
                  onPressed: () {
                    OnPressed1(_textFieldController.text);
                    _textFieldController.clear();
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.green,
                  ),
                  child: Text(Button1),
                  onPressed: () {
                    OnPressed2(_textFieldController.text);
                    _textFieldController.clear();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Text(Title),
    );
  }
}
