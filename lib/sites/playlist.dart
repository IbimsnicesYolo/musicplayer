import 'package:tagmusicplayer/main.dart';
import "../settings.dart" as CFG;
import 'package:flutter/material.dart';
import 'components/search.dart' as SearchPage;
import 'components/string_input.dart' as SInput;
import 'components/checkbox.dart' as C;

// TODO Implement SearchPage the right way
IconButton buildActions(BuildContext context, CurrentPlayList Playlist) {
  return IconButton(
    onPressed: () => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MaterialApp(
          theme: ThemeData.dark(),
          home: SearchPage.SearchPage(Playlist),
        ),
      ),
    ),
    icon: const Icon(Icons.search),
  );
}

// TODO Implemment the Song Tile right
Container buildContent(void Function(void Function()) c, BuildContext context,
    CurrentPlayList Playlist) {
  return Container(
    child: ListView(
      children: [
        if (!Playlist.songs.isEmpty) ...[
          for (var i in Playlist.songs) Text(i.title), // <-- TODO
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
