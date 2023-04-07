//This dart file is responsible for building the end screen where the user can disengage the lock and check the connection of their bluetooth device

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:smartlock/lockStatus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

var locking = 0;
var isConnected = 0;
var password = 1;

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  //This is where the user entered password is sent to the Ardunio to disengage the lock
  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    readPass();
    return services
        .map((e) => Column(
              children: [
                ListTile(
                  title: Text("Unlock using Password"),
                  onTap: () {
                    print(e.characteristics);
                    e.characteristics[0].write([password]);
                    print(password);
                    print(
                        "********************************************************" +
                            password.toString());
                    LockStatus('Unlocked');
                    locking = 0;
                  },
                ),
              ],
            ))
        .toList();
  }

  Future<String> getLocalPath() async {
    var dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> getLocalFilePass() async {
    String path = await getLocalPath();
    return File('/$path/pass.txt');
  }

  Future<int> readPass() async {
    final file = await getLocalFilePass();
    String content = await file.readAsString();
    print(content);
    password = int.parse(content);
    return int.parse(content);
  }

  //This is the main build the constructs the layout of the screen with the buttons and their approriate functions
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback? onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => device.disconnect();
                  text = 'DISCONNECT';
                  isConnected = 1;
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => device.connect();
                  text = 'CONNECT';
                  isConnected = 0;
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return TextButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .button
                        ?.copyWith(color: Colors.white),
                  ));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                leading: (snapshot.data == BluetoothDeviceState.connected)
                    ? Icon(Icons.bluetooth_connected)
                    : Icon(Icons.bluetooth_disabled),
                title: Text(
                    'Device is ${snapshot.data.toString().split('.')[1]}.'),
                subtitle: Text('${device.id}'),
                trailing: StreamBuilder<bool>(
                  stream: device.isDiscoveringServices,
                  initialData: false,
                  builder: (c, snapshot) => IndexedStack(
                    index: snapshot.data! ? 1 : 0,
                    children: <Widget>[
                      TextButton(
                        child: Text("View Options"),
                        onPressed: () => device.discoverServices(),
                      ),
                      IconButton(
                        icon: SizedBox(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.grey),
                          ),
                          width: 18.0,
                          height: 18.0,
                        ),
                        onPressed: null,
                      )
                    ],
                  ),
                ),
              ),
            ),
            StreamBuilder<List<BluetoothService>>(
              stream: device.services,
              initialData: [],
              builder: (c, snapshot) {
                return Column(
                  children: _buildServiceTiles(snapshot.data!),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
