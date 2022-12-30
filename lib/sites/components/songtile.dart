import 'string_input.dart';
import 'tagedit.dart';
import 'package:flutter/material.dart';
import "../../classes/song.dart";
import "../../classes/playlist.dart";

PopupMenuButton SongTile(BuildContext context, Song s,
    void Function(void Function()) c, CurrentPlayList Playlist) {
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
      Playlist.Save();
    },
    child: ListTile(
      title: Text(s.title),
      subtitle: Text(s.interpret + " | " + s.featuring),
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
    ],
  );
}
