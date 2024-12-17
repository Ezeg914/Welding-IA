import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:welding/home_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'welding-app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 4, 110, 172)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}