import 'dart:core';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:external_path/external_path.dart';

final Color HomeColor = Color.fromRGBO(100, 255, 0, 255);
final Color ContrastColor = Color.fromRGBO(0, 0, 0, 100);

Map Songs = {};
Map UnsortedSongs = {};
Map Tags = {};

Future<void> ShowSth(String info, context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(info),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[],
          ),
        ),
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

void LoadData() async {
  print("Loading Data");
  String appDocDirectory = await ExternalPath.getExternalStoragePublicDirectory(
      ExternalPath.DIRECTORY_DOCUMENTS);
  File(appDocDirectory + '/songs.json')
      .create(recursive: true)
      .then((File file) {
    file.readAsString().then((String contents) {
      if (contents.isNotEmpty) {
        jsonDecode(contents).forEach((key, value) {
          Song currentsong = Song.fromJson(value); // TODO: Check if file exists
          if (currentsong.tags.isEmpty) {
            UnsortedSongs[key] = currentsong;
          } else {
            Songs[key] = currentsong;
          }
        });
      }
    });
  });
  ValidateSongs();

  File(appDocDirectory + '/tags.json')
      .create(recursive: true)
      .then((File file) {
    file.readAsString().then((String contents) {
      if (contents.isNotEmpty) {
        jsonDecode(contents).forEach((key, value) {
          Tag currenttag = Tag.fromJson(value);
          Tags[currenttag.id] = currenttag;
          GetSongsFromTag(currenttag);
        });
      }
    });
  });
}

/* Songs */
class Song {
  String path = "";
  String filename = "";
  String title = "Song Title";
  String interpret = "Song Interpret";
  List tags = [];
  Song(this.path);
  Info() {
    print("Song Info");
    print(path);
    print(filename);
    print(title);
    print(interpret);
    print(tags.toString());
  }

  Song.fromJson(Map<String, dynamic> json)
      : path = json['p'],
        filename = json['f'],
        title = json['t'],
        interpret = json['i'],
        tags = json['ta'];
  Map<String, dynamic> toJson(Song value) => {
        'p': value.path,
        'f': value.filename,
        't': value.title,
        'i': value.interpret,
        'ta': value.tags
      };
}

class CurrentPlayList {
  List<Song> songs = [];
  int current = 0;
}

bool CreateSong(path) {
  String filename = path.split("/").last;
  if (Songs.containsKey(filename) || UnsortedSongs.containsKey(filename)) {
    return false;
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

  Song newsong = Song(path);
  newsong.title = title;
  newsong.filename = filename;
  newsong.interpret = interpret;
  UnsortedSongs[filename] = newsong;
  return true;
}

void UpdateSongInterpret(Song s, String newtitle) {
  s.interpret = newtitle;
  SaveSongs();
}

void UpdateSongTitle(Song s, String newtitle) {
  s.title = newtitle;
  SaveSongs();
}

void UpdateSongTags(Song s, List newtags) {
  s.tags = newtags;
  SaveSongs();
}

void DeleteSong(Song s) {
  if (Songs.containsKey(s.filename)) {
    Songs.remove(s.filename);
  }
  if (UnsortedSongs.containsKey(s.filename)) {
    UnsortedSongs.remove(s.filename);
  }
  SaveSongs();
}

void SaveSongs() async {
  String appDocDirectory = await ExternalPath.getExternalStoragePublicDirectory(
      ExternalPath.DIRECTORY_DOCUMENTS);
  String json = "{";
  Songs.forEach((k, v) {
    json += '"' + k + '":' + jsonEncode(v.toJson(v)) + ",";
  });
  UnsortedSongs.forEach((k, v) {
    json += '"' + k + '":' + jsonEncode(v.toJson(v)) + ",";
  });
  File(appDocDirectory + '/songs.json')
      .writeAsString(json.substring(0, json.length - 1) + "}");
  // remove last comma, close json
  LoadData();
}

// Check if file in Song path still exists
void ValidateSongs() async {
  Songs.forEach((k, v) {
    if (!File(v.path).existsSync()) {
      print("Song " + v.path + " does not exist anymore!");
      DeleteSong(v);
    }
  });
  UnsortedSongs.forEach((k, v) {
    if (!File(v.path).existsSync()) {
      print("Song " + v.path + " does not exist anymore!");
      DeleteSong(v);
    }
  });
}

/* Tags */

class Tag {
  String name = "New Tag";
  int id = -1;
  int used = 0;
  Tag(this.name);
  Tag.fromJson(Map<String, dynamic> json)
      : name = json['n'],
        used = json['u'],
        id = json['i'];
  Map<String, dynamic> toJson(Tag value) =>
      {'n': value.name, 'u': value.used, 'i': value.id};
}

void CreateTag(name) {
  if (Tags.containsKey(name)) {
    print("Trying to create existing Tag!");
    return;
  }

  Tag newtag = Tag(name);
  newtag.id = Tags.length + 1;
  Tags[newtag.id] = newtag;
  SaveTags();
}

void UpdateTagName(tag, name) {
  if (Tags.containsKey(tag)) {
    Tags[tag].name = name;
    SaveTags();
  }
}

void SaveTags() async {
  String appDocDirectory = await ExternalPath.getExternalStoragePublicDirectory(
      ExternalPath.DIRECTORY_DOCUMENTS);

  String json = "{";
  Tags.forEach((k, v) {
    json += '"' + k.toString() + '":' + jsonEncode(v.toJson(v)) + ",";
  });

  File(appDocDirectory + '/tags.json').writeAsString(
      json.substring(0, json.length - 1) +
          "}"); // remove last comma, close json
  LoadData();
}

void DeleteTag(Tag t) {
  Tags.remove(t.id);
  Songs.forEach(
    (k, v) {
      if (v.tags.contains(t.id)) {
        v.tags.remove(t.id);
      }
    },
  );
  SaveTags();
}

Map GetSongsFromTag(Tag T) {
  Map songs = {};
  int songcount = 0;

  for (String s in Songs.keys) {
    Song so = Songs[s];
    if (so.tags.contains(T.id)) songcount += 1;
    songs[so.filename] = so;
  }
  ;

  Tags[T.id].used = songcount;
  return songs;
}
