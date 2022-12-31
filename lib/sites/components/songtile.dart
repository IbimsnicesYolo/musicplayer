import 'string_input.dart';
import 'tagedit.dart';
import 'package:flutter/material.dart';
import "../../classes/song.dart";
import "../../classes/playlist.dart";

PopupMenuButton SongTile(
    BuildContext context,
    Song s,
    void Function(void Function()) c,
    CurrentPlayList Playlist,
    bool showchild) {
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
        Playlist.InsertAfterLastAdded(s);
        // Add Song to End of Added Songs
      }
      if (result == 8) {
        s.blacklisted = !s.blacklisted;
        ShouldSaveSongs = true;
        SaveSongs();
      }
      Playlist.Save();
    },
    child: (showchild)
        ? ListTile(
            title: Text(s.title),
            subtitle: Text(s.interpret + " | " + s.featuring),
          )
        : null,
    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
      PopupMenuItem(
        child: Text(s.title),
        value: 0,
      ),
      PopupMenuItem(
        child: Text(s.interpret),
        value: 1,
      ),
      PopupMenuItem(
        child: Text(s.featuring),
        value: 2,
      ),
      const PopupMenuDivider(),
      const PopupMenuItem(child: Text('Edit Tags'), value: 3),
      const PopupMenuItem(child: Text('Delete Song'), value: 4),
      const PopupMenuDivider(),
      const PopupMenuItem(child: Text('Play Next'), value: 5),
      const PopupMenuItem(child: Text('Add to Playlist'), value: 6),
      const PopupMenuItem(child: Text('Add to Play Next Stack'), value: 7),
      const PopupMenuDivider(),
      PopupMenuItem(
          child: Text(s.blacklisted ? 'Un Blacklist Song' : "Blacklist Song"),
          value: 8),
    ],
  );
}

PopupMenuButton TagSongTile(
    BuildContext context, CurrentPlayList Playlist, String songkey, int key) {
  return PopupMenuButton(
    onSelected: (result) {
      if (result == 0) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TagEdit(Songs[songkey])),
        );
      }
      if (result == 1) {
        Playlist.InsertAsNext(Songs[songkey]);
// Play Song as Next Song
      }
      if (result == 2) {
        Playlist.AddToPlaylist(Songs[songkey]);
// Add Song to End of Playlist
      }
      if (result == 3) {
        Playlist.InsertAfterLastAdded(Songs[songkey]);
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

Dismissible DismissibleSongTile(BuildContext context, Song s,
    void Function(void Function()) c, CurrentPlayList Playlist) {
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
        Playlist.InsertAfterLastAdded(s);
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
            Text('Play Next', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    ),
    child: ListTile(
      title: Text(s.title),
      subtitle: Text(s.interpret),
      onLongPress: () => {
        Playlist.InsertAsNext(s),
        Playlist.PlayNextSong(),
      },
      trailing: SongTile(context, s, c, Playlist, false),
    ),
  );
}
