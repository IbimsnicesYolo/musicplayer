import 'dart:core';
import 'dart:io';
import "dart:ui";
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

final Color StandardTag = Color.fromRGBO(100, 255, 255, 255);
final Color HomeColor = Color.fromRGBO(100, 255, 0, 255);
final Color ContrastColor = Color.fromRGBO(0, 0, 0, 100);

class Song {
  String path = "";
  String title = "Song Title";
  String interpret = "Song Interpret";
  List tags = [];
  Song(this.path);
  Info() {
    print("Song Info");
    print(path);
    print(title);
    print(interpret);
    print(tags.toString());
  }

  Song.fromJson(Map<String, dynamic> json)
      : path = json['p'],
        title = json['t'],
        interpret = json['i'],
        tags = json['ta'];
  Map<String, dynamic> toJson(Song value) => {
        'p': value.path,
        't': value.title,
        'i': value.interpret,
        'ta': value.tags
      };
}

class Tag {
  String name = "New Tag";
  Color color = StandardTag;
  int id = -1;
  Tag(this.name);
  Tag.fromJson(Map<String, dynamic> json)
      : name = json['n'],
        color = json['c'],
        id = json['i'];
  Map<String, dynamic> toJson(Tag value) =>
      {'n': value.name, 'c': value.color, 'i': value.id};
}

Map Songs = {};
Map UnsortedSongs = {};
Map Tags = {};

void LoadData(VoidCallback callback) async {
  print("Loading Data");
  Directory appDocDirectory = await getApplicationDocumentsDirectory();
  new File(appDocDirectory.path + '/songs.json')
      .create(recursive: true)
      .then((File file) {
    file.readAsString().then((String contents) {
      if (contents.isNotEmpty) {
        jsonDecode(contents).forEach((key, value) {
          Song currentsong = Song.fromJson(value);
          if (currentsong.tags.isEmpty) {
            UnsortedSongs[key] = currentsong;
          } else {
            Songs[key] = currentsong;
          }
          print("Loaded Song: " + currentsong.title);
        });
      }
    });
  });
  new File(appDocDirectory.path + '/tags.json')
      .create(recursive: true)
      .then((File file) {
    file.readAsString().then((String contents) {
      if (contents.isNotEmpty) {
        jsonDecode(contents).forEach((key, value) {
          Tags[key] = Tag.fromJson(value);
          print("Loaded Tag: " + Tags[key].name);
        });
      }
    });
  });
  callback();
}

void SaveSongs() async {
  Directory appDocDirectory = await getApplicationDocumentsDirectory();
  String json = "{";
  Songs.forEach((k, v) {
    json += '"' + k + '":' + jsonEncode(v.toJson(v)) + ",";
  });
  File(appDocDirectory.path + '/songs.json').writeAsString(
      json.substring(0, json.length - 1) +
          "}"); // remove last comma, close json
}

void SaveTags() async {
  Directory appDocDirectory = await getApplicationDocumentsDirectory();
  String json = "";
  Tags.forEach((k, v) {
    json += '"' + k + '":' + jsonEncode(v.toJson(v)) + ",";
  });
  File(appDocDirectory.path + '/tags.json').writeAsString(
      json.substring(0, json.length - 1) +
          "}"); // remove last comma, close json
}

void CreateSong(path) {
  if (Songs.containsKey(path)) {
    print("Trying to create existing Song!");
    return;
  }
  String interpret =
      path.split("/").last.split(" - ").first.replaceAll(RegExp(".mp3"), "");

  String title = path
      .split("/")
      .last
      .split(" - ")
      .last
      .replaceAll(RegExp(".mp3"), "")
      .split(" _ ")
      .first;

  print("Creating new Song: $path");
  Song newsong = Song(path);
  newsong.title = title;
  newsong.interpret = interpret;
  Songs[path] = newsong;
  SaveSongs();
}

void CreateTag(name) {
  if (Tags.containsKey(name)) {
    print("Trying to create existing Tag!");
    return;
  }
  print("Creating new Tag: $name");
  Tag newtag = Tag(name);
  newtag.id = Tags.length + 1;
  Tags[name] = newtag;
  SaveTags();
}
