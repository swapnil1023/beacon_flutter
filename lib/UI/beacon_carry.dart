import 'dart:async';
import 'dart:math';
import 'package:beacon_futter/functionalities/firestore_service.dart';
import 'package:beacon_futter/functionalities/location_service.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class BeaconCarry extends StatefulWidget {
  @override
  _BeaconCarryState createState() => _BeaconCarryState();
}

class _BeaconCarryState extends State<BeaconCarry> {
  int timer;
  int carry = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: new EdgeInsets.only(top: 30),
      child: Scaffold(
          body: FutureBuilder(
        future: LocationService().getLocation(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return FireMap(location: snapshot.data);
          } else {
            return Center(
              child: SpinKitChasingDots(
                color: Colors.blue,
              ),
            );
          }
        },
      )),
    );
  }
}

class FireMap extends StatefulWidget {
  final LatLng location;
  FireMap({Key key, this.location}) : super(key: key);
  @override
  _FireMapState createState() => _FireMapState();
}

class _FireMapState extends State<FireMap> {
  int carry = 0, timer = 0;
  String passkey;
  GoogleMapController mapController;

  StreamSubscription locationSubscription;
  Location location = Location();
  CountDownController _controller = CountDownController();
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(
        Iterable.generate(
          length,
          (_) => _chars.codeUnitAt(
            _rnd.nextInt(_chars.length),
          ),
        ),
      );

  _buildPopupDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Duration for carrying'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter in minutes',
            ),
            onChanged: (value) {
              setState(() {
                timer = int.parse(value);
              });
            },
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () async {
            // GeoPoint loc = new GeoPoint(0, 0);
            // await db.collection('beacons').doc(passkey).set({'location': loc});
            await FirestoreService().createToken(passkey);
            setState(() {
              carry = 1;
              _controller.restart(duration: timer * 60);
            });
            Navigator.of(context).pop();
          },
          child: const Text('Start'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  @override
  void initState() {
    passkey = getRandomString(5);
    super.initState();
  }

  @override
  void dispose() {
    stopCarry();
    locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> stopCarry() async {
    if (timer != 0)
      Fluttertoast.showToast(
        msg: "Stopped broadcasting location",
      );
    setState(() {
      carry = 0;
      timer = 0;
      _controller.restart(duration: 0);
      _controller.pause();
    });
    await FirestoreService().deleteBeacon(passkey);
  }

  void locationSub() {
    if (locationSubscription != null) locationSubscription.cancel();

    locationSubscription =
        location.onLocationChanged.listen((locationData) async {
      LatLng loc = new LatLng(locationData.latitude, locationData.longitude);
      if (carry != 0) FirestoreService().updateLocation(passkey, loc);
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: loc, zoom: 15),
        ),
      );
      print("location changed-> ");
      print(locationData);
    });
  }

  @override
  Widget build(BuildContext context) {
    locationSub();

    CameraPosition campos = CameraPosition(target: widget.location, zoom: 15);

    return Stack(
      alignment: Alignment.center,
      children: [
        GoogleMap(
          mapType: MapType.normal,
          rotateGesturesEnabled: true,
          initialCameraPosition: campos,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          onMapCreated: (controller) {
            mapController = controller;
          },
        ),
        Positioned(
          left: 10,
          bottom: 30,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                  child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text('you passkey - ' + passkey,
                    style: TextStyle(fontWeight: FontWeight.bold)),
              )),
              Card(
                elevation: 2,
                child: Container(
                  height: MediaQuery.of(context).size.height / 5,
                  width: MediaQuery.of(context).size.width - 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      (carry == 0)
                          ? ElevatedButton(
                              child: Text('Start carrying'),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      _buildPopupDialog(context),
                                );
                              },
                            )
                          : ElevatedButton(
                              child: Text('Stop carrying'),
                              onPressed: () async {
                                await stopCarry();
                              },
                            ),
                      CircularCountDownTimer(
                        duration: (timer != null) ? timer * 60 : 0,
                        initialDuration: 0,
                        controller: _controller,
                        width: MediaQuery.of(context).size.width / 3,
                        height: MediaQuery.of(context).size.height / 8,
                        ringColor: Colors.grey[300],
                        ringGradient: null,
                        fillColor: Colors.purpleAccent[100],
                        fillGradient: null,
                        backgroundColor: Colors.blue,
                        backgroundGradient: null,
                        strokeWidth: 10.0,
                        strokeCap: StrokeCap.round,
                        textStyle: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        textFormat: CountdownTextFormat.S,
                        isReverse: true,
                        isReverseAnimation: true,
                        isTimerTextShown: true,
                        autoStart: false,
                        onStart: () {
                          print('Countdown Started');
                          Fluttertoast.showToast(
                            msg: "Started broadcasting location",
                          );
                        },
                        onComplete: () async {
                          await stopCarry();
                          print('Countdown Ended');
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
