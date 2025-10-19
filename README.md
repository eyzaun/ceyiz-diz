# 🎁 Çeyiz Diz# 🎁 Çeyiz Diz



Çeyiz listelerinizi dijital ortamda yönetin, bütçenizi takip edin ve arkadaşlarınızla paylaşın.**Çeyiz Diz**, çeyiz listelerinizi dijital ortamda kolayca yönetebileceğiniz, modern ve kullanıcı dostu bir mobil uygulamadır.



![Flutter](https://img.shields.io/badge/Flutter-3.35.5-02569B?logo=flutter)![Flutter](https://img.shields.io/badge/Flutter-3.35.5-02569B?logo=flutter)

![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)

![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)

![License](https://img.shields.io/badge/License-Private-red)![Material 3](https://img.shields.io/badge/Material-3-6200EE)



## 🌐 Demo## 🌐 Demo



**Web:** [ceyiz-diz.web.app](https://ceyiz-diz.web.app)**Web:** [ceyiz-diz.web.app](https://ceyiz-diz.web.app)



## ✨ Özellikler## ✨ Özellikler



- 🔐 **Email/Şifre & Google ile Giriş**- 🔐 **Email/Şifre & Google ile Giriş**

- 📦 **Ürün Yönetimi** - Fotoğraf, fiyat, kategori takibi- 📦 **Ürün Yönetimi** - Fotoğraf, fiyat, kategori takibi

- 💰 **Bütçe Takibi** - Hedef bütçe belirleme, harcama analizi- � **Bütçe Takibi** - Hedef bütçe belirleme, harcama analizi

- ⏱️ **Çalışma Saati Hesabı** - Ürünlerin kaç saatlik maaşa denk geldiğini görün- ⏱️ **Çalışma Saati Hesabı** - Ürünlerin kaç saatlik maaşa denk geldiğini görün

- 👥 **Paylaşım** - Listelerinizi aile ve arkadaşlarınızla paylaşın- 👥 **Paylaşım** - Listelerinizi aile ve arkadaşlarınızla paylaşın

- 📊 **Raporlama** - Excel dışa aktarım, istatistikler- 📊 **Raporlama** - Excel dışa aktarım, istatistikler

- 🖼️ **Optimize Edilmiş Görseller** - Otomatik thumbnail oluşturma (40x daha küçük!)- 📱 **Optimize Edilmiş Görseller** - Otomatik thumbnail oluşturma (200x200, 400x400)

- 🎨 **Modern Tasarım** - Material 3, Karanlık/Açık tema- 🎨 **Modern Tasarım** - Material 3, Karanlık/Açık tema

- 🌍 **Çoklu Dil** - Türkçe/İngilizce- 🌍 **Çoklu Dil** - Türkçe/İngilizce



## 🚀 Kurulum---



```bash## 🚀 Kurulum

# Repo'yu klonlayın

git clone https://github.com/eyzaun/ceyiz-diz.git### Gereksinimler

cd ceyiz-diz

- Flutter SDK 3.35.5+

# Bağımlılıkları yükleyin- Dart SDK 3.9.2+

flutter pub get- Android Studio / Xcode (mobil geliştirme için)

- Firebase hesabı

# Firebase ayarlarını yapın

# google-services.json (Android) ve GoogleService-Info.plist (iOS) ekleyin### Adımlar



# Çalıştırın1. **Repo'yu klonlayın:**

flutter run   ```bash

```   git clone https://github.com/eyzaun/ceyiz-diz.git

   cd ceyiz-diz

Detaylı Firebase ve Google Sign-In kurulumu için: [GOOGLE_SIGNIN_SETUP.md](GOOGLE_SIGNIN_SETUP.md)   ```



## 📱 Platformlar2. **Bağımlılıkları yükleyin:**

   ```bash

- ✅ **Android** (API 21+)   flutter pub get

- ✅ **Web** (Firebase Hosting)   ```

- 🔄 **iOS** (Planlanan)

3. **Firebase ayarlarını yapın:**

## 🏗️ Teknolojiler   - Firebase Console'dan yeni bir proje oluşturun

   - Android/iOS uygulamalarını ekleyin

- **Frontend:** Flutter 3.35.5, Material Design 3   - `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) dosyalarını indirin

- **Backend:** Firebase (Auth, Firestore, Storage, App Check)   - İlgili klasörlere kopyalayın

- **State Management:** Provider

- **Routing:** go_router4. **Google Sign-In yapılandırması (Opsiyonel ama önerilen):**

- **Image Optimization:** Firebase Storage Resize Extension   - [GOOGLE_SIGNIN_SETUP.md](GOOGLE_SIGNIN_SETUP.md) dosyasındaki adımları takip edin



## 📦 Ana Paketler5. **Uygulamayı çalıştırın:**

   ```bash

```yaml   flutter run

dependencies:   ```

  # Firebase

  firebase_core: ^3.8.0---

  firebase_auth: ^5.3.3

  cloud_firestore: ^5.5.0## 📦 Kullanılan Paketler

  firebase_storage: ^12.3.7

  google_sign_in: ^6.3.0### Firebase & Backend

  - `firebase_core: ^3.8.0` - Firebase temel yapı

  # State & Navigation- `firebase_auth: ^5.3.3` - Kimlik doğrulama

  provider: ^6.1.2- `cloud_firestore: ^5.5.0` - Veritabanı

  go_router: ^14.6.2- `firebase_storage: ^12.3.7` - Dosya depolama

  - `firebase_app_check: ^0.3.2+10` - Güvenlik

  # UI- `google_sign_in: ^6.3.0` - Google OAuth 🆕

  cached_network_image: ^3.4.1

  shimmer: ^3.0.0### State Management

  - `provider: ^6.1.2` - Durum yönetimi

  # Utils

  image_picker: ^1.1.2### UI & Navigation

  excel: ^4.0.6- `go_router: ^14.6.2` - Routing

  share_plus: ^10.1.3- `flutter_svg: ^2.0.10` - SVG desteği

```- `cached_network_image: ^3.4.1` - Görsel önbellekleme

- `shimmer: ^3.0.0` - Yükleme animasyonları

## 📁 Proje Yapısı- `smooth_page_indicator: ^1.2.0` - Sayfa göstergesi



```### Utilities

lib/- `image_picker: ^1.1.2` - Görsel seçimi

├── core/           # Sabitler, tema, yardımcılar- `shared_preferences: ^2.3.3` - Yerel veri saklama

├── data/           # Modeller, repository'ler, servisler- `intl: ^0.20.2` - Çoklu dil desteği

├── l10n/           # Çoklu dil (tr, en)- `excel: ^4.0.6` - Excel dışa aktarım

└── presentation/   # Providers, screens, widgets- `share_plus: ^10.1.3` - Paylaşım

```- `url_launcher: ^6.3.1` - URL açma

- `package_info_plus: ^8.0.2` - Uygulama bilgisi

## 🔥 Firebase Koleksiyonları

---

### `users`

```dart## 🏗️ Proje Yapısı

{

  uid, email, displayName, photoURL,```

  trousseauIds: [], sharedTrousseauIds: []lib/

}├── core/

```│   ├── constants/       # Sabitler (app_constants.dart)

│   ├── errors/          # Hata yönetimi

### `trousseaus`│   ├── localization/    # Çoklu dil

```dart│   ├── services/        # Servisler (calculator, etc.)

{│   ├── theme/           # Tasarım sistemi (Material 3)

  id, name, ownerId,│   └── utils/           # Yardımcı fonksiyonlar

  sharedWith: [],  // Görüntüleyiciler├── data/

  editors: []      // Editörler│   ├── models/          # Veri modelleri (User, Trousseau, Product)

}│   ├── repositories/    # Veri erişim katmanı

```│   └── services/        # Firebase servisleri

├── l10n/                # Çeviri dosyaları (tr, en)

### `products`└── presentation/

```dart    ├── providers/       # State management (Provider)

{    ├── router/          # Routing yapılandırması

  id, trousseauId, name, category,    ├── screens/         # Ekranlar (Auth, Home, Product, etc.)

  quantity, price, images: []    └── widgets/         # Özel widget'lar

}```

```

---

## 📸 Görsel Optimizasyonu

## 🔥 Firebase Yapılandırması

Firebase Storage Resize Extension ile otomatik thumbnail oluşturma:

- **200x200** → Liste görünümü (~5 KB)### Authentication

- **400x400** → Detay önizleme (~15 KB)- Email/Password Provider: ✅ Enabled

- **Orijinal** → Tam ekran görünüm- Google Provider: ✅ Enabled

- Email Verification: ✅ Required

**Sonuç:** %97 daha az veri kullanımı, 10-20x daha hızlı yüklenme 🚀

### Firestore Collections

## 📄 Lisans

#### `users`

Bu proje özel bir projedir. Ticari kullanım için izin gereklidir.```dart

{

## 👨‍💻 Geliştirici  uid: String,

  email: String,

**Eyyup Zafer Ünal**    displayName: String,

GitHub: [@eyzaun](https://github.com/eyzaun)  photoURL: String?, // Google'dan gelen profil fotoğrafı

  createdAt: Timestamp,

---  lastLoginAt: Timestamp,

  trousseauIds: List<String>,

⭐ Projeyi beğendiyseniz yıldız vermeyi unutmayın!  sharedTrousseauIds: List<String>,

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
