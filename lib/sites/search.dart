import 'package:flutter/material.dart';
import "../settings.dart" as CFG;
import "song.dart" as Song;

// Search Page
class SearchPage extends StatefulWidget {
  SearchPage(this.songs, {Key? key}) : super(key: key);

  Map<dynamic, dynamic> songs;

  @override
  State<SearchPage> createState() => _SearchPageState(list: songs);
}

class _SearchPageState extends State<SearchPage> {
  _SearchPageState({required this.list});
  final myController = TextEditingController();
  final list;

  String searchtext = "";

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
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
              height: 40,
              decoration: BoxDecoration(
                  color: CFG.ContrastColor,
                  borderRadius: BorderRadius.circular(5)),
              child: Center(
                child: TextField(
                  onEditingComplete: () {
                    this.searchtext = myController.text;
                    setState(() {});
                  },
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
                          setState(() {});
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
              if (list.length != 0) ...[
                for (var i in list.keys)
                  if (list[i]
                          .title
                          .toLowerCase()
                          .contains(this.searchtext.toLowerCase()) ||
                      list[i]
                          .interpret
                          .toLowerCase()
                          .contains(this.searchtext.toLowerCase()))
                    Song.SongInfo(s: list[i], c: () => setState(() {}))
              ] else ...[
                for (var i in CFG.Songs.keys)
                  if (CFG.Songs[i].title
                          .toLowerCase()
                          .contains(this.searchtext.toLowerCase()) ||
                      CFG.Songs[i].interpret
                          .toLowerCase()
                          .contains(this.searchtext.toLowerCase()))
                    Song.SongInfo(s: CFG.Songs[i], c: () => setState(() {}))
              ]
              // TO:Do Make Tags Searchable and show Songs sorted after Tags
            ],
          ),
        ),
      ),
    );
  }
}

class SearchPageT extends StatefulWidget {
  SearchPageT(this.songs, {Key? key}) : super(key: key);

  Map<dynamic, dynamic> songs;

  @override
  State<SearchPageT> createState() => _SearchPageStateT(list: songs);
}

class _SearchPageStateT extends State<SearchPageT> {
  _SearchPageStateT({required this.list});
  final myController = TextEditingController();
  final list;

  String searchtext = "";

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
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
              height: 40,
              decoration: BoxDecoration(
                  color: CFG.ContrastColor,
                  borderRadius: BorderRadius.circular(5)),
              child: Center(
                child: TextField(
                  onEditingComplete: () {
                    this.searchtext = myController.text;
                    setState(() {});
                  },
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
                          setState(() {});
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
              if (list.length != 0)
                for (var i in list.keys)
                  if (list[i]
                      .name
                      .toLowerCase()
                      .contains(this.searchtext.toLowerCase()))
                    Song.TagTile(t: CFG.Tags[i], c: () => setState(() {})),
            ],
          ),
        ),
      ),
    );
  }
}
