import 'package:tagmusicplayer/main.dart';
import "../settings.dart" as CFG;
import 'package:flutter/material.dart';
import 'components/search.dart' as SearchPage;
import 'components/string_input.dart' as SInput;
import 'components/checkbox.dart' as C;

// TODO Fix Create Tag Button Color
// TODO Implement SearchPage the right way at all 3 Positions
// ( Search Songs in Tag, Search all songs)

IconButton buildActions(BuildContext context, CurrentPlayList Playlist,
    void Function(void Function()) c) {
  return IconButton(
    onPressed: () => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MaterialApp(
          theme: ThemeData.dark(),
          home: SearchPage.SearchPage(
            (search, update) => Container(
              child: ListView(
                children: [
                  for (int key in CFG.Tags.keys)
                    if (CFG.Tags[key].name
                        .toLowerCase()
                        .contains(search.toLowerCase()))
                      Dismissible(
                        key: Key(key.toString()),
                        onDismissed: (direction) {
                          update(() {
                            CFG.DeleteTag(CFG.Tags[key]);
                          });
                        },
                        background: Container(
                          color: Colors.red,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.white),
                                Text('Move to trash',
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.delete, color: Colors.white),
                                Text('Move to trash',
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                        child: ListTile(
                          onLongPress: () => {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MaterialApp(
                                  theme: ThemeData.dark(),
                                  home: SearchPage.SearchPage(
                                    (search, update) => Container(
                                      child: ListView(
                                        children: [
                                          for (String songkey
                                              in CFG.GetSongsFromTag(
                                                      CFG.Tags[key])
                                                  .keys)
                                            if (CFG.Songs[songkey].title
                                                    .toLowerCase()
                                                    .contains(
                                                        search.toLowerCase()) ||
                                                CFG.Songs[songkey].interpret
                                                    .toLowerCase()
                                                    .contains(
                                                        search.toLowerCase()))
                                              Dismissible(
                                                key: Key(songkey +
                                                    CFG.Songs[songkey].hash),
                                                onDismissed: (DismissDirection
                                                    direction) {
                                                  update(() {
                                                    if (direction ==
                                                        DismissDirection
                                                            .endToStart) {
                                                      // Left
                                                      CFG.Songs[songkey].hash +=
                                                          "1";
                                                      Playlist.AddToPlaylist(
                                                          CFG.Songs[songkey]);
                                                    } else {
                                                      // Right
                                                      CFG.UpdateSongTags(
                                                          songkey, key, false);
                                                    }
                                                  });
                                                },
                                                background: Container(
                                                  color: Colors.red,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.delete,
                                                            color:
                                                                Colors.white),
                                                        Text('Remove from Tag',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                secondaryBackground: Container(
                                                  color: Colors.green,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Icon(Icons.add,
                                                            color:
                                                                Colors.white),
                                                        Text('Add To Stack',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                child: PopupMenuButton(
                                                  onSelected: (result) {
                                                    if (result == 0) {
                                                      showModalBottomSheet<
                                                          void>(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return Container(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                2,
                                                            color:
                                                                CFG.HomeColor,
                                                            child: Center(
                                                              child: Column(
                                                                children: <
                                                                    Widget>[
                                                                  for (CFG.Tag t
                                                                      in CFG
                                                                          .Tags
                                                                          .values)
                                                                    C.CoolerCheckBox(
                                                                        CFG
                                                                            .Songs[
                                                                                songkey]
                                                                            .tags
                                                                            .contains(t.id),
                                                                        (bool?
                                                                            b) {
                                                                      CFG.UpdateSongTags(
                                                                          CFG.Songs[songkey]
                                                                              .filename,
                                                                          t.id,
                                                                          b);
                                                                    }, t.name),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    }
                                                    if (result == 1) {
                                                      Playlist.PlayNext(
                                                          CFG.Songs[songkey]);
                                                      // Play Song as Next Song
                                                    }
                                                    if (result == 2) {
                                                      Playlist.AddToPlaylist(
                                                          CFG.Songs[songkey]);
                                                      // Add Song to End of Playlist
                                                    }
                                                    if (result == 3) {
                                                      Playlist
                                                          .PlayAfterLastAdded(
                                                              CFG.Songs[
                                                                  songkey]);
                                                      // Add Song to End of Added Songs
                                                    }
                                                    CFG.SaveConfig();
                                                  },
                                                  child: ListTile(
                                                    title: Text(CFG
                                                        .Songs[songkey].title),
                                                    subtitle: Text(CFG
                                                        .Songs[songkey]
                                                        .interpret),
                                                  ),
                                                  itemBuilder:
                                                      (BuildContext context) =>
                                                          <PopupMenuEntry>[
                                                    const PopupMenuItem(
                                                        child:
                                                            Text('Edit Tags'),
                                                        value: 0),
                                                    const PopupMenuDivider(),
                                                    const PopupMenuItem(
                                                        child:
                                                            Text('Play Next'),
                                                        value: 1),
                                                    const PopupMenuItem(
                                                        child: Text(
                                                            'Add to Playlist'),
                                                        value: 2),
                                                    const PopupMenuItem(
                                                        child: Text(
                                                            'Add to Play Next Stack'),
                                                        value: 3),
                                                  ],
                                                ),
                                              ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            c(() {}),
                          },
                          trailing:
                              Row(mainAxisSize: MainAxisSize.min, children: [
                            PopupMenuButton(
                              onSelected: (result) {
                                if (result == 0) {
                                  // Change Name
                                  SInput.StringInput(
                                    context,
                                    "Rename Tag",
                                    "Save",
                                    "Cancel",
                                    (String s) {
                                      CFG.UpdateTagName(CFG.Tags[key].id, s);
                                      c(() {});
                                    },
                                    (String s) {},
                                    false,
                                    CFG.Tags[key].name,
                                  );
                                }
                                if (result == 1) {
                                  CFG.GetSongsFromTag(CFG.Tags[key])
                                      .forEach((key, value) {
                                    Playlist.AddToPlaylist(value);
                                  });
                                }
                                if (result == 2) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => MaterialApp(
                                        theme: ThemeData.dark(),
                                        home: SearchPage.SearchPage(
                                          (search, update) => Container(
                                            child: ListView(
                                              children: [
                                                for (String songkey
                                                    in CFG.Songs.keys)
                                                  if ((CFG.Songs[songkey].title
                                                              .toLowerCase()
                                                              .contains(search
                                                                  .toLowerCase()) ||
                                                          CFG.Songs[songkey]
                                                              .interpret
                                                              .toLowerCase()
                                                              .contains(search
                                                                  .toLowerCase())) &
                                                      !CFG.Songs[songkey].tags
                                                          .contains(key))
                                                    Dismissible(
                                                      key: Key(songkey +
                                                          CFG.Songs[songkey]
                                                              .hash),
                                                      onDismissed:
                                                          (DismissDirection
                                                              direction) {
                                                        update(() {
                                                          CFG.UpdateSongTags(
                                                              songkey,
                                                              key,
                                                              true);
                                                        });
                                                      },
                                                      background: Container(
                                                        color: Colors.green,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(15),
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.add,
                                                                  color: Colors
                                                                      .white),
                                                              Text('Add To Tag',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white)),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      secondaryBackground:
                                                          Container(
                                                        color: Colors.green,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(15),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Icon(Icons.add,
                                                                  color: Colors
                                                                      .white),
                                                              Text('Add To Tag',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white)),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      child: PopupMenuButton(
                                                        onSelected: (result) {
                                                          if (result == 0) {
                                                            showModalBottomSheet<
                                                                void>(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return Container(
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height /
                                                                      2,
                                                                  color: CFG
                                                                      .HomeColor,
                                                                  child: Center(
                                                                    child:
                                                                        Column(
                                                                      children: <
                                                                          Widget>[
                                                                        for (CFG.Tag t in CFG
                                                                            .Tags
                                                                            .values)
                                                                          C.CoolerCheckBox(
                                                                              CFG.Songs[songkey].tags.contains(t.id),
                                                                              (bool? b) {
                                                                            CFG.UpdateSongTags(
                                                                                CFG.Songs[songkey].filename,
                                                                                t.id,
                                                                                b);
                                                                          }, t.name),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          }
                                                          if (result == 1) {
                                                            Playlist.PlayNext(
                                                                CFG.Songs[
                                                                    songkey]);
                                                            // Play Song as Next Song
                                                          }
                                                          if (result == 2) {
                                                            Playlist
                                                                .AddToPlaylist(
                                                                    CFG.Songs[
                                                                        songkey]);
                                                            // Add Song to End of Playlist
                                                          }
                                                          if (result == 3) {
                                                            Playlist
                                                                .PlayAfterLastAdded(
                                                                    CFG.Songs[
                                                                        songkey]);
                                                            // Add Song to End of Added Songs
                                                          }
                                                          CFG.SaveConfig();
                                                        },
                                                        child: ListTile(
                                                          title: Text(CFG
                                                              .Songs[songkey]
                                                              .title),
                                                          subtitle: Text(CFG
                                                              .Songs[songkey]
                                                              .interpret),
                                                        ),
                                                        itemBuilder:
                                                            (BuildContext
                                                                    context) =>
                                                                <PopupMenuEntry>[
                                                          const PopupMenuItem(
                                                              child: Text(
                                                                  'Edit Tags'),
                                                              value: 0),
                                                          const PopupMenuDivider(),
                                                          const PopupMenuItem(
                                                              child: Text(
                                                                  'Play Next'),
                                                              value: 1),
                                                          const PopupMenuItem(
                                                              child: Text(
                                                                  'Add to Playlist'),
                                                              value: 2),
                                                          const PopupMenuItem(
                                                              child: Text(
                                                                  'Add to Play Next Stack'),
                                                              value: 3),
                                                        ],
                                                      ),
                                                    ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                if (result == 3) {
                                  // Delete
                                  CFG.DeleteTag(CFG.Tags[key]);
                                  c(() {});
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry>[
                                PopupMenuItem(
                                    child: Text(CFG.Tags[key].name), value: 0),
                                PopupMenuDivider(),
                                const PopupMenuItem(
                                    child: Text('Add Songs to Playlist'),
                                    value: 1),
                                PopupMenuDivider(),
                                const PopupMenuItem(
                                    child: Text('Search all Songs'), value: 2),
                                PopupMenuDivider(),
                                const PopupMenuItem(
                                    child: Text('Delete Tag'), value: 3),
                              ],
                            ),
                          ]),
                          title: Text(CFG.Tags[key].name),
                          subtitle: Text(CFG.Tags[key].used.toString()),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    icon: const Icon(Icons.search),
  );
}

Container buildContent(void Function(void Function()) c, BuildContext context,
    CurrentPlayList Playlist) {
  CFG.UpdateAllTags();
  return Container(
    child: ListView(
      children: [
        for (int key in CFG.Tags.keys)
          ListTile(
            onLongPress: () => {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MaterialApp(
                    theme: ThemeData.dark(),
                    home: SearchPage.SearchPage(
                      (search, update) => Container(
                        child: ListView(
                          children: [
                            for (String songkey
                                in CFG.GetSongsFromTag(CFG.Tags[key]).keys)
                              if (CFG.Songs[songkey].title
                                      .toLowerCase()
                                      .contains(search.toLowerCase()) ||
                                  CFG.Songs[songkey].interpret
                                      .toLowerCase()
                                      .contains(search.toLowerCase()))
                                Dismissible(
                                  key: Key(songkey + CFG.Songs[songkey].hash),
                                  onDismissed: (DismissDirection direction) {
                                    update(() {
                                      if (direction ==
                                          DismissDirection.endToStart) {
                                        // Left
                                        CFG.Songs[songkey].hash += "1";
                                        Playlist.AddToPlaylist(
                                            CFG.Songs[songkey]);
                                      } else {
                                        // Right
                                        CFG.UpdateSongTags(songkey, key, false);
                                      }
                                    });
                                  },
                                  background: Container(
                                    color: Colors.red,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete,
                                              color: Colors.white),
                                          Text('Remove from Tag',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  secondaryBackground: Container(
                                    color: Colors.green,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Icon(Icons.add, color: Colors.white),
                                          Text('Add To Stack',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  child: PopupMenuButton(
                                    onSelected: (result) {
                                      if (result == 0) {
                                        showModalBottomSheet<void>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  2,
                                              color: CFG.HomeColor,
                                              child: Center(
                                                child: Column(
                                                  children: <Widget>[
                                                    for (CFG.Tag t
                                                        in CFG.Tags.values)
                                                      C.CoolerCheckBox(
                                                          CFG.Songs[songkey]
                                                              .tags
                                                              .contains(t.id),
                                                          (bool? b) {
                                                        CFG.UpdateSongTags(
                                                            CFG.Songs[songkey]
                                                                .filename,
                                                            t.id,
                                                            b);
                                                      }, t.name),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                      if (result == 1) {
                                        Playlist.PlayNext(CFG.Songs[songkey]);
                                        // Play Song as Next Song
                                      }
                                      if (result == 2) {
                                        Playlist.AddToPlaylist(
                                            CFG.Songs[songkey]);
                                        // Add Song to End of Playlist
                                      }
                                      if (result == 3) {
                                        Playlist.PlayAfterLastAdded(
                                            CFG.Songs[songkey]);
                                        // Add Song to End of Added Songs
                                      }
                                      CFG.SaveConfig();
                                    },
                                    child: ListTile(
                                      title: Text(CFG.Songs[songkey].title),
                                      subtitle:
                                          Text(CFG.Songs[songkey].interpret),
                                    ),
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry>[
                                      const PopupMenuItem(
                                          child: Text('Edit Tags'), value: 0),
                                      const PopupMenuDivider(),
                                      const PopupMenuItem(
                                          child: Text('Play Next'), value: 1),
                                      const PopupMenuItem(
                                          child: Text('Add to Playlist'),
                                          value: 2),
                                      const PopupMenuItem(
                                          child: Text('Add to Play Next Stack'),
                                          value: 3),
                                    ],
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              c(() {}),
            },
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              PopupMenuButton(
                onSelected: (result) {
                  if (result == 0) {
                    // Change Name
                    SInput.StringInput(
                      context,
                      "Rename Tag",
                      "Save",
                      "Cancel",
                      (String s) {
                        CFG.UpdateTagName(CFG.Tags[key].id, s);
                        c(() {});
                      },
                      (String s) {},
                      false,
                      CFG.Tags[key].name,
                    );
                  }
                  if (result == 1) {
                    CFG.GetSongsFromTag(CFG.Tags[key]).forEach((key, value) {
                      Playlist.AddToPlaylist(value);
                    });
                  }
                  if (result == 2) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MaterialApp(
                          theme: ThemeData.dark(),
                          home: SearchPage.SearchPage(
                            (search, update) => Container(
                              child: ListView(
                                children: [
                                  for (String songkey in CFG.Songs.keys)
                                    if ((CFG.Songs[songkey].title
                                                .toLowerCase()
                                                .contains(
                                                    search.toLowerCase()) ||
                                            CFG.Songs[songkey].interpret
                                                .toLowerCase()
                                                .contains(
                                                    search.toLowerCase())) &
                                        !CFG.Songs[songkey].tags.contains(key))
                                      Dismissible(
                                        key: Key(
                                            songkey + CFG.Songs[songkey].hash),
                                        onDismissed:
                                            (DismissDirection direction) {
                                          update(() {
                                            CFG.UpdateSongTags(
                                                songkey, key, true);
                                          });
                                        },
                                        background: Container(
                                          color: Colors.green,
                                          child: Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: Row(
                                              children: [
                                                Icon(Icons.add,
                                                    color: Colors.white),
                                                Text('Add To Tag',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        secondaryBackground: Container(
                                          color: Colors.green,
                                          child: Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Icon(Icons.add,
                                                    color: Colors.white),
                                                Text('Add To Tag',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        child: PopupMenuButton(
                                          onSelected: (result) {
                                            if (result == 0) {
                                              showModalBottomSheet<void>(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            2,
                                                    color: CFG.HomeColor,
                                                    child: Center(
                                                      child: Column(
                                                        children: <Widget>[
                                                          for (CFG.Tag t in CFG
                                                              .Tags.values)
                                                            C.CoolerCheckBox(
                                                                CFG
                                                                    .Songs[
                                                                        songkey]
                                                                    .tags
                                                                    .contains(
                                                                        t.id),
                                                                (bool? b) {
                                                              CFG.UpdateSongTags(
                                                                  CFG
                                                                      .Songs[
                                                                          songkey]
                                                                      .filename,
                                                                  t.id,
                                                                  b);
                                                            }, t.name),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                            if (result == 1) {
                                              Playlist.PlayNext(
                                                  CFG.Songs[songkey]);
                                              // Play Song as Next Song
                                            }
                                            if (result == 2) {
                                              Playlist.AddToPlaylist(
                                                  CFG.Songs[songkey]);
                                              // Add Song to End of Playlist
                                            }
                                            if (result == 3) {
                                              Playlist.PlayAfterLastAdded(
                                                  CFG.Songs[songkey]);
                                              // Add Song to End of Added Songs
                                            }
                                            CFG.SaveConfig();
                                          },
                                          child: ListTile(
                                            title:
                                                Text(CFG.Songs[songkey].title),
                                            subtitle: Text(
                                                CFG.Songs[songkey].interpret),
                                          ),
                                          itemBuilder: (BuildContext context) =>
                                              <PopupMenuEntry>[
                                            const PopupMenuItem(
                                                child: Text('Edit Tags'),
                                                value: 0),
                                            const PopupMenuDivider(),
                                            const PopupMenuItem(
                                                child: Text('Play Next'),
                                                value: 1),
                                            const PopupMenuItem(
                                                child: Text('Add to Playlist'),
                                                value: 2),
                                            const PopupMenuItem(
                                                child: Text(
                                                    'Add to Play Next Stack'),
                                                value: 3),
                                          ],
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  if (result == 3) {
                    // Delete
                    CFG.DeleteTag(CFG.Tags[key]);
                    c(() {});
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                  PopupMenuItem(child: Text(CFG.Tags[key].name), value: 0),
                  PopupMenuDivider(),
                  const PopupMenuItem(
                      child: Text('Add Songs to Playlist'), value: 1),
                  PopupMenuDivider(),
                  const PopupMenuItem(
                      child: Text('Search all Songs'), value: 2),
                  PopupMenuDivider(),
                  const PopupMenuItem(child: Text('Delete Tag'), value: 3),
                ],
              ),
            ]),
            title: Text(CFG.Tags[key].name),
            subtitle: Text(CFG.Tags[key].used.toString()),
          ),
        Align(
          alignment: AlignmentDirectional.bottomCenter,
          child: ElevatedButton(
            style: ButtonStyle(
              enableFeedback: true,
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                return Color(CFG.Config["ContrastColor"]);
              }),
            ),
            onPressed: () {
              SInput.StringInput(
                context,
                "Create new Tag",
                "Create",
                "Cancel",
                (String s) {
                  CFG.CreateTag(s);
                  c(() {});
                },
                (String s) {},
                false,
                "",
              );
            },
            child: const Text("Create new Tag"),
          ),
        )
      ],
    ),
  );
}
