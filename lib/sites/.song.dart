import 'package:flutter/material.dart';
import "../settings.dart" as CFG;
import 'components/search.dart' as SearchPage;
import 'components/string_input.dart' as SInput;

class SongPage extends StatelessWidget {
  SongPage({
    Key? key,
    required this.c,
    required this.songs,
  });

  final Map songs;
  final void Function() c;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            actions: [
              // Navigate to the Search Screen
              IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => SearchPage.SearchPage(songs))),
                  icon: const Icon(Icons.search))
            ],
            backgroundColor: CFG.HomeColor,
          ),
          body: Container(
            child: ListView(
              children: [
                for (CFG.Song song in songs.values) SongInfo(s: song, c: c),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SongInfo extends ListTile {
  const SongInfo({
    Key? key,
    required this.c,
    required this.s,
  }) : super(key: key);

  final CFG.Song s;
  final void Function() c;
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (result) {
        if (result == 0) {
          // Change Title
          SInput.StringInput(
            context,
            "New Song Title",
            "Save",
            "Cancel",
            (String si) {
              CFG.UpdateSongTitle(s.filename, si);
              c();
            },
            (String si) {},
            true,
            s.title,
          );
        }
        if (result == 1) {
          // Change Interpret
          SInput.StringInput(
            context,
            "New Song Interpret",
            "Save",
            "Cancel",
            (String si) {
              CFG.UpdateSongInterpret(s.filename, si);
              c();
            },
            (String si) {},
            true,
            s.interpret,
          );
        }
        if (result == 2) {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: MediaQuery.of(context).size.height / 2,
                color: CFG.HomeColor,
                child: Center(
                  child: Column(
                    children: <Widget>[
                      for (CFG.Tag t in CFG.Tags.values)
                        CoolerCheckBox(s.tags.contains(t.id), (bool? b) {
                          CFG.UpdateSongTags(s.filename, t.id, b);
                        }, t.name),
                    ],
                  ),
                ),
              );
            },
          );
        }
        if (result == 3) {
          CFG.DeleteSong(s);
          c();
        }
        if (result == 4) {
          CFG.CurrList.PlayNext(s);
          // Play Song as Next Song
        }
        if (result == 5) {
          CFG.CurrList.AddToPlaylist(s);
          // Add Song to End of Playlist
        }
        if (result == 6) {
          CFG.CurrList.PlayAfterLastAdded(s);
          // Add Song to End of Added Songs
        }
      },
      child: ListTile(
        title: Text(s.title),
        subtitle: Text(s.interpret),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        PopupMenuItem(
          child: Text(s.title),
          value: 0,
        ),
        PopupMenuItem(
          child: Text(s.interpret),
          value: 1,
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(child: Text('Edit Tags'), value: 2),
        const PopupMenuItem(child: Text('Delete Song'), value: 3),
        const PopupMenuDivider(),
        const PopupMenuItem(child: Text('Play Next'), value: 4),
        const PopupMenuItem(child: Text('Add to Playlist'), value: 5),
        const PopupMenuItem(child: Text('Add to Play Next Stack'), value: 6),
      ],
    );
  }
}

class TagTile extends ListTile {
  const TagTile({
    Key? key,
    required this.c,
    required this.t,
  }) : super(key: key);

  final CFG.Tag t;
  final void Function() c;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onLongPress: () => {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SongPage(songs: CFG.GetSongsFromTag(t), c: c),
          ),
        ),
        c(),
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
                  CFG.UpdateTagName(t.id, s);
                  c();
                },
                (String s) {},
                false,
                t.name,
              );
            }
            if (result == 1) {
              CFG.GetSongsFromTag(t).forEach((key, value) {
                CFG.CurrList.AddToPlaylist(value);
              });
            }
            if (result == 2) {
              // Delete
              CFG.DeleteTag(t);
              c();
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
            PopupMenuItem(child: Text(t.name), value: 0),
            const PopupMenuItem(child: Text('Add Songs to Playlist'), value: 1),
            const PopupMenuItem(child: Text('Delete Tag'), value: 2),
          ],
        ),
      ]),
      title: Text(t.name),
      subtitle: Text(t.used.toString()),
    );
  }
}
