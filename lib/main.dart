import 'package:flutter/material.dart';
import "package:permission_handler/permission_handler.dart";
import "sites/components/drawer.dart" as Side;
import "settings.dart" as CFG;
import "sites/playlist.dart" as PlaylistSide;
import "sites/tagsite.dart" as TagSite;
import "sites/unsortedsongs.dart" as USongs;

void checkpermissions() async {
  PermissionStatus status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }
  status = await Permission.manageExternalStorage.status;
  if (!status.isGranted) {
    await Permission.manageExternalStorage.request();
  }
}

void main() {
  runApp(MaterialApp(home: MainSite()));
  checkpermissions();
}

class MainSite extends StatefulWidget {
  const MainSite({Key? key}) : super(key: key);
  @override
  State<MainSite> createState() => _MainSite();
}

class _MainSite extends State<MainSite> {
  int side = 0;
  CurrentPlayList Playlist = CurrentPlayList();

  @override
  void initState() {
    CFG.LoadData(update);
    super.initState();
  }

  @override
  void dispose() {
    CFG.SaveConfig();
    super.dispose();
  }

  void update(void Function() c) {
    setState(
      () {
        c();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    CFG.LoadData(update);
    Playlist.LoadPlaylist(update);
    return MaterialApp(
      theme: ThemeData.dark(),
      home: buildSafeArea(context, side),
    );
  }

  SafeArea buildSafeArea(BuildContext context, side) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if (side == 0) PlaylistSide.buildActions(context, Playlist),
            if (side == 1) TagSite.buildActions(context, Playlist, update),
            if (side == 2) USongs.buildActions(context),
          ],
        ),
        body: (side == 0
            ? PlaylistSide.buildContent(update, context, Playlist)
            : (side == 1
                ? TagSite.buildContent(update, context, Playlist)
                : USongs.buildContent(context, update, Playlist))),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.downloading),
          onPressed: () {
            setState(() {});
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: this.side,
          onTap: (int index) {
            setState(() {
              this.side = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.play_arrow),
              label: "Current Playlist",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tag),
              label: "All Tags",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fiber_new_outlined),
              label: "Unsorted Songs",
            ),
          ],
        ),
        drawer: Side.SongDrawer(c: update),
      ),
    );
  }
}

/* Playlist */
class CurrentPlayList {
  List<CFG.Song> songs = [];
  int last_added_pos = 0;

  void AddToPlaylist(CFG.Song song) {
    for (int i = 0; i < songs.length; i++) {
      if (songs[i].filename == song.filename) {
        return;
      }
    }
    songs.add(song);
    CFG.Config["Playlist"] = Save();
  }

  void AddSong(CFG.Song song) {
    AddToPlaylist(song);
  }

  void PlayNext(CFG.Song song) {
    last_added_pos = 0;
    if (!songs.contains(song)) {
      songs.insert(0, song);
    } else {
      songs.remove(song);
      songs.insert(0, song);
    }
    CFG.Config["Playlist"] = Save();
  }

  void PlayAfterLastAdded(CFG.Song song) {
    last_added_pos += 1;
    if (!songs.contains(song)) {
      songs.insert(last_added_pos, song);
    } else {
      songs.remove(song);
      songs.insert(last_added_pos, song);
    }
    CFG.Config["Playlist"] = Save();
  }

  void RemoveSong(CFG.Song song) {
    songs.remove(song);
    CFG.Config["Playlist"] = Save();
  }

  void Shuffle() {
    songs.shuffle();
    CFG.Config["Playlist"] = Save();
  }

  List<String> Save() {
    List<String> names = [];
    songs.forEach((element) {
      names.add(element.filename);
    });
    return names;
  }

  void LoadPlaylist(void Function(void Function()) reload) {
    List savedsongs = CFG.Config["Playlist"];
    if (savedsongs.isNotEmpty) {
      savedsongs.forEach((element) {
        if (CFG.Songs.containsKey(element)) {
          AddToPlaylist(CFG.Songs[element]);
        }
      });
    }
    reload(() {});
  }
}
