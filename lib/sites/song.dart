import "../classes/playlist.dart";
import "components/music_control.dart";
import "components/player_widget.dart";
import "components/tagedit.dart";
import "allsongs.dart" as AllSongs;
import "../settings.dart" as CFG;
import 'package:flutter/material.dart';

IconButton buildActions(BuildContext context, void Function(void Function()) c,
    MyAudioHandler Playlist) {
  return AllSongs.buildActions(context, c, Playlist);
}

Container buildContent(BuildContext context, void Function(void Function()) c,
    MyAudioHandler Playlist) {
  if (CFG.NewVersionAvailable) {
    final snackBar = SnackBar(
      content: const Text('New Version Available, Update Config!'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          CFG.NewVersionAvailable = false;
          // Some code to undo the change.
        },
      ),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

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
        ],
      ),
    ),
  );
}
