import 'package:flutter/material.dart';
import "../settings.dart" as CFG;

class SongInfo extends ListTile {
  const SongInfo({
    Key? key,
    required this.s,
  }) : super(key: key);

  final CFG.Song s;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      child: ListTile(
        title: Text(s.title),
        subtitle: Text(s.interpret),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.add),
            title: Text(s.title),
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.anchor),
            title: Text(s.interpret),
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.article),
            title: Text("Edit Tags"),
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: 200,
                    color: Colors.amber,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Text('Modal BottomSheet'),
                          ElevatedButton(
                            child: const Text('Close BottomSheet'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(child: Text('Item A')),
        const PopupMenuItem(child: Text('Item B')),
      ],
    );
  }
}

class TagTile extends ListTile {
  const TagTile({
    Key? key,
    required this.t,
  }) : super(key: key);

  final CFG.Tag t;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (result) {
        if (result == 0) {
          CFG.DeleteTag(context, t);
        }
      },
      child: ListTile(
        title: Text(t.name),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.add),
            title: Text(t.name),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(child: Text('Delete Tag'), value: 0),
        const PopupMenuItem(child: Text('Item B')),
      ],
    );
  }
}
