import "../classes/tag.dart";
import "../classes/playlist.dart";
import 'components/string_input.dart';
import "components/music_control.dart";
import "components/player_widget.dart";
import "allsongs.dart" as AllSongs;
import 'package:flutter/material.dart';
import 'package:flutter_visualizers/Visualizers/LineVisualizer.dart';
import 'package:flutter_visualizers/Visualizers/MultiWaveVisualizer.dart';
import 'package:flutter_visualizers/visualizer.dart';

IconButton buildActions(BuildContext context, void Function(void Function()) c,
    CurrentPlayList Playlist) {
  return AllSongs.buildActions(context, c, Playlist);
}

Container buildContent(BuildContext context, void Function(void Function()) c,
    CurrentPlayList Playlist) {
  int playerID = Playlist.CurrentPlayerID;
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
          PlayerWidget(player: Playlist.player),
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
                    StringInput(context, "Tag Name to Save", "Save", "Nah",
                        (p0) {
                      int id = CreateTag(p0);
                      Playlist.SaveToTag(id);
                      Playlist.Clear();
                    }, (p0) {}, false, "", "Tag Name");
                  });
                },
                child: Text("Save Playlist To Tag"),
              ),
              TextButton(
                onPressed: () {
                  StringInput(context, "Tag Name to Add", "Add", "Nah", (p0) {
                    int id = CreateTag(p0);
                    Playlist.SaveToTag(id);
                  }, (p0) {}, false, "", "Tag Name");
                },
                child: Text("Add all Songs To Tag"),
              ),
            ],
          ),
          Visualizer(
            builder: (BuildContext context, List<int> wave) {
              return new CustomPaint(
                painter: new LineVisualizer(
                  waveData: wave,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.blueAccent,
                ),
                child: new Container(),
              );
            },
            id: playerID,
          ),
        ],
      ),
    ),
  );
}
