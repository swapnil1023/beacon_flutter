import 'package:beacon_futter/functionalities/firestore_service.dart';
import 'package:beacon_futter/functionalities/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BeaconFollow extends StatefulWidget {
  @override
  _BeaconFollowState createState() => _BeaconFollowState();
}

class _BeaconFollowState extends State<BeaconFollow> {
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
  int follow = 0;
  int carry = 0;
  String passkey;
  GoogleMapController mapController;
  Marker marker;
  _buildPopupDialog(BuildContext context) {
    String tempKey;
    return AlertDialog(
      title: const Text('Start Following'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter the passkey',
            ),
            onChanged: (value) {
              setState(() {
                tempKey = value;
              });
            },
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () async {
            bool exists;
            exists = await FirestoreService().beaconExists(tempKey);
            if (exists) {
              setState(() {
                follow = 1;
                passkey = tempKey;
              });
            } else {
              Fluttertoast.showToast(
                msg: "Beacon does not exist",
                gravity: ToastGravity.CENTER,
              );
            }
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

  void stopFollow() {
    follow = 0;
    marker = null;
    passkey = null;
  }

  void markerUpdate(LatLng location) {
    marker = Marker(
      markerId: MarkerId('beacon'),
      position: location,
      icon: BitmapDescriptor.defaultMarker,
      draggable: false,
    );
    if (mapController != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: location, zoom: 15),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition campos = CameraPosition(
        target: LatLng(widget.location.latitude, widget.location.longitude),
        zoom: 15);
    return StreamBuilder<Object>(
        stream: (follow == 1 && passkey != null)
            ? FirestoreService().getBeaconStream(passkey)
            : null,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            DocumentSnapshot beaconDoc = snapshot.data;
            GeoPoint gPoint = beaconDoc['location'];
            LatLng location = new LatLng(gPoint.latitude, gPoint.longitude);
            carry = beaconDoc['carry'];
            if (carry == 1) {
              if (passkey != null) {
                follow = 1;
                markerUpdate(location);
              }
            } else {
              if (follow == 1)
                Fluttertoast.showToast(
                  msg: "Beacon stopped sharing its location",
                  gravity: ToastGravity.CENTER,
                );
              stopFollow();
            }
          }
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
                markers: Set.of((marker != null) ? [marker] : []),
                onMapCreated: (controller) {
                  mapController = controller;
                },
              ),
              Positioned(
                left: 10,
                bottom: 30,
                child: Card(
                  elevation: 2,
                  child: Container(
                    height: MediaQuery.of(context).size.height / 5,
                    width: MediaQuery.of(context).size.width - 20,
                    child: (follow == 0)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'You are not following anyone',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        _buildPopupDialog(context),
                                  );
                                },
                                child: Text('Start Following'),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              (passkey != null)
                                  ? Text(
                                      'You are now following ' + passkey,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  : Text('  '),
                              SizedBox(
                                height: 5,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (follow == 1)
                                    Fluttertoast.showToast(
                                      msg: "Stopped follwing the beacon",
                                      gravity: ToastGravity.CENTER,
                                    );
                                  setState(() {
                                    stopFollow();
                                  });
                                },
                                child: Text('Stop Following'),
                              ),
                            ],
                          ),
                  ),
                ),
              )
            ],
          );
        });
  }
}
