library;

/// Version Update Service
///
/// Bu servis web uygulamasının güncel olup olmadığını kontrol eder
/// ve iOS Safari gibi aggressive cache yapan tarayıcılarda
/// kullanıcıyı yeni versiyona yönlendirir.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'version_service_stub.dart'
    if (dart.library.html) 'version_service_web.dart';

class VersionService {
  static const String _lastCheckKey = 'version_last_check';
  static const String _skipVersionKey = 'version_skip_version';
  
  // Minimum 4 saat aralıkla kontrol yap
  static const Duration _checkInterval = Duration(hours: 4);

  /// Firestore'dan minimum required version'ı çeker
  /// Document: config/app_version
  /// Fields: { version: "1.0.17", forceUpdate: false }
  static Future<VersionCheckResult> checkVersion() async {
    // Sadece web için çalışır
    if (!kIsWeb) {
      return VersionCheckResult(
        isUpToDate: true,
        currentVersion: '',
        latestVersion: '',
        forceUpdate: false,
      );
    }

    try {
      // Last check zamanını kontrol et
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt(_lastCheckKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Çok sık kontrol etme (4 saatte bir)
      if (now - lastCheck < _checkInterval.inMilliseconds) {
        return VersionCheckResult(
          isUpToDate: true,
          currentVersion: '',
          latestVersion: '',
          forceUpdate: false,
        );
      }

      // Mevcut versiyon
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Firestore'dan latest version çek (app_versions/latest)
      final doc = await FirebaseFirestore.instance
          .collection('app_versions')
          .doc('latest')
          .get();

      if (!doc.exists) {
        // Config yoksa güncel kabul et
        await prefs.setInt(_lastCheckKey, now);
        return VersionCheckResult(
          isUpToDate: true,
          currentVersion: currentVersion,
          latestVersion: currentVersion,
          forceUpdate: false,
        );
      }

      final data = doc.data()!;
      final latestVersion = data['version'] as String? ?? currentVersion;
      final forceUpdate = data['forceUpdate'] as bool? ?? false;
      final updateMessage = data['updateMessage'] as String? ?? 
          'Yeni bir versiyon mevcut! Güncellemek ister misiniz?';

      // Son kontrol zamanını güncelle
      await prefs.setInt(_lastCheckKey, now);

      // Version karşılaştırması
      final isUpToDate = _compareVersions(currentVersion, latestVersion) >= 0;

      // Kullanıcı bu versiyonu skip ettiyse ve force update değilse
      if (!forceUpdate) {
        final skippedVersion = prefs.getString(_skipVersionKey);
        if (skippedVersion == latestVersion && !isUpToDate) {
          // Skip edilmiş, şimdilik gösterme
          return VersionCheckResult(
            isUpToDate: true, // Skip edildiği için "güncel" gibi davran
            currentVersion: currentVersion,
            latestVersion: latestVersion,
            forceUpdate: false,
          );
        }
      }

      return VersionCheckResult(
        isUpToDate: isUpToDate,
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        forceUpdate: forceUpdate,
        updateMessage: updateMessage,
      );
    } catch (e) {
      // Hata durumunda güncel kabul et
      return VersionCheckResult(
        isUpToDate: true,
        currentVersion: '',
        latestVersion: '',
        forceUpdate: false,
      );
    }
  }

  /// Kullanıcı bu versiyonu skip etmek istediğinde
  static Future<void> skipVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_skipVersionKey, version);
  }

  /// Hard reload yapar (iOS Safari cache'i temizler)
  static void forceReload() {
    if (kIsWeb) {
      forceReloadWeb();
    }
  }

  /// Version string'lerini karşılaştırır
  /// Returns: 1 if v1 > v2, -1 if v1 < v2, 0 if equal
  static int _compareVersions(String v1, String v2) {
    final v1Parts = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final v2Parts = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      final v1Part = i < v1Parts.length ? v1Parts[i] : 0;
      final v2Part = i < v2Parts.length ? v2Parts[i] : 0;

      if (v1Part > v2Part) return 1;
      if (v1Part < v2Part) return -1;
    }

    return 0;
  }
}

class VersionCheckResult {
  final bool isUpToDate;
  final String currentVersion;
  final String latestVersion;
  final bool forceUpdate;
  final String updateMessage;

  VersionCheckResult({
    required this.isUpToDate,
    required this.currentVersion,
    required this.latestVersion,
    required this.forceUpdate,
    this.updateMessage = 'Yeni bir versiyon mevcut! Güncellemek ister misiniz?',
  });

  bool get needsUpdate => !isUpToDate;
}
