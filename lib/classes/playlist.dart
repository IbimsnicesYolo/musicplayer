import 'song.dart';
import "tag.dart";
import "../settings.dart";
import 'package:audioplayers/audioplayers.dart';

class CurrentPlayList {
  List<Song> songs = [];
  int last_added_pos = 0;
  bool start = false;
  AudioPlayer player = AudioPlayer();

  CurrentPlayList() {
    player.setReleaseMode(ReleaseMode.stop);
    player.onPlayerComplete.listen((event) {
      start = true;
      PlayNextSong();
    });
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
    if (player.state == PlayerState.playing) {
      StartPlaying();
    } else {
      LoadNextToPlayer();
    }
  }

  void PlayNextSong() {
    if (songs.length > 0) {
      songs.add(songs.removeAt(0));
      if (player.state == PlayerState.playing || start) {
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
      if (player.state == PlayerState.playing) {
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
      await player.setSource(DeviceFileSource(songs[0].path));
      await player.stop();
      await player.play(DeviceFileSource(songs[0].path));
      player.seek(Duration(seconds: 0));
    }
  }

  void StopPlaying() async {
    await player.stop();
  }

  void PausePlaying() async {
    if (player.state == PlayerState.playing) {
      await player.pause();
    } else {
      await player.resume();
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
