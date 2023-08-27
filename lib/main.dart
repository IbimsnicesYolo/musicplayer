import "package:audio_service/audio_service.dart";
import 'package:flutter/material.dart';
import "package:permission_handler/permission_handler.dart";

import "settings.dart";
import "sites/allsongs.dart" as AllSongs;
import "sites/components/drawer.dart" as Side;
import 'sites/components/string_input.dart';
import "sites/playlist.dart" as PlaylistSide;
import "sites/song.dart" as SongSite;
import "sites/tagsite.dart" as TagSite;

late MyAudioHandler _audioHandler;

Future<void> main() async {
  _audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ibimsnicesyolo.musicplayer',
      androidNotificationChannelName: 'Music Player',
      androidNotificationOngoing: true,
      notificationColor: Color.fromARGB(255, 69, 194, 150),
      androidNotificationClickStartsActivity: true,
    ),
  );
  runApp(MaterialApp(theme: ThemeData.dark(), home: const MainSite()));
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
  bool importing = false;

  @override
  void initState() {
    _audioHandler.SetUpdate(update, doneloading);
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
      if (!importing) {
        checkpermissions().then((value) async {
          if (!value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Please allow storage permissions"),
                duration: const Duration(seconds: 1),
              ),
            );
            Future.delayed(const Duration(seconds: 5), () {
              setState(() {});
            });
          } else {
            LoadData(_audioHandler, context);
          }
        });
      }
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
                child: const Icon(Icons.downloading),
                onPressed: () {
                  reverse += 1;
                  if (reverse > 3) {
                    if (side == 2) {
                      StringInput(context, "Create new Tag", "Create", "Cancel", (String s) async {
                        await CreateTag(s);
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
              icon: const Icon(Icons.play_arrow),
              backgroundColor: ContrastColor,
              label: "Current Song",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.music_note),
              backgroundColor: ContrastColor,
              label: "Current Playlist",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.tag),
              backgroundColor: ContrastColor,
              label: "All Tags",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.all_inclusive_sharp),
              backgroundColor: ContrastColor,
              label: "All Songs",
            ),
          ],
        ),
        drawer: Side.SongDrawer(c: update, Playlist: _audioHandler, done: doneloading),
      ),
    );
  }
}

Future<bool> checkpermissions() async {
  print("Checking permissions");
  PermissionStatus status = await Permission.storage.status;
  if (!status.isGranted) {
    print("Requesting1");
    await Permission.storage.request();
  }
  if (!await Permission.storage.status.isGranted) {
    //return false;
  }

  status = await Permission.manageExternalStorage.status;
  if (!status.isGranted) {
    print("Requesting2");
    await Permission.manageExternalStorage.request();
  }
  if (!await Permission.manageExternalStorage.status.isGranted) {
    return false;
  }

  return true;
}
