import "dart:async";
import 'dart:io';
import "dart:math";

import 'package:flutter/material.dart';
import "package:tagmusicplayer/sites/components/tagedit.dart";

import '../../settings.dart';
import "../allsongs.dart";
import "elevatedbutton.dart";
import "search.dart";
import "songtile.dart";
import "string_input.dart";

class SongDrawer extends Drawer {
  const SongDrawer({Key? key, required this.c, required this.Playlist, required this.done})
      : super(key: key);

  final MyAudioHandler Playlist;
  final void Function(void Function()) c;
  final done;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: HomeColor,
      // column holds all the widgets in the drawer
      child: Column(
        children: <Widget>[
          // This container holds the align
          Align(
            alignment: FractionalOffset.bottomCenter,
            // This container holds all the children that will be aligned
            // on the bottom and should not scroll with the above ListView
            child: Column(
              children: [
                StyledElevatedButton(
                    child: const Text("Search for new Songs"),
                    onPressed: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (_) => const SearchSongPage(),
                            ),
                          )
                          .then((value) => c(() {}));
                    }),
                StyledElevatedButton(
                    child: const Text("Edit Song Informations"),
                    onPressed: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (_) => ShowSongEdit(Playlist: Playlist, c: c),
                            ),
                          )
                          .then((value) => c(() {}));
                    }),
                StyledElevatedButton(
                  child: const Text("Open Settings"),
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => const ShowConfig(),
                          ),
                        )
                        .then((value) => c(() {}));
                  },
                ),
                StyledElevatedButton(
                  child: const Text("Open Blacklist"),
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => ShowBlacklist(Playlist: Playlist, c: c),
                          ),
                        )
                        .then((value) => c(() {}));
                  },
                ),
                StyledElevatedButton(
                  child: const Text("Critical Buttons"),
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => CriticalButtons(Pl: Playlist),
                          ),
                        )
                        .then((value) => c(() {}));
                  },
                ),
                StyledElevatedButton(
                  child: const Text("Add Random Song to Playlist"),
                  onPressed: () {
                    int tries = 0;
                    final random = Random();
                    List keys = Songs.keys.toList();
                    Song s;
                    do {
                      String element = keys[random.nextInt(keys.length)];
                      s = Songs[element]!;
                      tries++;
                      if (tries > Songs.length) {
                        // no unlimited loop if every song is already in the playlist
                        return;
                      }
                    } while (Playlist.Contains(s));
                    Playlist.AddToPlaylist(s);
                    final snackBar = SnackBar(
                      backgroundColor: Colors.green,
                      content: Text('Added ${s.title} to Playlist'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                ),
                Text("\nTags:${Tags.length}", style: const TextStyle(fontSize: 20)),
                Text("\nSongs:${Songs.length}", style: const TextStyle(fontSize: 20)),
              ],
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
    for (String p in Config["SearchPaths"]) {
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
        List<FileSystemEntity> files;
        files = dir.listSync(recursive: true, followLinks: true);

        for (FileSystemEntity entity in files) {
          await Future.delayed(const Duration(milliseconds: 1));
          String path = entity.path;
          if (path.endsWith('.mp3')) {
            if (await CreateSong(path)) {
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
          backgroundColor: ContrastColor,
          onPressed: () => {
            Navigator.of(context).pop(),
          },
          child: const Icon(Icons.arrow_back),
        ),
        appBar: AppBar(
          title: const Text("Search for unregistered Songs"),
          backgroundColor: HomeColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            children: [
              TextButton(
                onPressed: () {
                  if (!searching) {
                    StartSearch();
                  }
                },
                child: Text(searching ? "Searching..." : "Start Search"),
              ),
              Text(searchcount),
              Text(searchinfo),
            ],
          ),
        ),
      ),
    );
  }
}

class ShowSongEdit extends StatefulWidget {
  const ShowSongEdit({Key? key, required this.Playlist, required this.c}) : super(key: key);

  final MyAudioHandler Playlist;
  final void Function(void Function()) c;

  @override
  State<ShowSongEdit> createState() => _ShowSongEdit();
}

class _ShowSongEdit extends State<ShowSongEdit> {
  List<Song> FoundSongs = AllNotEditedSongs();
  int currentsong = 0;

  Widget SongEditPage() {
    if (currentsong < 0) {
      currentsong = FoundSongs.length - 1;
    }
    if (currentsong >= FoundSongs.length || currentsong < 0) {
      return const Center(
        child: Text("Done Editing all Songs"),
      );
    }
    Song csong = FoundSongs[currentsong];

    return Column(
      children: [
        Text("Editing Song ${currentsong + 1} of ${FoundSongs.length}\n",
            style: const TextStyle(fontSize: 15)),
        Text("\n${csong.filename}\n", style: const TextStyle(fontSize: 17)),
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
                            UpdateSongTitle(csong.id, s);
                          }),
                    ),
                  )
                  .then((value) => {
                        csong.title = value,
                        UpdateSongTitle(csong.id, value),
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
                            UpdateSongInterpret(csong.id, s);
                          }),
                    ),
                  )
                  .then((value) => {
                        csong.interpret = value,
                        UpdateSongInterpret(csong.id, value),
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
                            UpdateSongFeaturing(csong.id, s);
                          }),
                    ),
                  )
                  .then((value) => {
                        csong.featuring = value,
                        UpdateSongFeaturing(csong.id, value),
                        setState(() {}),
                      });
            },
            child: Text("Featuring: ${csong.featuring}")),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          StyledElevatedButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => ArtistTagChoose(s: csong)))
                  .then((value) {
                if (value != -1) {
                  UpdateSongTags(csong.id, value, true);
                }
              });
            },
            child: const Text("Artist Tags"),
          ),
          StyledElevatedButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const TagChoose()))
                  .then((value) {
                if (value != -1) {
                  UpdateSongTags(csong.id, value, true);
                }
              });
            },
            child: const Text("Playlist Tags"),
          ),
        ]),
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
                  currentsong += 1;
                  UpdateSongEdited(csong.id, true);
                  UpdateSongBlacklisted(csong.id, true);
                  widget.c(() {});
                  setState(() {});
                },
                child: const Text("Blacklist")),
            StyledElevatedButton(
                onPressed: () {
                  widget.Playlist.AddToPlaylist(csong);
                },
                child: const Text("Add to Playlist")),
            StyledElevatedButton(
                onPressed: () async {
                  currentsong += 1;
                  UpdateSongEdited(csong.id, true);
                  setState(() {});
                },
                child: const Text("Done")),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: ContrastColor,
          onPressed: () => {
            Navigator.of(context).pop(),
          },
          child: const Icon(Icons.arrow_back),
        ),
        appBar: AppBar(
          title: const Text("Song Edit"),
          backgroundColor: HomeColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => {
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
  const ShowConfig({Key? key}) : super(key: key);

  @override
  State<ShowConfig> createState() => _ShowConfig();
}

class _ShowConfig extends State<ShowConfig> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Config"),
        ),
        body: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
                child: Text("Home Color:${Config["HomeColor"]}"),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
                child: Text("Contrast Color:${Config["ContrastColor"]}"),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                child: Text("SearchPaths:${Config["SearchPaths"]}"),
              ),
              ElevatedButton(
                  onPressed: () {
                    StringInput(context, "Add Path", "Create", "Cancel", (String s) {
                      AddSearchPath(s);
                      setState(() {});
                    }, (String s) {
                      setState(() {});
                    }, false, "", "");
                    setState(() {});
                  },
                  child: const Text("Add Path")),
              ExpansionTile(
                title: const Text('Playlist'),
                children: <Widget>[
                  Builder(
                    builder: (BuildContext context) {
                      return Container(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int id in Config["Playlist"])
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, left: 5, right: 5, bottom: 0),
                                child: Text(Songs[id]!.title),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Close"))
            ],
          ),
        ),
      ),
    );
  }
}

class ShowBlacklist extends StatefulWidget {
  const ShowBlacklist({Key? key, required this.Playlist, required this.c}) : super(key: key);

  final MyAudioHandler Playlist;
  final void Function(void Function()) c;
  @override
  State<ShowBlacklist> createState() => _ShowBlacklist();
}

class _ShowBlacklist extends State<ShowBlacklist> {
  void update(void Function() c) {
    setState(
      () {
        c();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: ContrastColor,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back),
        ),
        appBar: AppBar(
          title: const Text("Blacklist"),
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (_) => SearchPage(
                          (search, update) => ListView(
                                children: [
                                  for (int key in Songs.keys)
                                    if (ShouldShowSong(key, search))
                                      SongTile(
                                          context, Songs[key]!, update, widget.Playlist, true, {
                                        0: true,
                                        1: true,
                                        2: true,
                                        3: false,
                                        4: false,
                                        5: false,
                                        6: false,
                                        7: false,
                                        8: true,
                                        9: false,
                                        10: false,
                                        11: false,
                                      }),
                                ],
                              ),
                          ""),
                    ),
                  )
                  .then((value) => update(() {})),
              icon: const Icon(Icons.search),
            ),
          ],
          backgroundColor: HomeColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => {
              Navigator.of(context).pop(),
            },
          ),
        ),
        body: ListView(
          children: [
            for (int key in Songs.keys)
              if (Songs[key]!.blacklisted)
                SongTile(context, Songs[key]!, update, widget.Playlist, true, {
                  0: true,
                  1: true,
                  2: true,
                  3: false,
                  4: false,
                  5: false,
                  6: false,
                  7: false,
                  8: true,
                  9: false,
                  10: false,
                  11: false,
                }),
          ],
        ),
      ),
    );
  }
}

class CriticalButtons extends StatefulWidget {
  const CriticalButtons({Key? key, required this.Pl}) : super(key: key);

  final MyAudioHandler Pl;
  @override
  State<CriticalButtons> createState() => _ShowTagDeletion();
}

class _ShowTagDeletion extends State<CriticalButtons> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: ContrastColor,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back),
        ),
        appBar: AppBar(
          title: const Text("Tag Deletion"),
        ),
        body: Center(
          child: Column(
            children: [
              StyledElevatedButton(
                  child: const Text("Add All To Edit"),
                  onPressed: () {
                    Songs.forEach((key, value) {
                      UpdateSongEdited(key, false);
                    });
                  }),
              TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    DeleteAllTags();
                    Songs.forEach((key, value) {
                      ClearSongTags(key);
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Delete All Tags", style: TextStyle(fontSize: 30))),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () {
                  widget.Pl.Clear();
                  DeleteAllSongs();
                  UpdateAllTags();
                  Navigator.pop(context);
                },
                child: const Text("Delete All Songs", style: TextStyle(fontSize: 30)),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () {
                  widget.Pl.Clear();
                  ResetConfig();
                  Navigator.pop(context);
                },
                child: const Text("Reset Config", style: TextStyle(fontSize: 30)),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () async {
                  widget.Pl.Clear();
                  await ImportFromFile(widget.Pl);
                  Navigator.pop(context);
                },
                child: const Text("Import From File", style: TextStyle(fontSize: 30)),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () async {
                  await ExportToFile(widget.Pl);
                  Navigator.pop(context);
                },
                child: const Text("Export to File", style: TextStyle(fontSize: 30)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
