import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sqflite/sqflite.dart';

late Database database;

Color HomeColor = const Color(0xFF485F4F);
Color ContrastColor = const Color(0xFF4BBDAE);
Map Config = {
  "HomeColor": HomeColor.value,
  "ContrastColor": ContrastColor.value,
  "SearchPaths": ["storage/emulated/0/Music", "storage/emulated/0/Download", "C:", "D:", "Library"],
  "Playlist": <int>[],
  "Version": "1"
};

void AddSearchPath(String path) {
  Config["SearchPaths"].add(path);
  database.rawUpdate('UPDATE Config SET value = ? WHERE name = ?',
      [jsonEncode(Config["SearchPaths"]), "SearchPaths"]);
}

void ResetConfig() {
  Config = {
    "HomeColor": HomeColor.value,
    "ContrastColor": ContrastColor.value,
    "SearchPaths": [
      "storage/emulated/0/Music",
      "storage/emulated/0/Download",
      "C:",
      "D:",
      "Library"
    ],
    "Playlist": <int>[],
    "Version": "1"
  };
  database.rawUpdate('UPDATE Config SET value = ? WHERE name = ?', [HomeColor.value, "HomeColor"]);
  database.rawUpdate(
      'UPDATE Config SET value = ? WHERE name = ?', [ContrastColor.value, "ContrastColor"]);
  database.rawUpdate('UPDATE Config SET value = ? WHERE name = ?',
      [jsonEncode(Config["SearchPaths"]), "SearchPaths"]);
  database.rawUpdate(
      'UPDATE Config SET value = ? WHERE name = ?', [jsonEncode(Config["Playlist"]), "Playlist"]);
}

Map<int, Tag> Tags = <int, Tag>{};
Map<int, Song> Songs = <int, Song>{};

// ../../../../../storage/emulated/0/Documents/
void LoadData(MyAudioHandler audioHandler, context) async {
  database =
      await openDatabase("musicplayer.db", version: 1, onCreate: (Database db, int version) async {
    // When creating the db, create the table
    await db.execute('CREATE TABLE Config (name STRING, value STRING)');
    // Load Config
    await db.rawInsert('INSERT INTO Config(name, value) VALUES("Version", "1")');
    await db.rawInsert('INSERT INTO Config(name, value) VALUES("HomeColor", ${HomeColor.value})');
    await db.rawInsert(
        'INSERT INTO Config(name, value) VALUES("ContrastColor", ${ContrastColor.value})');
    await db.rawInsert('INSERT INTO Config(name, value) VALUES("SearchPaths", "' +
        jsonEncode(Config["SearchPaths"]).replaceAll(RegExp(r'"'), "'") +
        '")');
    await db.rawInsert('INSERT INTO Config(name, value) VALUES("Playlist", "' +
        jsonEncode(Config["Playlist"]).replaceAll(RegExp(r'"'), "'") +
        '")');

    await db.execute(
        'CREATE TABLE Tags (id INTEGER PRIMARY KEY, name TEXT, lastused INTEGER, is_artist INTEGER)');
    await db.execute(
        'CREATE TABLE Songs (id INTEGER PRIMARY KEY, path TEXT, filename TEXT, title TEXT, interpret TEXT, featuring TEXT, edited INTEGER, blacklisted INTEGER, tags TEXT, lastplayed INTEGER)');
  });

  List<Map> allrows = await database.rawQuery('SELECT * FROM Config');
  allrows.forEach((element) {
    if (element["name"] == "Playlist" || element["name"] == "SearchPaths") {
      Config[element["name"]] = jsonDecode(element["value"].replaceAll(RegExp(r"'"), '"'));
    } else {
      Config[element["name"]] = element["value"];
    }
  });

  List<Map> alltags = await database.rawQuery('SELECT * FROM Tags');
  alltags.forEach((element) {
    Tags[element["id"]] = Tag(element["id"], element["name"], element["is_artist"] == 1);
    Tags[element["id"]]!.used = element["lastused"];
  });

  List<Map> allsongs = await database.rawQuery('SELECT * FROM Songs');
  allsongs.forEach((element) {
    List tags = jsonDecode(element["tags"].replaceAll(RegExp(r"'"), '"'));
    Songs[element["id"]] = Song(element["id"], element["path"]);
    Songs[element["id"]]!.filename = element["filename"];
    Songs[element["id"]]!.title = element["title"];
    Songs[element["id"]]!.interpret = element["interpret"];
    Songs[element["id"]]!.featuring = element["featuring"];
    Songs[element["id"]]!.edited = element["edited"] == 1;
    Songs[element["id"]]!.blacklisted = element["blacklisted"] == 1;
    Songs[element["id"]]!.tags = tags;
  });

  Future.delayed(const Duration(seconds: 1), () {
    UpdateAllTags();
    audioHandler.LoadPlaylist();
  });
}

class Tag {
  String name = "New Tag";
  int id = -1;
  int used = 0;
  bool is_artist = false;
  Tag(this.id, this.name, this.is_artist);

  Tag.fromJson(Map<String, dynamic> json)
      : name = json['n'],
        used = json['u'],
        is_artist = json['a'],
        id = json['i'];
  Map<String, dynamic> toJson(Tag value) =>
      {'n': value.name, 'u': value.used, 'a': is_artist, 'i': value.id};
}

Future<int> CreateTag(name) async {
  for (Tag t in Tags.values) {
    if (t.name == name) {
      return t.id;
    }
  }

  int id = -1;
  name = name.trim();
  int time = DateTime.now().millisecondsSinceEpoch;

  await database.transaction((txn) async {
    id = await txn.rawInsert('INSERT INTO Tags(name, is_artist, lastused) VALUES("' +
        name +
        '",' +
        true.toString() +
        ',' +
        time.toString() +
        ')');
  });

  Tags[id] = Tag(id, name, true);
  return id;
}

Future<int> CreatePlaylistTag(name) async {
  for (Tag t in Tags.values) {
    if (t.name == name) {
      return t.id;
    }
  }

  int id = -1;
  name = name.trim();
  int time = DateTime.now().millisecondsSinceEpoch;

  await database.transaction((txn) async {
    id = await txn.rawInsert('INSERT INTO Tags(name, is_artist, lastused) VALUES("' +
        name +
        '",' +
        false.toString() +
        ',' +
        time.toString() +
        ')');
  });

  Tags[id] = Tag(id, name, false);
  return id;
}

void UpdateTagName(tag, name) async {
  if (Tags[tag] == null) {
    return;
  }
  name = name.trim();
  Tags[tag]!.name = name;
  int time = DateTime.now().millisecondsSinceEpoch;

  database.rawUpdate('UPDATE Tags SET name = ?, lastused = ? WHERE id = ?', [name, time, tag]);
}

Future<void> DeleteTag(int key) async {
  await database.rawDelete('DELETE FROM Tags WHERE id = ?', [key]);
}

void UpdateAllTags() {
  Tags.forEach((k, v) {
    v.used = 0;
  });
  Songs.forEach((k, v) {
    if (!v.blacklisted) {
      v.tags.forEach((element) {
        try {
          Tags[element]!.used += 1;
        } catch (e) {}
      });
    }
  });
}

Map GetSongsFromTag(Tag T) {
  Map songs = {};

  for (int id in Songs.keys) {
    Song so = Songs[id]!;
    List t = so.tags;
    if (t.contains(T.id) && !so.blacklisted) {
      songs[so.id] = so;
    }
  }
  T.used = songs.length;
  return songs;
}

class Song {
  int id = -1;
  String path = "";
  String filename = "";
  String title = "Song Title";
  String interpret = "Song Interpret";
  String featuring = "";
  bool edited = false;
  bool blacklisted = false;
  List tags = [];
  Song(this.id, this.path);

  Song.fromJson(Map<String, dynamic> json)
      : path = json['p'],
        filename = json['f'],
        title = json['t'],
        interpret = json['i'],
        featuring = json['fe'],
        edited = json['e'],
        blacklisted = json['b'],
        tags = json['ta'];
  Map<String, dynamic> toJson(Song value) => {
        'p': value.path,
        'f': value.filename,
        't': value.title,
        'i': value.interpret,
        'fe': value.featuring,
        'e': value.edited,
        'b': value.blacklisted,
        'ta': value.tags
      };
}

Future<bool> CreateSong(String path) async {
  // Check if a song for this file already exists
  bool found = false;
  Songs.forEach((k, v) {
    if (v.path == path) {
      found = true;
    }
  });
  if (found) {
    return false;
  }

  String filename = path.split("/").last;
  String title =
      filename.split(" -_ ").last.replaceAll(RegExp(".mp3"), "").split(" _ ").first.trim();
  String interpret = filename.split(" -_ ").first.replaceAll(RegExp(".mp3"), "").trim();

  int time = DateTime.now().millisecondsSinceEpoch;
  int id = -1;
  await database.transaction((txn) async {
    id = await txn.rawInsert(
        'INSERT INTO Songs(path, filename, title, interpret, featuring, edited, blacklisted, tags, lastplayed) VALUES("' +
            path +
            '","' +
            filename +
            '","' +
            title +
            '","' +
            interpret +
            '","", 0, 0, "[]",' +
            time.toString() +
            ')');
  });

  Song newsong = Song(id, path);
  newsong.title = title;
  newsong.filename = filename;
  newsong.interpret = interpret;
  Songs[id] = newsong;
  return true;
}

void UpdateSongInterpret(int key, String newtitle) {
  if (Songs[key] == null) {
    return;
  }
  newtitle = newtitle.trim();
  Songs[key]!.interpret = newtitle;

  database.rawUpdate('UPDATE Songs SET interpret = ? WHERE id = ?', [newtitle, key]);
}

void UpdateSongFeaturing(int key, String newtitle) {
  if (Songs[key] == null) {
    return;
  }
  newtitle = newtitle.trim();
  Songs[key]!.featuring = newtitle;

  database.rawUpdate('UPDATE Songs SET featuring = ? WHERE id = ?', [newtitle, key]);
}

void UpdateSongTitle(int key, String newtitle) {
  if (Songs[key] == null) {
    return;
  }
  newtitle = newtitle.trim();
  Songs[key]!.title = newtitle;

  database.rawUpdate('UPDATE Songs SET title = ? WHERE id = ?', [newtitle, key]);
}

void UpdateSongBlacklisted(int key, bool blacklisted) {
  if (Songs[key] == null) {
    return;
  }
  Songs[key]!.blacklisted = blacklisted;

  int placeholder = 0;
  if (blacklisted) {
    placeholder = 1;
  }

  database.rawUpdate('UPDATE Songs SET blacklisted = ? WHERE id = ?', [placeholder, key]);
}

void UpdateSongEdited(int key, bool edited) {
  if (Songs[key] == null) {
    return;
  }
  Songs[key]!.edited = edited;

  int placeholder = 0;
  if (edited) {
    placeholder = 1;
  }

  database.rawUpdate('UPDATE Songs SET edited = ? WHERE id = ?', [placeholder, key]);
}

void ClearSongTags(int key) {
  if (Songs[key] == null) {
    return;
  }
  Songs[key]!.tags = [];

  database.rawUpdate('UPDATE Songs SET tags = ? WHERE id = ?', ["[]", key]);
}

void UpdateSongTags(int key, int Tagid, bool add) {
  if (Songs[key] == null) {
    return;
  }
  if (add && !Songs[key]!.tags.contains(Tagid)) {
    Songs[key]!.tags.add(Tagid);
    Tags[Tagid]!.used += 1;
  } else if (!add && Songs[key]!.tags.contains(Tagid)) {
    Songs[key]!.tags.remove(Tagid);
    Tags[Tagid]!.used -= 1;
  }

  database.rawUpdate('UPDATE Songs SET tags = ? WHERE id = ?', [jsonEncode(Songs[key]!.tags), key]);
}

void SetSongTags(int key, List<int> Tagids) {
  if (Songs[key] == null) {
    return;
  }
  Songs[key]!.tags = Tagids;

  database.rawUpdate('UPDATE Songs SET tags = ? WHERE id = ?', [jsonEncode(Tagids), key]);
}

Future<void> DeleteSong(int key) async {
  await database.rawDelete('DELETE FROM Songs WHERE id = ?', [key]);
  Songs.remove(key);
}

// Check if file in Song path still exists
Future<void> ValidateSongs() async {
  Songs.forEach((k, v) async {
    if (!File(v.path).existsSync()) {
      await DeleteSong(k);
    }
  });
}

void SongPlayed(int id) async {
  int time = DateTime.now().millisecondsSinceEpoch;
  database.rawUpdate('UPDATE Songs SET lastplayed = ? WHERE id = ?', [time, id]);
}

List<Song> AllNotEditedSongs() {
  List<Song> noteditedsongs = [];
  Songs.forEach((k, v) {
    if (!v.edited) {
      noteditedsongs.add(v);
    }
  });
  return noteditedsongs;
}

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  late void Function(void Function()) update;
  late void Function() done;
  List<Song> songs = [];
  int last_added_pos = 0;
  bool paused = false;
  AudioPlayer player = AudioPlayer();

  MyAudioHandler() {
    player.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed && event.playing) {
        skipToNext(true);
        decreaseStack();
      }
    });
    player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  void decreaseStack() {
    if (last_added_pos > 0) {
      last_added_pos -= 1;
    }
  }

  bool Contains(Song song) {
    for (int i = 0; i < songs.length; i++) {
      if (songs[i].filename == song.filename) {
        return true;
      }
    }
    return false;
  }

  void SetUpdate(void Function(void Function()) c, void Function() doneL) {
    update = c;
    done = doneL;
  }

  void AddToPlaylist(Song song) {
    if (Contains(song)) {
      return;
    }
    songs.add(song);

    UpDateMediaItem();
  }

  void BulkAdd(Map songstobeadded) {
    songstobeadded.forEach((key, element) {
      if (!Contains(element)) {
        songs.add(element);
      }
    });
    UpDateMediaItem();
  }

  void InsertAsNext(Song song) {
    decreaseStack();
    if (!Contains(song) && songs.length > 1) {
      songs.insert(1, song);
    } else if (!Contains(song)) {
      songs.insert(0, song);
    } else {
      songs.remove(song);
      songs.insert(1, song);
    }
    UpDateMediaItem();
  }

  void Stack(Song song) {
    last_added_pos += 1;
    if (!Contains(song)) {
      songs.insert(last_added_pos, song);
    } else {
      songs.remove(song);
      songs.insert(last_added_pos, song);
    }
    UpDateMediaItem();
  }

  void UpDateMediaItem() {
    if (songs.length > 1) {
      mediaItem.add(MediaItem(
        id: 'file://storage/${songs[0].path}',
        album: (songs[1].edited) ? "Next: ${songs[1].title}" : "No Next Song",
        title: songs[0].title,
        artist: songs[0].interpret,
        duration: player.duration,
      ));
    } else if (songs.isNotEmpty) {
      mediaItem.add(MediaItem(
        id: 'file://storage/${songs[0].path}',
        album: "No Next Song",
        title: songs[0].title,
        artist: songs[0].interpret,
        duration: player.duration,
      ));
    }
    update(() {});
    Save();
  }

  void RemoveSong(Song s) {
    for (int i = 0; i < songs.length; i++) {
      if (songs[i] == s) {
        songs.remove(s);
      }
    }
    UpDateMediaItem();
  }

  void Shuffle() {
    if (songs.isEmpty) {
      return;
    }
    if (player.playing) {
      Song current = songs.removeAt(0);
      songs.shuffle();
      songs.insert(0, current);
    } else {
      songs.shuffle();
    }
    last_added_pos = 0;
    UpDateMediaItem();
  }

  void JumpToSong(Song song) async {
    int index = -1;
    for (int i = 0; i < songs.length; i++) {
      if (songs[i].filename == song.filename) {
        index = i;
        break;
      }
    }

    if (index < 0) return;
    for (int i = 0; i < index; i++) {
      songs.add(songs.removeAt(0));
    }
    if (player.playing) {
      await player.seek(const Duration(seconds: 0));
      play();
    } else {
      LoadNextToPlayer();
    }
    last_added_pos = 0;
  }

  void DragNDropUpdate(int oldIndex, int newIndex) {
    Song song = songs.removeAt(oldIndex);
    songs.insert(newIndex, song);
    UpDateMediaItem();
  }

  void LoadNextToPlayer() async {
    decreaseStack();
    if (songs.isNotEmpty) {
      await player.seek(const Duration(seconds: 0));
      await play(true);
    }
  }

  void Save() {
    List<int> names = [];
    for (var element in songs) {
      names.add(element.id);
    }
    Config["Playlist"] = names;
    database.rawUpdate(
        'UPDATE Config SET value = ? WHERE name = ?', [jsonEncode(Config["Playlist"]), "Playlist"]);
  }

  void AddTagToAll(Tag t) {
    for (Song element in songs) {
      UpdateSongTags(element.id, t.id, true);
    }
  }

  void SaveToTag(int id) {
    for (Song element in songs) {
      UpdateSongTags(element.id, id, true);
    }
    Clear();
    UpDateMediaItem();

    update(() {});
  }

  Future<void> LoadPlaylist() async {
    List savedsongs = Config["Playlist"];
    if (savedsongs.isNotEmpty) {
      savedsongs.forEach((element) async {
        await Future.delayed(const Duration(milliseconds: 50));
        if (Songs.containsKey(element)) {
          if (Contains(Songs[element]!)) {
            return;
          }
          songs.add(Songs[element]!);
        }
      });
    }
    Future.delayed(const Duration(seconds: 1)).then((value) {
      done();
      UpDateMediaItem();
    });
    last_added_pos = 0;
  }

  void Clear() {
    stop();
    songs = [];
    last_added_pos = -1;
    Save();
  }

  @override
  Future<void> play([pause = false]) async {
    if (paused) {
      player.play();
      paused = false;
    } else {
      if (songs.isNotEmpty) {
        await player.stop();
        await player.setUrl('file://storage/${songs[0].path}');
        if (pause || paused) {
          player.pause();
        } else {
          paused = false;
          player.play();
        }
        UpDateMediaItem();
      }
    }
  }

  @override
  Future<void> pause() async {
    if (player.playing) {
      await player.pause();
      paused = true;
    } else if (paused) {
      player.play();
      paused = false;
    } else {
      play();
    }
  }

  @override
  Future<void> stop() async {
    await player.stop();
    paused = false;
    await player.seek(const Duration(seconds: 0));
    UpDateMediaItem();
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    Shuffle();
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    Shuffle();
  }

  @override
  Future<void> skipToNext([next = false]) async {
    if (songs.isNotEmpty) {
      songs.add(songs.removeAt(0));
      if (player.playing || next) {
        await player.seek(const Duration(seconds: 0));
        play();
      } else {
        LoadNextToPlayer();
      }
    }
  }

  DateTime lastback = DateTime.now();
  @override
  Future<void> skipToPrevious() async {
    if (songs.isNotEmpty) {
      if (player.playing && DateTime.now().difference(lastback).inSeconds > 3) {
        lastback = DateTime.now();
        await player.seek(const Duration(seconds: 0));
        play();
      } else {
        await pause();
        Shuffle();
        play();
      }
    }
  }

  @override
  Future<void> seek(Duration position) async {
    await player.seek(position);
  }

  /// Transform a just_audio event into an audio_service state.
  ///
  /// This method is used from the constructor. Every event received from the
  /// just_audio player will be transformed into an audio_service state so that
  /// it can be broadcast to audio_service clients.
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      // Which other actions should be enabled in the notification
      systemActions: {
        MediaAction.skipToPrevious,
        if (player.playing) MediaAction.pause else MediaAction.play,
        MediaAction.stop,
        MediaAction.skipToNext,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[player.processingState]!,
      playing: player.playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
      queueIndex: event.currentIndex,
    );
  }
}

/*
Import Code
 */

Song? FindSongByFilename(filename) {
  Song? song;
  Songs.forEach((key, value) {
    if (value.filename == filename) {
      song = Songs[key];
    }
  });

  return song;
}

int? GetIdBySongPath(String path) {
  int? id;
  Songs.forEach((key, value) {
    if (value.path == path) {
      id = key;
    }
  });

  return id;
}

void DeleteAllSongs() async {
  List<int> keys = [];
  Songs.forEach((key, value) {
    keys.add(key);
  });
  keys.forEach((element) async {
    await DeleteSong(element);
  });
  Songs = {};
}

void DeleteAllTags() async {
  List<int> keys = [];
  Tags.forEach((key, value) {
    keys.add(key);
  });
  keys.forEach((element) async {
    await DeleteTag(element);
  });
  Tags = {};
}

Future<void> ImportFromFile(MyAudioHandler audiohandler) async {
  print("Deleting Current Stuff");

  DeleteAllSongs();
  DeleteAllTags();

  Config["Playlist"] = [];

  print("Starting Import");
  String appDocDirectory = "storage/emulated/0/Music";

  try {
    print("Loading Tags");
    await File(appDocDirectory + '/tags.json').create(recursive: true).then((File file) async {
      await file.readAsString().then((String contents) async {
        if (contents.isNotEmpty) {
          await jsonDecode(contents).forEach((key, value) async {
            print(value["n"].toString() + value["i"].toString());
            if (value["a"] == 0) {
              await CreatePlaylistTag(value["n"]);
            } else {
              await CreateTag(value["n"]);
            }
            print("Tag ${value["n"]} created");
          });
        } else
          print("No Tags");
      });
    });
    await Future.delayed(const Duration(seconds: 10));
    print("Tags Loaded");
  } catch (e) {
    print(e);
  }

  try {
    print("Loading Songs");
    await File(appDocDirectory + '/songs.json').create(recursive: true).then((File file) async {
      await file.readAsString().then((String contents) async {
        print(contents);
        if (contents.isNotEmpty) {
          await jsonDecode(contents).forEach((key, value) async {
            if (FindSongByFilename(value["f"]) == null) {
              await CreateSong(value["p"]);

              if (GetIdBySongPath(value["p"]) != null) {
                int id = GetIdBySongPath(value["p"])!;

                UpdateSongTitle(id, value["t"]);
                UpdateSongInterpret(id, value["i"]);
                UpdateSongFeaturing(id, value["fe"]);
                UpdateSongEdited(id, value["e"]);
                UpdateSongBlacklisted(id, value["b"]);
                List<int> a = <int>[];
                value["ta"].forEach((element) {
                  a.add(element);
                });
                SetSongTags(id, a);

                print("Song $id created");
              }
            }
          });
          await ValidateSongs();
        } else
          print("No Songs");
      });
    });
    await Future.delayed(const Duration(seconds: 10));
    print("Songs Loaded");
  } catch (e) {
    print(e);
  }

  try {
    // Load Config
    await File(appDocDirectory + '/config.json').create(recursive: true).then((File file) async {
      await file.readAsString().then((String contents) async {
        if (contents.isNotEmpty) {
          await jsonDecode(contents).forEach((key, value) {
            if (key == "Playlist") {
              List filenames = value;
              List newids = [];
              filenames.forEach((element) {
                if (FindSongByFilename(element) != null) {
                  newids.add(FindSongByFilename(element)!.id);
                }
              });

              Config[key] = newids;
            } else {
              Config[key] = value;
            }
          });
        }
      });
    });
  } catch (e) {
    print(e);
  }

  await Future.delayed(const Duration(seconds: 5));
  print("Import Done");

  Future.delayed(const Duration(seconds: 1), () async {
    UpdateAllTags();
    await audiohandler.LoadPlaylist();
  });
}

Future<void> ExportToFile(MyAudioHandler audiohandler) async {
  print("Starting Exprt");
  String appDocDirectory = "storage/emulated/0/Music";

  try {
    print("Exporting Tags");

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

    print("Tags Exported");
  } catch (e) {
    print(e);
  }

  try {
    print("Exporting Songs");

    String json = "{";
    bool nosongsfound = true;
    await Future.delayed(Duration(milliseconds: 10));
    for (var song in Songs.values) {
      await Future.delayed(Duration(milliseconds: 1));
      nosongsfound = false;
      json += '"' + song.filename + '":' + jsonEncode(song.toJson(song)) + ",";
    }

    if (nosongsfound) {
      json = "{}";
    } else {
      json = json.substring(0, json.length - 1) + "}";
      // remove last comma, close json
    }
    File(appDocDirectory + '/songs.json').writeAsString(json);

    await Future.delayed(const Duration(seconds: 10));
    print("Songs Exported");
  } catch (e) {
    print(e);
  }

  try {
    print("Exporting Config");
    List ids = Config["Playlist"];
    List filenames = [];
    ids.forEach((element) {
      filenames.add(Songs[element]!.filename);
    });
    Config["Playlist"] = filenames;
    File(appDocDirectory + '/config.json').create(recursive: true).then((File file) {
      file.writeAsString(jsonEncode(Config));
    });
    Config["Playlist"] = ids;
    print("Config Exported");
  } catch (e) {
    print(e);
  }

  print("Export Done");
}
