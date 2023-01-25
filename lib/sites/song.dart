import "../classes/playlist.dart";
import "components/music_control.dart";
import "components/player_widget.dart";
import "components/tagedit.dart";
import "components/songtile.dart";
import "allsongs.dart" as AllSongs;
import 'package:flutter/material.dart';

IconButton buildActions(BuildContext context, void Function(void Function()) c,
    MyAudioHandler Playlist) {
  return AllSongs.buildActions(context, c, Playlist);
}

Container buildContent(BuildContext context, void Function(void Function()) c,
    MyAudioHandler Playlist) {
  return Container(
    child: Center(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
            child: Text(
              (Playlist.songs.length > 0)
                  ? Playlist.songs[0].title
                  : "No songs in playlist",
              style: TextStyle(fontSize: 16),
            ),
          ),
          ControlTile(Playlist: Playlist, c: c),
          PlayerWidget(playlist: Playlist),
          Text("Lautstärke:"),
          VolumeWidget(player: Playlist.player),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  c(() {
                    Playlist.Clear();
                  });
                },
                child: Text("Clear Playlist"),
              ),
              TextButton(
                onPressed: () {
                  c(() {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => TagChoose()))
                        .then((value) {
                      if (value != -1) {
                        Playlist.SaveToTag(value, c);
                      }
                    });
                  });
                },
                child: Text("Save Playlist To Tag"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => TagChoose()))
                      .then((value) {
                    if (value != -1) {
                      Playlist.AddTagToAll(value);
                    }
                  });
                },
                child: Text("Add all Songs To Tag"),
              ),
            ],
          ),
          // Place for Equializer
          // Place for Visualizer
          Padding(
              padding:
                  EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 10),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (int i = 1; i < 5; i++)
                    if (i < Playlist.songs.length)
                      DragTarget<int>(
                        builder: (
                          BuildContext context,
                          List<dynamic> accepted,
                          List<dynamic> rejected,
                        ) {
                          return DismissibleSongTile(
                              context, Playlist.songs[i], c, Playlist);
                        },
                        onAccept: (int data) {
                          if (data == i) return;
                          if (i == 0 || data == 0) return;
                          Playlist.DragNDropUpdate(data, i);
                        },
                      ),
                ],
              )),
        ],
      ),
    ),
  );
}
