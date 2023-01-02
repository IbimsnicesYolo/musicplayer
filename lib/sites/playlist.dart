import "../classes/playlist.dart";
import "../classes/song.dart";
import "../settings.dart";
import 'package:flutter/material.dart';
import 'components/search.dart';
import "components/music_control.dart";
import 'components/songtile.dart';

bool ShouldShowSong(String key, String search) {
  if (Songs[key].blacklisted) {
    return false;
  }
  if (search == "") return true;

  if (Songs[key].title.toLowerCase().contains(search.toLowerCase()))
    return true;

  if (Songs[key].interpret.toLowerCase().contains(search.toLowerCase()))
    return true;

  if (Songs[key].featuring != "" &&
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
    MyAudioHandler Playlist) {
  return IconButton(
    onPressed: () => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchPage(
            (search, update) => Container(
                  child: ListView(
                    children: [
                      for (String key in Config["Playlist"])
                        if (ShouldShowSong(key, search))
                          DismissibleSongTile(context, Songs[key], c, Playlist),
                    ],
                  ),
                ),
            ""),
      ),
    ),
    icon: const Icon(Icons.search),
  );
}

Container buildContent(BuildContext context, void Function(void Function()) c,
    MyAudioHandler Playlist) {
  return Container(
    child: ListView(
      reverse: true,
      children: [
        if (!Playlist.songs.isEmpty) ...[
          ControlTile(Playlist: Playlist, c: c),
          for (int i = 0; i < Playlist.songs.length; i++)
            DismissibleSongTile(context, Playlist.songs[i], c, Playlist),
        ] else ...[
          const Align(
            alignment: Alignment.center,
            heightFactor: 10,
            child: Text(
              'No Current Playlist',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
          ),
        ]
      ],
    ),
  );
}
