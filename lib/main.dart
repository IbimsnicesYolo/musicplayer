import 'package:flutter/material.dart';

import 'backend.dart';

enum ROUTES { HOME, PLAYER, SETTINGS, DB }

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
      ),
      home: LoadingPage(),
    );
  }

  Widget LoadingPage() {
    return FutureBuilder(
      future: Database().initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          return HomePage();
        } else {
          return Scaffold(
            body: Center(
              child: Text('Error initializing database'),
            ),
          );
        }
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final List<ROUTES> available_routes = [ROUTES.PLAYER, ROUTES.SETTINGS, ROUTES.DB];

  ROUTES currentRoute = ROUTES.HOME;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('Current Route: ${widget.currentRoute}'),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemCount: widget.available_routes.length,
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        widget.currentRoute = widget.available_routes[index];
                      });
                    },
                    child: Text(widget.available_routes[index].toString()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
