import 'package:flutter/material.dart';

import "../../settings.dart";
import "checkbox.dart";
import "elevatedbutton.dart";

// Search Page
class TagEdit extends StatefulWidget {
  const TagEdit(this.s, {Key? key}) : super(key: key);

  final Song s;

  @override
  State<TagEdit> createState() => _TagEdit(s: s);
}

class _TagEdit extends State<TagEdit> {
  _TagEdit({required this.s});
  Song s;

  TextEditingController create = TextEditingController();
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
    List<Tag> InSong = [];

    for (int i = 0; i < Tags.length; i++) {
      if (Tags.containsKey(i) && s.tags.contains(i)) {
        InSong.add(Tags[i]);
      }
    }

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
            backgroundColor: HomeColor,
            // The search area here
            title: const Text("Tag Editor")),
        backgroundColor: Colors.blueGrey,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: ContrastColor,
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
            for (int i = 0; i < InSong.length; i = i + 2)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CoolerCheckBox(s.tags.contains(InSong[i].id), (bool? b) {
                    ToUpdate[s.filename] = [InSong[i].id, b];
                  }, InSong[i].name),
                  if (i + 1 < InSong.length)
                    CoolerCheckBox(s.tags.contains(InSong[i + 1].id), (bool? b) {
                      ToUpdate[s.filename] = [InSong[i + 1].id, b];
                    }, InSong[i + 1].name),
                ],
              ),
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
                    ToUpdate[s.filename] = [id, true];
                    ToUpdate.forEach((key, value) {
                      UpdateSongTags(key, value[0], value[1]);
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text("Create Tag")),
            for (int i = 1; i < Tags.length; i++)
              if (Tags.containsKey(i) && !s.tags.contains(i))
                if (create.text == "" ||
                    Tags[i].name.toLowerCase().contains(create.text.toLowerCase()))
                  CoolerCheckBox(s.tags.contains(i), (bool? b) {
                    ToUpdate[s.filename] = [i, b];
                  }, Tags[i].name),
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
            backgroundColor: HomeColor,
            // The search area here
            title: const Text("Tag Chooser")),
        backgroundColor: Colors.blueGrey,
        floatingActionButton: FloatingActionButton(
          backgroundColor: ContrastColor,
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
                  if (create.text.trim() != "") {
                    int id = CreateTag(create.text.trim());
                    Navigator.of(context).pop(id);
                  }
                },
                child: const Text("Create Tag")),
            if (create.text.trim() == "")
              for (int i = 0; i < Tags.length; i = i + 2)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    if (Tags.containsKey(i))
                      StyledElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(i);
                        },
                        child: Text(Tags[i].name),
                      ),
                    if (Tags.length > i + 1 && Tags.containsKey(i + 1))
                      StyledElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(i + 1);
                        },
                        child: Text(Tags[i + 1].name),
                      ),
                  ],
                ),
            if (create.text.trim() != "")
              for (int i = 0; i < Tags.length; i++)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    if (Tags.containsKey(i) &&
                        Tags[i].name.toLowerCase().contains(create.text.toLowerCase()))
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
