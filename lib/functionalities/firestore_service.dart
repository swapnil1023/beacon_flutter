import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirestoreService _firestoreService =
      FirestoreService._internal();

  final FirebaseFirestore db = FirebaseFirestore.instance;

  FirestoreService._internal();

  factory FirestoreService() {
    return _firestoreService;
  }
  Future<void> createToken(String passkey) async {
    GeoPoint loc = new GeoPoint(0, 0);
    await db.collection('beacons').doc(passkey).set({'location': loc});
  }

  void updateLocation(String passkey, LatLng userLocation) async {
    GeoPoint loc = new GeoPoint(userLocation.latitude, userLocation.longitude);
    await db
        .collection('beacons')
        .doc(passkey)
        .update({'location': loc, 'carry': 1});
  }

  Future<void> deleteBeacon(String passkey) async {
    await db.collection('beacons').doc(passkey).update({'carry': 0});
  }

  Future<bool> beaconExists(String passkey) async {
    DocumentSnapshot beacon = await db.collection('beacons').doc(passkey).get();
    if (beacon.exists)
      return true;
    else
      return false;
  }

  Stream<DocumentSnapshot> getBeaconStream(String passkey) {
    return db.collection('beacons').doc(passkey).snapshots();
  }
}
