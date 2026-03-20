import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double progress = 0;

  @override
  void initState() {
    super.initState();
    startLoading();
  }

  void startLoading() {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        progress += 0.01;
      });

      if (progress >= 1) {
        timer.cancel();
        Navigator.pushReplacementNamed(context, "/home");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [

            const Spacer(),

            Image.asset(
              "assets/logo.png",
              width: 120,
            ),

            const SizedBox(height: 20),

            const Text(
              "TEPETL",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "APRENDE NÁHUATL",
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Cargando TEPETL"),
                Text("${(progress * 100).toInt()}%"),
              ],
            ),

            const SizedBox(height: 10),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "v0.0.0",
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}