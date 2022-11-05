import 'package:tagmusicplayer/main.dart';
import "../settings.dart" as CFG;
import 'package:flutter/material.dart';
import 'components/search.dart' as SearchPage;
import 'components/string_input.dart' as SInput;
import 'components/checkbox.dart' as C;

bool ShouldShowSong(String key, String search) {
  if (search == "") return true;

  if (CFG.Songs[key].title.toLowerCase().contains(search.toLowerCase()))
    return true;

  if (CFG.Songs[key].interpret.toLowerCase().contains(search.toLowerCase()))
    return true;

  List<String> name = CFG.Songs[key].title.toLowerCase().split(" ");
  name += CFG.Songs[key].interpret.toLowerCase().split(" ");
  name += CFG.Songs[key].filename.toLowerCase().split(" ");

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
        builder: (_) => MaterialApp(
          theme: ThemeData.dark(),
          home: SearchPage.SearchPage(
            (search, update) => Container(
              child: ListView(
                children: [
                  for (String key in CFG.Songs.keys)
                    if (ShouldShowSong(key, search))
                      SongTile(context, CFG.Songs[key], c, Playlist),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    icon: const Icon(Icons.search),
  );
}

ListView buildContent(BuildContext context, void Function(void Function()) c,
    CurrentPlayList Playlist) {
  return ListView(
    children: [
      for (String key in CFG.Songs.keys)
        if (!CFG.Songs[key].hastags)
          SongTile(context, CFG.Songs[key], c, Playlist),
    ],
  );
}

PopupMenuButton SongTile(BuildContext context, CFG.Song s,
    void Function(void Function()) c, CurrentPlayList Playlist) {
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
            c(() {});
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
            c(() {});
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
                      C.CoolerCheckBox(s.tags.contains(t.id), (bool? b) {
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
        c(() {});
      }
      if (result == 4) {
        Playlist.PlayNext(s);
        // Play Song as Next Song
      }
      if (result == 5) {
        Playlist.AddToPlaylist(s);
        // Add Song to End of Playlist
      }
      if (result == 6) {
        Playlist.PlayAfterLastAdded(s);
        // Add Song to End of Added Songs
      }
      Playlist.Save();
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
