import 'song.dart';
import "tag.dart";
import "../settings.dart";
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';

class CurrentPlayList {
  List<Song> songs = [];
  int last_added_pos = 0;
  bool start = false;
  AudioPlayer player = AudioPlayer();

  CurrentPlayList() {
    /*
    player.onPlayerComplete.listen((event) {
      start = true;
      PlayNextSong();
    });
    */
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
        StartPlaying();
      } else {
        LoadNextToPlayer();
      }
    }
  }

  void LoadNextToPlayer() async {
    if (songs.length > 0) {
      await StartPlaying();
      await player.pause();
    }
  }

  Future<void> StartPlaying() async {
    if (songs.length > 0) {
      await player.setUrl('file://' + songs[0].path);
      await player.stop();
      player.play();
      player.seek(Duration(seconds: 0));
    }
  }

  Future<void> StopPlaying() async {
    await player.stop();
    player.seek(Duration(seconds: 0));
  }

  Future<void> PausePlaying() async {
    if (player.playing) {
      await player.pause();
    } else {
      player.play();
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
}

CurrentPlayList Playlist = CurrentPlayList();

class MyAudioHandler extends BaseAudioHandler
    with
        QueueHandler, // mix in default queue callback implementations
        SeekHandler {
  CurrentPlayList playlist = Playlist;

  static final _item = MediaItem(
    id: 'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3',
    album: "Science Friday",
    title: "A Salute To Head-Scratching Science",
    artist: "Science Friday and WNYC Studios",
    duration: const Duration(milliseconds: 5739820),
    artUri: Uri.parse(
        'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'),
  );

  MyAudioHandler() {
    // So that our clients (the Flutter UI and the system notification) know
    // what state to display, here we set up our audio handler to broadcast all
    // playback state changes as they happen via playbackState...
    playlist.player.playbackEventStream
        .map(_transformEvent)
        .pipe(playbackState);
    // ... and also the current media item via mediaItem.
    mediaItem.add(_item);

    // Load the player.
    playlist.player.setAudioSource(AudioSource.uri(Uri.parse(_item.id)));
  }

  // mix in default seek callback implementations

  // The most common callbacks:
  Future<void> play() async {
    await Playlist.StartPlaying();
  }

  Future<void> pause() async {
    await Playlist.PausePlaying();
  }

  Future<void> stop() async {
    await Playlist.StopPlaying();
  }

  Future<void> seek(Duration position) async {
    await Playlist.player.seek(position);
  }

  Future<void> skipToQueueItem(int i) async {
    Playlist.JumpToSong(Playlist.songs[i]);
  }

  /// Transform a just_audio event into an audio_service state.
  ///
  /// This method is used from the constructor. Every event received from the
  /// just_audio player will be transformed into an audio_service state so that
  /// it can be broadcast to audio_service clients.
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (playlist.player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[playlist.player.processingState]!,
      playing: playlist.player.playing,
      updatePosition: playlist.player.position,
      bufferedPosition: playlist.player.bufferedPosition,
      speed: playlist.player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
