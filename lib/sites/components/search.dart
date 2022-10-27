import 'package:flutter/material.dart';
import '../../settings.dart' as CFG;

// Search Page
class SearchPage extends StatefulWidget {
  SearchPage(this.content, {Key? key}) : super(key: key);

  final content;

  @override
  State<SearchPage> createState() => _SearchPageState(content: content);
}

class _SearchPageState extends State<SearchPage> {
  _SearchPageState({required this.content});

  final myController = TextEditingController();
  final content;

  String searchtext = "";

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
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
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          if (myController.text != "") {
                            myController.clear();
                          } else {
                            Navigator.pop(context);
                          }
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
        body: content(searchtext),
      ),
    );
  }
}
