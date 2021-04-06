import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('carry beacon'),
              onPressed: () {
                Navigator.of(context).pushNamed('/beacon_carry');
              },
            ),
            ElevatedButton(
              child: Text('follow beacon'),
              onPressed: () {
                Navigator.of(context).pushNamed('/beacon_follow');
              },
            ),
          ],
        ),
      ),
    );
  }
}
