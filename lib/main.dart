import 'package:flutter/material.dart';
import 'package:flutter_blue/gen/flutterblue.pb.dart';
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
  int count = 0;
  List bluetoothDevices = [];
}

// Store Mutations
class Increment extends VxMutation<MyStore> {
  @override
  perform() => store?.count++;
}

class GetDevices extends VxMutation<MyStore> {
  @override
  perform() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (int i = 0; i < results.length; i++) {
        var r = results[i];
        if (r.device.name.length > 0) {
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define when this widget should re render
    VxState.watch(context, on: [Increment, GetDevices]);

    // Get access to the store
    MyStore store = VxState.store;

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Count: ${store.count}"),
              TextButton(
                child: const Text('Increment'),
                onPressed: () {
                  // Invoke mutation
                  Increment();
                },
              ),
              TextButton(
                child: const Text('Scan for devices'),
                onPressed: () {
                  // Invoke mutation
                  GetDevices();
                },
              ),
              Expanded(
                child: VxBuilder(
                    mutations: {GetDevices},
                    builder: (context, store, status) => ListView.builder(
                        itemCount: store.bluetoothDevices.length,
                        itemBuilder: (context, index) {
                          return TextButton(
                              child: Text(store.bluetoothDevices[index].name),
                              onPressed: () {
                                store.bluetoothDevices[index].connect();
                              });
                        })),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
