import 'package:flutter/material.dart';

import '../settings.dart';
import "components/music_control.dart";
import 'components/search.dart';
import 'components/songtile.dart';

bool ShouldShowSong(int key, String search) {
  if (Songs[key]!.blacklisted) {
    return false;
  }
  if (search == "") return true;

  if (Songs[key]!.title.toLowerCase().contains(search.toLowerCase())) return true;

  if (Songs[key]!.interpret.toLowerCase().contains(search.toLowerCase())) return true;

  if (Songs[key]!.featuring != "" &&
      Songs[key]!.featuring.toLowerCase().contains(search.toLowerCase())) return true;
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
                (search, update) => ListView(
                      children: [
                        for (Song s in Playlist.songs)
                          if (ShouldShowSong(s.id, search))
                            DismissibleSongTile(context, Songs[s.id]!, c, Playlist),
                      ],
                    ),
                ""),
          ),
        )
        .then((value) => c(() {})),
    icon: const Icon(Icons.search),
  );
}

ListView buildContent(
    BuildContext context, void Function(void Function()) c, MyAudioHandler Playlist) {
  return ListView(
    reverse: true,
    children: [
      if (Playlist.songs.isNotEmpty) ...[
        Center(
          child: Text(
            "${Playlist.songs.length} Songs",
            style: const TextStyle(fontSize: 30),
          ),
        ),
        ControlTile(Playlist: Playlist, c: c),
        SongTile(context, Playlist.songs[0], c, Playlist, true, {
          0: true,
          1: true,
          2: true,
          3: true,
          4: false,
          5: false,
          6: false,
          7: false,
          8: false,
          9: false,
          10: false,
          11: true,
        }),
        for (int i = 1; i < Playlist.songs.length; i++)
          DragTarget<int>(
            builder: (
              BuildContext context,
              List<dynamic> accepted,
              List<dynamic> rejected,
            ) {
              return DismissibleSongTile(context, Playlist.songs[i], c, Playlist);
            },
            onAccept: (int data) {
              if (data == i) return;
              if (i == 0 || data == 0) return;
              Playlist.DragNDropUpdate(data, i);
              c(() {});
            },
          ),
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
  );
}
