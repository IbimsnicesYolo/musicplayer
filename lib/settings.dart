import 'dart:core';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'classes/song.dart';
import "classes/tag.dart";
import 'classes/playlist.dart';

final String Version = "Dev 1.8";
bool NewVersionAvailable = false; // Bool which shows that the config saved on the phone is older than the Apps Version
Color HomeColor = Color.fromRGBO(61, 61, 61, 0);
Color ContrastColor = Color.fromRGBO(0, 255, 76, 0);

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

void LoadData(void Function(void Function()) reload, MyAudioHandler _audioHandler) {
  String appDocDirectory = "storage/emulated/0/Music";

  try {
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
            _audioHandler.LoadPlaylist();
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
          _audioHandler.LoadPlaylist();
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
  } catch (e) {
    print(e);
  }
}
