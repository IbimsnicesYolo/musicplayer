import 'song.dart';
import "tag.dart";
import "../settings.dart";
import 'package:audioplayers/audioplayers.dart';

/* Playlist */
class CurrentPlayList {
  List<Song> songs = [];
  int last_added_pos = 0;

  void AddToPlaylist(Song song) {
    if (!songs.contains(song)) {
      return;
    }
    songs.add(song);
  }

  void PlayNext(Song song) {
    last_added_pos = 0;
    if (!songs.contains(song)) {
      songs.insert(0, song);
    } else {
      songs.remove(song);
      songs.insert(0, song);
    }
  }

  void PlayAfterLastAdded(Song song) {
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
    songs.shuffle();
  }

  void PlayNextSong() {
    if (songs.length > 0) {
      songs.add(songs.removeAt(0));
    }
  }

  void PlayPreviousSong() {
    if (songs.length > 0) {
      songs.insert(0, songs.removeAt(songs.length - 1));
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
    songs = [];
  }
}
