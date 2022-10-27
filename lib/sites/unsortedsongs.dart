import "../settings.dart" as CFG;
import 'package:flutter/material.dart';
import 'components/search.dart' as SearchPage;
import 'components/string_input.dart' as SInput;
import 'components/checkbox.dart' as C;

// TODO Implement SearchPage the right way
IconButton buildActions(BuildContext context) {
  return IconButton(
    onPressed: () => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MaterialApp(
          theme: ThemeData.dark(),
          home: SearchPage.SearchPage(CFG.Songs),
        ),
      ),
    ),
    icon: const Icon(Icons.search),
  );
}

// TODO Implemment the Song Tile right
Container buildContent(void Function() c, BuildContext context) {
  return Container(
    child: ListView(
      children: [
        for (String i in CFG.Songs.keys)
          if (!CFG.Songs[i].hastags) Text(CFG.Songs[i].title), // <-- TODO
      ],
    ),
  );
}
