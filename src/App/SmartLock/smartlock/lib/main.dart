import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/services.dart';
import 'package:smartlock/device.dart';

import 'dart:async';
import 'dart:math';

import './engageStatus.dart';
import './lockStatus.dart';
import './device.dart';

const deviceID = 'BADD50F7-1AF2-35CE-FE4C-37C22B8F2C9F';

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
  var statusEngage = ['Bluetooth Off', 'Bluetooth On'];
  var statusLock = ['Locked', 'Unlocked'];

  var engaged = 0;

  var locked = 0;

  var locationImage = 'assets/pinMessage.png';

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

  void lockOrUnlock() {
    setState(() {
      if (locking == 0) {
        locked = 1;
      } else {
        locking = 0;
      }
    });
  }

  void setImage() {
    setState(() {
      locationImage = 'assets/mcmasterPin.png';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('SMART LOCK'),
        ),
        body: Column(children: [
          SizedBox(
            height: 30,
          ),
          SizedBox(
            height: 20,
            width: 40,
          ),
          ElevatedButton(
            onPressed: engageOrDisengage,
            child: EngageStatus(statusEngage[isConnected]),
          ),
          //_buildListViewOfDevices(),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {}, //lockOrUnlock,
            child: LockStatus(statusLock[locking]),
          ),
          SizedBox(height: 20),
          FloatingActionButton.large(
            onPressed: setImage,
            child: Icon(
              Icons.add_location_sharp,
              size: 20,
              color: Colors.black,
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Image(
              image: AssetImage(locationImage),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(250, 20, 20, 20),
            child: ElevatedButton(
              onPressed: null,
              child: Text('85%'),
            ),
          ),
        ]),
      ),
    );
  }
}

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
        title: Text('Find Devices'),
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
                onPressed: () => FlutterBlue.instance
                    .startScan(timeout: Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}
