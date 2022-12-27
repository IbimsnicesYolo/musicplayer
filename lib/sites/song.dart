import "../classes/tag.dart";
import "../classes/playlist.dart";
import "../settings.dart" as CFG;
import "unsortedsongs.dart" as USongs;
import 'package:flutter/material.dart';

IconButton buildActions(BuildContext context, void Function(void Function()) c,
    CurrentPlayList Playlist) {
  return USongs.buildActions(context, c, Playlist);
}

Container buildContent(BuildContext context, void Function(void Function()) c,
    CurrentPlayList Playlist) {
  UpdateAllTags();
  return Container(
    child: Center(
      child: Column(
        children: [
          Text((Playlist.songs.length > 0)
              ? Playlist.songs[0].title
              : "No songs in playlist"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  c(() {
                    Playlist.PlayPreviousSong();
                  });
                },
                icon: Icon(Icons.skip_previous),
              ),
              IconButton(
                onPressed: () {
                  c(() {
                    Playlist.Shuffle();
                  });
                },
                icon: Icon(Icons.shuffle),
              ),
              IconButton(
                onPressed: () {
                  c(() {
                    Playlist.StartPlaying();
                  });
                },
                icon: Icon(Icons.play_arrow),
              ),
              IconButton(
                onPressed: () {
                  c(() {
                    Playlist.PausePlaying();
                  });
                },
                icon: Icon(Icons.pause),
              ),
              IconButton(
                onPressed: () {
                  c(() {
                    Playlist.StopPlaying();
                  });
                },
                icon: Icon(Icons.stop),
              ),
              IconButton(
                onPressed: () {
                  c(() {
                    Playlist.PlayNextSong();
                  });
                },
                icon: Icon(Icons.skip_next),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  c(() {
                    Playlist.Clear();
                  });
                },
                icon: Icon(Icons.clear),
              ),
              IconButton(
                onPressed: () {
                  c(() {
                    Playlist.Save();
                  });
                },
                icon: Icon(Icons.save),
              ),
              TextButton(
                onPressed: () {
                  CFG.ShowSth("Nah", context);
                },
                child: Text("Add all To Tag"),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
