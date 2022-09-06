import 'package:flutter/material.dart';
import "../config.dart" as CFG;
import "song.dart" as Song;

class SongDrawer extends Drawer {
  const SongDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Center(
        child: ButtonBar(
          children: [
            TextButton(
              child: const Text("Search for new Songs"),
              onPressed: () {
                Directory dir = Directory('/storage/emulated/0/');
                List<FileSystemEntity> _files;
                _files = dir.listSync(recursive: true, followLinks: false);
                for (FileSystemEntity entity in _files) {
                  String path = entity.path;
                  if (path.endsWith('.mp3')) {
                    CFG.CreateSong(path);
                  }
                  ;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
