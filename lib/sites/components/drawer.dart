import 'package:flutter/material.dart';
import '../../settings.dart' as CFG;
import "../../classes/song.dart";
import 'dart:io';

class SearchSongPage extends StatefulWidget {
  const SearchSongPage({
    Key? key,
  }) : super(key: key);
  @override
  State<SearchSongPage> createState() => _SearchSongPage();
}

class _SearchSongPage extends State<SearchSongPage> {
  String searchinfo = "";
  String searchcount = "";
  bool searching = false;

  void StartSearch() async {
    setState(() {
      searching = true;
    });

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
        int reload = 0;
        int filecount = _files.length;

        for (FileSystemEntity entity in _files) {
          await Future.delayed(Duration(milliseconds: 1));
          String path = entity.path;
          if (path.endsWith('.mp3')) {
            if (CreateSong(path)) {
              count += 1;
            }
          }
          reload += 1;
          if (reload % (filecount / 10) == 0) {
            reload = 0;
            setState(() {
              searchcount = "Found $count songs";
              searchinfo += "Scanning $path\n";
            });
          }
        }
      } catch (e) {
        setState(() {
          searchinfo += "\t Error Searching $path\n";
        });
      }
      ;
    }
    if (count > 0) {
      SaveSongs();
    }

    setState(() {
      searchcount = "Found $count new songs";
      searchinfo = "Finished searching";
      searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: CFG.ContrastColor,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back),
        ),
        appBar: AppBar(
          title: Text("Search"),
        ),
        body: Container(
          child: Center(
            child: Column(
              children: [
                Container(
                  child: TextButton(
                    onPressed: () => StartSearch(),
                    child: Text(searching ? "Searching..." : "Start Search"),
                  ),
                ),
                Text(searchcount),
                Text(searchinfo),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShowConfig extends StatefulWidget {
  ShowConfig({Key? key}) : super(key: key);

  @override
  State<ShowConfig> createState() => _ShowConfig();
}

class _ShowConfig extends State<ShowConfig> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: CFG.ContrastColor,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back),
        ),
        appBar: AppBar(
          title: Text("Config"),
        ),
        body: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              for (var key in CFG.Config.keys)
                Text("$key: " + CFG.Config["$key"].toString()),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    CFG.SaveConfig();
                  },
                  child: Text("Close"))
            ],
          ),
        ),
      ),
    );
  }
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
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (_) => SearchSongPage(),
                                ),
                              )
                              .then((value) => c(() {}));
                        }),
                    TextButton(
                      child: const Text("Open Settings"),
                      onPressed: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (_) => ShowConfig(),
                              ),
                            )
                            .then((value) => c(() {}));
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
