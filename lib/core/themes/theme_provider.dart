import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';

enum AppThemeType {
  defaultTheme,
  modern,
  ocean,
  rose,
  forest,
  night,
}

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  AppThemeType _currentThemeType = AppThemeType.defaultTheme;
  
  ThemeProvider(this._prefs) {
    _loadTheme();
  }
  
  AppThemeType get currentThemeType => _currentThemeType;
  
  ThemeData get currentTheme => _buildTheme(_currentThemeType);
  
  void _loadTheme() {
    final themeIndex = _prefs.getInt('theme_index') ?? 0;
    _currentThemeType = AppThemeType.values[themeIndex];
    notifyListeners();
  }
  
  void setTheme(AppThemeType type) {
    _currentThemeType = type;
    _prefs.setInt('theme_index', type.index);
    notifyListeners();
  }
  
  ThemeData _buildTheme(AppThemeType type) {
    late Color primaryColor;
    late Color secondaryColor;
    late Color accentColor;
    late bool isDark;
    
    switch (type) {
      case AppThemeType.defaultTheme:
        primaryColor = AppColors.primaryDefault;
        secondaryColor = AppColors.secondaryDefault;
        accentColor = AppColors.accentDefault;
        isDark = false;
        break;
      case AppThemeType.modern:
        primaryColor = AppColors.primaryModern;
        secondaryColor = AppColors.secondaryModern;
        accentColor = AppColors.accentModern;
        isDark = true;
        break;
      case AppThemeType.ocean:
        primaryColor = AppColors.primaryOcean;
        secondaryColor = AppColors.secondaryOcean;
        accentColor = AppColors.accentOcean;
        isDark = false;
        break;
      case AppThemeType.rose:
        primaryColor = AppColors.primaryRose;
        secondaryColor = AppColors.secondaryRose;
        accentColor = AppColors.accentRose;
        isDark = false;
        break;
      case AppThemeType.forest:
        primaryColor = AppColors.primaryForest;
        secondaryColor = AppColors.secondaryForest;
        accentColor = AppColors.accentForest;
        isDark = true;
        break;
      case AppThemeType.night:
        primaryColor = AppColors.primaryNight;
        secondaryColor = AppColors.secondaryNight;
        accentColor = AppColors.accentNight;
        isDark = true;
        break;
    }
    
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
      ),
      scaffoldBackgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      cardColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      dividerColor: isDark ? AppColors.borderDark : AppColors.borderLight,
      
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        foregroundColor: isDark ? AppColors.textLight : AppColors.textDark,
        shadowColor: AppColors.shadow,
        scrolledUnderElevation: 4,
        titleTextStyle: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: AppColors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.white10 : Colors.black5,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        labelStyle: TextStyle(
          color: isDark ? AppColors.textLight.withOpacity(0.7) : AppColors.textSecondary,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          color: isDark ? AppColors.textLight.withOpacity(0.5) : AppColors.textSecondary.withOpacity(0.7),
          fontSize: 14,
        ),
      ),
      
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shadowColor: AppColors.shadow,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: primaryColor.withOpacity(0.1),
        deleteIconColor: primaryColor,
        disabledColor: AppColors.grey.withOpacity(0.1),
        selectedColor: primaryColor,
        secondarySelectedColor: secondaryColor,
        labelStyle: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textDark,
          fontSize: 14,
        ),
        secondaryLabelStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
        ),
        brightness: brightness,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        selectedItemColor: primaryColor,
        unselectedItemColor: AppColors.grey,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      dialogTheme: DialogTheme(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: isDark ? AppColors.textLight.withOpacity(0.8) : AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.darkGrey,
        contentTextStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: primaryColor.withOpacity(0.2),
        circularTrackColor: primaryColor.withOpacity(0.2),
      ),
      
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return AppColors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return AppColors.grey.withOpacity(0.3);
        }),
      ),
      
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(AppColors.white),
      ),
      
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return AppColors.grey;
        }),
      ),
      
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textDark,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        displayMedium: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textDark,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        displaySmall: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textDark,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        headlineLarge: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textDark,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        headlineMedium: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        headlineSmall: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        titleLarge: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
        titleMedium: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
        titleSmall: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
        bodyLarge: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textDark,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          fontFamily: 'Inter',
        ),
        bodyMedium: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textDark,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          fontFamily: 'Inter',
        ),
        bodySmall: TextStyle(
          color: isDark ? AppColors.textLight.withOpacity(0.7) : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          fontFamily: 'Inter',
        ),
        labelLarge: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        labelMedium: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textDark,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        labelSmall: TextStyle(
          color: isDark ? AppColors.textLight.withOpacity(0.7) : AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
  
  String getThemeName(AppThemeType type) {
    switch (type) {
      case AppThemeType.defaultTheme:
        return 'Varsayılan';
      case AppThemeType.modern:
        return 'Modern';
      case AppThemeType.ocean:
        return 'Okyanus';
      case AppThemeType.rose:
        return 'Gül';
      case AppThemeType.forest:
        return 'Orman';
      case AppThemeType.night:
        return 'Gece';
    }
  }
}