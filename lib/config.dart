import 'dart:core';
import 'dart:io';
import "dart:ui";
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

final Color StandardTag = Color.fromRGBO(100, 255, 255, 255);

class Song {
  String path = "";
  String title = "Song Title";
  String interpret = "Song Interpret";
  List tags = [];
  Song();
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
  Tag();
  Tag.fromJson(Map<String, dynamic> json)
      : name = json['n'],
        color = json['c'],
        id = json['i'];
  Map<String, dynamic> toJson(Tag value) =>
      {'n': value.name, 'c': value.color, 'i': value.id};
}

List Songs = [];
List Tags = [];

void LoadData() async {
  Directory appDocDirectory = await getApplicationDocumentsDirectory();
  new File(appDocDirectory.path + '/songs.json')
      .create(recursive: true)
      .then((File file) {
    file.readAsString().then((String contents) {
      if (contents.isNotEmpty) {
        Map<String, dynamic> M = jsonDecode(contents);
        var song = Song.fromJson(M);
        print(song.title);
        Songs.add(song);
      }
    });
  });
  new File(appDocDirectory.path + '/tags.json')
      .create(recursive: true)
      .then((File file) {
    file.readAsString().then((String contents) {
      if (contents.isNotEmpty) {
        Map<String, dynamic> M = jsonDecode(contents);
        var tag = Tag.fromJson(M);
        print(tag.name);
        Tags.add(tag);
      }
    });
  });
}

void SaveSongs() async {
  Directory appDocDirectory = await getApplicationDocumentsDirectory();
  String json = "";
  for (Song s in Songs) {
    json += jsonEncode(s.toJson(s));
  }
  File(appDocDirectory.path + '/songs.json').writeAsString(json);
}

void SaveTags() async {
  Directory appDocDirectory = await getApplicationDocumentsDirectory();
  String json = "";
  for (Tag t in Tags) {
    json += jsonEncode(t.toJson(t));
  }
  File(appDocDirectory.path + '/tags.json').writeAsString(json);
}

void CreateSong(path) {
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
  //print("Path:\t\t $path");
  //print("Interpret:\t $interpret");
  //print("Title:\t\t $title");
  //print("\n\n");

  Song newsong = Song();
  newsong.path = path;
  newsong.title = title;
  newsong.interpret = interpret;

  Songs.add(newsong);
  SaveSongs();
}
