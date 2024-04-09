import 'package:flutter/material.dart';
import 'package:flutter_app/screens/splash_screen.dart';
import 'package:flutter_app/utils/home_controller.dart';
import 'package:get/get.dart';


void main() {
  // Initialize HomeController
  Get.put(HomeController());

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Move ID",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: SplashScreen(), // Show splash screen initially
    );
  }
}

