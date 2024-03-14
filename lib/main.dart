import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importa el paquete SystemChrome
import 'IntroductionScreen.dart';
import 'package:camera/camera.dart';

// List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // cameras = await availableCameras();
  runApp(MyApp());
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PEDIASURE IA IMG',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: IntroductionScreen(),
    );
  }
}
