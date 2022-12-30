import "../classes/song.dart";
import "../classes/playlist.dart";
import 'package:flutter/material.dart';
import 'components/search.dart';
import "components/songtile.dart";

bool ShouldShowSong(String key, String search) {
  if (Songs[key].blacklisted) {
    return false;
  }
  if (search == "") return true;

  if (Songs[key].title.toLowerCase().contains(search.toLowerCase()))
    return true;

  if (Songs[key].interpret.toLowerCase().contains(search.toLowerCase()))
    return true;

  if (Songs[key].featuring != 0 &&
      Songs[key].featuring.toLowerCase().contains(search.toLowerCase()))
    return true;

  List<String> searchname = search.toLowerCase().split(" ");

  for (String s2 in searchname) {
    if (Songs[key].title.contains(s2) ||
        Songs[key].interpret.contains(s2) ||
        Songs[key].featuring.contains(s2)) return true;
  }

  return false;
}

IconButton buildActions(BuildContext context, void Function(void Function()) c,
    CurrentPlayList Playlist) {
  return IconButton(
    onPressed: () => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchPage(
            (search, update) => Container(
                  child: ListView(
                    children: [
                      for (String key in Songs.keys)
                        if (ShouldShowSong(key, search))
                          SongTile(context, Songs[key], c, Playlist),
                    ],
                  ),
                ),
            ""),
      ),
    ),
    icon: const Icon(Icons.search),
  );
}

ListView buildContent(BuildContext context, void Function(void Function()) c,
    CurrentPlayList Playlist) {
  return ListView(
    children: [
      for (String key in Songs.keys)
        if (ShouldShowSong(key, "")) SongTile(context, Songs[key], c, Playlist),
    ],
  );
}
