import 'package:flutter/material.dart';
import "package:velocity_x/velocity_x.dart";
import 'package:flutter_blue/flutter_blue.dart'


void main() {
  runApp(VxState(
    store: MyStore(),
    child: MyApp(),
  ));
}

// Store definition
class MyStore extends VxStore {
  int count = 0;
}

// Store Mutations
class Increment extends VxMutation<MyStore> {
  perform() => store.count++;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Define when this widget should re render
    VxState.watch(context, on: [Increment]);

    // Get access to the store
    MyStore store = VxState.store;

    // Obtain an instance of FlutterBlue
    FlutterBlue flutterBlue = FlutterBlue.instance;

    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: <Widget>[
            Text("Count: ${store.count}"),
            TextButton(
              child: const Text('Increment'),
              onPressed: () {
                // Invoke mutation
                Increment();
              },
            ),
          ],
        ),
      ),
    );
  }
}
