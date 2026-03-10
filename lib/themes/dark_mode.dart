import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: const Color(0xFF0F172A), // Deep Slate/Black
    primary: const Color(0xFF3B82F6), // Vibrant Blue
    secondary: const Color(0xFF1E293B), // Lighter Slate for cards
    tertiary: const Color(0xFF2D3748), // Highlight Slate
    inversePrimary: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFF0F172A),
);