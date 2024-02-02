import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_task/pages/authentications/login.dart';
import 'package:flutter_task/pages/home.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return initScreen(context);
  }

  startTime() async {
    var duration = const Duration(seconds: 5);
    return Timer(duration, route);
  }

  route() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String uuid = prefs.getString('uuid') ?? " ";
    print("Is User Already Logged in :  $isLoggedIn");
    print("User  :  $uuid");
    Navigator.pop(context);
    Get.to(
      () => isLoggedIn == false ? const Login() : const Home(),
    );
  }

  initScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Image.asset('assets/images/Instagram_logo.png'))
        ],
      ),
    );
  }
}
