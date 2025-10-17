import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'design_system.dart';

enum AppThemeType {
  defaultTheme,
  modern,
  ocean,
  forest,
  sunset,
  // Backward compatibility - deprecated
  rose,
  night,
}

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  AppThemeType _currentThemeType = AppThemeType.defaultTheme;
  
  ThemeProvider(this._prefs) {
    _loadTheme();
  }
  
  AppThemeType get currentThemeType => _currentThemeType;
  
  ThemeData get currentTheme => DesignSystem.themeFor(_currentThemeType);
  
  void _loadTheme() {
    final themeIndex = _prefs.getInt('theme_index');

    // Eğer daha önce tema seçilmemişse, sistem temasına göre varsayılanı belirle
    if (themeIndex == null) {
      // Sistem temasını kontrol et
      final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;

      if (brightness == Brightness.dark) {
        // Koyu tema kullanıyorsa -> Monokrom (modern)
        _currentThemeType = AppThemeType.modern;
      } else {
        // Açık tema kullanıyorsa -> Default
        _currentThemeType = AppThemeType.defaultTheme;
      }

      // İlk kez belirlenen temayı kaydet
      _prefs.setInt('theme_index', _currentThemeType.index);
    } else {
      // Daha önce seçilmiş tema varsa onu kullan
      var loaded = AppThemeType.values[themeIndex];
      // Map old themes to new palettes to keep selection valid in UI
      if (loaded == AppThemeType.rose) {
        loaded = AppThemeType.modern; // Gece Mavisi
      } else if (loaded == AppThemeType.night) {
        loaded = AppThemeType.ocean; // Monokrom
      }
      _currentThemeType = loaded;
    }

    notifyListeners();
  }
  
  void setTheme(AppThemeType type) {
    _currentThemeType = type;
    _prefs.setInt('theme_index', type.index);
    notifyListeners();
  }
  
  // Legacy API kept for compatibility in case of external usage
  // ignore: unused_element
  ThemeData _buildTheme(AppThemeType type) => DesignSystem.themeFor(type);
  
  String getThemeName(AppThemeType type) {
    switch (type) {
      case AppThemeType.defaultTheme:
      case AppThemeType.modern:
      case AppThemeType.ocean:
      case AppThemeType.forest:
      case AppThemeType.sunset:
      case AppThemeType.rose:
      case AppThemeType.night:
        return DesignSystem.nameFor(type);
    }
  }
}