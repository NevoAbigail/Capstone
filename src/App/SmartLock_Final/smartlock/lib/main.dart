//Imported packages for bluetooth connection, Google Maps API, and general dart control
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartlock/currentLocation.dart';
import 'package:smartlock/device.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

//The default coordinates the application uses when it first opens
const locationLAT = 43.260059;
const locationLOG = -79.921768;

var locationLatitude = 43.260059;
var locationLongitude = -79.921768;

var locationMessage = 0;

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  //This is the opening function that runs when before the screen is displayed
  void initState() {
    //getLatLog();
    readCounter();
    super.initState();
  }

  //These get functions are responsible for getting the information on battery percentage and location used within the application
  Future<void> getBattery() async {
    writeCounter(100);
    setState(() {
      batteryPercent = readCounter().toString();
    });
  }

  Future<void> getLatLog() async {
    setState(() {
      readLat().then((result) => locationLatitude = result);
      readLog().then((result) => locationLongitude = result);
      readPass().then((result) => password = result);
    });
  }

  Future<String> getLocalPath() async {
    var dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> getLocalFile() async {
    String path = await getLocalPath();
    return File('/$path/counter.txt');
  }

  Future<File> getLocalFileLat() async {
    String path = await getLocalPath();
    return File('/$path/locationLat.txt');
  }

  Future<File> getLocalFileLog() async {
    String path = await getLocalPath();
    return File('/$path/locationLog.txt');
  }

  Future<File> getLocalFilePass() async {
    String path = await getLocalPath();
    return File('/$path/pass.txt');
  }

  //These write functions are responsible for writing the information on battery percentage and location used within the application
  Future<File> writeCounter(int c) async {
    File file = await getLocalFile();
    return file.writeAsString('$c');
  }

  Future<File> writeLat(double c) async {
    File file = await getLocalFileLat();
    return file.writeAsString('$c');
  }

  Future<File> writeLog(double c) async {
    File file = await getLocalFileLog();
    return file.writeAsString('$c');
  }

  Future<File> writePass(int c) async {
    File file = await getLocalFilePass();
    return file.writeAsString('$c');
  }

  //This function is responsilbe for creating the approriate text file to store coordinates and battery information
  void createFile(double content, String fileName) async {
    print("Creating file!");
    Directory dir = await getApplicationDocumentsDirectory();
    File file = new File(dir.path + "/" + fileName);
    file.createSync();
    file.writeAsStringSync(json.encode(content));
  }

  //These read functions are responsible for reading the information on battery percentage and location used within the application
  Future<int> readCounter() async {
    final file = await getLocalFile();
    String content = await file.readAsString();
    setState(() {
      batteryPercent = int.parse(content).toString();
    });
    return int.parse(content);
  }

  Future<double> readLat() async {
    final file = await getLocalFileLat();
    if (await file.exists()) {
      print("ITS HERE");
      final file = await getLocalFileLat();
      String content = await file.readAsString();
      print(content);
      locationLatitude = double.parse(content);
      return double.parse(content);
    }
    createFile(43.25, "locationLat.txt");
    final ofile = await getLocalFileLat();
    String content = await ofile.readAsString();
    locationLatitude = double.parse(content);
    return double.parse(content);
  }

  Future<double> readLog() async {
    final file = await getLocalFileLog();
    if (await file.exists()) {
      print("ITS HERE");
      final file = await getLocalFileLog();
      String content = await file.readAsString();
      print(content);
      locationLongitude = double.parse(content);
      return double.parse(content);
    }
    createFile(-79.935, "locationLog.txt");
    final ofile = await getLocalFileLog();
    String content = await ofile.readAsString();
    locationLongitude = double.parse(content);
    return double.parse(content);
  }

  Future<int> readPass() async {
    final file = await getLocalFilePass();
    if (await file.exists()) {
      print("ITS HERE");
      final file = await getLocalFilePass();
      String content = await file.readAsString();
      print(content);
      password = int.parse(content);
      return int.parse(content);
    }
    createFile(1, "pass.txt");
    final ofile = await getLocalFilePass();
    String content = await ofile.readAsString();
    password = int.parse(content);
    return int.parse(content);
  }

  //variables used for testing the connection and locking of the SmartLock
  var statusEngage = ['Bluetooth ', 'Bluetooth '];
  var statusLock = ['Locked', 'Unlocked'];
  var engaged = 0;
  var locked = 0;
  var locationData;
  var batteryPercent = "Battery";
  var myText = "";

  //this variable is used to store the password entered by the user
  var password = 1;

  //This code is responsible for setting up Google Maps API
  final _controller = TextEditingController();
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};
  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(locationLAT, locationLOG), zoom: 14);

  CameraPosition getCameraPosition() {
    getLatLog();

    CameraPosition intCameraPosition = CameraPosition(
        target: LatLng(locationLatitude, locationLongitude), zoom: 14);
    markers.add(Marker(
        markerId: const MarkerId('currentLocation'),
        position: LatLng(locationLatitude, locationLongitude)));
    return intCameraPosition;
  }

  //Function used for testing the connection of the bluetooth and changing screens to bluetooth connection screen
  void engageOrDisengage() {
    setState(() {
      if (isConnected == 0) {
        engaged = 1;
      } else {
        engaged = 0;
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SecondRoute()),
      );
    });
  }

  //Function used for testing the locking of the SmartLock
  void lockOrUnlock() {
    setState(() {
      if (locking == 0) {
        locked = 1;
      } else {
        locking = 0;
      }
    });
  }

  //This function is responsilbe for changing screens to the Google Maps interactive screen where the user can request the coordinates of their current location
  void setImage() async {
    setState(() {});
    await Navigator.push(context,
        MaterialPageRoute(builder: (context) => CurrentLocationScreen()));
  }

  //This is the main build that displays and builds the layout of the mainscreen. It holds all the buttons and calls the approriate functions
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('SMART LOCK'),
      ),
      body: Column(children: [
        SizedBox(
          height: 15,
        ),
        Container(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            child: Text(
              "BLUETOOTH CONNECTION",
              style: TextStyle(fontSize: 17),
            ),
            onPressed: engageOrDisengage,
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Container(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
                //hintText: password.toString(),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)))),
            obscureText: true,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
            child: ElevatedButton(
          child: Text("Save Password"),
          onPressed: () {
            setState(() {
              password = int.parse(_controller.text);
              writePass(password);
            });
          },
        )),
        SizedBox(height: 20),
        Wrap(spacing: 5, children: <Widget>[
          FloatingActionButton.small(
            onPressed: () async {
              final data = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CurrentLocationScreen()));
              setState(() {
                locationData = data;
              });
            },
            child: Icon(
              Icons.add_location_sharp,
              size: 20,
              color: Colors.black,
            ),
          ),
          Container(
              padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
              child: Text("Pin New Location", textAlign: TextAlign.center)),
        ]),
        SizedBox(height: 10),
        Container(
          child: GoogleMap(
            initialCameraPosition: getCameraPosition(),
            markers: markers,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              googleMapController = controller;
            },
          ),
          width: 350,
          height: 280,
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(
                  text: locationMessage == 0 ? "Coordinates" : locationData));
            },
            child: Text(
              locationMessage == 0 ? "Coordinates" : locationData,
              style: TextStyle(fontSize: 17),
            ),
          ),
        ),
        Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
          child: ElevatedButton(
            onPressed: () async {
              googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: LatLng(locationLatitude, locationLongitude),
                      zoom: 14)));
              markers.clear();
              markers.add(Marker(
                  markerId: const MarkerId('currentLocation'),
                  position: LatLng(locationLatitude, locationLongitude)));
            },
            child: Text("Get Stored Location"),
          ),
        ),
        Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.all(10),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                getBattery;
              });
            }, //() => myText = _read().toString(),
            child: Text(batteryPercent.toString() + " %"),
          ),
        ),
      ]),
    ));
  }
}

//The build of the second screen where bluetooth devices are seen
class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return FindDevicesScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        /*leading: BackButton(
            onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyApp(),
                  ),
                )),*/
        title: Text('Find Devices'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<List<ScanResult>>(
              stream: FlutterBlue.instance.scanResults,
              initialData: [],
              builder: (c, snapshot) => Column(
                children: snapshot.data!
                    .map((result) => ListTile(
                          title: Text(result.device.name == ""
                              ? "No Name "
                              : result.device.name),
                          subtitle: Text(result.device.id.toString()),
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            result.device.connect();
                            isConnected = 1;
                            return DeviceScreen(device: result.device);
                          })),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => FlutterBlue.instance.startScan(
                    timeout: Duration(seconds: 4), allowDuplicates: false));
          }
        },
      ),
    );
  }
}
