// ignore_for_file: avoid_web_libraries_in_flutter
// ignore_for_file: deprecated_member_use
import 'dart:html' as html;

/// Web-specific implementation of force reload
void forceReloadWeb() {
  // Service Worker'ı temizle
  html.window.navigator.serviceWorker?.getRegistrations().then((registrations) {
    for (var registration in registrations) {
      registration.unregister();
    }
  });

  // Cache'i temizle ve hard reload
  html.window.location.reload();
}
