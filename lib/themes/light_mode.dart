import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Color(0xFFF8FAFC), // Very soft slate
    primary: Color(0xFF2563EB), // Strong blue
    secondary: Colors.white, // Pure white for cards
    tertiary: Color(0xFFE2E8F0), // Border/Divider slate
    inversePrimary: Color(0xFF0F172A), // Deep text/icons
  ),
  scaffoldBackgroundColor: Color(0xFFF8FAFC),
);