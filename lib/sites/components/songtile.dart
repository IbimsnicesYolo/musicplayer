import 'package:flutter/material.dart';

import '../../settings.dart';
import 'string_input.dart';
import 'tagedit.dart';

PopupMenuButton SongTile(BuildContext context, Song s, void Function(void Function()) c,
    MyAudioHandler Playlist, bool showchild, Map<int, bool> activated) {
  return PopupMenuButton(
    onSelected: (result) {
      if (result == 0) {
        // Change Title
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (_) => StringInputExpanded(
                    Title: "Song Title Edit",
                    Text: s.title,
                    additionalinfos: s.filename,
                    OnSaved: (String si) {
                      s.title = si;
                      UpdateSongTitle(s.id, si);
                    }),
              ),
            )
            .then((value) => {s.title = value, UpdateSongTitle(s.id, value), c(() {})});
      }
      if (result == 1) {
        // Change Interpret
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (_) => StringInputExpanded(
                    Title: "Song Artist Edit",
                    Text: s.interpret,
                    additionalinfos: s.filename,
                    OnSaved: (String si) {
                      s.interpret = si;
                      UpdateSongInterpret(s.id, si);
                    }),
              ),
            )
            .then((value) => {s.interpret = value, UpdateSongInterpret(s.id, value), c(() {})});
      }
      if (result == 2) {
        // Change Featuring
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (_) => StringInputExpanded(
                    Title: "Song Featuring Edit",
                    Text: s.featuring,
                    additionalinfos: s.filename,
                    OnSaved: (String si) {
                      s.featuring = si;
                      UpdateSongFeaturing(s.id, si);
                    }),
              ),
            )
            .then((value) => {s.featuring = value, UpdateSongFeaturing(s.id, value), c(() {})});
      }
      if (result == 3) {
        Navigator.of(context)
            .push(
              MaterialPageRoute(builder: (_) => TagEdit(s)),
            )
            .then((value) => c(() {}));
      }
      if (result == 4) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Delete ${s.title}?"),
            content: const Text("Are you sure you want to delete this song?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(true);
                  Playlist.RemoveSong(s);
                  await DeleteSong(s.id);
                },
                child: const Text("Yes"),
              ),
            ],
          ),
        );
      }
      if (result == 5) {
        Playlist.InsertAsNext(s);
        // Play Song as Next Song
      }
      if (result == 6) {
        Playlist.AddToPlaylist(s);
        // Add Song to End of Playlist
      }
      if (result == 7) {
        Playlist.Stack(s);
        // Add Song to End of Added Songs
      }
      if (result == 8) {
        s.blacklisted = !s.blacklisted;
        UpdateSongBlacklisted(s.id, s.blacklisted);
      }
      if (result == 9) {
        Playlist.JumpToSong(s);
      }
      if (result == 10) {
        Playlist.RemoveSong(s);
        Playlist.AddToPlaylist(s);
      }
      if (result == 11) {
        Playlist.RemoveSong(Playlist.songs[0]);
        Playlist.JumpToSong(s);
      }
      c(() {});
    },
    child: (showchild)
        ? ListTile(
            title: Text(s.title),
            subtitle: Text("${s.interpret} | ${s.featuring}"),
          )
        : null,
    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
      if (activated[0] == true)
        PopupMenuItem(
          value: 0,
          child: Text(s.title),
        ),
      if (activated[1] == true)
        PopupMenuItem(
          value: 1,
          child: Text(s.interpret),
        ),
      if (activated[2] == true)
        PopupMenuItem(
          value: 2,
          child: Text(s.featuring),
        ),
      const PopupMenuDivider(),
      if (activated[3] == true) const PopupMenuItem(value: 3, child: Text('Edit Tags')),
      if (activated[4] == true) const PopupMenuItem(value: 4, child: Text('Delete Song')),
      const PopupMenuDivider(),
      if (activated[5] == true) const PopupMenuItem(value: 5, child: Text('Play Next')),
      if (activated[6] == true) const PopupMenuItem(value: 6, child: Text('Add to Playlist')),
      if (activated[7] == true) const PopupMenuItem(value: 7, child: Text('Add to Stack')),
      if (activated[8] == true)
        PopupMenuItem(
            value: 8, child: Text(s.blacklisted ? 'Un Blacklist Song' : "Blacklist Song")),
      if (activated[9] == true) const PopupMenuItem(value: 9, child: Text("Jump To")),
      if (activated[10] == true) const PopupMenuItem(value: 10, child: Text("Move to End")),
      if (activated[11] == true)
        const PopupMenuItem(value: 11, child: Text("Play and Delete current")),
    ],
  );
}

Dismissible DismissibleSongTile(
    BuildContext context, Song s, void Function(void Function()) c, MyAudioHandler Playlist) {
  int i = Playlist.songs.indexOf(s);

  return Dismissible(
    key: Key(s.filename),
    onDismissed: (DismissDirection direction) {
      if (direction == DismissDirection.startToEnd) {
        // Dismissed to the right
        // background
        Playlist.RemoveSong(s);
      }
      c(() {});
    },
    confirmDismiss: (dir) {
      if (dir == DismissDirection.endToStart) {
        Playlist.Stack(s);
        c(() {});
      }
      return Future.value(true);
    },
    background: Container(
      color: Colors.red,
      child: const Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          children: [
            Icon(Icons.add, color: Colors.white),
            Text('Remove from Playlist', style: TextStyle(color: Colors.white)),
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
            Text('Stack', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    ),
    child: ListTile(
      title: Text(s.title),
      subtitle: Text(s.interpret),
      onLongPress: () => {
        Playlist.JumpToSong(s),
        c(() {}),
      },
      trailing: Draggable<int>(
        // Data is the value this Draggable stores.
        data: i,
        feedback: Material(
          child: Text(
            s.title,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        childWhenDragging: PopupMenuButton(
          onSelected: (result) {},
          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
            const PopupMenuItem(
              value: 0,
              child: Text(''),
            ),
          ],
        ),
        child: DragTarget<int>(
          builder: (
            BuildContext context,
            List<dynamic> accepted,
            List<dynamic> rejected,
          ) {
            return SongTile(context, s, c, Playlist, false, {
              0: true,
              1: false,
              2: false,
              3: true,
              4: false,
              5: true,
              6: false,
              7: true,
              8: false,
              9: true,
              10: true,
              11: true,
            });
          },
          onAccept: (int data) {
            if (data == i) return;
            if (i == 0 || data == 0) return;
            Playlist.DragNDropUpdate(data, i);
            c(() {});
          },
        ),
      ),
    ),
  );
}
