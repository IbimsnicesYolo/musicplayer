import "../classes/tag.dart";
import "../classes/playlist.dart";
import "unsortedsongs.dart" as USongs;
import "../classes/song.dart";
import "../settings.dart";
import 'package:flutter/material.dart';
import 'components/search.dart';
import 'components/string_input.dart';
import 'components/checkbox.dart';

IconButton buildActions(BuildContext context, void Function(void Function()) c,
    CurrentPlayList Playlist) {
  return USongs.buildActions(context, c, Playlist);
}

Container buildContent(BuildContext context, void Function(void Function()) c,
    CurrentPlayList Playlist) {
  UpdateAllTags();
  return Container(
    child: Text((Playlist.songs.length > 0)
        ? Playlist.songs[0].title
        : "No songs in playlist"),
  );
}
