import 'song.dart';
import "tag.dart";
import "../settings.dart";
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';

class MyAudioHandler extends BaseAudioHandler
    with
        QueueHandler, // mix in default queue callback implementations
        SeekHandler {
  List<Song> songs = [];
  int last_added_pos = 0;
  bool start = false;
  bool paused = false;
  AudioPlayer player = AudioPlayer();

  MyAudioHandler() {
    player.setSkipSilenceEnabled(true);
    player.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        start = true;
        PlayNextSong();
      }
    });

    // So that our clients (the Flutter UI and the system notification) know
    // what state to display, here we set up our audio handler to broadcast all
    // playback state changes as they happen via playbackState...
    player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  void AddToPlaylist(Song song) {
    if (songs.contains(song)) {
      return;
    }
    songs.add(song);
  }

  void InsertAsNext(Song song) {
    last_added_pos = 1;
    if (!songs.contains(song)) {
      songs.insert(1, song);
    } else {
      songs.remove(song);
      songs.insert(1, song);
    }
  }

  void Stack(Song song) {
    last_added_pos += 1;
    if (!songs.contains(song)) {
      songs.insert(last_added_pos, song);
    } else {
      songs.remove(song);
      songs.insert(last_added_pos, song);
    }
  }

  void RemoveSong(Song song) {
    songs.remove(song);
  }

  void Shuffle() {
    if (songs.length < 1) {
      return;
    }
    Song current = songs.removeAt(0);
    songs.shuffle();
    songs.insert(0, current);
    Save();
  }

  void JumpToSong(Song song) {
    int index = songs.indexOf(song);
    for (int i = 0; i < index; i++) {
      songs.add(songs.removeAt(0));
    }
    if (player.playing) {
      StartPlaying();
    } else {
      LoadNextToPlayer();
    }
  }

  void PlayNextSong() {
    if (songs.length > 0) {
      songs.add(songs.removeAt(0));
      if (player.playing || start) {
        start = false;
        player.seek(Duration(seconds: 0));
        StartPlaying();
      } else {
        LoadNextToPlayer();
      }
    }
  }

  void PlayPreviousSong() {
    if (songs.length > 0) {
      songs.insert(0, songs.removeAt(songs.length - 1));
      if (player.playing) {
        player.seek(Duration(seconds: 0));
        StartPlaying();
      } else {
        LoadNextToPlayer();
      }
    }
  }

  void LoadNextToPlayer() async {
    if (songs.length > 0) {
      player.seek(Duration(seconds: 0));
      await StartPlaying();
      await player.pause();
    }
  }

  Future<void> StartPlaying() async {
    if (songs.length > 0) {
      await player.stop();
      await player.setUrl('file://storage/' + songs[0].path);
      player.play();
      paused = false;
      var item = MediaItem(
        id: 'file://storage/' + songs[0].path,
        album: 'ajjdkansdukkanshgabds',
        title: songs[0].title,
        artist: songs[0].interpret,
      );
      mediaItem.add(item);
    }
  }

  Future<void> StopPlaying() async {
    await player.stop();
    paused = false;
    player.seek(Duration(seconds: 0));
  }

  Future<void> PausePlaying() async {
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
    List<String> names = [];
    songs.forEach((element) {
      names.add(element.filename);
    });
    Config["Playlist"] = names;
    SaveConfig();
  }

  void SaveToTag(id) {
    List<String> names = [];
    songs.forEach((element) {
      UpdateSongTags(element.filename, id, true);
    });
    ShouldSaveTags = true;
    ShouldSaveSongs = true;
    SaveTags();
    SaveSongs();
  }

  void LoadPlaylist(void Function(void Function()) reload) {
    List savedsongs = Config["Playlist"];
    if (savedsongs.isNotEmpty) {
      savedsongs.forEach((element) {
        if (Songs.containsKey(element)) {
          AddToPlaylist(Songs[element]);
        }
      });
    }
    reload(() {});
  }

  void AddTagToAll(Tag t) {
    songs.forEach((element) {
      UpdateSongTags(element.filename, t.id, true);
    });
  }

  void Clear() {
    StopPlaying();
    songs = [];
    last_added_pos = 0;
    Save();
  }

  // The most common callbacks:
  Future<void> play() async {
    await PausePlaying();
  }

  Future<void> pause() async {
    await PausePlaying();
  }

  Future<void> stop() async {
    await StopPlaying();
  }

  Future<void> shuffle() async {
    Shuffle();
  }

  Future<void> skipToNext() async {
    PlayNextSong();
  }

  Future<void> skipToPrevious() async {
    PlayPreviousSong();
  }

  Future<void> seek(Duration position) async {
    await player.seek(position);
  }

  Future<void> skipToQueueItem(int i) async {
    JumpToSong(songs[i]);
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
      systemActions: const {},
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
