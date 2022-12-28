import 'package:flutter/material.dart';
import '../../settings.dart' as CFG;
import "../../classes/playlist.dart";
import "../../classes/song.dart";
import "../../classes/tag.dart";
import "../allsongs.dart";
import 'dart:io';
import "search.dart";
import "string_input.dart";
import "elevatedbutton.dart";

class SongDrawer extends Drawer {
  const SongDrawer({Key? key, required this.c, required this.Playlist})
      : super(key: key);

  final CurrentPlayList Playlist;
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
                        child: const Text("Edit Song Informations"),
                        onPressed: () {
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ShowSongEdit(Playlist: Playlist, c: c),
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
                                builder: (_) => ShowSongDeletion(
                                  Pl: Playlist,
                                ),
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
      ShouldSaveSongs = true;
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
          onPressed: () => {
            Navigator.of(context).pop(),
          },
          child: const Icon(Icons.arrow_back),
        ),
        appBar: AppBar(
          title: Text("Search for unregistered Songs"),
          backgroundColor: CFG.HomeColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(
          child: Center(
            child: Column(
              children: [
                Container(
                  child: TextButton(
                    onPressed: () {
                      if (!searching) {
                        StartSearch();
                      }
                    },
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

class ShowSongEdit extends StatefulWidget {
  ShowSongEdit({Key? key, required this.Playlist, required this.c})
      : super(key: key);

  final Playlist;
  final c;

  @override
  State<ShowSongEdit> createState() => _ShowSongEdit();
}

// TODO add Songs via swipe from SearchPage to the FoundSongs list
class _ShowSongEdit extends State<ShowSongEdit> {
  List<Song> FoundSongs = AllNotEditedSongs();
  int currentsong = 0;

  Center SongEditPage() {
    if (currentsong < 0) {
      return Center(
        child: Text("No Songs Found"),
      );
    }
    if (currentsong >= FoundSongs.length) {
      return Center(
        child: Text("Done Editing all Songs"),
      );
    }
    Song csong = FoundSongs[currentsong];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Editing Song ${currentsong + 1} of ${FoundSongs.length}\n",
              style: const TextStyle(fontSize: 15)),
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
              child: Text("Artist: ${csong.interpret}")),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StyledElevatedButton(
                onPressed: () {
                  setState(() {
                    currentsong -= 1;
                  });
                },
                child: const Text("Back"),
              ),
              StyledElevatedButton(
                  onPressed: () {
                    int id = CreateTag(csong.interpret);
                    if (id > -1) {
                      UpdateSongTags(csong.filename, id, true);
                    }
                    currentsong += 1;
                    csong.edited = true;

                    if (currentsong % 10 == 0) {
                      SaveSongs();
                    }
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
          onPressed: () => {
            ShouldSaveSongs = true,
            ShouldSaveTags = true,
            SaveTags(),
            SaveSongs(),
            Navigator.of(context).pop(),
          },
          child: const Icon(Icons.arrow_back),
        ),
        appBar: AppBar(
          title: Text("Song Edit"),
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SearchPage(
                      (search, update) => Container(
                            child: ListView(
                              children: [
                                for (String key in Songs.keys)
                                  if (ShouldShowSong(key, search))
                                    SongTile(context, Songs[key], widget.c,
                                        widget.Playlist),
                              ],
                            ),
                          ),
                      ""),
                ),
              ),
              icon: const Icon(Icons.search),
            ),
          ],
          backgroundColor: CFG.HomeColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => {
              ShouldSaveSongs = true,
              ShouldSaveTags = true,
              SaveTags(),
              SaveSongs(),
              Navigator.of(context).pop(),
            },
          ),
        ),
        body: Container(
          child: SongEditPage(),
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
  ShowSongDeletion({Key? key, required this.Pl}) : super(key: key);

  final CurrentPlayList Pl;
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
                widget.Pl.Clear();
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
