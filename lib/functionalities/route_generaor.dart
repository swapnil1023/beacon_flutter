import 'package:beacon_futter/UI/beacon_carry.dart';
import 'package:beacon_futter/UI/beacon_follow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../UI/home_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    var args = settings.arguments;
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(
          builder: (_) => HomePage(),
        );
      case '/beacon_carry':
        return MaterialPageRoute(
          builder: (_) => BeaconCarry(),
        );
      case '/beacon_follow':
        return MaterialPageRoute(
          builder: (_) => BeaconFollow(),
        );
      // If args is not of the correct type, return an error page.
      default:
        return _errorRoute();
    }
  }

  static Route<void> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      //SystemNavigator.pop();
      return Scaffold(
          body: Center(
            child: SpinKitChasingDots(
              color: Colors.purple,
            ),
          ),
          );
    });
  }
}
