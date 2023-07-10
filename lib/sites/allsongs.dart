import 'package:flutter/material.dart';

import "../classes/playlist.dart";
import "../classes/song.dart";
import 'components/search.dart';
import "components/songtile.dart";

bool ShouldShowSong(String key, String search) {
  if (Songs[key].blacklisted) {
    return false;
  }
  if (search == "") return true;

  if (Songs[key].title.toLowerCase().contains(search.toLowerCase())) return true;

  if (Songs[key].interpret.toLowerCase().contains(search.toLowerCase())) return true;

  if (Songs[key].featuring != 0 &&
      Songs[key].featuring.toLowerCase().contains(search.toLowerCase())) return true;

  /*
  List<String> searchname = search.toLowerCase().split(" ");
  for (String s2 in searchname) {
    if (Songs[key].title.contains(s2) ||
        Songs[key].interpret.contains(s2) ||
        Songs[key].featuring.contains(s2)) return true;
  }
  */
  return false;
}

IconButton buildActions(
    BuildContext context, void Function(void Function()) c, MyAudioHandler Playlist) {
  return IconButton(
    onPressed: () => Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => SearchPage(
                (search, update) => Container(
                      child: ListView(
                        children: [
                          for (String key in Songs.keys)
                            if (ShouldShowSong(key, search))
                              SongTile(context, Songs[key], c, Playlist, true, {
                                0: true,
                                1: true,
                                2: true,
                                3: true,
                                4: true,
                                5: true,
                                6: true,
                                7: true,
                                8: true,
                                9: false,
                                10: false,
                              }),
                        ],
                      ),
                    ),
                ""),
          ),
        )
        .then((value) => c(() {})),
    icon: const Icon(Icons.search),
  );
}

ListView buildContent(
    BuildContext context, void Function(void Function()) c, MyAudioHandler Playlist, int reverse) {
  List sorted = Songs.values.toList();
  sorted.sort((a, b) {
    return a.tags.length.compareTo(b.tags.length);
  });
  if (reverse == 0) {
    // sorted by used, highest first
    sorted = sorted.reversed.toList();

    // reversed = 1 sorted by used, lowest first
  } else if (reverse == 2) {
    // sorted by name, a-z
    sorted.sort((a, b) {
      return a.title.compareTo(b.title);
    });
  } else if (reverse == 3) {
    // sorted by name, z-a
    sorted.sort((a, b) {
      return a.title.compareTo(b.title);
    });
    sorted = sorted.reversed.toList();
  }
  return ListView(
    children: [
      for (Song s in sorted)
        if (ShouldShowSong(s.filename, ""))
          SongTile(
            context,
            s,
            c,
            Playlist,
            true,
            {
              0: true,
              1: true,
              2: true,
              3: true,
              4: true,
              5: true,
              6: true,
              7: true,
              8: true,
              9: false,
              10: false,
            },
          ),
    ],
  );
}
