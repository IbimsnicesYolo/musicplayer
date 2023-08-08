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
void LoadData(reload, MyAudioHandler audioHandler) async {
  database = await openDatabase("music.db", version: 1, onCreate: (Database db, int version) async {
    // When creating the db, create the table
    await db.execute('CREATE TABLE Config (name STRING, value STRING)');
    // Load Config
    await db.rawInsert('INSERT INTO Config(name, value) VALUES("HomeColor", ${HomeColor.value})');
    await db.rawInsert(
        'INSERT INTO Config(name, value) VALUES("ContrastColor", ${ContrastColor.value})');
    await db.rawInsert(
        'INSERT INTO Config(name, value) VALUES("SearchPaths", "${jsonEncode(Config["SearchPaths"])}")');
    await db.rawInsert(
        'INSERT INTO Config(name, value) VALUES("Playlist", "${jsonEncode(Config["Playlist"])}")');

    await db.execute('CREATE TABLE Tags (id INTEGER PRIMARY KEY, name TEXT, lastused INTEGER)');
    await db.execute(
        'CREATE TABLE Songs (id INTEGER PRIMARY KEY, path TEXT, filename TEXT, title TEXT, interpret TEXT, featuring TEXT, edited INTEGER, blacklisted INTEGER, tags TEXT, lastplayed INTEGER)');
  });

  List<Map> allrows = await database.rawQuery('SELECT * FROM Config');
  allrows.forEach((element) {
    print(element);
    Config[element["name"]] = element["value"];
  });

  List<Map> alltags = await database.rawQuery('SELECT * FROM Tags');
  alltags.forEach((element) {
    print(element);
  });

  List<Map> allsongs = await database.rawQuery('SELECT * FROM Songs');
  allsongs.forEach((element) {
    print(element);
  });

  Future.delayed(const Duration(seconds: 1), () {
    UpdateAllTags();
    audioHandler.LoadPlaylist(reload);
  });
}

class Tag {
  String name = "New Tag";
  int id = -1;
  int used = 0;
  Tag(this.id, this.name);
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
    id = await txn.rawInsert('INSERT INTO Tags(name, lastused) VALUES($name, $time)');
    print('inserted1: $id');
  });

  Tags[id] = Tag(id, name);
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

void DeleteTag(int key) {
  database.rawDelete('DELETE FROM Tags WHERE id = ?', [key]);
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
      songs[so.filename] = so;
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
        'INSERT INTO Songs(path, filename, title, interpret, featuring, edited, blacklisted, tags, lastused) VALUES($path, $filename, $title, $interpret, "", 0, 0, "[]", $time)');
    print('inserted1: $id');
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

  database.rawUpdate('UPDATE Songs SET blacklisted = ? WHERE id = ?', [blacklisted, key]);
}

void UpdateSongEdited(int key, bool edited) {
  if (Songs[key] == null) {
    return;
  }
  Songs[key]!.edited = edited;

  database.rawUpdate('UPDATE Songs SET edited = ? WHERE id = ?', [edited, key]);
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

void DeleteSong(int key) {
  database.rawDelete('DELETE FROM Songs WHERE id = ?', [key]);
  Songs.remove(key);
}

// Check if file in Song path still exists
void ValidateSongs() {
  Songs.forEach((k, v) {
    if (!File(v.path).existsSync()) {
      DeleteSong(k);
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

  Future<void> LoadPlaylist(done) async {
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
