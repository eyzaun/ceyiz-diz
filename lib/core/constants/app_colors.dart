import 'package:flutter/material.dart';

class AppColors {
  // Default Theme Colors
  static const Color primaryDefault = Color(0xFF6B4EFF);
  static const Color secondaryDefault = Color(0xFFFF6B9D);
  static const Color accentDefault = Color(0xFF00C896);
  
  // Modern Theme Colors  
  static const Color primaryModern = Color(0xFF2D3436);
  static const Color secondaryModern = Color(0xFF00B894);
  static const Color accentModern = Color(0xFFFDCB6E);
  
  // Ocean Theme Colors
  static const Color primaryOcean = Color(0xFF006BA6);
  static const Color secondaryOcean = Color(0xFF0496FF);
  static const Color accentOcean = Color(0xFF59C3C3);
  
  // Rose Theme Colors
  static const Color primaryRose = Color(0xFFE84855);
  static const Color secondaryRose = Color(0xFFF9B4AB);
  static const Color accentRose = Color(0xFFFDEEF4);
  
  // Forest Theme Colors
  static const Color primaryForest = Color(0xFF2D5016);
  static const Color secondaryForest = Color(0xFF73AB84);
  static const Color accentForest = Color(0xFFA2D5AB);
  
  // Night Theme Colors
  static const Color primaryNight = Color(0xFF1A1A2E);
  static const Color secondaryNight = Color(0xFF16213E);
  static const Color accentNight = Color(0xFFEF4F4F);
  
  // Common Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF424242);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF000000);
  
  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);
  
  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x40000000);
}

/// Extension for Color to add helper methods
extension ColorExtension on Color {
  /// Converts Color to ARGB32 integer value (compatible with Firestore)
  int toARGB32() {
    return (a * 255).round() << 24 |
           (r * 255).round() << 16 |
           (g * 255).round() << 8 |
           (b * 255).round();
  }
}