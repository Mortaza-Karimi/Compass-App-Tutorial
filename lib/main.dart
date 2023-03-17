import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Compass App',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool hasPermission = false;

  void fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      setState(() {
        hasPermission = status == PermissionStatus.granted;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchPermissionStatus();
  }

  Widget buildCompass() {
    return Center(
      child: StreamBuilder<CompassEvent>(
          stream: FlutterCompass.events,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error : ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            double? direction = snapshot.data!.heading;

            if (direction == null) {
              return const Text('this Device does not have sensor!');
            }

            return Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              margin: const EdgeInsets.all(60),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.teal[600],
                boxShadow: [
                  BoxShadow(
                      color: Colors.teal.shade800,
                      offset: const Offset(4.0, 4.0),
                      blurRadius: 15.0,
                      spreadRadius: 1.0),
                  BoxShadow(
                      color: Colors.teal.shade500,
                      offset: const Offset(-4.0, -4.0),
                      blurRadius: 15.0,
                      spreadRadius: 1.0),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.teal.shade500,
                    Colors.teal.shade600,
                    Colors.teal.shade700,
                    Colors.teal.shade800,
                  ],
                  stops: const [0.1, 0.3, 0.8, 1],
                ),
              ),
              child: Transform.rotate(
                angle: (direction * (pi / 180) * -1),
                child: Image.asset(
                  'assets/compass.png',
                  color: Colors.white,
                  height: MediaQuery.of(context).size.width,
                  fit: BoxFit.fill,
                ),
              ),
            );
          }),
    );
  }

  Widget buildRequestPermission() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Permission.locationWhenInUse.request().then((_) {
            fetchPermissionStatus();
          });
        },
        child: const Text('Request Permission'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[600],
      body: Builder(
        builder: (context) {
          if (hasPermission) {
            return buildCompass();
          } else {
            return buildRequestPermission();
          }
        },
      ),
    );
  }
}
