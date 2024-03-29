import 'package:flutter/material.dart';

import '../settings.dart';
import "allsongs.dart" as AllSongs;
import "components/music_control.dart";
import "components/player_widget.dart";
import "components/songtile.dart";
import "components/tagedit.dart";

IconButton buildActions(
    BuildContext context, void Function(void Function()) c, MyAudioHandler Playlist) {
  return AllSongs.buildActions(context, c, Playlist);
}

Center buildContent(
    BuildContext context, void Function(void Function()) c, MyAudioHandler Playlist) {
  return Center(
    child: Column(
      children: [
        Expanded(
          flex: 0,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
                child: Text(
                  (Playlist.songs.isNotEmpty)
                      ? "${Playlist.songs[0].title} || ${Playlist.songs[0].interpret}"
                      : "No songs in playlist",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              ControlTile(Playlist: Playlist, c: c),
              PlayerWidget(playlist: Playlist),
              //Text("Volume:"),
              //VolumeWidget(player: Playlist.player),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    child: const Text("Clear"),
                    onPressed: () {
                      Playlist.Clear();
                      c(() {
                        Playlist.Clear();
                      });
                    },
                  ),
                  ElevatedButton(
                    child: const Text("Save To Tag"),
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => const TagChoose()))
                          .then((value) {
                        if (value != -1) {
                          Playlist.SaveToTag(value);
                        }
                      }).then((value) => c(() {}));
                    },
                  ),
                  ElevatedButton(
                    child: const Text("Add To Tag"),
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => const TagChoose()))
                          .then((value) {
                        if (value != -1) {
                          Playlist.AddTagToAll(Tags[value]!);
                        }
                      }).then((value) => c(() {}));
                    },
                  ),
                  Text(
                    Playlist.songs.length.toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              // Place for Equializer
              // Place for Visualizer
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 10),
            child: ListView(
              shrinkWrap: true,
              children: [
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
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
