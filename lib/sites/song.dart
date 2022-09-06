import 'package:flutter/material.dart';
import "../config.dart" as CFG;

class Song extends StatelessWidget {
  const Song({
    Key? key,
    required this.i,
  }) : super(key: key);

  final String i;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(CFG.Songs[i].title),
      subtitle: Text(CFG.Songs[i].interpret),
      onTap: () {
        print(CFG.Songs[i].path);
      },
    );
  }
}
