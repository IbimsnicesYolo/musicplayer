import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import "../settings.dart";
import 'song.dart';
import "tag.dart";

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
        id: 'file://storage/' + songs[0].path,
        album: (songs[1] != null) ? "Next: " + songs[1].title : "No Next Song",
        title: songs[0].title,
        artist: songs[0].interpret,
        duration: player.duration,
      ));
    } else if (songs.length > 0) {
      mediaItem.add(MediaItem(
        id: 'file://storage/' + songs[0].path,
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
    if (songs.length < 1) {
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
      await player.seek(Duration(seconds: 0));
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
    if (songs.length > 0) {
      await player.seek(Duration(seconds: 0));
      await play(true);
    }
  }

  void Save() {
    List<String> names = [];
    songs.forEach((element) {
      names.add(element.filename);
    });
    Config["Playlist"] = names;
    SaveConfig();
  }

  void AddTagToAll(Tag t) {
    songs.forEach((element) {
      UpdateSongTags(element.filename, t.id, true);
    });
  }

  void SaveToTag(int id) {
    List<String> names = [];
    songs.forEach((element) {
      UpdateSongTags(element.filename, id, true);
    });
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
        await Future.delayed(Duration(milliseconds: 50));
        if (Songs.containsKey(element)) {
          if (Contains(Songs[element])) {
            return;
          }
          songs.add(Songs[element]);
        }
      });
    }
    Future.delayed(Duration(seconds: 1)).then((value) {
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

  Future<void> play([pause = false]) async {
    if (paused) {
      player.play();
      paused = false;
    } else {
      if (songs.length > 0) {
        await player.stop();
        await player.setUrl('file://storage/' + songs[0].path);
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

  Future<void> stop() async {
    await player.stop();
    paused = false;
    await player.seek(Duration(seconds: 0));
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

  Future<void> skipToNext([next = false]) async {
    if (songs.length > 0) {
      songs.add(songs.removeAt(0));
      if (player.playing || next) {
        await player.seek(Duration(seconds: 0));
        play();
      } else {
        LoadNextToPlayer();
      }
    }
  }

  DateTime lastback = DateTime.now();
  Future<void> skipToPrevious() async {
    if (songs.length > 0) {
      if (player.playing && DateTime.now().difference(lastback).inSeconds > 3) {
        lastback = DateTime.now();
        await player.seek(Duration(seconds: 0));
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
