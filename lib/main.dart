// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import "package:velocity_x/velocity_x.dart";
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(VxState(
    store: MyStore(),
    child: const MyApp(),
  ));
}

// Obtain an instance of FlutterBlue
FlutterBlue flutterBlue = FlutterBlue.instance;

// Store definition
class MyStore extends VxStore {
  List bluetoothDevices = [];
  bool connected = false;
}

// Store Mutations
class GetDevices extends VxMutation<MyStore> {
  @override
  perform() {
    flutterBlue.startScan(timeout: const Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (int i = 0; i < results.length; i++) {
        var r = results[i];
        if (r.device.name.isNotEmpty) {
          print('${r.device.name} found! rssi: ${r.rssi}');
          print(r.device);

          // Check for duplicates
          if (!store!.bluetoothDevices.contains(r.device)) {
            store?.bluetoothDevices.add(r.device);
          }
        }
      }
    });
  }
}

// Store Interceptors
class Hydrated extends VxInterceptor {
  @override
  void afterMutation(VxMutation<VxStore> mutation) {
    print("Hydrated");
  }
}

class GetConnectionState extends VxMutation<MyStore> {
  @override
  Future<void> perform() async {
    var connectedDevices = await flutterBlue.connectedDevices;
    if (connectedDevices.isNotEmpty) {
      store?.connected = true;
    } else {
      store?.connected = false;
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  child: const Text('Scan for devices'),
                  onPressed: () {
                    // Invoke mutation
                    GetDevices();
                  },
                ),
                Expanded(
                  child: VxBuilder(
                      mutations: const {GetDevices, GetConnectionState},
                      builder: (context, store, status) => ListView.builder(
                          itemCount: store.bluetoothDevices.length,
                          itemBuilder: (context, index) {
                            return TextButton(
                                child: Text(store.bluetoothDevices[index].name),
                                onPressed: () {
                                  store.bluetoothDevices[index].connect();
                                  GetConnectionState();
                                });
                          })),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
