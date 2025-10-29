import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locale Provider - Dil Yönetimi
/// 
/// Kullanıcının seçtiği dili (Türkçe/İngilizce) yönetir ve
/// SharedPreferences'ta saklar.

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('tr'); // Varsayılan Türkçe
  
  Locale get locale => _locale;
  
  LocaleProvider() {
    _loadLocale();
  }
  
  /// SharedPreferences'tan kayıtlı dili yükle
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'tr';
    _locale = Locale(languageCode);
    debugPrint('🌍 [LocaleProvider] Dil yüklendi: $languageCode');
    notifyListeners();
  }
  
  /// Dili değiştir ve kaydet
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) {
      debugPrint('🌍 [LocaleProvider] Dil zaten aynı: ${locale.languageCode}');
      return;
    }
    
    debugPrint('🌍 [LocaleProvider] Dil değiştiriliyor: ${_locale.languageCode} -> ${locale.languageCode}');
    _locale = locale;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    debugPrint('🌍 [LocaleProvider] Dil kaydedildi: ${locale.languageCode}');
  }
  
  /// Türkçe'ye geç
  Future<void> setTurkish() async {
    debugPrint('🌍 [LocaleProvider] Türkçe\'ye geçiliyor...');
    await setLocale(const Locale('tr'));
  }
  
  /// İngilizce'ye geç
  Future<void> setEnglish() async {
    debugPrint('🌍 [LocaleProvider] İngilizce\'ye geçiliyor...');
    await setLocale(const Locale('en'));
  }
  
  /// Mevcut dil adını döndür (Türkçe / English)
  String get currentLanguageName {
    final name = _locale.languageCode == 'tr' ? 'Türkçe' : 'English';
    debugPrint('🌍 [LocaleProvider] Mevcut dil adı: $name (kod: ${_locale.languageCode})');
    return name;
  }
}
