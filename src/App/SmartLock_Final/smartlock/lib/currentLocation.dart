//This dart file is responsible for constructing and controlling of the current location screen
//that appears when the user clicks the geo pin button on the main screen

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartlock/main.dart';

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

var locLAT = 0.0;
var locLOG = 0.0;

class CurrentLocationScreen extends StatefulWidget {
  const CurrentLocationScreen({Key? key}) : super(key: key);

  @override
  _CurrentLocationScreenState createState() => _CurrentLocationScreenState();
}

class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> getLatLog() async {
    final String response = await rootBundle.loadString('lib/data.json');
    final data = await json.decode(response);
    setState(() {
      var locationLatitude = data['latitude'];
      var locationLongitude = data['longitude'];
      print(locationLatitude);
    });
  }

  Future<String> getLocalPath() async {
    var dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> getLocalFileLat() async {
    String path = await getLocalPath();
    return File('/$path/locationLat.txt');
  }

  Future<File> getLocalFileLog() async {
    String path = await getLocalPath();
    return File('/$path/locationLog.txt');
  }

  Future<File> writeLat(double c) async {
    File file = await getLocalFileLat();
    return file.writeAsString('$c');
  }

  Future<File> writeLog(double c) async {
    File file = await getLocalFileLog();
    return file.writeAsString('$c');
  }

  late GoogleMapController googleMapController;

  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(locationLAT, locationLOG), zoom: 14);

  Set<Marker> markers = {};

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return Future.value(false);
        },
        child: Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () {
                if (locationMessage == 1) {
                  var locData = locLAT.toString().substring(0, 8) +
                      ", " +
                      locLOG.toString().substring(0, 9);
                  Navigator.pop(context, locData);
                } else {
                  Navigator.pop(context, "Location");
                }
              },
            ),
            title: const Text("User current location"),
            centerTitle: true,
          ),
          body: GoogleMap(
            initialCameraPosition: initialCameraPosition,
            markers: markers,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              googleMapController = controller;
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              Position position = await _determinePosition();

              googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: LatLng(position.latitude, position.longitude),
                      zoom: 14)));

              markers.clear();
              markers.add(Marker(
                  markerId: const MarkerId('currentLocation'),
                  position: LatLng(position.latitude, position.longitude)));
              setState(() {
                locLAT = position.latitude;
                locLOG = position.longitude;
                writeLat(locLAT);
                writeLog(locLOG);
                locationMessage = 1.toInt();
              });
            },
            label: const Text("Current Location"),
            icon: const Icon(Icons.location_history),
          ),
        ));
  }

  //This function is responsilbe for getting and handling user permission to use their mobile's GPS
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }
}
