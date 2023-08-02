import 'dart:core';
import 'dart:convert';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';


Color HomeColor = const Color.fromRGBO(61, 61, 61, 0);
Color ContrastColor = const Color.fromRGBO(0, 255, 76, 0);

Map Config = {
  "HomeColor": HomeColor.value,
  "ContrastColor": ContrastColor.value,
  "SearchPaths": ["storage/emulated/0/Music", "storage/emulated/0/Download", "C:", "D:", "Library"],
  "Playlist": [],
};

/* Config */

void SaveConfig() {}

void LoadData(reload, MyAudioHandler audioHandler) async {
  Database database = await openDatabase("storage/emulated/0/Documents", version: 1,
      onCreate: (Database db, int version) async {
    // When creating the db, create the table
    await db
        .execute('CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)');
    await db.execute('CREATE TABLE Playlist (id INTEGER PRIMARY KEY, name TEXT, songs TEXT)');
  });

  List<Map> list = await database.rawQuery('SELECT * FROM Test');

  // Count the records
  int? count = Sqflite.firstIntValue(await database.rawQuery('SELECT COUNT(*) FROM Test'));
}

/*
await database.transaction((txn) async {
  int id1 = await txn.rawInsert(
      'INSERT INTO Test(name, value, num) VALUES("some name", 1234, 456.789)');
  print('inserted1: $id1');
  int id2 = await txn.rawInsert(
      'INSERT INTO Test(name, value, num) VALUES(?, ?, ?)',
      ['another name', 12345678, 3.1416]);
  print('inserted2: $id2');
});

// Update some record
int count = await database.rawUpdate(
    'UPDATE Test SET name = ?, value = ? WHERE name = ?',
    ['updated name', '9876', 'some name']);
print('updated: $count');

// Delete a record
count = await database
    .rawDelete('DELETE FROM Test WHERE name = ?', ['another name']);


void SaveConfig() {
  SaveSongs();
  String appDocDirectory = "storage/emulated/0/Music";
  File('$appDocDirectory/config.json').create(recursive: true).then((File file) {
    file.writeAsString(jsonEncode(Config));
  });
}

void LoadData(reload, MyAudioHandler audioHandler) async {
  String appDocDirectory = "storage/emulated/0/Music";

  Future.delayed(const Duration(seconds: 2), () {
    try {
      // Load Config
      File('$appDocDirectory/config.json').create(recursive: true).then((File file) {
        file.readAsString().then((String contents) {
          if (contents.isNotEmpty) {
            jsonDecode(contents).forEach((key, value) {
              Config[key] = value;
            });
          }
          // Load Songs
          File('$appDocDirectory/songs.json').create(recursive: true).then((File file) {
            file.readAsString().then((String contents) {
              if (contents.isNotEmpty) {
                jsonDecode(contents).forEach((key, value) async {
                  await Future.delayed(const Duration(milliseconds: 1));
                  Song currentsong = Song.fromJson(value);
                  Songs[key] = currentsong;
                });
                ValidateSongs();
              }
              // Load Tags
              File('$appDocDirectory/tags.json').create(recursive: true).then((File file) {
                file.readAsString().then((String contents) {
                  if (contents.isNotEmpty) {
                    jsonDecode(contents).forEach((key, value) async {
                      await Future.delayed(const Duration(milliseconds: 1));

                      Tag currenttag = Tag.fromJson(value);
                      Tags[currenttag.id] = currenttag;
                    });
                  }
                  Future.delayed(const Duration(seconds: 1), () {
                    UpdateAllTags();
                    audioHandler.LoadPlaylist(reload);
                  });
                });
              });
            });
          });
        });
      });
    } catch (e) {}
  });
}

*/


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
  Map<String, dynamic> toJson(Tag value) => {'n': value.name, 'u': value.used, 'i': value.id};
}

int CreateTag(name) {
  int newid = -1;
  Tags.forEach((key, value) {
    if (value.name.trim() == name.trim()) {
      newid = key;
    }
  });
  if (newid != -1) {
    return newid;
  }
  newid = 0;

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
    json = "${json.substring(0, json.length - 1)}}";
    // remove last comma, close json
  }
  File('$appDocDirectory/tags.json').writeAsString(json);
}

void DeleteTag(Tag t) {
  Songs.forEach(
        (k, v) {
      if (v.tags.contains(t.id)) {
        UpdateSongTags(v.filename, t.id, false);
      }
    },
  );
  Tags.remove(t.id);
  ShouldSaveTags = true;
  SaveTags();
}

void UpdateAllTags() {
  Tags.forEach((k, v) {
    v.used = 0;
  });
  Songs.forEach((k, v) {
    if (!v.blacklisted) {
      v.tags.forEach((element) {
        try {
          Tags[element].used += 1;
        } catch (e) {}
      });
    }
  });
}

Map GetSongsFromTag(Tag T) {
  Map songs = {};

  for (String s in Songs.keys) {
    Song so = Songs[s];
    List t = so.tags;
    if (t.contains(T.id) && !so.blacklisted) {
      songs[so.filename] = so;
    }
  }
  T.used = songs.length;
  return songs;
}


Map Songs = {};
bool ShouldSaveSongs = false;
/* Songs */

class Song {
  String path = "";
  String filename = "";
  String title = "Song Title";
  String interpret = "Song Interpret";
  String featuring = "";
  bool edited = false;
  bool blacklisted = false;
  bool hastags = false;
  List tags = [];
  Song(this.path);

  Song.fromJson(Map<String, dynamic> json)
      : path = json['p'],
        filename = json['f'],
        title = json['t'],
        interpret = json['i'],
        featuring = json['fe'],
        edited = json['e'],
        hastags = json['h'],
        blacklisted = json['b'],
        tags = json['ta'];
  Map<String, dynamic> toJson(Song value) => {
    'p': value.path,
    'f': value.filename,
    't': value.title,
    'i': value.interpret,
    'fe': value.featuring,
    'e': value.edited,
    'h': value.hastags,
    'b': value.blacklisted,
    'ta': value.tags
  };
}

bool CreateSong(path) {
  String filename = path.split("/").last;

  if (Songs.containsKey(filename)) {
    return false;
  }

  String interpret = filename.split(" -_ ").first.replaceAll(RegExp(".mp3"), "").trim();

  String title =
  filename.split(" -_ ").last.replaceAll(RegExp(".mp3"), "").split(" _ ").first.trim();

  Song newsong = Song(path);
  newsong.title = title;
  newsong.filename = filename;
  newsong.interpret = interpret;
  if (interpret.contains("feat.")) {
    newsong.featuring = interpret.split("feat.").last.trim();
    newsong.interpret = interpret.split("feat.").first.trim();
  }
  if (interpret.contains("feat")) {
    newsong.featuring = interpret.split("feat").last.trim();
    newsong.interpret = interpret.split("feat").first.trim();
  }
  if (interpret.contains("ft")) {
    newsong.featuring = interpret.split("ft").last.trim();
    newsong.interpret = interpret.split("ft").first.trim();
  }
  if (interpret.contains("ft.")) {
    newsong.featuring = interpret.split("ft.").last.trim();
    newsong.interpret = interpret.split("ft.").first.trim();
  }
  if (interpret.contains("Feat.")) {
    newsong.featuring = interpret.split("Feat.").last.trim();
    newsong.interpret = interpret.split("Feat.").first.trim();
  }
  Songs[filename] = newsong;
  ShouldSaveSongs = true;
  return true;
}

void UpdateSongInterpret(String key, String newtitle) {
  Songs[key].interpret = newtitle.trim();
  ShouldSaveSongs = true;
}

void UpdateSongFeaturing(String key, String newtitle) {
  Songs[key].featuring = newtitle.trim();
  ShouldSaveSongs = true;
}

void UpdateSongTitle(String key, String newtitle) {
  Songs[key].title = newtitle.trim();
  ShouldSaveSongs = true;
}

void UpdateSongTags(String key, int Tagid, bool? add) {
  if (add != null && add && !Songs[key].tags.contains(Tagid)) {
    Songs[key].tags.add(Tagid);
    Tags[Tagid].used += 1;
  } else if (add != null && !add && Songs[key].tags.contains(Tagid)) {
    Songs[key].tags.remove(Tagid);
    Tags[Tagid].used -= 1;
  }

  Songs[key].hastags = Songs[key].tags.isNotEmpty;
  ShouldSaveSongs = true;
}

void DeleteSong(Song s) {
  if (Songs.containsKey(s.filename)) {
    Songs.remove(s.filename);
    ShouldSaveSongs = true;
    SaveSongs();
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
  await Future.delayed(const Duration(milliseconds: 10));
  for (var song in Songs.values) {
    await Future.delayed(const Duration(milliseconds: 1));
    nosongsfound = false;
    json += '"' + song.filename + '":' + jsonEncode(song.toJson(song)) + ",";
  }

  if (nosongsfound) {
    json = "{}";
  } else {
    json = "${json.substring(0, json.length - 1)}}";
    // remove last comma, close json
  }
  await Future.delayed(const Duration(milliseconds: 10));
  File('$appDocDirectory/songs.json').writeAsString(json);
}

// Check if file in Song path still exists
void ValidateSongs() {
  Songs.forEach((k, v) {
    v.hastags = v.tags.isNotEmpty;
    if (!File(v.path).existsSync()) {
      DeleteSong(v);
    }
  });
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

  void SetUpdate(void Function(void Function()) c) {
    update = c;
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
    if (!Contains(song)) {
      songs.insert(1, song);
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
    List<String> names = [];
    for (var element in songs) {
      names.add(element.filename);
    }
    Config["Playlist"] = names;
    SaveConfig();
  }

  void AddTagToAll(Tag t) {
    for (var element in songs) {
      UpdateSongTags(element.filename, t.id, true);
    }
  }

  void SaveToTag(int id) {
    for (var element in songs) {
      UpdateSongTags(element.filename, id, true);
    }
    Clear();
    UpDateMediaItem();
    ShouldSaveTags = true;
    ShouldSaveSongs = true;
    SaveTags();
    SaveConfig();
    update(() {});
  }

  Future<void> LoadPlaylist(done) async {
    List savedsongs = Config["Playlist"];
    if (savedsongs.isNotEmpty) {
      savedsongs.forEach((element) async {
        await Future.delayed(const Duration(milliseconds: 50));
        if (Songs.containsKey(element)) {
          if (Contains(Songs[element])) {
            return;
          }
          songs.add(Songs[element]);
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
