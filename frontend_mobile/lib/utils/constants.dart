import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = "SmartVote";
  
  // Replace with your local IP if running on a physical device
  // 10.0.2.2 is the alias for localhost in Android Emulator
  static const String baseUrl = "http://10.38.62.133:5000/api";
  
  // Institutional Palette
  static const Color primaryBlue = Color(0xFF2563EB); // Sovereign Blue
  static const Color navy = Color(0xFF0F172A); // Institutional Navy
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF0F172A);
  static const Color textSlate = Color(0xFF475569);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color success = Color(0xFF10B981);
  static const Color accent = Color(0xFFF59E0B); // Gold Accents for authority
  
  // Design Tokens
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double radius = 24.0; // More rounded for modern premium feel
  
  // Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.04),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
