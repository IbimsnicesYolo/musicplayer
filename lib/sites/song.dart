import 'package:flutter/material.dart';
import "../settings.dart" as CFG;
import "string_input.dart" as SInput;

class SongPage extends ListView {
  SongPage({
    Key? key,
    required this.songs,
  });

  final Map songs;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (CFG.Song song in songs.values) SongInfo(s: song),
      ],
    );
  }
}

class SongInfo extends ListTile {
  const SongInfo({
    Key? key,
    required this.s,
  }) : super(key: key);

  final CFG.Song s;

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
              CFG.UpdateSongTitle(s, si);
            },
            (String si) {},
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
              CFG.UpdateSongInterpret(s, si);
            },
            (String si) {},
            s.interpret,
          );
        }
        if (result == 2) {
          CFG.ShowSth("Not Programmed", context);
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: 200,
                color: Colors.lightBlue,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text('Modal BottomSheet'),
                      ElevatedButton(
                        child: const Align(
                            alignment: AlignmentDirectional.bottomCenter,
                            child: Text('Close BottomSheet')),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        if (result == 3) {
          CFG.DeleteSong(s);
        }
        if (result == 4) {
          CFG.ShowSth("Not Programmed", context);
          // Play as next Song
        }
        if (result == 5) {
          CFG.ShowSth("Not Programmed", context);
          // Add Song to End of Playlist
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
      ],
    );
  }
}

class TagTile extends ListTile {
  const TagTile({
    Key? key,
    required this.t,
  }) : super(key: key);

  final CFG.Tag t;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onLongPress: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => SongPage(songs: CFG.UnsortedSongs))),
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
                },
                (String s) {},
                t.name,
              );
            }
            if (result == 1) {
              // Delete
              CFG.DeleteTag(context, t);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
            PopupMenuItem(
              child: Text(t.name),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(child: Text('Edit Name'), value: 0),
            const PopupMenuItem(child: Text('Delete Tag'), value: 1),
          ],
        ),
      ]),
      title: Text(t.name),
      subtitle: Text(t.used.toString()),
    );
  }
}
