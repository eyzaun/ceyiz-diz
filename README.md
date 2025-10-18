# 🎁 Çeyiz Diz

**Çeyiz Diz**, çeyiz listelerinizi dijital ortamda kolayca yönetebileceğiniz, modern ve kullanıcı dostu bir mobil uygulamadır.

![Flutter](https://img.shields.io/badge/Flutter-3.35.5-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)
![Material 3](https://img.shields.io/badge/Material-3-6200EE)

---

## ✨ Özellikler

### 🔐 Kimlik Doğrulama
- ✅ **Email/Şifre ile Kayıt ve Giriş**
- ✅ **Google Sign-In** (Yeni! 🎉)
- ✅ Email doğrulama sistemi
- ✅ Şifre sıfırlama
- ✅ "Beni Hatırla" özelliği

### 📋 Çeyiz Yönetimi
- ✅ Çeyiz listesi oluşturma ve düzenleme
- ✅ Ürün ekleme, düzenleme ve silme
- ✅ Kategorilere göre filtreleme
- ✅ Ürün fotoğrafları yükleme
- ✅ Fiyat ve miktar takibi
- ✅ Toplam değer hesaplama

### 👥 Paylaşım ve İşbirliği
- ✅ Çeyiz listelerini başkalarıyla paylaşma
- ✅ Görüntüleyici ve Editör rolleri
- ✅ Ortak düzenleme özellikleri
- ✅ Paylaşım bağlantısı oluşturma

### 📊 Raporlama
- ✅ Kategori bazlı istatistikler
- ✅ Toplam harcama özeti
- ✅ Excel çıktısı alma
- ✅ Görsel grafikler

### 🎨 Tasarım
- ✅ Material Design 3
- ✅ Karanlık/Açık tema desteği
- ✅ Duyarlı (Responsive) tasarım
- ✅ Türkçe/İngilizce dil desteği
- ✅ Kullanıcı dostu UX/UI (Jakob, Fitts, Hick, Miller yasalarına uyumlu)

---

## 🚀 Kurulum

### Gereksinimler

- Flutter SDK 3.35.5+
- Dart SDK 3.9.2+
- Android Studio / Xcode (mobil geliştirme için)
- Firebase hesabı

### Adımlar

1. **Repo'yu klonlayın:**
   ```bash
   git clone https://github.com/eyzaun/ceyiz-diz.git
   cd ceyiz-diz
   ```

2. **Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```

3. **Firebase ayarlarını yapın:**
   - Firebase Console'dan yeni bir proje oluşturun
   - Android/iOS uygulamalarını ekleyin
   - `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) dosyalarını indirin
   - İlgili klasörlere kopyalayın

4. **Google Sign-In yapılandırması (Opsiyonel ama önerilen):**
   - [GOOGLE_SIGNIN_SETUP.md](GOOGLE_SIGNIN_SETUP.md) dosyasındaki adımları takip edin

5. **Uygulamayı çalıştırın:**
   ```bash
   flutter run
   ```

---

## 📦 Kullanılan Paketler

### Firebase & Backend
- `firebase_core: ^3.8.0` - Firebase temel yapı
- `firebase_auth: ^5.3.3` - Kimlik doğrulama
- `cloud_firestore: ^5.5.0` - Veritabanı
- `firebase_storage: ^12.3.7` - Dosya depolama
- `firebase_app_check: ^0.3.2+10` - Güvenlik
- `google_sign_in: ^6.3.0` - Google OAuth 🆕

### State Management
- `provider: ^6.1.2` - Durum yönetimi

### UI & Navigation
- `go_router: ^14.6.2` - Routing
- `flutter_svg: ^2.0.10` - SVG desteği
- `cached_network_image: ^3.4.1` - Görsel önbellekleme
- `shimmer: ^3.0.0` - Yükleme animasyonları
- `smooth_page_indicator: ^1.2.0` - Sayfa göstergesi

### Utilities
- `image_picker: ^1.1.2` - Görsel seçimi
- `shared_preferences: ^2.3.3` - Yerel veri saklama
- `intl: ^0.20.2` - Çoklu dil desteği
- `excel: ^4.0.6` - Excel dışa aktarım
- `share_plus: ^10.1.3` - Paylaşım
- `url_launcher: ^6.3.1` - URL açma
- `package_info_plus: ^8.0.2` - Uygulama bilgisi

---

## 🏗️ Proje Yapısı

```
lib/
├── core/
│   ├── constants/       # Sabitler (app_constants.dart)
│   ├── errors/          # Hata yönetimi
│   ├── localization/    # Çoklu dil
│   ├── services/        # Servisler (calculator, etc.)
│   ├── theme/           # Tasarım sistemi (Material 3)
│   └── utils/           # Yardımcı fonksiyonlar
├── data/
│   ├── models/          # Veri modelleri (User, Trousseau, Product)
│   ├── repositories/    # Veri erişim katmanı
│   └── services/        # Firebase servisleri
├── l10n/                # Çeviri dosyaları (tr, en)
└── presentation/
    ├── providers/       # State management (Provider)
    ├── router/          # Routing yapılandırması
    ├── screens/         # Ekranlar (Auth, Home, Product, etc.)
    └── widgets/         # Özel widget'lar
```

---

## 🔥 Firebase Yapılandırması

### Authentication
- Email/Password Provider: ✅ Enabled
- Google Provider: ✅ Enabled
- Email Verification: ✅ Required

### Firestore Collections

#### `users`
```dart
{
  uid: String,
  email: String,
  displayName: String,
  photoURL: String?, // Google'dan gelen profil fotoğrafı
  createdAt: Timestamp,
  lastLoginAt: Timestamp,
  trousseauIds: List<String>,
  sharedTrousseauIds: List<String>,
}
```

#### `trousseaus`
```dart
{
  id: String,
  name: String,
  ownerId: String,
  createdAt: Timestamp,
  updatedAt: Timestamp,
  sharedWith: List<String>, // Görüntüleyiciler
  editors: List<String>,    // Editörler
}
```

#### `products`
```dart
{
  id: String,
  trousseauId: String,
  name: String,
  category: String,
  quantity: int,
  price: double,
  imageUrl: String?,
  createdAt: Timestamp,
  updatedAt: Timestamp,
}
```

### Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /trousseaus/{trousseauId} {
      allow read: if request.auth != null && (
        resource.data.ownerId == request.auth.uid ||
        request.auth.uid in resource.data.sharedWith ||
        request.auth.uid in resource.data.editors
      );
      allow create: if request.auth != null;
      allow update: if request.auth != null && (
        resource.data.ownerId == request.auth.uid ||
        request.auth.uid in resource.data.editors
      );
      allow delete: if request.auth != null && resource.data.ownerId == request.auth.uid;
    }

    match /products/{productId} {
      allow read: if request.auth != null &&
        exists(/databases/$(database)/documents/trousseaus/$(resource.data.trousseauId)) &&
        (
          get(/databases/$(database)/documents/trousseaus/$(resource.data.trousseauId)).data.ownerId == request.auth.uid ||
          request.auth.uid in get(/databases/$(database)/documents/trousseaus/$(resource.data.trousseauId)).data.sharedWith ||
          request.auth.uid in get(/databases/$(database)/documents/trousseaus/$(resource.data.trousseauId)).data.editors
        );
      allow create, update, delete: if request.auth != null &&
        (
          get(/databases/$(database)/documents/trousseaus/$(request.resource.data.trousseauId)).data.ownerId == request.auth.uid ||
          request.auth.uid in get(/databases/$(database)/documents/trousseaus/$(request.resource.data.trousseauId)).data.editors
        );
    }
  }
}
```

---

## 🎯 Google Sign-In Kurulumu

Detaylı kurulum adımları için: **[GOOGLE_SIGNIN_SETUP.md](GOOGLE_SIGNIN_SETUP.md)**

**Hızlı Özet:**
1. Firebase Console → Authentication → Google Provider'ı etkinleştir
2. Android SHA-1 fingerprint ekle
3. `google-services.json` dosyasını güncelle
4. Test et!

---

## 📱 Platformlar

- ✅ **Android** (API 21+)
- 🔄 **iOS** (Planlanan)
- 🔄 **Web** (Planlanan)

---

## 🧪 Test

```bash
# Widget testlerini çalıştır
flutter test

# Analiz
flutter analyze

# Build
flutter build apk --release
```

---

## 📄 Lisans

Bu proje özel bir projedir. Ticari kullanım için izin gereklidir.

---

## 👨‍💻 Geliştirici

**Eyyup Zafer Ünal**
- GitHub: [@eyzaun](https://github.com/eyzaun)
- Email: eyyup.zaferr.unal@gmail.com

---

## 📝 Değişiklik Geçmişi

### v1.0.17+24 (2025-10-19) - Google Sign-In 🎉
- ✅ Google Sign-In entegrasyonu
- ✅ AuthRepository ve AuthProvider güncellemeleri
- ✅ Login ve Register ekranlarına Google butonları
- ✅ Material 3 uyumlu tasarım
- ✅ Detaylı kurulum dokümantasyonu

### v1.0.16 (Önceki)
- ✅ Email/Password authentication
- ✅ Çeyiz ve ürün yönetimi
- ✅ Paylaşım özellikleri
- ✅ Excel export
- ✅ Material Design 3

---

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'feat: Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

---

## 🙏 Teşekkürler

Bu proje aşağıdaki açık kaynak paketleri kullanmaktadır:
- Flutter Team
- Firebase Team
- Provider Package maintainers
- Tüm diğer bağımlılık geliştiricileri

---

**⭐ Projeyi beğendiyseniz yıldız vermeyi unutmayın!**
