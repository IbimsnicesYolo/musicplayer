import 'package:flutter/material.dart';
import '../../settings.dart' as CFG;
import 'dart:io';

void SearchPaths(context) async {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AlertDialog(
        title: Text("Searching for Songs"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Close"))
            ],
          ),
        ),
      ),
    ),
  );

  int count = 0;
  List<String> path = [];
  for (String p in CFG.Config["SearchPaths"]) {
    path.add(p);
  }

  for (var i = 0; i < path.length; i++) {
    try {
      Directory dir = Directory(path[i]);
      List<FileSystemEntity> _files;
      _files = dir.listSync(recursive: true, followLinks: true);

      for (FileSystemEntity entity in _files) {
        await Future.delayed(Duration(milliseconds: 50));
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
  CFG.ShowSth("Created $count new Songs", context);
  if (count > 0) {
    CFG.SaveSongs();
  }
}

void ShowConfig(context, void Function(void Function()) update) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AlertDialog(
        title: Text("Config"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              for (var key in CFG.Config.keys)
                Text("$key: " + CFG.Config["$key"].toString()),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    update(() {});
                    CFG.SaveConfig();
                  },
                  child: Text("Close"))
            ],
          ),
        ),
      ),
    ),
  );
}

class SongDrawer extends Drawer {
  const SongDrawer({
    Key? key,
    required this.c,
  }) : super(key: key);

  final void Function(void Function()) c;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: CFG.HomeColor,
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
                          c(() {});
                        }),
                    TextButton(
                      child: const Text("Open Settings"),
                      onPressed: () {
                        ShowConfig(context, c);
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
