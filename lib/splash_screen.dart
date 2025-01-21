import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:landmarkcoop_mobile_app/main_view.dart';
import 'package:landmarkcoop_mobile_app/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_animations/animation_builder/mirror_animation_builder.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
   startTimer();
    super.initState();
  }

  void startTimer() async{
    final prefs = await SharedPreferences.getInstance();
    bool isLoginPage = prefs.getBool('atLoginPage') ?? false;

    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => isLoginPage ? const MainView() : const OnboardingScreen(),
        ),
      );
    });

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xff045d5d),
      backgroundColor: Colors.white,
      body: Center(
        child: MirrorAnimationBuilder<double>(
          tween: Tween(begin: -100.0, end: 100.0),
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOutSine,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(value, 0),
              child: child,
            );
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/Logo.png'),
                  fit: BoxFit.contain
              ),
            ),
          ),
        ),
      ),
    );
  }
}