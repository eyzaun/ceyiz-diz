// Centralized Design System
// -------------------------
// Professional color palettes based on industry best practices
// Dark themes use neutral backgrounds with vibrant accent colors
//
// Highlights:
// - DesignPalette: carefully crafted color combinations per theme
// - DesignTokens: spacing, radii, elevation, durations, platform-aware alphas
// - AppSemanticColors: success/warning/danger/info colors
// - AppStatsColors: dedicated statistics tile colors
// - DesignSystem.themeFor: builds Material 3 ThemeData
//
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../constants/app_colors.dart';
import 'theme_provider.dart' show AppThemeType;

/// Semantic color layer for meaning-driven UI signals
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;

  const AppSemanticColors({
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
  });

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
  }) => AppSemanticColors(
        success: success ?? this.success,
        warning: warning ?? this.warning,
        danger: danger ?? this.danger,
        info: info ?? this.info,
      );

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
      info: Color.lerp(info, other.info, t) ?? info,
    );
  }
}

/// Statistics tile colors - decoupled from ColorScheme
@immutable
class AppStatsColors extends ThemeExtension<AppStatsColors> {
  final Color budget;
  final Color spent;
  final Color total;
  final Color completed;

  const AppStatsColors({
    required this.budget,
    required this.spent,
    required this.total,
    required this.completed,
  });

  @override
  AppStatsColors copyWith({
    Color? budget,
    Color? spent,
    Color? total,
    Color? completed,
  }) => AppStatsColors(
        budget: budget ?? this.budget,
        spent: spent ?? this.spent,
        total: total ?? this.total,
        completed: completed ?? this.completed,
      );

  @override
  AppStatsColors lerp(ThemeExtension<AppStatsColors>? other, double t) {
    if (other is! AppStatsColors) return this;
    return AppStatsColors(
      budget: Color.lerp(budget, other.budget, t) ?? budget,
      spent: Color.lerp(spent, other.spent, t) ?? spent,
      total: Color.lerp(total, other.total, t) ?? total,
      completed: Color.lerp(completed, other.completed, t) ?? completed,
    );
  }
}

/// Design palette with harmonious color combinations
class DesignPalette {
  final String name;
  final bool isDark;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color background;
  final Color surface;
  final Color outline;

  const DesignPalette({
    required this.name,
    required this.isDark,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.background,
    required this.surface,
    required this.outline,
  });
}

/// Reusable design tokens
class DesignTokens {
  // Radius - Modern and clean
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  // Spacing - Balanced and comfortable
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;

  // Elevation - Subtle depth
  static const double elev1 = 0;
  static const double elev2 = 1;
  static const double elev4 = 3;
  static const double elev8 = 6;

  // Animation durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);

  // Platform-aware alphas for statistics tiles
  static double get statsBgAlphaLight => kIsWeb ? 0.08 : 0.10;
  static double get statsBgAlphaDark => kIsWeb ? 0.15 : 0.18;
  static double get statsBorderAlpha => 0.25;

  // Typography with Inter font
  static TextTheme buildTextTheme(bool isDark) {
    final baseColor = isDark ? AppColors.textLight : AppColors.textDark;
    final secondaryColor = isDark
        ? AppColors.textLight.withValues(alpha: 0.7)
        : AppColors.textSecondary;
    
    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        color: baseColor,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        height: 1.1,
        letterSpacing: -0.8,
      ),
      displayMedium: TextStyle(
        color: baseColor,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        height: 1.15,
        letterSpacing: -0.6,
      ),
      displaySmall: TextStyle(
        color: baseColor,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        height: 1.2,
        letterSpacing: -0.4,
      ),
      
      // Headline styles
      headlineLarge: TextStyle(
        color: baseColor,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        height: 1.25,
        letterSpacing: -0.2,
      ),
      headlineMedium: TextStyle(
        color: baseColor,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        height: 1.3,
        letterSpacing: -0.1,
      ),
      headlineSmall: TextStyle(
        color: baseColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        height: 1.35,
        letterSpacing: 0,
      ),
      
      // Title styles
      titleLarge: TextStyle(
        color: baseColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        height: 1.4,
        letterSpacing: 0,
      ),
      titleMedium: TextStyle(
        color: baseColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        height: 1.45,
        letterSpacing: 0.05,
      ),
      titleSmall: TextStyle(
        color: baseColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        height: 1.5,
        letterSpacing: 0.1,
      ),
      
      // Body styles
      bodyLarge: TextStyle(
        color: baseColor,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
        height: 1.55,
        letterSpacing: 0.15,
      ),
      bodyMedium: TextStyle(
        color: baseColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
        height: 1.5,
        letterSpacing: 0.1,
      ),
      bodySmall: TextStyle(
        color: secondaryColor,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
        height: 1.45,
        letterSpacing: 0.1,
      ),
      
      // Label styles
      labelLarge: TextStyle(
        color: baseColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        letterSpacing: 0.2,
      ),
      labelMedium: TextStyle(
        color: baseColor,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        letterSpacing: 0.3,
      ),
      labelSmall: TextStyle(
        color: secondaryColor,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
        letterSpacing: 0.4,
      ),
    );
  }
}

class DesignSystem {
  // Professional color palettes inspired by industry standards
  // Dark themes use neutral gray backgrounds with vibrant accents
  static final Map<AppThemeType, DesignPalette> palettes = {
    // Standard Light Theme - Clean and professional
    AppThemeType.defaultTheme: const DesignPalette(
      name: 'Varsayılan',
      isDark: false,
      primary: Color(0xFF2563EB),        // Professional blue
      secondary: Color(0xFF3B82F6),      // Bright blue
      tertiary: Color(0xFF60A5FA),       // Light blue
      background: Color(0xFFF8FAFC),     // Very light gray-blue
      surface: Color(0xFFFFFFFF),        // Pure white
      outline: Color(0xFFE2E8F0),        // Soft gray border
    ),
    
    // Monochrome Dark Theme - Pure black, white and gray tones
    // True monochrome: only grayscale colors, no color hues
    AppThemeType.modern: const DesignPalette(
      name: 'Monokrom',
      isDark: true,
      primary: Color(0xFFFFFFFF),        // Pure white (primary text/accent)
      secondary: Color(0xFFB3B3B3),      // Light gray (secondary actions)
      tertiary: Color(0xFFCCCCCC),       // Lighter gray (tertiary elements)
      background: Color(0xFF000000),     // Pure black background
      surface: Color(0xFF1A1A1A),        // Dark gray surface (cards, etc.)
      outline: Color(0xFF333333),        // Medium gray border
    ),

    // Purple Dark Theme - Dark gray with purple accents
    // Inspired by Discord's color system
    AppThemeType.ocean: const DesignPalette(
      name: 'Mor Okyanus',
      isDark: true,
      primary: Color(0xFFA78BFA),        // Soft purple (desaturated)
      secondary: Color(0xFFC4B5FD),      // Light purple
      tertiary: Color(0xFFDDD6FE),       // Very light purple
      background: Color(0xFF0F0F14),     // Very dark gray
      surface: Color(0xFF1A1A23),        // Dark gray-purple tint
      outline: Color(0xFF2D2D3D),        // Subtle purple-gray border
    ),

    // Green Dark Theme - Dark gray with emerald accents
    // Inspired by Material Design with green tones
    AppThemeType.forest: const DesignPalette(
      name: 'Orman Yeşili',
      isDark: true,
      primary: Color(0xFF34D399),        // Emerald green (desaturated)
      secondary: Color(0xFF6EE7B7),      // Light emerald
      tertiary: Color(0xFFA7F3D0),       // Mint green
      background: Color(0xFF0A0E0D),     // Very dark gray
      surface: Color(0xFF1A1F1E),        // Dark gray-green tint
      outline: Color(0xFF2D3432),        // Subtle green-gray border
    ),

    // Sunset Gradient Theme - Warm and vibrant
    // Inspired by sunset colors: orange, pink, purple
    AppThemeType.sunset: const DesignPalette(
      name: 'Gün Batımı',
      isDark: true,
      primary: Color(0xFFF59E0B),        // Warm orange
      secondary: Color(0xFFEC4899),      // Pink
      tertiary: Color(0xFFA855F7),       // Purple
      background: Color(0xFF0F0A14),     // Very dark purple-tinted
      surface: Color(0xFF1A1420),        // Dark purple-gray
      outline: Color(0xFF3D2D45),        // Purple-tinted border
    ),
    
    // Backward compatibility aliases (deprecated)
    AppThemeType.rose: const DesignPalette(
      name: 'Monokrom (Eski)',
      isDark: true,
      primary: Color(0xFFFFFFFF),        // Pure white
      secondary: Color(0xFFB3B3B3),      // Light gray
      tertiary: Color(0xFFCCCCCC),       // Lighter gray
      background: Color(0xFF000000),     // Pure black
      surface: Color(0xFF1A1A1A),        // Dark gray surface
      outline: Color(0xFF333333),        // Medium gray border
    ),
    AppThemeType.night: const DesignPalette(
      name: 'Mor Okyanus (Eski)',
      isDark: true,
      primary: Color(0xFFA78BFA),
      secondary: Color(0xFFC4B5FD),
      tertiary: Color(0xFFDDD6FE),
      background: Color(0xFF0F0F14),
      surface: Color(0xFF1A1A23),
      outline: Color(0xFF2D2D3D),
    ),
  };

  static String nameFor(AppThemeType type) => palettes[type]?.name ?? 'Tema';

  static ThemeData themeFor(AppThemeType type) {
    final p = palettes[type] ?? palettes[AppThemeType.defaultTheme]!;
    final brightness = p.isDark ? Brightness.dark : Brightness.light;
    final onSurface = p.isDark ? AppColors.textLight : AppColors.textDark;

    final scheme = ColorScheme.fromSeed(
      seedColor: p.primary,
      brightness: brightness,
      primary: p.primary,
      secondary: p.secondary,
      tertiary: p.tertiary,
    ).copyWith(
      surface: p.surface,
      outline: p.outline,
      onPrimary: _onColorFor(p.primary),
      onSecondary: _onColorFor(p.secondary),
      onTertiary: _onColorFor(p.tertiary),
      onSurface: onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      cardColor: p.surface,
      dividerColor: p.outline,
      
      // Theme extensions
      extensions: <ThemeExtension<dynamic>>[
        AppSemanticColors(
          success: const Color(0xFF10B981),
          warning: const Color(0xFFF59E0B),
          danger: const Color(0xFFEF4444),
          info: p.primary,
        ),
        AppStatsColors(
          budget: scheme.primary,
          spent: scheme.secondary,
          total: scheme.tertiary,
          completed: const Color(0xFF10B981),
        ),
      ],

      // AppBar theme
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: p.background,
        foregroundColor: onSurface,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(
          color: onSurface,
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: onSurface,
          size: 24,
        ),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: _onColorFor(p.primary),
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          minimumSize: const Size(100, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            letterSpacing: 0.3,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.black.withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.hovered)) {
              return Colors.black.withValues(alpha: 0.05);
            }
            return null;
          }),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.primary,
          side: BorderSide(color: p.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          minimumSize: const Size(100, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            letterSpacing: 0.3,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return p.primary.withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.hovered)) {
              return p.primary.withValues(alpha: 0.05);
            }
            return null;
          }),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          minimumSize: const Size(64, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            letterSpacing: 0.2,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return p.primary.withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.hovered)) {
              return p.primary.withValues(alpha: 0.05);
            }
            return null;
          }),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.isDark 
            ? p.surface.withValues(alpha: 0.6)
            : p.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide(color: p.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide(color: p.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide(color: p.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(
            color: Color(0xFFEF4444),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(
            color: Color(0xFFEF4444),
            width: 2,
          ),
        ),
        labelStyle: TextStyle(
          color: p.isDark
              ? AppColors.textLight.withValues(alpha: 0.7)
              : AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
        floatingLabelStyle: TextStyle(
          color: p.primary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        hintStyle: TextStyle(
          color: p.isDark
              ? AppColors.textLight.withValues(alpha: 0.4)
              : AppColors.textSecondary.withValues(alpha: 0.6),
          fontSize: 14,
          fontFamily: 'Inter',
        ),
        prefixIconColor: p.isDark
            ? AppColors.textLight.withValues(alpha: 0.6)
            : AppColors.textSecondary,
        suffixIconColor: p.isDark
            ? AppColors.textLight.withValues(alpha: 0.6)
            : AppColors.textSecondary,
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: p.isDark ? DesignTokens.elev1 : DesignTokens.elev2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          side: BorderSide(
            color: p.outline.withValues(alpha: p.isDark ? 0.3 : 0.5),
            width: 1,
          ),
        ),
        color: p.surface,
        shadowColor: p.isDark 
            ? Colors.black.withValues(alpha: 0.4)
            : Colors.black.withValues(alpha: 0.06),
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: p.primary.withValues(alpha: 0.12),
        deleteIconColor: p.primary,
        disabledColor: p.outline.withValues(alpha: 0.15),
        selectedColor: p.primary,
        secondarySelectedColor: p.secondary,
        labelStyle: TextStyle(
          color: onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
          letterSpacing: 0.15,
        ),
        secondaryLabelStyle: TextStyle(
          color: _onColorFor(p.primary),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
          letterSpacing: 0.15,
        ),
        brightness: brightness,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        side: BorderSide.none,
      ),

      // Bottom navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: p.surface,
        selectedItemColor: p.primary,
        unselectedItemColor: onSurface.withValues(alpha: 0.5),
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
          letterSpacing: 0.15,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: p.isDark ? 0 : 6,
        selectedIconTheme: IconThemeData(
          color: p.primary,
          size: 26,
        ),
        unselectedIconTheme: IconThemeData(
          color: onSurface.withValues(alpha: 0.5),
          size: 24,
        ),
      ),

      // FAB theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: _onColorFor(p.primary),
        elevation: DesignTokens.elev4,
        focusElevation: DesignTokens.elev4,
        hoverElevation: DesignTokens.elev8,
        highlightElevation: DesignTokens.elev8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
        iconSize: 24,
        extendedPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        extendedTextStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
          letterSpacing: 0.2,
        ),
      ),

      // SnackBar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.isDark 
            ? p.surface.withValues(alpha: 0.95)
            : const Color(0xFF1F2937),
        contentTextStyle: TextStyle(
          color: p.isDark 
              ? AppColors.textLight 
              : Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: DesignTokens.elev4,
        actionTextColor: p.primary,
      ),

      // Progress indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.primary,
        linearTrackColor: p.outline.withValues(alpha: 0.25),
        circularTrackColor: p.outline.withValues(alpha: 0.25),
        linearMinHeight: 5,
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return p.isDark 
                ? AppColors.textDark 
                : Colors.white;
          }
          if (states.contains(WidgetState.disabled)) {
            return p.outline.withValues(alpha: 0.4);
          }
          return p.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return p.primary;
          }
          if (states.contains(WidgetState.disabled)) {
            return p.outline.withValues(alpha: 0.15);
          }
          return p.outline.withValues(alpha: 0.4);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return p.primary;
          }
          if (states.contains(WidgetState.disabled)) {
            return p.outline.withValues(alpha: 0.25);
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(_onColorFor(p.primary)),
        side: BorderSide(
          color: p.outline,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        visualDensity: VisualDensity.comfortable,
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return p.primary;
          }
          if (states.contains(WidgetState.disabled)) {
            return p.outline.withValues(alpha: 0.25);
          }
          return p.outline;
        }),
        visualDensity: VisualDensity.comfortable,
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: p.outline.withValues(alpha: 0.3),
        thickness: 1,
        space: 1,
      ),

      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: p.primary,
        inactiveTrackColor: p.outline.withValues(alpha: 0.25),
        thumbColor: p.primary,
        overlayColor: p.primary.withValues(alpha: 0.1),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 9,
        ),
        overlayShape: const RoundSliderOverlayShape(
          overlayRadius: 18,
        ),
      ),

      // Tooltip theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.isDark
              ? const Color(0xFF1F2937)
              : const Color(0xFF374151),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        iconColor: onSurface.withValues(alpha: 0.7),
        textColor: onSurface,
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        subtitleTextStyle: TextStyle(
          color: p.isDark
              ? AppColors.textLight.withValues(alpha: 0.7)
              : AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          fontFamily: 'Inter',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
      ),

      // Text theme
      textTheme: DesignTokens.buildTextTheme(p.isDark),
    );
  }

  /// Helper to pick legible on-color (light/dark) for background
  static Color _onColorFor(Color c) =>
      c.computeLuminance() > 0.5 ? AppColors.textDark : AppColors.textLight;
}