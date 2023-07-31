import 'package:flutter/material.dart';

import "../classes/playlist.dart";
import "../classes/song.dart";
import "../classes/tag.dart";
import 'components/search.dart';
import 'components/songtile.dart';
import 'components/string_input.dart';
import 'components/tagedit.dart';

bool ShouldShowTag(int key, String search) {
  if (search == "") return true;

  if (Tags[key].name.toLowerCase().contains(search.toLowerCase())) return true;

  //List<String> searchname = search.toLowerCase().split(" ");

  //for (String s2 in searchname) {
  //if (Tags[key].name.contains(s2)) return true;
  //}

  return false;
}

IconButton buildActions(
    BuildContext context, void Function(void Function()) c, MyAudioHandler Playlist) {
  return IconButton(
    onPressed: () => Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => SearchPage(
                (search, update) => ListView(
                      children: [
                        for (int key in Tags.keys)
                          if (ShouldShowTag(key, search))
                            Dismissible(
                              key: Key(key.toString()),
                              onDismissed: (direction) {
                                DeleteTag(Tags[key]);
                                update(() {});
                              },
                              background: Container(
                                color: Colors.red,
                                child: const Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.white),
                                      Text('Move to trash', style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                              secondaryBackground: Container(
                                color: Colors.red,
                                child: const Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(Icons.delete, color: Colors.white),
                                      Text('Move to trash', style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                              child: TagTile(update, context, Playlist, key),
                            ),
                      ],
                    ),
                ""),
          ),
        )
        .then((value) => c(() {})),
    icon: const Icon(Icons.search),
  );
}

ListView buildContent(
    BuildContext context, void Function(void Function()) c, MyAudioHandler Playlist, int reverse) {
  UpdateAllTags();
  List sortedtags = Tags.values.toList();
  sortedtags.sort((a, b) {
    return a.used.compareTo(b.used);
  });
  if (reverse == 0) {
    // sorted by used, highest first
    sortedtags = sortedtags.reversed.toList();

    // reversed = 1 sorted by used, lowest first
  } else if (reverse == 2) {
    // sorted by name, a-z
    sortedtags.sort((a, b) {
      return a.name.compareTo(b.name);
    });
  } else if (reverse == 3) {
    // sorted by name, z-a
    sortedtags.sort((a, b) {
      return a.name.compareTo(b.name);
    });
    sortedtags = sortedtags.reversed.toList();
  }
  return ListView(
    children: [
      for (Tag t in sortedtags) TagTile(c, context, Playlist, t.id),
    ],
  );
}

ListTile TagTile(
    void Function(void Function()) c, BuildContext context, MyAudioHandler Playlist, int key) {
  return ListTile(
    onLongPress: () => {
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (_) => SearchPage(
                  (search, update) => ListView(
                        children: [
                          for (String songkey in GetSongsFromTag(Tags[key]).keys)
                            if (Songs[songkey].title.toLowerCase().contains(search.toLowerCase()) ||
                                Songs[songkey]
                                    .interpret
                                    .toLowerCase()
                                    .contains(search.toLowerCase()))
                              Dismissible(
                                key: Key(songkey),
                                onDismissed: (DismissDirection direction) {
                                  if (direction == DismissDirection.startToEnd) {
                                    UpdateSongTags(songkey, key, false);
                                  }
                                  update(() {});
                                },
                                confirmDismiss: (DismissDirection direction) async {
                                  if (direction == DismissDirection.endToStart) {
                                    Playlist.Stack(Songs[songkey]);
                                    update(() {});
                                    return Future.value(false);
                                  }
                                  return Future.value(true);
                                },
                                background: Container(
                                  color: Colors.red,
                                  child: const Padding(
                                    padding: EdgeInsets.all(15),
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.white),
                                        Text('Remove from Tag',
                                            style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                                secondaryBackground: Container(
                                  color: Colors.green,
                                  child: const Padding(
                                    padding: EdgeInsets.all(15),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(Icons.add, color: Colors.white),
                                        Text('Add To Stack', style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                                child: SongTile(context, Songs[songkey], update, Playlist, true, {
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
                                  10: false,
                                  11: false,
                                }),
                              ),
                        ],
                      ),
                  ""),
            ),
          )
          .then((value) => c(() {})),
      c(() {}),
    },
    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
      PopupMenuButton(
        onSelected: (result) {
          if (result == 0) {
            // Change Name
            StringInput(context, "Rename Tag: $key", "Save", "Cancel", (String s) {
              UpdateTagName(Tags[key].id, s);
              c(() {});
            }, (String s) {}, false, Tags[key].name, "");
          }
          if (result == 1) {
            Playlist.BulkAdd(GetSongsFromTag(Tags[key]));
          }
          if (result == 2) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const TagChoose()))
                .then((value) {
              if (value != -1) {
                GetSongsFromTag(Tags[key]).forEach((songkey, song) {
                  UpdateSongTags(songkey, value, true);
                });
              }
            }).then((value) => c(() {}));
          }
          if (result == 3) {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (_) => SearchPage(
                        (search, update) => ListView(
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
                                      key: Key(songkey),
                                      onDismissed: (DismissDirection direction) {
                                        UpdateSongTags(songkey, key, true);
                                        update(() {});
                                      },
                                      background: Container(
                                        color: Colors.green,
                                        child: const Padding(
                                          padding: EdgeInsets.all(15),
                                          child: Row(
                                            children: [
                                              Icon(Icons.add, color: Colors.white),
                                              Text('Add To Tag',
                                                  style: TextStyle(color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      secondaryBackground: Container(
                                        color: Colors.green,
                                        child: const Padding(
                                          padding: EdgeInsets.all(15),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Icon(Icons.add, color: Colors.white),
                                              Text('Add To Tag',
                                                  style: TextStyle(color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      child: SongTile(context, Songs[songkey], c, Playlist, true, {
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
                                        10: false,
                                        11: false,
                                      }),
                                    ),
                              ],
                            ),
                        Tags[key].name),
                  ),
                )
                .then((value) => c(() {}));
          }
          if (result == 4) {
            // Delete
            DeleteTag(Tags[key]);
            c(() {});
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
          PopupMenuItem(value: 0, child: Text(Tags[key].name)),
          const PopupMenuDivider(),
          const PopupMenuItem(value: 1, child: Text('Add Songs to Playlist')),
          const PopupMenuDivider(),
          const PopupMenuItem(value: 2, child: Text('Add Songs to other Tag')),
          const PopupMenuDivider(),
          const PopupMenuItem(value: 3, child: Text('Search all Songs')),
          const PopupMenuDivider(),
          const PopupMenuItem(value: 4, child: Text('Delete Tag')),
        ],
      ),
    ]),
    title: Text(Tags[key].name),
    subtitle: Text(Tags[key].used.toString()),
  );
}
