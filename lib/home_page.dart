import 'package:flutter/material.dart';
import "color_config.dart" as CfgColors;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: CfgColors.background,
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.accessibility_new),
                    Row(
                      children: [
                        Icon(Icons.search),
                        SizedBox(width: 10),
                        Icon(Icons.notifications)
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Container(
                      margin: const EdgeInsets.only(left: 20),
                      child:
                          Text("Headline 1", style: TextStyle(fontSize: 30))),
                ],
              ),
              Container(
                  height: 180,
                  child: PageView.builder(
                      controller: PageController(viewportFraction: 0.8),
                      itemCount: 5,
                      itemBuilder: (_, i) {
                        return Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            // image:DecorationImage(image:AssetImage(""))
                          ),
                        );
                      }))
            ],
          ),
        ),
      ),
    );
  }
}
