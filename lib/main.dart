import 'package:flutter/material.dart';
import "package:permission_handler/permission_handler.dart";
import "settings.dart" as CFG;
import "sites/drawer.dart" as Side;
import "sites/search.dart" as SearchPage;
import "sites/song.dart" as Song;

void checkperms() async {
  var status = await Permission.storage.status;
  if (status.isDenied) {
    await Permission.storage.request();
  }
  status = await Permission.manageExternalStorage.status;
  if (status.isDenied) {
    await Permission.manageExternalStorage.request();
  }
}

void main() {
  runApp(MaterialApp(home: MainSite()));
  checkperms();
}

class MainSite extends StatefulWidget {
  const MainSite({Key? key}) : super(key: key);
  @override
  State<MainSite> createState() => _MainSite();
}

class _MainSite extends State<MainSite> {
  @override
  void initState() {
    super.initState();
    CFG.LoadData();
  }

  @override
  void dispose() {
    super.dispose();
    _textFieldController.dispose();
  }

  int side = 0;
  TextEditingController _textFieldController = TextEditingController();
  CFG.CurrentPlayList? Playlist;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            actions: [
              // Navigate to the Search Screen
              IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => SearchPage.SearchPage())),
                  icon: const Icon(Icons.search))
            ],
            backgroundColor: CFG.HomeColor,
          ),
          body: Container(
            child: ListView(
              children: [
                if (side == 0)
                  if (this.Playlist != null) ...[
                    for (var i in this.Playlist!.songs) Song.SongInfo(s: i),
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
                else if (side == 1) ...[
                  // Current Playlist Songs, also sortable via drag and drop
                  // at the top is always the current song
                  for (var i in CFG.Tags.keys) Song.TagTile(t: CFG.Tags[i]),
                  Align(
                    alignment: AlignmentDirectional.bottomCenter,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AlertDialog(
                              title: Text('Create New Tag'),
                              content: TextField(
                                onChanged: (value) {},
                                controller: _textFieldController,
                                decoration:
                                    InputDecoration(hintText: "Tag Name"),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Colors.red,
                                  ),
                                  child: Text('Back'),
                                  onPressed: () {
                                    _textFieldController.clear();
                                    Navigator.pop(context);
                                    setState(() {});
                                  },
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Colors.green,
                                  ),
                                  child: Text('Create'),
                                  onPressed: () {
                                    CFG.CreateTag(_textFieldController.text);
                                    _textFieldController.clear();
                                    Navigator.pop(context);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: const Text('Create New',
                          style: TextStyle(fontSize: 20)),
                    ),
                  )
                ] else if (side == 2) ...[
                  for (var i in CFG.UnsortedSongs.keys)
                    Song.SongInfo(
                      s: CFG.UnsortedSongs[i],
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
          drawer: Side.SongDrawer(),
        ),
      ),
    );
  }
}
