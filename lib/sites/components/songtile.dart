import 'package:flutter/material.dart';

import "../../classes/playlist.dart";
import "../../classes/song.dart";
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
                      UpdateSongTitle(s.filename, si);
                    }),
              ),
            )
            .then((value) => {s.title = value, UpdateSongTitle(s.filename, value), c(() {})});
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
                      UpdateSongInterpret(s.filename, si);
                    }),
              ),
            )
            .then(
                (value) => {s.interpret = value, UpdateSongInterpret(s.filename, value), c(() {})});
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
                      UpdateSongFeaturing(s.filename, si);
                    }),
              ),
            )
            .then(
                (value) => {s.featuring = value, UpdateSongFeaturing(s.filename, value), c(() {})});
      }
      if (result == 3) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TagEdit(s)),
        );
      }
      if (result == 4) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Delete " + s.title + "?"),
            content: Text("Are you sure you want to delete this song?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("No"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  Playlist.RemoveSong(s);
                  DeleteSong(s);
                },
                child: Text("Yes"),
              ),
            ],
          ),
        );
      }
      if (result == 5) {
        Playlist.RemoveSong(s);
        Playlist.InsertAsNext(s);
        // Play Song as Next Song
      }
      if (result == 6) {
        Playlist.RemoveSong(s);
        Playlist.AddToPlaylist(s);
        // Add Song to End of Playlist
      }
      if (result == 7) {
        Playlist.RemoveSong(s);
        Playlist.Stack(s);
        // Add Song to End of Added Songs
      }
      if (result == 8) {
        s.blacklisted = !s.blacklisted;
        ShouldSaveSongs = true;
        SaveSongs();
      }
      if (result == 9) {
        Playlist.JumpToSong(s);
      }
      if (result == 10) {
        Playlist.RemoveSong(s);
        Playlist.AddToPlaylist(s);
      }
      c(() {});
    },
    child: (showchild)
        ? ListTile(
            title: Text(s.title),
            subtitle: Text(s.interpret + " | " + s.featuring),
          )
        : null,
    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
      if (activated[0] == true)
        PopupMenuItem(
          child: Text(s.title),
          value: 0,
        ),
      if (activated[1] == true)
        PopupMenuItem(
          child: Text(s.interpret),
          value: 1,
        ),
      if (activated[2] == true)
        PopupMenuItem(
          child: Text(s.featuring),
          value: 2,
        ),
      const PopupMenuDivider(),
      if (activated[3] == true) PopupMenuItem(child: Text('Edit Tags'), value: 3),
      if (activated[4] == true) PopupMenuItem(child: Text('Delete Song'), value: 4),
      const PopupMenuDivider(),
      if (activated[5] == true) PopupMenuItem(child: Text('Play Next'), value: 5),
      if (activated[6] == true) PopupMenuItem(child: Text('Add to Playlist'), value: 6),
      if (activated[7] == true) PopupMenuItem(child: Text('Add to Stack'), value: 7),
      if (activated[8] == true)
        PopupMenuItem(
            child: Text(s.blacklisted ? 'Un Blacklist Song' : "Blacklist Song"), value: 8),
      if (activated[9] == true) PopupMenuItem(child: Text("Jump To"), value: 9),
      if (activated[10] == true) PopupMenuItem(child: Text("Move to End"), value: 10),
    ],
  );
}

Dismissible DismissibleSongTile(
    BuildContext context, Song s, void Function(void Function()) c, MyAudioHandler Playlist) {
  int i =
      -1; // Playlist.songs.indexOf(s); doesnt work because of the updated hash so it doesnt find the objects
  for (int j = 0; j < Playlist.songs.length; j++) {
    if (Playlist.songs[j].filename == s.filename) {
      i = j;
      break;
    }
  }
  if (i < 0 || i >= Playlist.songs.length) {
    return Dismissible(
      key: Key(s.filename + "weird"),
      child: ListTile(
        title: Text("ERROR: " + s.title),
        trailing: Icon(Icons.drag_handle),
        onTap: () {},
      ),
    );
  }
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
      child: Padding(
        padding: const EdgeInsets.all(15),
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
      child: Padding(
        padding: const EdgeInsets.all(15),
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
          child: Container(
            child: Text(
              s.title,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
        childWhenDragging: PopupMenuButton(
          onSelected: (result) {},
          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
            PopupMenuItem(
              child: Text(''),
              value: 0,
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
