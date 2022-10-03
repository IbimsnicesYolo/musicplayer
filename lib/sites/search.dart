import 'package:flutter/material.dart';
import "../settings.dart" as CFG;
import "song.dart" as Song;

// Search Page
class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final myController = TextEditingController();

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
                          setState(() {});
                          this.searchtext = myController.text;
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
                if (CFG.Songs[i].title
                        .toLowerCase()
                        .contains(this.searchtext.toLowerCase()) ||
                    CFG.Songs[i].interpret
                        .toLowerCase()
                        .contains(this.searchtext.toLowerCase()))
                  Song.SongInfo(s: CFG.Songs[i])
              // TO:Do Make Tags Searchable and show Songs sorted after Tags
            ],
          ),
        ),
      ),
    );
  }
}
