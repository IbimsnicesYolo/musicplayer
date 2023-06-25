import 'package:flutter/material.dart';
import "package:permission_handler/permission_handler.dart";
import "package:audio_service/audio_service.dart";
import "sites/components/drawer.dart" as Side;
import "settings.dart" as CFG;
import "sites/playlist.dart" as PlaylistSide;
import "sites/tagsite.dart" as TagSite;
import "sites/allsongs.dart" as AllSongs;
import "sites/song.dart" as SongSite;
import 'sites/components/string_input.dart';
import "classes/playlist.dart";
import "classes/tag.dart";

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
    CFG.LoadData(update, _audioHandler);
    _audioHandler.update = update;
    Future.delayed(const Duration(minutes:1), () {
      CheckForUpdate(context);
    });
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

  void CheckForUpdate(BuildContext context) async {
    if (CFG.NewVersionAvailable) {
      CFG.NewVersionAvailable = false;
      await Future.delayed(Duration(seconds: 1));
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: const Text('New Version Available, Update Config!'),
      );
      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      CFG.LoadData(update, _audioHandler);
      loaded = true;
    }
    return buildSafeArea(context, side);
  }

  SafeArea buildSafeArea(BuildContext context, side) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if (side == 0)
              SongSite.buildActions(context, update, _audioHandler),
            if (side == 1)
              PlaylistSide.buildActions(context, update, _audioHandler),
            if (side == 2) TagSite.buildActions(context, update, _audioHandler),
            if (side == 3)
              AllSongs.buildActions(context, update, _audioHandler),
          ],
        ),
        body: (side == 0
            ? SongSite.buildContent(context, update, _audioHandler)
            : (side == 1
                ? PlaylistSide.buildContent(context, update, _audioHandler)
                : (side == 2
                    ? TagSite.buildContent(
                        context, update, _audioHandler, reverse)
                    : AllSongs.buildContent(
                        context, update, _audioHandler, reverse)))),
        floatingActionButton: (side == 2 || side == 3 ? FloatingActionButton(
          child: Icon(Icons.downloading),
          onPressed: () {
            reverse += 1;
            if (reverse > 3) {
              if (side == 2) {
                StringInput(context, "Create new Tag", "Create", "Cancel",
                        (String s) {
                      int id = CreateTag(s);
                      SaveTags();
                      setState(() {});
                    }, (String s) {}, false, "", "Tag Name");
              }
              reverse = 0;
            }
            setState(() {});
          },
        ) : null),
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
