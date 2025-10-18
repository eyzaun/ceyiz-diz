# Firebase Web Version Update Sistemi

## 📋 Kurulum Adımları

### 1. Firestore'da Version Document Oluştur

Firebase Console → Firestore Database → `app_versions` koleksiyonu → `latest` dokümanı:

**Mevcut Yapı (Zaten Var):**
```json
{
  "buildNumber": 24,
  "forceUpdate": true,
  "lastUpdated": "October 13, 2025 at 1:59:59 AM UTC+3",
  "updateMessage": "Uygulamanın yeni bir versiyonu mevcut. Lütfen Play store'dan güncel sürümü indiriniz",
  "version": "1.0.17"
}
```

**Güncellenmiş Yapı (Web için optimize):**
```json
{
  "buildNumber": 24,
  "forceUpdate": false,
  "lastUpdated": "October 18, 2025 at 5:00:00 PM UTC+3",
  "updateMessage": "Yeni özellikler ve iyileştirmeler! Güncellemek ister misiniz?",
  "version": "1.0.17"
}
```

**Field Açıklaması:**
- `version`: Versiyon string (örn: "1.0.17")
- `buildNumber`: Build numarası (örn: 24)
- `forceUpdate`: Zorunlu güncelleme mi? (true/false)
- `updateMessage`: Kullanıcıya gösterilecek mesaj
- `lastUpdated`: Son güncelleme zamanı (otomatik timestamp)

### 2. Yeni Versiyon Yayınlama

Her yeni versiyon release ettiğinde:

1. **`pubspec.yaml`** version güncelle:
   ```yaml
   version: 1.0.18+25  # Yeni versiyon
   ```

2. **Firestore `app_versions/latest`** güncelle:
   ```json
   {
     "version": "1.0.18",
     "buildNumber": 25,
     "forceUpdate": false,
     "updateMessage": "🎉 Yeni özellikler eklendi! Lütfen güncelleyin.",
     "lastUpdated": "October 18, 2025 at 5:30:00 PM UTC+3"
   }
   ```

3. **Build & Deploy**:
   ```bash
   flutter build web --release
   firebase deploy --only hosting
   ```

## 🔧 Sistem Nasıl Çalışır?

### Web Cache Busting (3 Katman)

1. **HTTP Headers** (`firebase.json`):
   - `index.html`: `no-cache, no-store, must-revalidate`
   - `flutter_service_worker.js`: `no-cache`
   - `manifest.json`: `no-cache`

2. **HTML Meta Tags** (`web/index.html`):
   ```html
   <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
   <meta http-equiv="Pragma" content="no-cache">
   <meta http-equiv="Expires" content="0">
   ```

3. **Service Worker Cleanup** (`version_service_web.dart`):
   - Eski service worker'ları temizler
   - Hard reload yapar
   - iOS Safari cache'ini bypass eder

### Version Check Flow

```
App Başlatılıyor
    ↓
4 saniye bekle (tam yüklensin)
    ↓
VersionService.checkVersion()
    ↓
Firestore: app_versions/latest → oku
    ↓
currentVersion vs latestVersion karşılaştır
    ↓
Güncelleme gerekli mi?
    ↓ (Evet)
UpdateAvailableDialog göster
    ↓
Kullanıcı "Güncelle" butonuna basarsa
    ↓
Service Worker temizle
    ↓
Hard Reload → Yeni versiyon yüklenir
```

## 📱 iOS Safari İçin Özel Çözümler

### Problem: Aggressive Caching
- iOS Safari çok agresif cache yapar
- PWA olarak eklenen uygulamalar daha da sorunlu
- Normal "Yenile" butonu çalışmaz

### Çözüm: Multi-Layer Approach

1. **Meta Tags** → HTML düzeyinde cache engelleme
2. **HTTP Headers** → Sunucu düzeyinde cache engelleme
3. **Service Worker Cleanup** → Browser storage temizleme
4. **Hard Reload** → `window.location.reload()`

### Test Etmek İçin

iOS Safari'de:
1. Ayarlar → Safari → Gelişmiş → Website Data → Temizle
2. Uygulamayı tamamen kapat (swipe up)
3. Tekrar aç
4. 4-5 saniye sonra güncelleme dialog'u görmeli

## 🎯 forceUpdate Kullanımı

### Normal Update (forceUpdate: false)
```json
{
  "version": "1.0.18",
  "buildNumber": 25,
  "forceUpdate": false,
  "updateMessage": "Yeni özellikler mevcut! Güncellemek ister misiniz?",
  "lastUpdated": "October 18, 2025 at 5:30:00 PM UTC+3"
}
```
- Kullanıcı "Daha Sonra" diyebilir
- 4 saat sonra tekrar sorulur
- Skip ederse o versiyon için bir daha sorulmaz

### Zorunlu Update (forceUpdate: true)
```json
{
  "version": "1.0.18",
  "buildNumber": 25,
  "forceUpdate": true,
  "updateMessage": "Kritik güvenlik güncellemesi! Lütfen hemen güncelleyin.",
  "lastUpdated": "October 18, 2025 at 5:30:00 PM UTC+3"
}
```
- Dialog kapatılamaz
- "Daha Sonra" butonu gösterilmez
- Kullanıcı mecburen güncellemeli

## 🚀 Deployment Checklist

Every release öncesi:

- [ ] `pubspec.yaml` version artır
- [ ] Firestore `app_versions/latest` güncelle
- [ ] `flutter build web --release`
- [ ] `firebase deploy --only hosting`
- [ ] Tarayıcıda test et (cache temizle)
- [ ] iOS Safari'de test et
- [ ] Version check dialog'unun çalıştığını doğrula

## 🔍 Troubleshooting

### Dialog Görünmüyor
- Firestore rules kontrol et (`app_versions` collection read izni)
- Console'da error var mı kontrol et
- 4 saniye bekle, çok erken çıkabilir

### iOS'ta Hala Eski Versiyon
1. Safari → Ayarlar → Website Data → Temizle
2. Uygulamayı sil ve tekrar ekle (PWA)
3. Cihazı yeniden başlat (son çare)

### forceUpdate Çalışmıyor
- Firestore document'i kontrol et
- `forceUpdate` boolean mu, string değil mi?
- Dialog'un `barrierDismissible` false olmalı

## 📊 Monitoring

### Log Messages

```dart
// Version check başladı
🔍 Checking version...

// Güncelleme mevcut
⚠️  Update available: 1.0.17 → 1.0.18

// Kullanıcı güncelledi
✅ User initiated update reload

// Hata
❌ Version check failed: [error]
```

### SharedPreferences Keys

- `version_last_check`: Son kontrol zamanı (timestamp)
- `version_skip_version`: Skip edilmiş versiyon (1.0.18)

## 🎨 Custom Messages

Özel mesajlar için Firestore:

```json
{
  "version": "1.0.18",
  "buildNumber": 25,
  "forceUpdate": false,
  "updateMessage": "🎉 Yeni tasarım ve 'Kaç Saat' özelliği eklendi! Keşfetmek için güncelleyin.",
  "lastUpdated": "October 18, 2025 at 5:30:00 PM UTC+3"
}
```

Emoji ve formatlamalar desteklenir!
