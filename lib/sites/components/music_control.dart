import "package:audioplayers/audioplayers.dart";
import 'package:flutter/material.dart';
import 'package:tagmusicplayer/classes/playlist.dart';

class ControlTile extends StatefulWidget {
  ControlTile({Key? key, required this.Playlist, required this.c})
      : super(key: key);

  CurrentPlayList Playlist;
  final c;

  @override
  State<ControlTile> createState() => _ControlTile();
}

class _ControlTile extends State<ControlTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    widget.c(() {
                      widget.Playlist.PlayPreviousSong();
                    });
                  },
                  icon: Icon(Icons.skip_previous),
                ),
                IconButton(
                  onPressed: () {
                    widget.c(() {
                      widget.Playlist.Shuffle();
                    });
                  },
                  icon: Icon(Icons.shuffle),
                ),
                IconButton(
                  onPressed: () {
                    widget.c(() {
                      if (widget.Playlist.player.state == PlayerState.playing ||
                          widget.Playlist.player.state == PlayerState.paused) {
                        widget.Playlist.PausePlaying();
                      } else {
                        widget.Playlist.StartPlaying();
                      }
                    });
                  },
                  icon: Icon(
                      (widget.Playlist.player.state == PlayerState.playing)
                          ? Icons.pause
                          : Icons.play_arrow),
                ),
                IconButton(
                  onPressed: () {
                    widget.c(() {
                      widget.Playlist.StopPlaying();
                    });
                  },
                  icon: Icon(Icons.stop),
                ),
                IconButton(
                  onPressed: () {
                    widget.c(() {
                      widget.Playlist.PlayNextSong();
                    });
                  },
                  icon: Icon(Icons.skip_next),
                ),
              ],
            ),
          ],
        ));
  }
}
