import 'package:flutter/material.dart';
import "package:permission_handler/permission_handler.dart";
import "sites/components/drawer.dart" as Side;
import "settings.dart" as CFG;
import "sites/playlist.dart" as PlaylistSide;
import "sites/tagsite.dart" as TagSite;
import "sites/unsortedsongs.dart" as USongs;
import "sites/song.dart" as SongSite;
import "classes/playlist.dart";
import "classes/tag.dart";

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
            if (side == 0) SongSite.buildActions(context, update, Playlist),
            if (side == 1) PlaylistSide.buildActions(context, update, Playlist),
            if (side == 2) TagSite.buildActions(context, update, Playlist),
            if (side == 3) USongs.buildActions(context, update, Playlist),
          ],
        ),
        body: (side == 0
            ? SongSite.buildContent(context, update, Playlist)
            : (side == 1
                ? PlaylistSide.buildContent(context, update, Playlist)
                : (side == 2
                    ? TagSite.buildContent(context, update, Playlist)
                    : USongs.buildContent(context, update, Playlist)))),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.downloading),
          onPressed: () {
            setState(() {
              if (side == 2) UpdateAllTags();
            });
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: this.side,
          onTap: (int index) {
            setState(() {
              this.side = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.play_arrow),
              backgroundColor: CFG.ContrastColor,
              label: "Current Song",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_arrow),
              backgroundColor: CFG.ContrastColor,
              label: "Current Playlist",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tag),
              backgroundColor: CFG.ContrastColor,
              label: "All Tags",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fiber_new_outlined),
              backgroundColor: CFG.ContrastColor,
              label: "Unsorted Songs",
            ),
          ],
        ),
        drawer: Side.SongDrawer(c: update),
      ),
    );
  }
}
