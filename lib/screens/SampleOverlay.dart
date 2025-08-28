import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart'
    as FlutterOverlayApps
    show showOverlay;

import 'TopScreen.dart';

class SampleOverlay extends StatelessWidget {
  const SampleOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              // Open overlay
              FlutterOverlayApps.showOverlay((context, progress,) {
                return const TopScreen();
              },

                  duration: const Duration(hours: 2),

              );

              // send data to ovelay
              // await Future.delayed(const Duration(seconds: 22));
              /* FlutterOverlayApps.sendDataToAndFromOverlay("Hello from main app");*/
            },
            child: const Text("showOverlay"),
          ),
        ),
      ),
    );
  }
}

class MyOverlaContent extends StatefulWidget {
  const MyOverlaContent({Key? key}) : super(key: key);

  @override
  State<MyOverlaContent> createState() => _MyOverlaContentState();
}

class _MyOverlaContentState extends State<MyOverlaContent> {
  final String _dataFromApp = "Hey send data";

  @override
  void initState() {
    super.initState();

    // lisent for any data from the main app
    /* FlutterOverlayApps.overlayListener().listen((event) {
      setState(() {
        _dataFromApp = event.toString();
      });
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          // close overlay
          // FlutterOverlayApps.closeOverlay();
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              _dataFromApp,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}
