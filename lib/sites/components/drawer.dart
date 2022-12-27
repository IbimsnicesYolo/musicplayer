import 'package:flutter/material.dart';
import '../../settings.dart' as CFG;
import "../../classes/song.dart";
import "../../classes/tag.dart";
import 'dart:io';
import "string_input.dart";
import "elevatedbutton.dart";

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
                    TextButton(
                      child: const Text("Delete All Tags"),
                      onPressed: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (_) => ShowTagDeletion(),
                              ),
                            )
                            .then((value) => c(() {}));
                      },
                    ),
                    TextButton(
                      child: const Text("Delete All Songs"),
                      onPressed: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (_) => ShowSongDeletion(),
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
  List<String> FoundSongs = [];
  bool SongEdit = false;

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
      setState(() {
        String a = path[i];
        searchcount = "Found $count songs";
        searchinfo += "Scanning $a\n";
      });
      await Future.delayed(const Duration(milliseconds: 500));
      try {
        Directory dir = Directory(path[i]);
        List<FileSystemEntity> _files;
        _files = dir.listSync(recursive: true, followLinks: true);

        for (FileSystemEntity entity in _files) {
          await Future.delayed(Duration(milliseconds: 1));
          String path = entity.path;
          if (path.endsWith('.mp3')) {
            if (CreateSong(path)) {
              FoundSongs.add(path);
              count += 1;
            }
          }
          if (count % 100 == 0) {
            setState(() {
              searchcount = "Found $count songs";
            });
          }
        }
      } catch (e) {
        setState(() {
          String a = path[i];
          searchinfo += "\t Error Searching $a\n";
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

  Center SearchPage() {
    return Center(
      child: Column(
        children: [
          Container(
            child: TextButton(
              onPressed: StartSearch,
              child: Text(searching ? "Searching..." : "Start Search"),
            ),
          ),
          Text(searchcount),
          Text(searchinfo),
          StyledElevatedButton(
              onPressed: () {
                if (searching) {
                  return;
                }
                if (FoundSongs.length == 0) {
                  return;
                }
                setState(() {
                  SongEdit = true;
                });
              },
              child: const Text("Edit Songs"))
        ],
      ),
    );
  }

  Center SongEditPage() {
    String currentsong = "";
    try {
      currentsong = FoundSongs[0];
    } catch (e) {
      setState(() {
        SongEdit = false;
      });
    }

    if (currentsong == "") {
      setState(() {
        SongEdit = false;
      });
      return Center();
    }

    Song csong = Songs[currentsong.split("/").last];

    return Center(
      child: Column(
        children: [
          Text("\n" + csong.filename + "\n",
              style: const TextStyle(fontSize: 20)),
          StyledElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) => StringInputExpanded(
                            Title: "Song Title Edit",
                            Text: csong.title,
                            additionalinfos: csong.filename,
                            OnSaved: (String s) {
                              csong.title = s;
                              UpdateSongTitle(csong.filename, s);
                            }),
                      ),
                    )
                    .then((value) => {
                          csong.title = value,
                          UpdateSongTitle(csong.filename, value),
                          setState(() {}),
                        });
              },
              child: Text("Title: ${csong.title}")),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StyledElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => StringInputExpanded(
                                Title: "Song Artist Edit",
                                Text: csong.interpret,
                                additionalinfos: csong.filename,
                                OnSaved: (String s) {
                                  csong.interpret = s;
                                  UpdateSongInterpret(csong.filename, s);
                                }),
                          ),
                        )
                        .then((value) => {
                              csong.interpret = value,
                              UpdateSongInterpret(csong.filename, value),
                              setState(() {}),
                            });
                  },
                  child: Text("Artist: ${csong.title}")),
              StyledElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => StringInputExpanded(
                                Title: "Song Featuring Edit",
                                Text: csong.featuring,
                                additionalinfos: csong.filename,
                                OnSaved: (String s) {
                                  csong.interpret = s;
                                  UpdateSongFeaturing(csong.filename, s);
                                }),
                          ),
                        )
                        .then((value) => {
                              csong.featuring = value,
                              UpdateSongFeaturing(csong.filename, value),
                              setState(() {}),
                            });
                  },
                  child: Text("Featuring: ${csong.featuring}")),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StyledElevatedButton(
                onPressed: () {
                  setState(() {
                    SongEdit = false;
                  });
                },
                child: const Text("Back"),
              ),
              StyledElevatedButton(
                  onPressed: () {
                    int id = CreateTag(csong.interpret);
                    if (id > 0) {
                      UpdateSongTags(csong.filename, id, true);
                      SaveTags();
                    }
                  },
                  child: const Text("Create Artist Tag")),
              StyledElevatedButton(
                  onPressed: () {
                    setState(() {
                      searchcount = "";
                      FoundSongs.removeAt(0);
                    });
                  },
                  child: const Text("Done")),
            ],
          ),
        ],
      ),
    );
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
          title: Text("Search for unregistered Songs"),
        ),
        body: Container(
          child: SongEdit ? SongEditPage() : SearchPage(),
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

class ShowTagDeletion extends StatefulWidget {
  ShowTagDeletion({Key? key}) : super(key: key);

  @override
  State<ShowTagDeletion> createState() => _ShowTagDeletion();
}

class _ShowTagDeletion extends State<ShowTagDeletion> {
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
          title: Text("Tag Deletion"),
        ),
        body: Center(
          child: TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Tags = {};
                ShouldSaveTags = true;
                SaveTags();
                UpdateAllTags();
                Songs.forEach((key, value) {
                  value.tags = [];
                });
                SaveSongs();
                Navigator.pop(context);
              },
              child: Text("Delete All Tags", style: TextStyle(fontSize: 30))),
        ),
      ),
    );
  }
}

class ShowSongDeletion extends StatefulWidget {
  ShowSongDeletion({Key? key}) : super(key: key);

  @override
  State<ShowSongDeletion> createState() => _ShowSongDeletion();
}

class _ShowSongDeletion extends State<ShowSongDeletion> {
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
          title: Text("Song Deletion"),
        ),
        body: Center(
          child: TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Songs = {};
                ShouldSaveSongs = true;
                UpdateAllTags();
                SaveSongs();
                Navigator.pop(context);
              },
              child: Text("Delete All Songs", style: TextStyle(fontSize: 30))),
        ),
      ),
    );
  }
}
