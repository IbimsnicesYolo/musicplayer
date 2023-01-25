import 'dart:core';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'classes/song.dart';
import "classes/tag.dart";

final String Version = "Dev 1.6";
bool NewVersionAvailable =
    false; // Bool which shows that the config saved on the phone is older than the Apps Version
Color HomeColor = Color.fromRGBO(61, 61, 61, 255);
Color ContrastColor = Color.fromRGBO(0, 255, 75, 255);

const List<String> Actions = [
  "Remove From Playlist",
  "Add To Playlist",
  "Play Next",
  "Add to Stack",
];

Map Config = {
  "HomeColor": HomeColor.value,
  "ContrastColor": ContrastColor.value,
  "SearchPaths": [
    "storage/emulated/0/Music",
    "storage/emulated/0/Download",
    "C:",
    "D:",
    "Library"
  ],
  "Playlist": [],
  "Version": Version,
};

/* Config */
void SaveConfig() {
  SaveSongs();
  String appDocDirectory = "storage/emulated/0/Music";
  File(appDocDirectory + '/config.json')
      .create(recursive: true)
      .then((File file) {
    file.writeAsString(jsonEncode(Config));
  });
}

/*  Misc  */
Future<void> ShowSth(String info, context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(info),
        content: const Text(""),
        actions: <Widget>[
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void LoadData(void Function(void Function()) reload) {
  String appDocDirectory = "storage/emulated/0/Music";

  // Load Config
  File(appDocDirectory + '/config.json')
      .create(recursive: true)
      .then((File file) {
    file.readAsString().then((String contents) {
      if (contents.isNotEmpty) {
        jsonDecode(contents).forEach((key, value) {
          Config[key] = value;
          if (key == "Version") {
            if (value != Version) {
              NewVersionAvailable = true;
            }
          }
        });
      }
      reload(() {});
    });
  });
  if (Songs.isEmpty) {
    // Load Songs
    File(appDocDirectory + '/songs.json')
        .create(recursive: true)
        .then((File file) {
      file.readAsString().then((String contents) {
        if (contents.isNotEmpty) {
          jsonDecode(contents).forEach((key, value) {
            Song currentsong = Song.fromJson(value);
            Songs[key] = currentsong;
          });
        }
        ValidateSongs();
        reload(() {});
      });
    });
  }

  if (Tags.isEmpty) {
    // Load Tags
    File(appDocDirectory + '/tags.json')
        .create(recursive: true)
        .then((File file) {
      file.readAsString().then((String contents) {
        if (contents.isNotEmpty) {
          jsonDecode(contents).forEach((key, value) {
            Tag currenttag = Tag.fromJson(value);
            Tags[currenttag.id] = currenttag;
          });
        }
        reload(() {});
      });
    });
    UpdateAllTags();
  }
}
