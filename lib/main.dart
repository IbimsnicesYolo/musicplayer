import 'package:flutter/material.dart';
import "config.dart" as CFG;
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    CFG.LoadData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
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
          child: Icon(Icons.access_alarm_outlined),
          onPressed: () {
            print("asd");
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.abc),
              label: "aosdd",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.accessibility_new_rounded),
              label: "aosaaaaaaaaaaaadd",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_box_outlined),
              label: "aosdd",
            ),
          ],
        ),
        drawer: Drawer(
          child: ButtonBar(
            children: [
              TextButton(
                child: const Text("asd"),
                onPressed: () {
                  Directory dir = Directory('/storage/emulated/0/');
                  String mp3Path = dir.toString();
                  List<FileSystemEntity> _files;
                  String lastpath = "";
                  _files = dir.listSync(recursive: true, followLinks: false);
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
    );
  }
}
