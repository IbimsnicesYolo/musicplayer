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
          home: SearchPage.SearchPage(CFG.Tags),
        ),
      ),
    ),
    icon: const Icon(Icons.search),
  );
}

// TODO Implement the Tag Tile with all functions for searching
Container buildContent(void Function() c, BuildContext context) {
  return Container(
    child: ListView(
      children: [
        for (var i in CFG.Tags.keys) Text(CFG.Tags[i].name), // <-- TODO
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
                  c();
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
  );
}
