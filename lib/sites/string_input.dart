import 'package:flutter/material.dart';
import "../settings.dart" as CFG;

// Possible Overflow because _textFieldController never gets disposed

void StringInput(
    context,
    String TitlePopup,
    String Button1,
    String Button2,
    void Function(String) OnPressed1,
    void Function(String) OnPressed2,
    bool clearbutton,
    String value) {
  TextEditingController _textFieldController = TextEditingController();
  _textFieldController.text = value;

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
          if (clearbutton)
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.lightGreenAccent,
              ),
              child: const Text("Strip ()"),
              // replace all () with ""
              onPressed: () {
                _textFieldController.text =
                    _textFieldController.text.replaceAll(RegExp(r"\(.*\)"), "");
              },
            ),
          TextButton(
            style: TextButton.styleFrom(
              primary: Colors.white,
              backgroundColor: Colors.red,
            ),
            child: Text(Button2),
            onPressed: () {
              OnPressed2(_textFieldController.text);
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
              OnPressed1(_textFieldController.text);
              _textFieldController.clear();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}
