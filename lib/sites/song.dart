import 'package:flutter/material.dart';
import "../settings.dart" as CFG;

class Song extends StatelessWidget {
  const Song({
    Key? key,
    required this.s,
  }) : super(key: key);

  final CFG.Song s;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(s.title),
      subtitle: Text(s.interpret),
      onTap: () {
        print(s.path);
      },
    );
  }
}
