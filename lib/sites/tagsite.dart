import 'package:tagmusicplayer/main.dart';
import "../settings.dart" as CFG;
import 'package:flutter/material.dart';
import 'components/search.dart' as SearchPage;
import 'components/string_input.dart' as SInput;
import 'components/checkbox.dart' as C;

// TODO Fix Button Color
// TODO Implement SearchPage the right way at all 3 Positions
// ( Search Tags, Search Songs in Tag, Search all songs)

IconButton buildActions(BuildContext context) {
  return IconButton(
    onPressed: () => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MaterialApp(
          theme: ThemeData.dark(),
          home: SearchPage.SearchPage(CFG.Tags),
        ),
      ),
    ),
    icon: const Icon(Icons.search),
  );
}

Container buildContent(void Function(void Function()) c, BuildContext context,
    CurrentPlayList Playlist) {
  CFG.UpdateAllTags();
  return Container(
    child: ListView(
      children: [
        for (int key in CFG.Tags.keys)
          ListTile(
            onLongPress: () => {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MaterialApp(
                    theme: ThemeData.dark(),
                    home: SearchPage.SearchPage(
                      CFG.GetSongsFromTag(CFG.Tags[key]),
                    ),
                  ),
                ),
              ),
              c(() {}),
            },
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              PopupMenuButton(
                onSelected: (result) {
                  if (result == 0) {
                    // Change Name
                    SInput.StringInput(
                      context,
                      "Rename Tag",
                      "Save",
                      "Cancel",
                      (String s) {
                        CFG.UpdateTagName(CFG.Tags[key].id, s);
                        c(() {});
                      },
                      (String s) {},
                      false,
                      CFG.Tags[key].name,
                    );
                  }
                  if (result == 1) {
                    CFG.GetSongsFromTag(CFG.Tags[key]).forEach((key, value) {
                      Playlist.AddToPlaylist(value);
                    });
                  }
                  if (result == 2) {
                    // Delete
                    CFG.DeleteTag(CFG.Tags[key]);
                    c(() {});
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                  PopupMenuItem(child: Text(CFG.Tags[key].name), value: 0),
                  const PopupMenuItem(
                      child: Text('Add Songs to Playlist'), value: 1),
                  const PopupMenuItem(child: Text('Delete Tag'), value: 2),
                ],
              ),
            ]),
            title: Text(CFG.Tags[key].name),
            subtitle: Text(CFG.Tags[key].used.toString()),
          ),
        Align(
          alignment: AlignmentDirectional.bottomCenter,
          child: ElevatedButton(
            style: ButtonStyle(
              enableFeedback: true,
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                return Color(CFG.Config["ContrastColor"]);
              }),
            ),
            onPressed: () {
              SInput.StringInput(
                context,
                "Create new Tag",
                "Create",
                "Cancel",
                (String s) {
                  CFG.CreateTag(s);
                  c(() {});
                },
                (String s) {},
                false,
                "",
              );
            },
            child: const Text("Create new Tag"),
          ),
        )
      ],
    ),
  );
}

/*
class SongPage extends StatefulWidget {
  SongPage({
    Key? key,
    required this.songs,
  });

  final Map songs;

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            actions: [
              // Navigate to the Search Screen
              IconButton(
                  onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SearchPage.SearchPage(widget.songs),
                        ),
                      ),
                  icon: const Icon(Icons.search)),
            ],
            backgroundColor: CFG.HomeColor,
          ),
          body: Container(
            child: ListView(
              children: [
                for (CFG.Song song in widget.songs.values) Text(song.title),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

ListView buildContent(BuildContext context, void Function(void Function()) c,
    CurrentPlayList Playlist) {
  final songs = CFG.Songs.values.toList();
  for (var i = 0; i < songs.length; i++) {
    if (songs[i].hastags) songs.removeAt(i);
  }
  return ListView.builder(
    itemCount: songs.length,
    itemBuilder: (context, index) {
      final item = songs[index];
      return Dismissible(
        key: Key(item.filename),
        onDismissed: (direction) {
          c(() {
            CFG.Songs[item.filename].hastags = true;
            songs.removeAt(index);
          });

          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('$item dismissed')));
        },
        // Show a red background as the item is swiped away.
        background: Container(color: Colors.red),
        child: ListTile(
          title: Text(item.title),
        ),
      );
    },
  );
}
*/
