import "../classes/playlist.dart";
import "components/music_control.dart";
import "components/player_widget.dart";
import "components/tagedit.dart";
import "allsongs.dart" as AllSongs;
import 'package:flutter/material.dart';

IconButton buildActions(BuildContext context, void Function(void Function()) c,
    CurrentPlayList Playlist) {
  return AllSongs.buildActions(context, c, Playlist);
}

Container buildContent(BuildContext context, void Function(void Function()) c,
    CurrentPlayList Playlist) {
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
          /*
          Not implemented in plugin yet
          Text("Balance:"),
          BalanceWidget(player: Playlist.player),
          */
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
                        Playlist.SaveToTag(value);
                        Playlist.Clear();
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
                      Playlist.SaveToTag(value);
                    }
                  });
                },
                child: Text("Add all Songs To Tag"),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
