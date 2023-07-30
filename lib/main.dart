import "package:audio_service/audio_service.dart";
import 'package:flutter/material.dart';
import "package:permission_handler/permission_handler.dart";

import "classes/playlist.dart";
import "classes/tag.dart";
import "settings.dart" as CFG;
import "sites/allsongs.dart" as AllSongs;
import "sites/components/drawer.dart" as Side;
import 'sites/components/string_input.dart';
import "sites/playlist.dart" as PlaylistSide;
import "sites/song.dart" as SongSite;
import "sites/tagsite.dart" as TagSite;

late MyAudioHandler _audioHandler;

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

Future<void> main() async {
  _audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.ibimsnicesyolo.musicplayer',
      androidNotificationChannelName: 'Music Player',
      androidNotificationOngoing: true,
      notificationColor: Color.fromARGB(255, 69, 194, 150),
      androidNotificationClickStartsActivity: true,
    ),
  );
  runApp(MaterialApp(theme: ThemeData.dark(), home: MainSite()));
  checkpermissions();
}

class MainSite extends StatefulWidget {
  const MainSite({Key? key}) : super(key: key);
  @override
  State<MainSite> createState() => _MainSite();
}

class _MainSite extends State<MainSite> {
  int side = 0;
  int reverse = 0;
  bool loaded = false;

  @override
  void initState() {
    _audioHandler.SetUpdate(update);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void update(void Function() c) {
    setState(
      () {
        c();
      },
    );
  }

  void doneloading() {
    setState(() {
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      CFG.LoadData(doneloading, _audioHandler);

      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/loading.gif"),
            ],
          ),
        ),
      );
    }

    return buildSafeArea(context, side);
  }

  SafeArea buildSafeArea(BuildContext context, side) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if (side == 0) SongSite.buildActions(context, update, _audioHandler),
            if (side == 1) PlaylistSide.buildActions(context, update, _audioHandler),
            if (side == 2) TagSite.buildActions(context, update, _audioHandler),
            if (side == 3) AllSongs.buildActions(context, update, _audioHandler),
          ],
        ),
        body: (side == 0
            ? SongSite.buildContent(context, update, _audioHandler)
            : (side == 1
                ? PlaylistSide.buildContent(context, update, _audioHandler)
                : (side == 2
                    ? TagSite.buildContent(context, update, _audioHandler, reverse)
                    : AllSongs.buildContent(context, update, _audioHandler, reverse)))),
        floatingActionButton: (side == 2 || side == 3
            ? FloatingActionButton(
                child: Icon(Icons.downloading),
                onPressed: () {
                  reverse += 1;
                  if (reverse > 3) {
                    if (side == 2) {
                      StringInput(context, "Create new Tag", "Create", "Cancel", (String s) {
                        CreateTag(s);
                        SaveTags();
                        setState(() {});
                      }, (String s) {}, false, "", "Tag Name");
                    }
                    reverse = 0;
                  }
                  setState(() {});
                },
              )
            : null),
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
              icon: Icon(Icons.music_note),
              backgroundColor: CFG.ContrastColor,
              label: "Current Playlist",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tag),
              backgroundColor: CFG.ContrastColor,
              label: "All Tags",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.all_inclusive_sharp),
              backgroundColor: CFG.ContrastColor,
              label: "All Songs",
            ),
          ],
        ),
        drawer: Side.SongDrawer(c: update, Playlist: _audioHandler),
      ),
    );
  }
}
