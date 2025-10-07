import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
	AppTheme._();

	static ThemeData light() {
		final colorScheme = ColorScheme.fromSeed(
			seedColor: AppColors.primaryDefault,
			brightness: Brightness.light,
		);

		return ThemeData(
			useMaterial3: true,
			colorScheme: colorScheme,
			scaffoldBackgroundColor: AppColors.backgroundLight,
			appBarTheme: const AppBarTheme(centerTitle: true),
		);
	}

	static ThemeData dark() {
		final colorScheme = ColorScheme.fromSeed(
			seedColor: AppColors.primaryNight,
			brightness: Brightness.dark,
		);

		return ThemeData(
			useMaterial3: true,
			colorScheme: colorScheme,
			scaffoldBackgroundColor: AppColors.backgroundDark,
			appBarTheme: const AppBarTheme(centerTitle: true),
		);
	}
}

