import 'package:flutter/material.dart';
import "../settings.dart" as CFG;
import "song.dart" as Song;
import 'dart:io';

class SongDrawer extends Drawer {
  const SongDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // column holds all the widgets in the drawer
      child: Column(
        children: <Widget>[
          Expanded(
            // ListView contains a group of widgets that scroll inside the drawer
            child: ListView(
              children: [
                for (var i in CFG.UnsortedSongs.keys)
                  Song.SongInfo(
                    s: CFG.UnsortedSongs[i],
                  ),
              ],
            ),
          ),
          // This container holds the align
          Container(
            // This align moves the children to the bottom
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              // This container holds all the children that will be aligned
              // on the bottom and should not scroll with the above ListView
              child: Container(
                child: Column(
                  children: [
                    TextButton(
                      child: const Text("Search for new Songs"),
                      onPressed: () {
                        Directory dir = Directory(
                            Platform.isAndroid ? '/storage/emulated/0/' : '');
                        List<FileSystemEntity> _files;
                        _files =
                            dir.listSync(recursive: true, followLinks: false);
                        for (FileSystemEntity entity in _files) {
                          String path = entity.path;
                          if (path.endsWith('.mp3')) {
                            CFG.CreateSong(path);
                          }
                          ;
                        }
                      },
                    ),
                    TextButton(
                      child: const Text("Open Settings"),
                      onPressed: () {
                        // open settings page...
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
