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
    var loaded = AppThemeType.values[themeIndex];
    // Map old themes to new palettes to keep selection valid in UI
    if (loaded == AppThemeType.rose) {
      loaded = AppThemeType.modern; // Gece Mavisi
    } else if (loaded == AppThemeType.night) {
      loaded = AppThemeType.ocean; // Monokrom
    }
    _currentThemeType = loaded;
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
    // Per-theme surfaces
    late Color backgroundColor;
    late Color surfaceColor;
    late Color borderColor;
    
    switch (type) {
      case AppThemeType.defaultTheme:
        primaryColor = AppColors.primaryDefault;
        secondaryColor = AppColors.secondaryDefault;
        accentColor = AppColors.accentDefault;
        isDark = false;
        backgroundColor = AppColors.backgroundLight;
        surfaceColor = AppColors.surfaceLight;
        borderColor = AppColors.borderLight;
        break;
      case AppThemeType.modern:
        // Midnight Blue (dark)
        primaryColor = const Color(0xFF3B82F6); // primary action
        secondaryColor = const Color(0xFF60A5FA); // links
        accentColor = const Color(0xFF334155); // tertiary/accent
        isDark = true;
        backgroundColor = const Color(0xFF0F172A); // bg
        surfaceColor = const Color(0xFF1E293B); // card
        borderColor = const Color(0xFF334155); // border
        break;
      case AppThemeType.ocean:
        // Monochrome Dark (pure black system)
        primaryColor = const Color(0xFFFFFFFF); // CTA on black
        secondaryColor = const Color(0xFFCCCCCC);
        accentColor = const Color(0xFF1A1A1A);
        isDark = true;
        backgroundColor = const Color(0xFF000000); // pure black
        surfaceColor = const Color(0xFF0A0A0A); // cards
        borderColor = const Color(0xFF1A1A1A);
        break;
      case AppThemeType.rose:
        // Use Midnight Blue palette as an alternative to previous Rose
        primaryColor = const Color(0xFF3B82F6);
        secondaryColor = const Color(0xFF60A5FA);
        accentColor = const Color(0xFF334155);
        isDark = true;
        backgroundColor = const Color(0xFF0F172A);
        surfaceColor = const Color(0xFF1E293B);
        borderColor = const Color(0xFF334155);
        break;
      case AppThemeType.forest:
        primaryColor = AppColors.primaryForest;
        secondaryColor = AppColors.secondaryForest;
        accentColor = AppColors.accentForest;
        isDark = true;
        backgroundColor = AppColors.backgroundDark;
        surfaceColor = AppColors.surfaceDark;
        borderColor = AppColors.borderDark;
        break;
      case AppThemeType.night:
        // Monochrome (dark)
        primaryColor = const Color(0xFFFFFFFF);
        secondaryColor = const Color(0xFFCCCCCC);
        accentColor = const Color(0xFF1A1A1A);
        isDark = true;
        backgroundColor = const Color(0xFF000000);
        surfaceColor = const Color(0xFF0A0A0A);
        borderColor = const Color(0xFF1A1A1A);
        break;
    }
    
  final brightness = isDark ? Brightness.dark : Brightness.light;
  Color _onColorFor(Color c) => c.computeLuminance() > 0.5 ? AppColors.textDark : AppColors.textLight;
  final onPrimaryColor = _onColorFor(primaryColor);
  final onSecondaryColor = _onColorFor(secondaryColor);
  final onTertiaryColor = _onColorFor(accentColor);
  final onSurfaceColor = isDark ? AppColors.textLight : AppColors.textDark;
  final onBackgroundColor = onSurfaceColor;
    
    final baseScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
    ).copyWith(
      surface: surfaceColor,
      background: backgroundColor,
      outline: borderColor,
      onPrimary: onPrimaryColor,
      onSecondary: onSecondaryColor,
      onTertiary: onTertiaryColor,
      onSurface: onSurfaceColor,
      onBackground: onBackgroundColor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: baseScheme,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      dividerColor: borderColor,
      
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: surfaceColor,
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
          foregroundColor: onPrimaryColor,
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
        fillColor: isDark ? Colors.white10 : const Color(0x0D000000),
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
      
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: surfaceColor,
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
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: onSurfaceColor.withValues(alpha: 0.6),
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
        foregroundColor: onPrimaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
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
        backgroundColor: isDark ? surfaceColor : AppColors.darkGrey,
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
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return AppColors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return AppColors.grey.withOpacity(0.3);
        }),
      ),
      
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
      ),
      
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
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
        return 'Gece Mavisi'; // Midnight Blue
      case AppThemeType.ocean:
        return 'Monokrom'; // Monochrome
      case AppThemeType.rose:
        return 'Gece Mavisi';
      case AppThemeType.forest:
        return 'Orman';
      case AppThemeType.night:
        return 'Monokrom';
    }
  }
}