import 'song.dart';
import "tag.dart";
import "../settings.dart";
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  List<Song> songs = [];
  int last_added_pos = 0;
  bool start = false;
  bool paused = false;
  bool deleteifplayed = false;
  AudioPlayer player = AudioPlayer();

  MyAudioHandler() {
    player.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed && event.playing) {
        start = true;
        PlayNextSong();
      }
    });
    player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }
  bool Contains(Song song) {
    for (int i = 0; i < songs.length; i++) {
      if (songs[i].filename == song.filename) {
        return true;
      }
    }
    return false;
  }

  void AddToPlaylist(Song song) {
    print("AddToPlaylist");
    if (Contains(song)) {
      return;
    }
    songs.add(song);
    UpDateMediaItem();
  }

  void InsertAsNext(Song song) {
    print("InsertAsNext");
    last_added_pos = 1;
    if (!Contains(song)) {
      songs.insert(1, song);
    } else {
      songs.remove(song);
      songs.insert(1, song);
    }
    UpDateMediaItem();
  }

  void Stack(Song song) {
    print("Stack");
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
    print("UpDateMediaItem");
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
    } else {
      mediaItem.add(MediaItem(
          id: "",
          album: "",
          title: "",
          artist: "",
          duration: Duration(seconds: 0)));
    }
    Save();
  }

  void RemoveSong(Song s) {
    print("RemoveSong");
    for (int i = 0; i < songs.length; i++) {
      if (songs[i] == s) {
        songs.remove(s);
      }
    }
    UpDateMediaItem();
  }

  void Shuffle() {
    print("Shuffle");
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
    UpDateMediaItem();
  }

  void JumpToSong(Song song) async {
    print("JumpToSong");
    int index = songs.indexOf(song);
    for (int i = 0; i < index; i++) {
      songs.add(songs.removeAt(0));
    }
    if (player.playing) {
      await player.seek(Duration(seconds: 0));
      StartPlaying();
    } else {
      LoadNextToPlayer();
    }
  }

  void DragNDropUpdate(int oldIndex, int newIndex) {
    print("DragNDropUpdate");
    Song song = songs.removeAt(oldIndex);
    songs.insert(newIndex, song);
    last_added_pos = 0;
    UpDateMediaItem();
  }

  void PlayNextSong() async {
    print("PlayNextSong");
    if (songs.length > 0) {
      if (deleteifplayed) {
        RemoveSong(songs[0]);
      } else {
        songs.add(songs.removeAt(0));
      }
      if (player.playing || start) {
        start = false;
        await player.seek(Duration(seconds: 0));
        StartPlaying();
      } else {
        LoadNextToPlayer();
      }
    }
  }

  DateTime lastback = DateTime.now();
  void PlayPreviousSong() async {
    print("PlayPreviousSong");
    if (songs.length > 0) {
      if (player.playing && DateTime.now().difference(lastback).inSeconds > 3) {
        lastback = DateTime.now();
        await player.seek(Duration(seconds: 0));
        StartPlaying();
      } else {
        await PausePlaying();
        Shuffle();
        StartPlaying();
      }
    }
  }

  void LoadNextToPlayer() async {
    print("LoadNextToPlayer");
    if (songs.length > 0) {
      await player.seek(Duration(seconds: 0));
      await StartPlaying();
      await player.pause();
    }
  }

  Future<void> StartPlaying() async {
    print("StartPlaying");
    if (songs.length > 0) {
      await player.stop();
      await player.setUrl('file://storage/' + songs[0].path);
      player.play();
      paused = false;
      UpDateMediaItem();
    }
  }

  Future<void> StopPlaying() async {
    print("StopPlaying");
    await player.stop();
    paused = false;
    await player.seek(Duration(seconds: 0));
    UpDateMediaItem();
  }

  Future<void> PausePlaying() async {
    print("PausePlaying");
    if (player.playing) {
      await player.pause();
      paused = true;
    } else if (paused) {
      player.play();
      paused = false;
    } else {
      StartPlaying();
    }
  }

  void Save() {
    print("Save");
    List<String> names = [];
    songs.forEach((element) {
      names.add(element.filename);
    });
    Config["Playlist"] = names;
    SaveConfig();
  }

  void AddTagToAll(Tag t) {
    print("AddTagToAll");
    songs.forEach((element) {
      UpdateSongTags(element.filename, t.id, true);
    });
  }

  void SaveToTag(id, void Function(void Function()) reload) {
    print("SaveToTag");
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
    reload(() {});
  }

  void LoadPlaylist(void Function(void Function()) reload) {
    print("LoadPlaylist");
    List savedsongs = Config["Playlist"];
    if (savedsongs.isNotEmpty) {
      savedsongs.forEach((element) {
        if (Songs.containsKey(element)) {
          AddToPlaylist(Songs[element]);
        }
      });
      reload(() {});
    }
  }

  void Clear() {
    print("Clear");
    StopPlaying();
    songs = [];
    last_added_pos = 0;
    Save();
  }

  // The most common callbacks:
  @override
  Future<void> play() async {
    await PausePlaying();
  }

  @override
  Future<void> pause() async {
    await PausePlaying();
  }

  @override
  Future<void> stop() async {
    await StopPlaying();
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
  Future<void> skipToNext() async {
    PlayNextSong();
  }

  @override
  Future<void> skipToPrevious() async {
    PlayPreviousSong();
  }

  @override
  Future<void> seek(Duration position) async {
    print("seek");
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
