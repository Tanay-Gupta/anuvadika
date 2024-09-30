import 'package:anuvadika/homepage.dart';
import 'package:anuvadika/translator.dart';
import 'package:flutter/material.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomePage()));
                },
                child: Text("App 1")),
            ElevatedButton(onPressed: () {
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => TranslatorPage()));
            }, child: Text("App 2")),
          ],
        ),
      ),
    );
  }
}
