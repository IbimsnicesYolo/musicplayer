import 'package:flutter/material.dart';
import "config.dart" as CFG;
import 'dart:io';

void main() {
  runApp(MaterialApp(home: MainSite()));
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
    Future<void> load() async {
      CFG.LoadData();
      setState(() {});
    }

    load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            actions: [
              // Navigate to the Search Screen
              IconButton(
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => SearchPage())),
                  icon: const Icon(Icons.search))
            ],
            backgroundColor: CFG.HomeColor,
          ),
          body: Container(
            child: ListView(
              children: [
                for (var i in CFG.Songs.keys)
                  ListTile(
                    title: Text(CFG.Songs[i].title),
                    subtitle: Text(CFG.Songs[i].interpret),
                    onTap: () {
                      print(CFG.Songs[i].path);
                    },
                  )
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.download),
            onPressed: () {
              setState(() {});
            },
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.play_arrow),
                label: "Current Playlist",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.tag),
                label: "All Tags",
              ),
            ],
          ),
          drawer: Drawer(
            child: Center(
              child: ButtonBar(
                children: [
                  TextButton(
                    child: const Text("Search for new Songs"),
                    onPressed: () {
                      Directory dir = Directory('/storage/emulated/0/');
                      String mp3Path = dir.toString();
                      List<FileSystemEntity> _files;
                      String lastpath = "";
                      _files =
                          dir.listSync(recursive: true, followLinks: false);
                      for (FileSystemEntity entity in _files) {
                        String path = entity.path;
                        if (path.endsWith('.mp3')) {
                          CFG.CreateSong(path);
                          lastpath = path;
                        }
                        ;
                      }
                      CFG.Songs[lastpath].Info();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Search Page
class SearchPage extends StatelessWidget {
  final myController = TextEditingController();

  String searchtext = "";

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: CFG.HomeColor,
            // The search area here
            title: Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                  color: CFG.ContrastColor,
                  borderRadius: BorderRadius.circular(5)),
              child: Center(
                child: TextField(
                  controller: myController,
                  decoration: InputDecoration(
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          myController.clear();
                        },
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          this.searchtext = myController.text;
                          setState() {}
                          ;
                        },
                      ),
                      hintText: 'Search...',
                      border: InputBorder.none),
                ),
              ),
            )),
        body: Container(
          child: ListView(
            children: [
              for (var i in CFG.Songs.keys)
                if ((CFG.Songs[i].title.contains(this.searchtext) ||
                    CFG.Songs[i].interpret.contains(this.searchtext)))
                  ListTile(
                    title: Text(CFG.Songs[i].title),
                    subtitle: Text(CFG.Songs[i].interpret),
                    onTap: () {
                      print(CFG.Songs[i].path);
                    },
                  )
            ],
          ),
        ),
      ),
    );
  }
}
