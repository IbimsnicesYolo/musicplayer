import "../classes/song.dart";
import "../classes/playlist.dart";
import 'package:flutter/material.dart';
import 'components/search.dart';
import 'components/string_input.dart';
import 'components/tagedit.dart';

bool ShouldShowSong(String key, String search) {
  if (Songs[key].blacklisted) {
    return false;
  }
  if (search == "") return true;

  if (Songs[key].title.toLowerCase().contains(search.toLowerCase()))
    return true;

  if (Songs[key].interpret.toLowerCase().contains(search.toLowerCase()))
    return true;

  if (Songs[key].featuring != 0 &&
      Songs[key].featuring.toLowerCase().contains(search.toLowerCase()))
    return true;

  List<String> searchname = search.toLowerCase().split(" ");

  for (String s2 in searchname) {
    if (Songs[key].title.contains(s2) ||
        Songs[key].interpret.contains(s2) ||
        Songs[key].featuring.contains(s2)) return true;
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
                      for (String key in Songs.keys)
                        if (ShouldShowSong(key, search))
                          SongTile(context, Songs[key], c, Playlist),
                    ],
                  ),
                ),
            ""),
      ),
    ),
    icon: const Icon(Icons.search),
  );
}

ListView buildContent(BuildContext context, void Function(void Function()) c,
    CurrentPlayList Playlist) {
  return ListView(
    children: [
      for (String key in Songs.keys)
        if (ShouldShowSong(key, "")) SongTile(context, Songs[key], c, Playlist),
    ],
  );
}

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