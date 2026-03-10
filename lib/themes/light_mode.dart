import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: const Color(0xFFF8FAFC), // Very soft slate
    primary: const Color(0xFF2563EB), // Strong blue
    secondary: Colors.white, // Pure white for cards
    tertiary: const Color(0xFFE2E8F0), // Border/Divider slate
    inversePrimary: const Color(0xFF0F172A), // Deep text/icons
  ),
  scaffoldBackgroundColor: const Color(0xFFF8FAFC),
);