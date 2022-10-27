import 'package:flutter/material.dart';
import "package:permission_handler/permission_handler.dart";
import "settings.dart" as CFG;
import "sites/drawer.dart" as Side;
import "sites/search.dart" as SearchPage;
import "sites/song.dart" as Song;
import "sites/string_input.dart" as SInput;

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
  CFG.CurrentPlayList Playlist = CFG.CurrList;

  @override
  void initState() {
    CFG.LoadData();
    Playlist.LoadPlaylist();
    super.initState();
  }

  @override
  void dispose() {
    CFG.SaveConfig();
    super.dispose();
  }

  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: buildSafeArea(context, side),
    );
  }

  SafeArea buildSafeArea(BuildContext context, side) {
    CFG.LoadData();
    Playlist.LoadPlaylist();
    if (side == 1) {
      return buildTaglist(context);
    } else if (side == 2) {
      return buildSongList(context);
    }

    return buildPlaylist(context);
  }

  SafeArea buildPlaylist(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            // Navigate to the Search Screen
            IconButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => MaterialApp(
                        theme: ThemeData.dark(),
                        home: SearchPage.SearchPage(CFG.Songs)))),
                icon: const Icon(Icons.search))
          ],
        ),
        body: Container(
          child: ListView(
            children: [
              if (!this.Playlist.songs.isEmpty) ...[
                for (var i in this.Playlist.songs)
                  Song.SongInfo(s: i, c: update),
              ] else ...[
                const Align(
                  alignment: Alignment.center,
                  heightFactor: 10,
                  child: Text(
                    'No Current Playlist',
                    style: TextStyle(color: Colors.black, fontSize: 30),
                  ),
                ),
              ]
            ],
          ),
        ),
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

  SafeArea buildTaglist(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
// Navigate to the Search Screen
            IconButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => MaterialApp(
                        theme: ThemeData.dark(),
                        home: SearchPage.SearchPageT(CFG.Tags)))),
                icon: const Icon(Icons.search))
          ],
        ),
        body: Container(
          child: ListView(
            children: [
              for (var i in CFG.Tags.keys)
                Song.TagTile(t: CFG.Tags[i], c: update),
              Align(
                alignment: AlignmentDirectional.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    SInput.StringInput(
                      context,
                      "Create new Tag",
                      "Create",
                      "Cancel",
                      (String s) {
                        CFG.CreateTag(s);
                        update();
                      },
                      (String s) {},
                      false,
                      "",
                    );
                  },
                  child: const Text('Add Tag'),
                ),
              )
            ],
          ),
        ),
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

  SafeArea buildSongList(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            // Navigate to the Search Screen
            IconButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => MaterialApp(
                        theme: ThemeData.dark(),
                        home: SearchPage.SearchPage(CFG.Songs)))),
                icon: const Icon(Icons.search))
          ],
        ),
        body: Container(
          child: ListView(
            children: [
              for (String i in CFG.Songs.keys)
                if (!CFG.Songs[i].hastags)
                  Song.SongInfo(s: CFG.Songs[i], c: update),
            ],
          ),
        ),
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
