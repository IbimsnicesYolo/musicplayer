import 'package:flutter/material.dart';
import "../settings.dart" as CFG;
import 'dart:io';

void SearchPaths(context) {
  int count = 0;
  List<String> path = [];
  path.add("storage/emulated/0/Music");
  path.add("storage/emulated/0/Download");

  for (var i = 0; i < path.length; i++) {
    try {
      Directory dir = Directory(path[i]);
      List<FileSystemEntity> _files;
      _files = dir.listSync(recursive: true, followLinks: true);

      for (FileSystemEntity entity in _files) {
        String path = entity.path;
        if (path.endsWith('.mp3')) {
          if (CFG.CreateSong(path)) {
            count += 1;
          }
        }
      }
    } catch (e) {
      CFG.ShowSth("There was an error searching: " + path[i], context);
    }
    ;
  }
  if (count > 0) {
    CFG.ShowSth("Created $count new Songs", context);
    CFG.SaveSongs();
  }
}

class SongDrawer extends Drawer {
  const SongDrawer({
    Key? key,
    required this.c,
  }) : super(key: key);

  final void Function() c;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      // column holds all the widgets in the drawer
      child: Column(
        children: <Widget>[
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
                          SearchPaths(context);
                          c();
                        }),
                    TextButton(
                      child: const Text("Open Settings"),
                      onPressed: () {
                        CFG.ShowSth("Pressed Settings", context);
                        // open settings page...
                        c();
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
