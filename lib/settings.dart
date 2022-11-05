import 'dart:core';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

Color HomeColor = Color.fromRGBO(61, 61, 61, 255);
Color ContrastColor = Color.fromRGBO(0, 255, 75, 255);

const List<String> Actions = [
  "Remove From Playlist",
  "Add To Playlist",
  "Play Next",
  "Add to Stack",
];

Map Songs = {};
Map Tags = {};
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
  "SwipeAction1": 1,
  "SwipeAction2": 0,
};

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

/* Config */
void SaveConfig() {
  String appDocDirectory = "storage/emulated/0/Music";
  File(appDocDirectory + '/config.json')
      .create(recursive: true)
      .then((File file) {
    file.writeAsString(jsonEncode(Config));
  });
}

/* Songs */
class Song {
  String path = "";
  String filename = "";
  String title = "Song Title";
  String interpret = "Song Interpret";
  String hash = "";
  bool hastags = false;
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
        hastags = json['h'],
        tags = json['ta'];
  Map<String, dynamic> toJson(Song value) => {
        'p': value.path,
        'f': value.filename,
        't': value.title,
        'i': value.interpret,
        'h': value.hastags,
        'ta': value.tags
      };
}

bool CreateSong(path) {
  String filename = path.split("/").last;
  // INFO: already filters for multiple file of the same song

  if (Songs.containsKey(filename)) {
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
  Songs[filename] = newsong;
  return true;
}

void UpdateSongInterpret(String key, String newtitle) {
  Songs[key].interpret = newtitle;
  SaveSongs();
}

void UpdateSongTitle(String key, String newtitle) {
  Songs[key].title = newtitle;
  SaveSongs();
}

void UpdateSongTags(String key, int Tagid, bool? add) {
  if (add != null && add) {
    Songs[key].tags.add(Tagid);
    Tags[Tagid].used += 1;
  } else {
    Songs[key].tags.remove(Tagid);
    Tags[Tagid].used -= 1;
  }

  Songs[key].hastags = Songs[key].tags.isNotEmpty;
  SaveSongs();
}

void DeleteSong(Song s) {
  if (Songs.containsKey(s.filename)) {
    for (int tagid in s.tags) {
      Tags[tagid].used = Tags[tagid].used - 1;
    }
    Songs.remove(s.filename);
    SaveSongs();
  }
}

void SaveSongs() async {
  String appDocDirectory = "storage/emulated/0/Music";
  String json = "{";
  bool nosongsfound = true;
  Songs.forEach((k, v) {
    nosongsfound = false;
    json += '"' + k + '":' + jsonEncode(v.toJson(v)) + ",";
  });

  if (nosongsfound) {
    json = "{}";
  } else {
    json = json.substring(0, json.length - 1) + "}";
    // remove last comma, close json
  }
  File(appDocDirectory + '/songs.json').writeAsString(json);
}

// Check if file in Song path still exists
void ValidateSongs() {
  Songs.forEach((k, v) {
    v.hastags = v.tags.isNotEmpty;
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
  int newid = 0;
  for (var i = 0; i < Tags.length; i++) {
    if (Tags.containsKey(i) && Tags[i].id == newid) {
      newid = i + 1;
    }
  }
  Tag newtag = Tag(name);
  newtag.id = newid;
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
  String appDocDirectory = "storage/emulated/0/Music";

  String json = "{";
  bool notagsexisting = true;

  Tags.forEach((k, v) {
    notagsexisting = false;
    json += '"' + k.toString() + '":' + jsonEncode(v.toJson(v)) + ",";
  });

  if (notagsexisting) {
    json = "{}";
  } else {
    json = json.substring(0, json.length - 1) + "}";
    // remove last comma, close json
  }
  File(appDocDirectory + '/tags.json').writeAsString(json);
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

void UpdateAllTags() {
  Tags.forEach((k, v) {
    v.used = 0;
  });
  Songs.forEach((k, v) {
    v.tags.forEach((element) {
      try {
        Tags[element].used += 1;
      } catch (e) {
        print("Big chungus error, tag doesnt exist:" + element.toString());
      }
    });
  });
}

Map GetSongsFromTag(Tag T) {
  Map songs = {};

  for (String s in Songs.keys) {
    Song so = Songs[s];
    List t = so.tags;
    if (t.indexOf(T.id, 0) != -1) {
      songs[so.filename] = so;
    }
  }
  T.used = songs.length;
  return songs;
}
