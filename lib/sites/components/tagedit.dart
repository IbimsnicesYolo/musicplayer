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
                    for (var i = 0; i < Tags.length; i += 2)
                      if (Tags.containsKey(i))
                        CoolerCheckBox(Songs[s.filename].tags.contains(i),
                            (bool? b) {
                          ToUpdate[s.filename] = [i, b];
                        }, Tags[i].name),
                  ],
                ),
                Column(
                  children: [
                    for (var i = 1; i < Tags.length; i += 2)
                      if (Tags.containsKey(i))
                        CoolerCheckBox(Songs[s.filename].tags.contains(i),
                            (bool? b) {
                          ToUpdate[s.filename] = [i, b];
                        }, Tags[i].name),
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: CFG.ContrastColor,
          onPressed: () {
            Navigator.of(context).pop(-1);
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
                    for (var i = 0; i < Tags.length; i += 2)
                      if (Tags.containsKey(i))
                        StyledElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(i);
                          },
                          child: Text(Tags[i].name),
                        ),
                  ],
                ),
                Column(
                  children: [
                    for (var i = 1; i < Tags.length; i += 2)
                      if (Tags.containsKey(i))
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
          ],
        ),
      ),
    );
  }
}
