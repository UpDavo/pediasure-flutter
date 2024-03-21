import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'IntroductionScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  runApp(MyApp());
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
