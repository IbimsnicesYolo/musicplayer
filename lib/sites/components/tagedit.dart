import 'package:flutter/material.dart';
import '../../classes/tag.dart';
import '../../classes/song.dart';
import "checkbox.dart";
import "elevatedbutton.dart";
import "../../settings.dart" as CFG;

// Search Page
class TagEdit extends StatefulWidget {
  TagEdit(this.s, {Key? key}) : super(key: key);

  Song s;

  @override
  State<TagEdit> createState() => _TagEdit(s: s);
}

class _TagEdit extends State<TagEdit> {
  _TagEdit({required this.s});
  Song s;

  Map<String, List> ToUpdate = {};

  void update(void Function() c) {
    setState(
      () {
        c();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
                ToUpdate.forEach((key, value) {
                  UpdateSongTags(key, value[0], value[1]);
                });
              },
              icon: const Icon(Icons.arrow_back),
            ),
            backgroundColor: CFG.HomeColor,
            // The search area here
            title: const Text("Tag Editor")),
        backgroundColor: Colors.blueGrey,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: CFG.ContrastColor,
          onPressed: () {
            Navigator.pop(context);
            ToUpdate.forEach((key, value) {
              UpdateSongTags(key, value[0], value[1]);
            });
          },
          child: const Icon(Icons.arrow_back),
        ),
        body: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    for (Tag t in Tags.values)
                      if ((t.id % 2 == 0))
                        CoolerCheckBox(Songs[s.filename].tags.contains(t.id),
                            (bool? b) {
                          ToUpdate[s.filename] = [t.id, b];
                        }, t.name),
                  ],
                ),
                Column(
                  children: [
                    for (Tag t in Tags.values)
                      if ((t.id % 2 == 1))
                        CoolerCheckBox(Songs[s.filename].tags.contains(t.id),
                            (bool? b) {
                          ToUpdate[s.filename] = [t.id, b];
                        }, t.name),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Search Page
class TagChoose extends StatefulWidget {
  const TagChoose({Key? key}) : super(key: key);

  @override
  State<TagChoose> createState() => _TagChoose();
}

class _TagChoose extends State<TagChoose> {
  TextEditingController create = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop(-1);
              },
              icon: const Icon(Icons.arrow_back),
            ),
            backgroundColor: CFG.HomeColor,
            // The search area here
            title: const Text("Tag Chooser")),
        backgroundColor: Colors.blueGrey,
        floatingActionButton: FloatingActionButton(
          backgroundColor: CFG.ContrastColor,
          onPressed: () {
            Navigator.of(context).pop(-1);
          },
          child: const Icon(Icons.arrow_back),
        ),
        body: ListView(
          children: [
            TextField(
              controller: create,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Tag Name',
              ),
              onChanged: (String value) {
                setState(() {});
              },
            ),
            StyledElevatedButton(
                onPressed: () {
                  if (create.text != "") {
                    int id = CreateTag(create.text.trim());
                    Navigator.of(context).pop(id);
                  }
                },
                child: const Text("Create Tag")),
            if (create.text == "")
              for (int i = 0; i <= Tags.length; i = i + 2)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    StyledElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(i);
                      },
                      child: Text(Tags[i].name),
                    ),
                    if (Tags.length > i + 1)
                      StyledElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(i + 1);
                        },
                        child: Text(Tags[i + 1].name),
                      ),
                  ],
                ),
            if (create.text != "")
              for (int i = 0; i < Tags.length; i++)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    if (Tags[i]
                        .name
                        .toLowerCase()
                        .contains(create.text.toLowerCase()))
                      StyledElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(i);
                        },
                        child: Text(Tags[i].name),
                      ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
/*

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (Tag t in Tags.values)
                  if ((t.id % 2 == 1))
                    StyledElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(t.id);
                      },
                      child: Text(t.name),
                    ),
                  ],
                ),
              ],
            ),
 */
