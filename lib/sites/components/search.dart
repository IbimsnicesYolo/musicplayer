import 'package:flutter/material.dart';

import '../../settings.dart' as CFG;

// Search Page
class SearchPage extends StatefulWidget {
  const SearchPage(this.content, this.s, {Key? key}) : super(key: key);

  final content;
  final String s;

  @override
  State<SearchPage> createState() =>
      _SearchPageState(s: s, myController: TextEditingController(text: s));
}

class _SearchPageState extends State<SearchPage> {
  _SearchPageState({required this.s, required this.myController});
  TextEditingController myController;

  String s;

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
    return MaterialApp(
      theme: ThemeData.dark(),
      home: SafeArea(
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton(
            backgroundColor: CFG.ContrastColor,
            onPressed: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back),
          ),
          appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              backgroundColor: CFG.HomeColor,
              // The search area here
              title: SizedBox(
                height: 40,
                child: Center(
                  child: TextField(
                    onChanged: (stext) {
                      s = stext;
                      setState(() {});
                    },
                    controller: myController,
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            myController.clear();
                            s = "";
                            setState(() {});
                          },
                        ),
                        border: const OutlineInputBorder(),
                        labelText: 'Search'),
                  ),
                ),
              )),
          body: widget.content(s.trim(), update),
        ),
      ),
    );
  }
}
