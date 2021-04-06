import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'functionalities/route_generaor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Beacon',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
