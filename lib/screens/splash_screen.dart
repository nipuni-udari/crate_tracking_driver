import 'package:crate_tracking_driver/screens/vehicle_checking.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the fade-in animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // Navigate to LoginScreen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => VehicleScreen()),
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
      backgroundColor: Colors.white, // Set background color
      body: Stack(
        children: [
          // Background pattern (use an image if available)
          Positioned.fill(
            child: Opacity(
              opacity: 0.07, // Light opacity for background pattern
              child: Image.asset(
                'assets/images/background_pattern.jpg', // Add your food-themed pattern here
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisSize:
                  MainAxisSize
                      .min, // Minimize column size to fit children tightly
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Image.asset(
                    'assets/images/logo.png', // Use your crate image
                    width: 350,
                    height: 350,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
