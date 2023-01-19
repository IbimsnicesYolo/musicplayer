import 'string_input.dart';
import 'tagedit.dart';
import 'package:flutter/material.dart';
import "../../classes/song.dart";
import "../../classes/playlist.dart";

PopupMenuButton SongTile(
    BuildContext context,
    Song s,
    void Function(void Function()) c,
    MyAudioHandler Playlist,
    bool showchild,
    Map<int, bool> activated) {
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
            .then((value) => {
                  s.title = value,
                  UpdateSongTitle(s.filename, value),
                  c(() {})
                });
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
            .then((value) => {
                  s.interpret = value,
                  UpdateSongInterpret(s.filename, value),
                  c(() {})
                });
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
            .then((value) => {
                  s.featuring = value,
                  UpdateSongFeaturing(s.filename, value),
                  c(() {})
                });
      }
      if (result == 3) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TagEdit(s)),
        );
      }
      if (result == 4) {
        DeleteSong(s);
        c(() {});
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
        c(() {});
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
      if (activated[3] == true)
        PopupMenuItem(child: Text('Edit Tags'), value: 3),
      if (activated[4] == true)
        PopupMenuItem(child: Text('Delete Song'), value: 4),
      const PopupMenuDivider(),
      if (activated[5] == true)
        PopupMenuItem(child: Text('Play Next'), value: 5),
      if (activated[6] == true)
        PopupMenuItem(child: Text('Add to Playlist'), value: 6),
      if (activated[7] == true)
        PopupMenuItem(child: Text('Add to Stack'), value: 7),
      if (activated[8] == true)
        PopupMenuItem(
            child: Text(s.blacklisted ? 'Un Blacklist Song' : "Blacklist Song"),
            value: 8),
      if (activated[9] == true) PopupMenuItem(child: Text("Jump To"), value: 9),
      if (activated[10] == true)
        PopupMenuItem(child: Text("Move to End"), value: 10),
    ],
  );
}

Dismissible DismissibleSongTile(BuildContext context, Song s,
    void Function(void Function()) c, MyAudioHandler Playlist) {
  int i = Playlist.songs.indexOf(s);
  return Dismissible(
    key: Key(s.filename + s.hash),
    onDismissed: (DismissDirection direction) {
      if (direction == DismissDirection.startToEnd) {
        // Dismissed to the left
        // background
        Playlist.RemoveSong(s);
      } else {
        // secondary background
        s.hash += "2";
        Playlist.Stack(s);
      }
      Playlist.Save();
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
            },
        trailing: Draggable<int>(
          // Data is the value this Draggable stores.
          data: i,
          feedback: Material(
            child: Container(
              child: Text(
                Playlist.songs[i].title,
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
            },
          ),
        )),
  );
}
