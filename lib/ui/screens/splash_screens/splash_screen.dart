import 'dart:async'; // for the timer shot

import 'package:chat_app/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _setupNavigation();
  }

  void _setupNavigation() {
    _timer = Timer(
      const Duration(seconds: 3),
      () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, wrapper);
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            frame,
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Center(
            child: Image.asset(
              logo,
              height: 170.h,
              width: 170.h,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
