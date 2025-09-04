import 'package:flutter/material.dart';
import 'package:pos/users/authenticaton/login_screen.dart';

import 'package:get/get.dart';
import 'package:pos/users/authenticaton/signup_screen.dart';
import 'package:pos/users/fragments/dashboard.dart';
import 'package:pos/users/userPreferences/user_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Point of Sale',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      navigatorKey: Get.key, // Tambahkan navigatorKey
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: RememeberUserPrefs.readUserInfo(),
        builder: (context, dataSnapShot) {
          if (dataSnapShot.data == null) {
            return LoginScreen();
          } else {
            return Dashboard();
          }
        },
      ),
    );
  }
}
