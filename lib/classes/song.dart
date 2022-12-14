import 'dart:io';
import 'dart:convert';
import "tag.dart";

Map Songs = {};
bool ShouldSaveSongs = false;
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
      filename.split(" -_ ").first.replaceAll(RegExp(".mp3"), "").trim();

  String title = filename.split(" -_ ")
      .last
      .replaceAll(RegExp(".mp3"), "")
      .split(" _ ")
      .first.trim();

  Song newsong = Song(path);
  newsong.title = title;
  newsong.filename = filename;
  newsong.interpret = interpret;
  Songs[filename] = newsong;
  ShouldSaveSongs = true;
  return true;
}

// TODO remove all these SaveSongs and save in the next setstate of the mainsite

void UpdateSongInterpret(String key, String newtitle) {
  Songs[key].interpret = newtitle;
  ShouldSaveSongs = true;
}

void UpdateSongTitle(String key, String newtitle) {
  Songs[key].title = newtitle;
  ShouldSaveSongs = true;
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
  ShouldSaveSongs = true;
}

void DeleteSong(Song s) {
  if (Songs.containsKey(s.filename)) {
    for (int tagid in s.tags) {
      Tags[tagid].used = Tags[tagid].used - 1;
    }
    Songs.remove(s.filename);
    ShouldSaveSongs = true;
  }
}

void SaveSongs() async {
  if (!ShouldSaveSongs) {
    return;
  }
  ShouldSaveSongs = false;

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
