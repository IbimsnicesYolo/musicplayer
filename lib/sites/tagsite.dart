import "../classes/tag.dart";
import "../classes/playlist.dart";
import "../classes/song.dart";
import "../settings.dart";
import 'package:flutter/material.dart';
import 'components/search.dart';
import 'components/string_input.dart';
import 'components/checkbox.dart';

bool ShouldShowTag(int key, String search) {
  if (search == "") return true;

  if (Tags[key].name.toLowerCase().contains(search.toLowerCase())) return true;

  List<String> name = Tags[key].name.toLowerCase().split(" ");
  List<String> searchname = search.toLowerCase().split(" ");

  for (String s in name) {
    for (String s2 in searchname) {
      if (s.contains(s2)) return true;
    }
  }

  return false;
}

IconButton buildActions(BuildContext context, void Function(void Function()) c,
    CurrentPlayList Playlist) {
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
                      child: TagTile(c, context, Playlist, key),
                    ),
              ],
            ),
          ),
        ),
      ),
    ),
    icon: const Icon(Icons.search),
  );
}

Container buildContent(BuildContext context, void Function(void Function()) c,
    CurrentPlayList Playlist) {
  UpdateAllTags();
  return Container(
    child: ListView(
      children: [
        for (int key in Tags.keys) TagTile(c, context, Playlist, key),
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
              StringInput(
                context,
                "Create new Tag",
                "Create",
                "Cancel",
                (String s) {
                  CreateTag(s);
                  SaveTags();
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

ListTile TagTile(void Function(void Function()) c, BuildContext context,
    CurrentPlayList Playlist, int key) {
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
                            if (direction == DismissDirection.endToStart) {
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
                                    style: TextStyle(color: Colors.white)),
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
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                        child: SongTile(context, Playlist, songkey, key),
                      ),
                ],
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
            StringInput(
              context,
              "Rename Tag",
              "Save",
              "Cancel",
              (String s) {
                UpdateTagName(Tags[key].id, s);
                c(() {});
              },
              (String s) {},
              false,
              Tags[key].name,
            );
          }
          if (result == 1) {
            GetSongsFromTag(Tags[key]).forEach((key, value) {
              Playlist.AddToPlaylist(value);
            });
            Playlist.Save();
          }
          if (result == 2) {
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
                                      Icon(Icons.add, color: Colors.white),
                                      Text('Add To Tag',
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
                                      Text('Add To Tag',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                              child: SongTile(context, Playlist, songkey, key),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          if (result == 3) {
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
          const PopupMenuItem(child: Text('Search all Songs'), value: 2),
          PopupMenuDivider(),
          const PopupMenuItem(child: Text('Delete Tag'), value: 3),
        ],
      ),
    ]),
    title: Text(Tags[key].name),
    subtitle: Text(Tags[key].used.toString()),
  );
}

PopupMenuButton SongTile(
    BuildContext context, CurrentPlayList Playlist, String songkey, int key) {
  return PopupMenuButton(
    onSelected: (result) {
      if (result == 0) {
        Map<String, List> ToUpdate = {};
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MaterialApp(
              theme: ThemeData.dark(),
              home: AlertDialog(
                actions: <Widget>[
                  for (Tag t in Tags.values)
                    CoolerCheckBox(Songs[songkey].tags.contains(t.id),
                        (bool? b) {
                      ToUpdate[Songs[songkey].filename] = [t.id, b];
                    }, t.name),
                  Center(
                    child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ToUpdate.forEach((key, value) {
                            UpdateSongTags(key, value[0], value[1]);
                          });
                        },
                        child: Text("Close")),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      if (result == 1) {
        Playlist.PlayNext(Songs[songkey]);
// Play Song as Next Song
      }
      if (result == 2) {
        Playlist.AddToPlaylist(Songs[songkey]);
// Add Song to End of Playlist
      }
      if (result == 3) {
        Playlist.PlayAfterLastAdded(Songs[songkey]);
// Add Song to End of Added Songs
      }
      Playlist.Save();
    },
    child: ListTile(
      title: Text(Songs[songkey].title),
      subtitle: Text(Songs[songkey].interpret),
    ),
    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
      const PopupMenuItem(child: Text('Edit Tags'), value: 0),
      const PopupMenuDivider(),
      const PopupMenuItem(child: Text('Play Next'), value: 1),
      const PopupMenuItem(child: Text('Add to Playlist'), value: 2),
      const PopupMenuItem(child: Text('Add to Play Next Stack'), value: 3),
    ],
  );
}
