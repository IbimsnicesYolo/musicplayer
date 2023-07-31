import 'package:flutter/material.dart';

import '../../../classes/playlist.dart';

class ControlTile extends StatefulWidget {
  const ControlTile({Key? key, required this.Playlist, required this.c}) : super(key: key);

  final MyAudioHandler Playlist;
  final void Function(void Function()) c;

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
                      widget.Playlist.skipToPrevious();
                    });
                  },
                  icon: const Icon(Icons.skip_previous),
                ),
                IconButton(
                  onPressed: () {
                    widget.c(() {
                      widget.Playlist.Shuffle();
                    });
                  },
                  icon: const Icon(Icons.shuffle),
                ),
                IconButton(
                  onPressed: () {
                    widget.c(() {
                      widget.Playlist.pause();
                    });
                  },
                  icon: Icon((widget.Playlist.player.playing) ? Icons.pause : Icons.play_arrow),
                ),
                IconButton(
                  onPressed: () {
                    widget.c(() {
                      widget.Playlist.stop();
                    });
                  },
                  icon: const Icon(Icons.stop),
                ),
                IconButton(
                  onPressed: () {
                    widget.c(() {
                      widget.Playlist.skipToNext();
                    });
                  },
                  icon: const Icon(Icons.skip_next),
                ),
              ],
            ),
          ],
        ));
  }
}
