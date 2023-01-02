import "../classes/tag.dart";
import "../classes/playlist.dart";
import "../classes/song.dart";
import "../settings.dart";
import 'package:flutter/material.dart';
import 'components/search.dart';
import 'components/string_input.dart';
import 'components/songtile.dart';
import 'components/tagedit.dart';

bool ShouldShowTag(int key, String search) {
  if (search == "") return true;

  if (Tags[key].name.toLowerCase().contains(search.toLowerCase())) return true;

  List<String> searchname = search.toLowerCase().split(" ");

  for (String s2 in searchname) {
    if (Tags[key].name.contains(s2)) return true;
  }

  return false;
}

IconButton buildActions(BuildContext context, void Function(void Function()) c,
    MyAudioHandler Playlist) {
  return IconButton(
    onPressed: () => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchPage(
            (search, update) => Container(
                  child: ListView(
                    children: [
                      for (int key in Tags.keys)
                        if (ShouldShowTag(key, search))
                          Dismissible(
                            key: Key(key.toString()),
                            onDismissed: (direction) {
                              update(() {
                                DeleteTag(Tags[key]);
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
                            child: TagTile(update, context, Playlist, key),
                          ),
                    ],
                  ),
                ),
            ""),
      ),
    ),
    icon: const Icon(Icons.search),
  );
}

Container buildContent(BuildContext context, void Function(void Function()) c,
    MyAudioHandler Playlist) {
  UpdateAllTags();
  List sortedtags = Tags.values.toList();
  sortedtags.sort((a, b) {
    return a.used.compareTo(b.used);
  });
  sortedtags = sortedtags.reversed.toList();
  return Container(
    child: ListView(
      children: [
        for (Tag t in sortedtags) TagTile(c, context, Playlist, t.id),
        Align(
          alignment: AlignmentDirectional.bottomCenter,
          child: ElevatedButton(
            style: ButtonStyle(
              enableFeedback: true,
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                return Color(Config["ContrastColor"]);
              }),
            ),
            onPressed: () {
              StringInput(context, "Create new Tag", "Create", "Cancel",
                  (String s) {
                int id = CreateTag(s);
                SaveTags();
                c(() {});
              }, (String s) {}, false, "", "Tag Name");
            },
            child: const Text("Create new Tag"),
          ),
        )
      ],
    ),
  );
}

ListTile TagTile(void Function(void Function()) c, BuildContext context,
    MyAudioHandler Playlist, int key) {
  return ListTile(
    onLongPress: () => {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SearchPage(
              (search, update) => Container(
                    child: ListView(
                      children: [
                        for (String songkey in GetSongsFromTag(Tags[key]).keys)
                          if (Songs[songkey]
                                  .title
                                  .toLowerCase()
                                  .contains(search.toLowerCase()) ||
                              Songs[songkey]
                                  .interpret
                                  .toLowerCase()
                                  .contains(search.toLowerCase()))
                            Dismissible(
                              key: Key(songkey + Songs[songkey].hash),
                              onDismissed: (DismissDirection direction) {
                                update(() {
                                  if (direction ==
                                      DismissDirection.endToStart) {
                                    // Left
                                    Songs[songkey].hash += "1";
                                    Playlist.AddToPlaylist(Songs[songkey]);
                                    Playlist.Save();
                                  } else {
                                    // Right
                                    UpdateSongTags(songkey, key, false);
                                  }
                                });
                              },
                              background: Container(
                                color: Colors.red,
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.white),
                                      Text('Remove from Tag',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                              secondaryBackground: Container(
                                color: Colors.green,
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(Icons.add, color: Colors.white),
                                      Text('Add To Stack',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                              child: SongTile(context, Songs[songkey], update,
                                  Playlist, true, {
                                0: true,
                                1: false,
                                2: false,
                                3: true,
                                4: false,
                                5: true,
                                6: true,
                                7: true,
                                8: true,
                                9: false,
                              }),
                            ),
                      ],
                    ),
                  ),
              ""),
        ),
      ),
      c(() {}),
    },
    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
      PopupMenuButton(
        onSelected: (result) {
          if (result == 0) {
            // Change Name
            StringInput(
                context, "Rename Tag: " + key.toString(), "Save", "Cancel",
                (String s) {
              UpdateTagName(Tags[key].id, s);
              c(() {});
            }, (String s) {}, false, Tags[key].name, "");
          }
          if (result == 1) {
            GetSongsFromTag(Tags[key]).forEach((key, value) {
              Playlist.AddToPlaylist(value);
            });
            Playlist.Save();
          }
          if (result == 2) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => TagChoose()))
                .then((value) {
              if (value != -1) {
                GetSongsFromTag(Tags[key]).forEach((songkey, song) {
                  UpdateSongTags(songkey, value, true);
                });
              }
            });
          }
          if (result == 3) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SearchPage(
                    (search, update) => Container(
                          child: ListView(
                            children: [
                              for (String songkey in Songs.keys)
                                if ((Songs[songkey]
                                            .title
                                            .toLowerCase()
                                            .contains(search.toLowerCase()) ||
                                        Songs[songkey]
                                            .interpret
                                            .toLowerCase()
                                            .contains(search.toLowerCase())) &
                                    !Songs[songkey].tags.contains(key))
                                  Dismissible(
                                    key: Key(songkey + Songs[songkey].hash),
                                    onDismissed: (DismissDirection direction) {
                                      update(() {
                                        UpdateSongTags(songkey, key, true);
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
                                    child: SongTile(context, Songs[songkey], c,
                                        Playlist, true, {
                                      0: true,
                                      1: false,
                                      2: false,
                                      3: true,
                                      4: false,
                                      5: true,
                                      6: true,
                                      7: true,
                                      8: true,
                                      9: false,
                                    }),
                                  ),
                            ],
                          ),
                        ),
                    Tags[key].name),
              ),
            );
          }
          if (result == 4) {
            // Delete
            DeleteTag(Tags[key]);
            c(() {});
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
          PopupMenuItem(child: Text(Tags[key].name), value: 0),
          PopupMenuDivider(),
          const PopupMenuItem(child: Text('Add Songs to Playlist'), value: 1),
          PopupMenuDivider(),
          const PopupMenuItem(child: Text('Add Songs to other Tag'), value: 2),
          PopupMenuDivider(),
          const PopupMenuItem(child: Text('Search all Songs'), value: 3),
          PopupMenuDivider(),
          const PopupMenuItem(child: Text('Delete Tag'), value: 4),
        ],
      ),
    ]),
    title: Text(Tags[key].name),
    subtitle: Text(Tags[key].used.toString()),
  );
}
