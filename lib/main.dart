import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() => runApp(const HumidityMeterApp());

class HumidityMeterApp extends StatelessWidget {
  const HumidityMeterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HumidityMeter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070A12),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          secondary: Color(0xFFF472B6),
          surface: Color(0xFF111827),
        ),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}