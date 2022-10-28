import 'package:flutter/material.dart';
import '../../settings.dart' as CFG;

// Search Page
class SearchPage extends StatefulWidget {
  SearchPage(this.content, {Key? key}) : super(key: key);

  final content;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final myController = TextEditingController();

  String searchtext = "";

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
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
                  onChanged: (searchtext) {
                    this.searchtext = searchtext;
                    setState(() {});
                  },
                  controller: myController,
                  decoration: InputDecoration(
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.backspace_outlined),
                        onPressed: () {
                          Navigator.maybePop(context);
                        },
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          myController.clear();
                          this.searchtext = "";
                          setState(() {});
                        },
                      ),
                      hintText: 'Search...',
                      border: InputBorder.none),
                ),
              ),
            )),
        body: widget.content(searchtext, update),
      ),
    );
  }
}

/*
// SearchPage example
class SearchPageTest extends StatelessWidget {
  const SearchPageTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: SearchPage(
        (search) => Container(
          child: ListView(
            children: [
              for (CFG.Song s in CFG.Songs.values)
                if (s.title.toLowerCase().contains(search.toLowerCase()))
                  PopupMenuButton(
                    onSelected: (result) {
                      if (result == 0) {
                        // Change Title
                        SInput.StringInput(
                          context,
                          "New Song Title",
                          "Save",
                          "Cancel",
                          (String si) {
                            CFG.UpdateSongTitle(s.filename, si);
                            c();
                          },
                          (String si) {},
                          true,
                          s.title,
                        );
                      }
                      if (result == 1) {
                        // Change Interpret
                        SInput.StringInput(
                          context,
                          "New Song Interpret",
                          "Save",
                          "Cancel",
                          (String si) {
                            CFG.UpdateSongInterpret(s.filename, si);
                            c();
                          },
                          (String si) {},
                          true,
                          s.interpret,
                        );
                      }
                      if (result == 2) {
                        showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: MediaQuery.of(context).size.height / 2,
                              color: CFG.HomeColor,
                              child: Center(
                                child: Column(
                                  children: <Widget>[
                                    for (CFG.Tag t in CFG.Tags.values)
                                      CoolerCheckBox(s.tags.contains(t.id),
                                          (bool? b) {
                                        CFG.UpdateSongTags(s.filename, t.id, b);
                                      }, t.name),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                      if (result == 3) {
                        CFG.DeleteSong(s);
                        c();
                      }
                      if (result == 4) {
                        CFG.CurrList.PlayNext(s);
                        // Play Song as Next Song
                      }
                      if (result == 5) {
                        CFG.CurrList.AddToPlaylist(s);
                        // Add Song to End of Playlist
                      }
                      if (result == 6) {
                        CFG.CurrList.PlayAfterLastAdded(s);
                        // Add Song to End of Added Songs
                      }
                    },
                    child: ListTile(
                      title: Text(s.title),
                      subtitle: Text(s.interpret),
                    ),
                    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                      PopupMenuItem(
                        child: Text(s.title),
                        value: 0,
                      ),
                      PopupMenuItem(
                        child: Text(s.interpret),
                        value: 1,
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(child: Text('Edit Tags'), value: 2),
                      const PopupMenuItem(child: Text('Delete Song'), value: 3),
                      const PopupMenuDivider(),
                      const PopupMenuItem(child: Text('Play Next'), value: 4),
                      const PopupMenuItem(
                          child: Text('Add to Playlist'), value: 5),
                      const PopupMenuItem(
                          child: Text('Add to Play Next Stack'), value: 6),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

 */
