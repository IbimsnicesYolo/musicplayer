import 'package:flutter/material.dart';
import '../../classes/tag.dart';
import '../../classes/song.dart';
import "checkbox.dart";

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
  @override
  void dispose() {

    super.dispose();
  }

  void update(void Function() c) {
    setState(
          () {
        c();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
          ToUpdate.forEach((key, value) {
            UpdateSongTags(key, value[0], value[1]);
          });
        },
          child: const Icon(Icons.arrow_back),
      ),
          body: Column(
            children: [
              for (Tag t in Tags.values)
                CoolerCheckBox(Songs[s.filename].tags.contains(t.id),
                        (bool? b) {
                      ToUpdate[s.filename] = [t.id, b];
                    }, t.name),
            ],
          ),

    );
  }
}