import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/loginpage.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Find My Buddy',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        colorScheme: ColorScheme.dark(
          primary: Colors.greenAccent,
          onPrimary: Colors.white,
          secondary: Colors.greenAccent,
          onSecondary: Colors.white,
        ),
      ),
      home: LoginPage(),
    );
  }
}
