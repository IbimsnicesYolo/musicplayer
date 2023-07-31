import 'dart:core';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'classes/playlist.dart';

Color HomeColor = const Color.fromRGBO(61, 61, 61, 0);
Color ContrastColor = const Color.fromRGBO(0, 255, 76, 0);

Map Config = {
  "HomeColor": HomeColor.value,
  "ContrastColor": ContrastColor.value,
  "SearchPaths": ["storage/emulated/0/Music", "storage/emulated/0/Download", "C:", "D:", "Library"],
  "Playlist": [],
};

/* Config */

void SaveConfig() {}

void LoadData(reload, MyAudioHandler audioHandler) async {
  Database database = await openDatabase("storage/emulated/0/Documents", version: 1,
      onCreate: (Database db, int version) async {
    // When creating the db, create the table
    await db
        .execute('CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)');
    await db.execute('CREATE TABLE Playlist (id INTEGER PRIMARY KEY, name TEXT, songs TEXT)');
  });

  List<Map> list = await database.rawQuery('SELECT * FROM Test');

  // Count the records
  int? count = Sqflite.firstIntValue(await database.rawQuery('SELECT COUNT(*) FROM Test'));
}

/*
await database.transaction((txn) async {
  int id1 = await txn.rawInsert(
      'INSERT INTO Test(name, value, num) VALUES("some name", 1234, 456.789)');
  print('inserted1: $id1');
  int id2 = await txn.rawInsert(
      'INSERT INTO Test(name, value, num) VALUES(?, ?, ?)',
      ['another name', 12345678, 3.1416]);
  print('inserted2: $id2');
});

// Update some record
int count = await database.rawUpdate(
    'UPDATE Test SET name = ?, value = ? WHERE name = ?',
    ['updated name', '9876', 'some name']);
print('updated: $count');

// Delete a record
count = await database
    .rawDelete('DELETE FROM Test WHERE name = ?', ['another name']);


void SaveConfig() {
  SaveSongs();
  String appDocDirectory = "storage/emulated/0/Music";
  File('$appDocDirectory/config.json').create(recursive: true).then((File file) {
    file.writeAsString(jsonEncode(Config));
  });
}

void LoadData(reload, MyAudioHandler audioHandler) async {
  String appDocDirectory = "storage/emulated/0/Music";

  Future.delayed(const Duration(seconds: 2), () {
    try {
      // Load Config
      File('$appDocDirectory/config.json').create(recursive: true).then((File file) {
        file.readAsString().then((String contents) {
          if (contents.isNotEmpty) {
            jsonDecode(contents).forEach((key, value) {
              Config[key] = value;
            });
          }
          // Load Songs
          File('$appDocDirectory/songs.json').create(recursive: true).then((File file) {
            file.readAsString().then((String contents) {
              if (contents.isNotEmpty) {
                jsonDecode(contents).forEach((key, value) async {
                  await Future.delayed(const Duration(milliseconds: 1));
                  Song currentsong = Song.fromJson(value);
                  Songs[key] = currentsong;
                });
                ValidateSongs();
              }
              // Load Tags
              File('$appDocDirectory/tags.json').create(recursive: true).then((File file) {
                file.readAsString().then((String contents) {
                  if (contents.isNotEmpty) {
                    jsonDecode(contents).forEach((key, value) async {
                      await Future.delayed(const Duration(milliseconds: 1));

                      Tag currenttag = Tag.fromJson(value);
                      Tags[currenttag.id] = currenttag;
                    });
                  }
                  Future.delayed(const Duration(seconds: 1), () {
                    UpdateAllTags();
                    audioHandler.LoadPlaylist(reload);
                  });
                });
              });
            });
          });
        });
      });
    } catch (e) {}
  });
}

*/
