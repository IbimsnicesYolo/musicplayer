import 'dart:io';
import 'dart:convert';
import 'song.dart';

Map Tags = {};
bool ShouldSaveTags = false;
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

int CreateTag(name) {
  int newid = 0;
  Tags.forEach((key, value) {
    if (value.name.trim() == name.trim()) {
      newid = key;
    }
  });
  if (newid != 0) {
    return newid;
  }

  for (var i = 0; i < Tags.length; i++) {
    if (Tags.containsKey(i) && Tags[i].id == newid) {
      newid = i + 1;
    }
  }
  Tag newtag = Tag(name.trim());
  newtag.id = newid;
  Tags[newtag.id] = newtag;
  ShouldSaveTags = true;
  return newid;
}

void UpdateTagName(tag, name) {
  if (Tags.containsKey(tag)) {
    Tags[tag].name = name.trim();
    ShouldSaveTags = true;
  }
}

void SaveTags() async {
  if (!ShouldSaveTags) {
    return;
  }
  ShouldSaveTags = false;

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
  ShouldSaveTags = false;
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
