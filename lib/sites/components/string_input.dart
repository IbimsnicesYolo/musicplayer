import 'package:flutter/material.dart';
import "../../settings.dart" as CFG;
import "elevatedbutton.dart";
// Possible Overflow because _textFieldController never gets disposed
// Hint Text is constantly Tag Name

void StringInput(
    context,
    String TitlePopup,
    String Button1,
    String Button2,
    void Function(String) OnPressed1,
    void Function(String) OnPressed2,
    bool clearbutton,
    String value,
    String htext) {
  TextEditingController _textFieldController = TextEditingController();
  _textFieldController.text = value;

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => MaterialApp(
        theme: ThemeData.dark(),
        home: AlertDialog(
          title: Text(TitlePopup),
          content: TextField(
            onChanged: (value) {},
            controller: _textFieldController,
            decoration: InputDecoration(hintText: htext),
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
                  _textFieldController.text = _textFieldController.text
                      .replaceAll(RegExp(r"\(.*\)"), "")
                      .trim();
                },
              ),
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: Text(Button2),
              onPressed: () {
                OnPressed2(_textFieldController.text.trim());
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
                OnPressed1(_textFieldController.text.trim());
                _textFieldController.clear();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class StringInputExpanded extends StatefulWidget {
  const StringInputExpanded({
    Key? key,
    required this.Title,
    required this.Text,
    required this.additionalinfos,
    required this.OnSaved,
  }) : super(key: key);

  final String Title;
  final String Text;
  final String additionalinfos;
  final void Function(String) OnSaved;

  @override
  State<StringInputExpanded> createState() => _StringInputExpanded();
}

class _StringInputExpanded extends State<StringInputExpanded> {
  @override
  Widget build(BuildContext context) {
    TextEditingController _textFieldController =
        TextEditingController(text: widget.Text);

    List<String> possibleinputs = [];

    widget.Text.split(" ").forEach((element) {
      if (element.length > 2) {
        possibleinputs.add(element);
      }
    });

    widget.additionalinfos.split(" ").forEach((element) {
      element = element.replaceAll(".mp3", "").replaceAll("Lyrics", "").trim();
      possibleinputs.add(element);
      element.split(" ").forEach((element) {
        possibleinputs.add(element);
      });
    });
    possibleinputs.add("Unknown");

    possibleinputs = possibleinputs.toSet().toList();
    return MaterialApp(
      theme: ThemeData.dark(),
      home: SafeArea(
        child: Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton(
            backgroundColor: CFG.ContrastColor,
            onPressed: () =>
                Navigator.of(context).pop(_textFieldController.text.trim()),
            child: const Icon(Icons.arrow_back),
          ),
          appBar: AppBar(
            title: Text(widget.Title),
            backgroundColor: CFG.HomeColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () =>
                  Navigator.of(context).pop(_textFieldController.text.trim()),
            ),
          ),
          body: Container(
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: TextField(
                    controller: _textFieldController,
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _textFieldController.clear();
                          },
                        ),
                        border: OutlineInputBorder(),
                        labelText: 'New Name'),
                  ),
                ),
                ListTile(
                  title: widget.additionalinfos,
                  onTap: () {
                    _textFieldController.text += " " + s;
                  },
                ),
                for (int i = 0; possibleinputs.length; i = i + 2) {
                  Row(
                    children: <Widget>[
                      if possibleinputs[i] {
                        StyledElevatedButton(
                          child: Text(possibleinputs[i]),
                          onPressed: () {
                            _textFieldController.text += " " + possibleinputs[i];
                          },
                        )
                      },
                      if possibleinputs[i + 1] {
                          StyledElevatedButton(
                          child: Text(possibleinputs[i + 1]),
                          onPressed: () {
                            _textFieldController.text += " " + possibleinputs[i + 1];
                          },
                        ),
                      },
                    ],
                  ),
                }
              ],
            ),
          ),
        ),
      ),
    );
  }
}