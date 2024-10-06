import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../Themes/DarkThemeProvider.dart';
import '../logic/StorageService.dart';
import 'SignInScreen.dart';

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({
    super.key,
    required FirebaseAuth auth,
  }) : _auth = auth;

  final FirebaseAuth _auth;

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  GoogleMapController? mapController;
  final CollectionReference _marketsCollection =
      FirebaseFirestore.instance.collection('markets');
  Position? _currentPosition;
  Marker? _selectedMarker;
  List<Marker> markers = [];
  late int howManyMarkersThere;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
        ),
        title: const Text("Map"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          CupertinoSwitch(
            activeColor: Theme.of(context).disabledColor,
            value: themeChange.darkTheme,
            onChanged: (bool? value) {
              themeChange.darkTheme = value!;
            },
          ),
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () async {
                  await widget._auth.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                  );
                },
                child: const Icon(
                  Icons.logout_sharp,
                  size: 26.0,
                ),
              )),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('markets').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Markets available.'));
          } else {
            snapshot.data!.docs.forEach((document) {
              GeoPoint location = document['location'];
              int markerTitle = document['id'];
              Marker mark = Marker(
                markerId: MarkerId(markerTitle.toString()),
                position: LatLng(location.latitude, location.longitude),
                infoWindow: InfoWindow(title: markerTitle.toString()),
              );
              if (markers.contains(mark)) {
              } else {
                markers.add(mark);
              }
            });
            return Stack(
              children: [
                GoogleMap(
                  padding: const EdgeInsets.all(15),
                  //onTap: _onMapTapped,
                  zoomGesturesEnabled: false,
                  myLocationEnabled: true,
                  onLongPress: (argument) {
                    int id = markers.length;
                    GeoPoint location =
                        GeoPoint(argument.latitude, argument.longitude);
                    _addMarket(id, location);
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentPosition?.latitude ?? 30.375952,
                      _currentPosition?.longitude ?? -9.537086,
                    ),
                    zoom: 18,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  markers: Set<Marker>.from(
                      markers), // Call the method to create markers
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    _zoomminusfunction(),
                    _zoomplusfunction(),
                  ]),
                ),
                _marketsNumberfunction(markers.length),
              ],
            );
          }
        },
      ),
    );
  }

  void _onMarkerTapped(Marker marker) {
    setState(() {
      _selectedMarker = marker; // Track the selected marker
    });
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedMarker = null; // Deselect the marker on map tap
    });
  }

  void _deleteSelectedMarker() {
    // if (_selectedMarker != null) {
    //   setState(() {
    //     markers.remove(_selectedMarker); // Remove the selected marker
    //     _selectedMarker = null; // Deselect the marker
    //   });

    //   _mapController?.updateMarkers(_markers); // Apply the changes to the map
    // }
  }

  Future<void> _addMarket(int id, GeoPoint location) async {
    await StorageService().addMarket(id, location);
    if (kDebugMode) {
      print("$id ,${location.longitude};,${location.latitude}");
    }
  }

  void _zoomOut() {
    if (mapController != null) {
      // Decrease the current zoom level by 1
      mapController!.animateCamera(CameraUpdate.zoomOut());
    }
  }

  void _zoomIn() {
    if (mapController != null) {
      // Decrease the current zoom level by 1
      mapController!.animateCamera(CameraUpdate.zoomIn());
    }
  }

  void _getMarkerNumber() {
    setState(() {
      howManyMarkersThere = markers.length;
    });
  }

  Widget _zoomminusfunction() {
    return Align(
        alignment: Alignment.topRight,
        child: IconButton(
          icon: Icon(FontAwesomeIcons.searchMinus,
              color: Theme.of(context).indicatorColor),
          onPressed: _zoomOut,
        ));
  }

  Widget _zoomplusfunction() {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
          icon: Icon(FontAwesomeIcons.searchPlus,
              color: Theme.of(context).indicatorColor),
          onPressed: _zoomIn),
    );
  }

  Widget _marketsNumberfunction(int lenght) {
    //_getMarkerNumber();
    return Padding(
      padding: const EdgeInsets.all(45.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Theme.of(context).indicatorColor,
          ),
          height: 40,
          width: 150,
          child: Center(
            child: Text(
              "Total Markets : ${lenght}",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    // Check if location services are enabled.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      print(
          'Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
      print(position.toString());
    });
  }
}
