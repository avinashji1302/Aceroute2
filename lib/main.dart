import 'package:ace_routes/view/home_screen.dart';
import 'package:ace_routes/view/login_screen.dart';
import 'package:ace_routes/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/fontSizeController.dart';

void main() {
  // Initialize FFI for sqflite
  // sqfliteFfiInit();
  // databaseFactory = databaseFactoryFfi; // This is crucial
  // print("SQLite initialized using FFI");

  Get.put(FontSizeController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginScreen(),
      // home:  HomeScreen(),
    );
  }
}
