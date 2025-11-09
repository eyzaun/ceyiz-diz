# Çeyiz Diz — Kapsamlı Proje Bağlam Dokümanı

Bu doküman, projeyi devralan bir geliştiricinin yalnızca bu belgeye bakarak “nerede neyi, nasıl” değiştireceğine karar verebilmesi için derin bağlam, dosya eşlemesi, akış, veri modeli ve operasyonel rehber içerir. Her başlıkta ilgili dosya/dizinler ve dikkat notları verilir.

Son güncelleme: 2025-11-09 • Sürüm: 1.2.1+35 • Depo: `eyzaun/ceyiz-diz`

---

## 1) Ürün Özeti (Ne yapar?)

- Amaç: Çeyiz hazırlığını planlama ve yönetme (ürün, kategori, bütçe, istatistik, paylaşım, raporlama).
- Platformlar: Android (tam), Web (Firebase Hosting + PWA). iOS planlı.
- Kimlik & Güvenlik: Firebase Auth (Email/Şifre + Google), Firebase App Check (Web: reCAPTCHA Enterprise, Android: Debug/Play Integrity).
- Veri: Cloud Firestore (koleksiyonlar: `users`, `trousseaus`, `products`, `feedbacks`) ve Firebase Storage (görseller + thumbnail stratejisi).
- Yerelleştirme: TR ve EN (ARB + gen_l10n).

Başlamak için en kritik dosyalar:
- Giriş: `lib/main.dart`
- Router: `lib/presentation/router/app_router.dart`
- Sağlayıcılar: `lib/presentation/providers/*`
- Veri katmanı: `lib/data/models/*`, `lib/data/repositories/*`, `lib/data/services/firebase_service.dart`
- UI: `lib/presentation/screens/*`, `lib/presentation/widgets/*`

---

## 2) Teknoloji Yığını ve Paket-Kod Eşlemesi

Kaynak: `pubspec.yaml`

- Flutter 3.x (Material 3), Dart >= 3.0
- Router: `go_router` → `presentation/router/app_router.dart`
- State: `provider` → `main.dart` (MultiProvider), `presentation/providers/*`
- Firebase:
  - `firebase_core` → tüm platform başlatma (`main.dart`, `firebase_options.dart`)
  - `firebase_auth` → Auth akışları (repo/provider, router redirect)
  - `cloud_firestore` → CRUD (`data/repositories/*`)
  - `firebase_storage` → ürün görsellleri (image picker + upload + thumbnail)
  - `firebase_app_check` → `main.dart` (platforma göre sağlayıcı seçimi)
  - `google_sign_in` → Google OAuth (auth ekranları, Web için `web/index.html` GIS script + meta)
- UI/Görsel: `flutter_svg`, `cached_network_image`, `shimmer`, `flutter_staggered_grid_view`, `smooth_page_indicator`
- Yardımcılar: `image_picker` (widget), `share_plus` (Excel paylaş), `intl` (format), `uuid` (id), `shared_preferences` (onboarding/tercihler), `path_provider` (dosya erişimi), `package_info_plus` (sürüm), `http`, `image` (görsel işleme), `syncfusion_flutter_xlsio` (Excel)
- Lint: `flutter_lints` (analysis_options.yaml üzerinden)

Hızlı arama referansları:
- Görsel seçimi & yükleme → `presentation/widgets/common/image_picker_widget.dart`
- Excel export → `core/services/excel_export_service_v3.dart`
- Saat hesaplayıcı → `core/services/kac_saat_calculator.dart`
- Sürüm kontrolü → `core/services/version_service*.dart` + `presentation/widgets/dialogs/update_available_dialog.dart`

---

## 3) Uygulama Yaşam Döngüsü ve Başlatma

Dosya: `lib/main.dart`

Sözleşme (contract):
- Input: FirebaseOptions (platforma göre), SharedPreferences
- Output: Çalışan `MaterialApp.router` + çoklu Provider context + App Check aktif
- Yan etkiler: Web’de yüklemeden ~4sn sonra versiyon kontrol diyalogu tetiklenebilir

Akış:
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `Firebase.initializeApp(DefaultFirebaseOptions.currentPlatform)`
3. App Check aktivasyonu:
   - Web: `ReCaptchaEnterpriseProvider(<site-key>)`
   - Android Debug: `AndroidProvider.debug`
   - Android Release: `AndroidProvider.playIntegrity`
4. `SharedPreferences.getInstance()`
5. `runApp(MyApp(prefs))`
6. `MultiProvider` ile tüm provider’lar enjekte edilir.
7. `MaterialApp.router` kurulur → `AppRouter.router`, `AppLocalizations.*`, tema & locale.
8. Web: `VersionService.checkVersion()` sonucu `UpdateAvailableDialog` (opsiyonel zorunlu güncelleme davranışı).

Dikkat:
- App Check başarısız olduğunda sessizce yakalanır; prod’da sağlayıcılar doğru olmalı.
- `LocaleProvider` ve `ThemeProvider` kullanıcı tercihlerini `SharedPreferences` ile saklar.
- `ChangeNotifierProxyProvider` ile `ProductProvider`/`TrousseauProvider` auth’a bağlı güncellenir.

---

## 4) Router (GoRouter) — Rota Tablosu ve Koruyucular

Dosya: `lib/presentation/router/app_router.dart`

Redirect Kuralları (öncelik sırası):
1) Onboarding tamamlanmamışsa → `/onboarding`
2) Kimlik doğrulandı fakat e‑posta doğrulanmamışsa → `/verify-email/:email`
3) Kimlik doğrulanmamış ve auth dışı rotaya gidiyorsa → `/login`
4) Kimlik doğrulanmış ve auth rotasına gidiyorsa → `/`

Debounce: Aynı redirect’ın 500ms içinde tekrar tetiklenmesi engellenir.

Tüm Rotalar:
- `/` → `HomeScreen`
  - `create-trousseau` → `CreateTrousseauScreen`
  - `trousseau/:id` → `TrousseauDetailScreen`
    - `edit` → `EditTrousseauScreen`
    - `share` → `ShareTrousseauScreen`
    - `manage` → `TrousseauManagementScreen` (YENİ: Çeyiz sıralama ekranı)
    - `products` → `ProductListScreen`
      - `categories` → `CategoryManagementScreen`
      - `add` → `AddProductScreen`
      - `:productId` → `ProductDetailScreen`
        - `edit` → `EditProductScreen`
  - `settings` → `SettingsScreen`
    - `theme` → `ThemeSettingsScreen`
    - `change-password` → `ChangePasswordScreen`
    - `kac-saat` → `KacSaatSettingsScreen`
    - `feedback` → `FeedbackScreen`
      - `history` → `FeedbackHistoryScreen`
  - `shared-trousseaus` → `SharedTrousseauListScreen`
- `/onboarding` → `NewOnboardingScreen`
- `/login` → `LoginScreen`
- `/register` → `RegisterScreen`
- `/forgot-password` → `ForgotPasswordScreen`
- `/verify-email/:email` → `EmailVerificationScreen`

Hata Ekranı: go_router `errorBuilder` ile basit bir 404 ve ana sayfaya dönüş butonu.

Değişiklik Yapmak İçin:
- Yeni bir ekran eklerken rota hiyerarşisine uygun alt rota açın; gerekiyorsa `Auth` kontrolüne takılmaması için redirect koşullarını güncelleyin.

---

## 5) Dizin Yapısı (Detaylı)

Önemli dosya ve dizinlerin “ne işe yarar” özeti. Dosya taşıma/değiştirme yaparken bu sözleşmeyi koruyun.

```
lib/
├─ main.dart                          # App init, App Check, Provider, Router
├─ firebase_options.dart              # FlutterFire konfigleri (Web+Android)
├─ core/
│  ├─ constants/
│  │  ├─ app_colors.dart              # Renk paleti
│  │  ├─ app_constants.dart           # Sabitler (limitler, zaman aşımı vb.)
│  │  └─ app_strings.dart             # Sabit metinler (ARB dışı metinler)
│  ├─ enums/                          # (Boş/opsiyonel) enum tipleri için yer
│  ├─ localization/                   # (Şu an boş) ek i18n yardımcıları
│  ├─ services/
│  │  ├─ excel_export_service_v3.dart # XLSX üretimi (Syncfusion)
│  │  ├─ kac_saat_calculator.dart     # Ücret/prim/süre hesapları
│  │  ├─ version_service.dart         # (mobil) sürüm/force update kontrolü
│  │  ├─ version_service_web.dart     # (web) sürüm kontrolü implementasyonu
│  │  └─ version_service_stub.dart    # (diğer platformlar için stub)
│  ├─ theme/
│  │  └─ design_tokens.dart           # Spacing, radius, typography tokenları
│  ├─ themes/
│  │  ├─ app_theme.dart               # MaterialTheme setleri (5 tema)
│  │  ├─ design_system.dart           # Bileşen ölçeğinde ortak stil
│  │  └─ theme_provider.dart          # Tema seçimi & persist (SharedPrefs)
│  └─ utils/
│     ├─ currency_formatter.dart      # Para birimi formatlayıcı
│     ├─ formatters.dart              # Ortak formatlayıcılar
│     ├─ image_optimization_utils.dart# Thumbnail & memCache yardımcıları
│     └─ validators.dart              # Form/alan doğrulayıcılar
├─ data/
│  ├─ models/
│  │  ├─ user_model.dart              # Kullanıcı profili, tarih alanları
│  │  ├─ trousseau_model.dart         # Çeyiz: ownerId, budget, paylaşımlar
│  │  ├─ product_model.dart           # Ürün: fiyat, quantity, links, images
│  │  ├─ category_model.dart          # Kategori: ikon/renk, özel/varsayılan
│  │  └─ feedback_model.dart          # Geri bildirim: rating, message, reply
│  ├─ repositories/
│  │  ├─ auth_repository.dart         # Giriş/çıkış, register, verify, Google
│  │  ├─ trousseau_repository.dart    # Çeyiz CRUD + paylaşım akışları
│  │  ├─ product_repository.dart      # Ürün CRUD + görsel/progres akışları
│  │  ├─ category_repository.dart     # Kategori CRUD + varsayılanlar
│  │  └─ feedback_repository.dart     # Geri bildirim CRUD + list/history
│  └─ services/
│     └─ firebase_service.dart        # Firestore/Storage ortak yardımcılar
├─ l10n/
│  ├─ app_tr.arb, app_en.arb          # Çeviri anahtarları (çok kapsamlı)
│  └─ generated/app_localizations.dart# Otomatik üretilir (elle düzenleme yok)
└─ presentation/
   ├─ providers/
   │  ├─ auth_provider.dart           # Kullanıcı, auth state, aksiyonlar
   │  ├─ trousseau_provider.dart      # Çeyiz state + Auth proxy
   │  ├─ product_provider.dart        # Ürün state + Auth proxy
   │  ├─ category_provider.dart       # Kategori state
   │  ├─ feedback_provider.dart       # Feedback state
   │  ├─ locale_provider.dart         # Locale state (TR/EN)
   │  └─ onboarding_provider.dart     # Onboarding tamamlandı bilgisi
   ├─ router/app_router.dart          # Rota tablosu + guardlar
   ├─ screens/
   │  ├─ auth/
   │  │  ├─ login_screen.dart         # Email/Şifre + Google giriş
  │  │  ├─ register_screen.dart      # Yeni hesap
  │  │  ├─ forgot_password_screen.dart# Şifre sıfırlama
   │  │  └─ email_verification_screen.dart# E-posta doğrulama akışı
   │  ├─ home/
   │  │  ├─ home_screen.dart          # 4 tab + özetler
   │  │  └─ statistics_screen.dart    # Kategori/bütçe analizleri
   │  ├─ onboarding/new_onboarding_screen.dart
   │  ├─ product/
   │  │  ├─ add_product_screen.dart   # Form, link/doğrulama, foto ekleme
   │  │  ├─ edit_product_screen.dart  # Form + mevcut foto güncelleme
   │  │  ├─ product_list_screen.dart  # Filtre/sırala, thumbnail list
   │  │  ├─ product_detail_screen.dart# Tam ekran fotoğraf, swipe/zoom
   │  │  └─ category_management_screen.dart
   │  ├─ settings/
   │  │  ├─ settings_screen.dart
   │  │  ├─ theme_settings_screen.dart
   │  │  ├─ change_password_screen.dart
   │  │  ├─ feedback_screen.dart
   │  │  └─ feedback_history_screen.dart
   │  └─ trousseau/
   │     ├─ create_trousseau_screen.dart
   │     ├─ edit_trousseau_screen.dart
   │     ├─ trousseau_detail_screen.dart
   │     ├─ trousseau_management_screen.dart  # YENİ: Drag-drop sıralama
   │     ├─ share_trousseau_screen.dart
   │     └─ shared_trousseau_list_screen.dart
   └─ widgets/
      ├─ common/
      │  ├─ app_button.dart, app_card.dart, app_input.dart
      │  ├─ category_chip.dart, filter_pill.dart, custom_app_bar.dart
      │  ├─ image_picker_widget.dart, fullscreen_image_viewer.dart
      │  ├─ icon_color_picker.dart, language_selector.dart
      │  ├─ loading_overlay.dart, responsive_container.dart, web_frame.dart
      └─ dialogs/
         ├─ sort_bottom_sheet.dart
         └─ update_available_dialog.dart
```

Diğer kök dizinler ve amaç:
- `web/` → PWA ve Web giriş (`index.html`), manifestler, ikonlar
- `android/` → Gradle, imzalama ve shrink/proguard ayarları
- `analysis_options.yaml` → Lint kuralları
- `l10n.yaml` → gen_l10n giriş/çıkış klasörleri

---

## 6) Veri Modeli (Alanlar + Örnekler)

Not: Aşağıdaki örnekler yönlendirici niteliktedir; gerçek alanlar model dosyalarında tanımlıdır.

### users/{userId}
Örnek (JSON benzeri):
```
{
  "uid": "U123",
  "email": "user@example.com",
  "displayName": "Ada Bilgin",
  "photoURL": "https://...",
  "createdAt": <Timestamp>,
  "lastLoginAt": <Timestamp>,
  "trousseauIds": ["T100", "T101"],
  "sharedTrousseauIds": ["T200"],
  "pinned": ["T100"],
  "kacSaatSettings": { ... }
}
```

### trousseaus/{trousseauId}
```
{
  "id": "T100",
  "name": "Düğün Çeyizi",
  "ownerId": "U123",
  "description": "...",
  "targetBudget": 50000,
  "sharedWith": ["U222"],
  "editors": ["U333"],
  "sortOrder": 0,  // YENİ: Firestore'da saklanır (opsiyonel)
  "createdAt": <Timestamp>,
  "updatedAt": <Timestamp>
}
```

### user_preferences/{userId}  (YENİ)
```
{
  "trousseauOrder": {
    "T100": 0,
    "T101": 1,
    "T200": 2
  },
  "updatedAt": <Timestamp>
}
```
Not: Kullanıcıya özel çeyiz sıralama tercihleri. TrousseauProvider `getSortedTrousseaus()` bu koleksiyondan okur.

### products/{productId}
```
{
  "id": "P900",
  "trousseauId": "T100",
  "name": "Çatal Bıçak Takımı",
  "category": "kitchen",
  "quantity": 1,
  "price": 1500.0,
  "links": ["https://...", "..."],
  "images": ["https://.../thumb200", "https://.../thumb400", "https://.../full"],
  "notes": "...",
  "purchased": false,
  "createdAt": <Timestamp>,
  "updatedAt": <Timestamp>
}
```

### feedbacks/{feedbackId}
```
{
  "id": "F123",
  "userId": "U123",
  "rating": 5,
  "message": "Harika!",
  "email": "opsiyonel",
  "reply": { "from": "Support", "text": "Teşekkürler" },
  "createdAt": <Timestamp>
}
```

Güvenlik Notu: Owner ve editors listeleri CRUD izinleri için tek kaynaktır. Firestore Rules bu alanlar üzerinden kontrol edilir (örn. sadece owner silebilir, editors güncelleyebilir).

---

## 7) Repository & Provider Sözleşmeleri (Nasıl kullanılır?)

Her repository, spesifik koleksiyonun CRUD ve iş kurallarını kapsar; provider’lar UI için durum + aksiyon sağlar.

- AuthRepository / AuthProvider
  - login(email, pass) / logout() / register(...) / sendPasswordReset / resendEmailVerification / loginWithGoogle()
  - State: currentUser, isLoading, error
  - Hatalar: kimlik hatası, bağlantı; UI: ARB mesajlarını kullanın

- TrousseauRepository / Provider
  - create/update/delete, shareWith(email, permission), accept/decline, pin/unpin
  - YENİ: `updateTrousseauOrder(trousseauId, sortOrder)` / `updateTrousseauOrders(Map<id,order>)` — batch sıralama güncellemesi
  - YENİ: `getUserTrousseauOrder(userId)` / `updateUserTrousseauOrder(userId, Map<id,order>)` — kullanıcıya özel `user_preferences` entegrasyonu
  - Provider: `getSortedTrousseaus()` — user_preferences veya model sortOrder'a göre sıralı liste döner
  - Provider: `updateUserTrousseauOrders(Map<id,order>)` — kullanıcı sıralama tercihini kaydeder
  - Listeners: owner/shared listelerini stream olarak dinleyebilir
  - State: trousseaux, shared, pinned, loading, error

- ProductRepository / Provider
  - add/edit/delete, markPurchased, search/filter/sort
  - Fotoğraflar: max 5; upload + thumbnail URL’leri saklanır
  - State: list, selected, filters, sortMode, loading, error

- CategoryRepository / Provider
  - **ÖNEMLİ: "isCustom" alanı kaldırıldı (9 Kasım 2025)** — Artık tüm kategoriler eşit statüde, "default" vs "custom" ayrımı yok
  - Model: `CategoryModel` → `id`, `name`, `displayName`, `icon`, `color`, `sortOrder` (isCustom kaldırıldı)
  - Repository: `addCategory` → `isCustom` parametresi kaldırıldı; `initializeDefaultCategories` artık "starter categories" olarak isimlendiriliyor
  - Provider: `allCategories` getter döner; `defaultCategories` ve `customCategories` getter'ları KALDIRILDI
  - add/edit/delete; ikon/renk seçme (tüm kategoriler için icon/color persist edilir)
  - `updateCategoryOrder(trousseauId, categoryId, newOrder)` — tek kategori sırası günceller
  - `updateCategoryOrders(trousseauId, Map<categoryId, order>)` — batch kategori sıralama güncellemesi
  - UI: CategoryManagementScreen artık tek liste gösterir (default/custom ayrımı yok), ReorderableListView ile entegre

- FeedbackRepository / Provider
  - sendFeedback, listMyFeedbacks; history ekranı ile entegre

- ExcelExportService
  - exportTrousseau(trousseauId) → Uint8List (dosya) → share_plus ile paylaş

- KacSaatCalculator
  - Config: salary, dailyHours, workingDays, bonuses
  - API: priceToHours(price) → string/sayı; istatistikte de kullanılır

---

## 8) Yerelleştirme (TR/EN) — Uygulamalı

- Dosyalar: `lib/l10n/app_tr.arb`, `lib/l10n/app_en.arb` (çok kapsamlı hazır anahtar seti)
- Üretim: `l10n.yaml` → `lib/l10n/generated/app_localizations.dart`
- Kullanım: `AppLocalizations.of(context).<key>`

Yeni anahtar ekleme adımları:
1. Her iki ARB'ye aynı anahtarı ekleyin (açıklamalar `@key` altında olabilir).
2. Kaydedin → IDE `gen_l10n` tetikler (veya `flutter gen-l10n`).
3. UI'da `AppLocalizations` üzerinden çağırın.

Son Eklenen Anahtarlar (YENİ - 9 adet):
- `trousseauManagement`, `manageTrousseaus`, `reorderTrousseaus`
- `holdAndDragToReorder`, `orderUpdated`, `noTrousseausYet`
- `items`, `shared`, `view`

Edge Cases:
- Anahtar eksik: build sırasında uyarı; fallback için TR kullanılabilir (projede fallback Türkçe mantığı var).

---

## 9) Tema & Tasarım — Pratik Kılavuz

- 5 hazır tema → `core/themes/app_theme.dart`
- Tokenlar → `core/theme/design_tokens.dart`
- Sağlayıcı → `core/themes/theme_provider.dart`

Tema Değiştirme:
- `ThemeProvider.setTheme(<id>)` → SharedPreferences ile kalıcı kılar.

Komponentler:
- Giriş/Buton/Input → `presentation/widgets/common/*` (ör. `app_button.dart`, `app_input.dart`)
- Görsel/Pickers → `image_picker_widget.dart`, `fullscreen_image_viewer.dart`

---

## 10) Platform & Yapılandırma

Android (`android/app/build.gradle.kts`):
- `minifyEnabled = true` + `shrinkResources = true` (release)
- Proguard aktif (`proguard-android-optimize.txt` + `proguard-rules.pro`)
- **YENİ Proguard kuralları (9 Kasım):** Enhanced Firestore, SharedPreferences, SQLite/Room koruma kuralları eklendi
- `multidexEnabled = true`
- `applicationId = "com.Loncagames.ceyizdiz"`
- **YENİ:** `packaging.jniLibs.useLegacyPackaging = true` (native lib uyumluluğu için)
- **YENİ Manifest:** `allowBackup="true"`, `fullBackupContent="@xml/backup_rules"`, `dataExtractionRules="@xml/data_extraction_rules"`
- **YENİ XML:** `android/app/src/main/res/xml/backup_rules.xml` ve `data_extraction_rules.xml` — kullanıcı verilerini uygulama güncellemelerinde korur (SharedPreferences, veritabanı, dosyalar)

Web (`web/index.html`):
- GIS: `<script src="https://accounts.google.com/gsi/client" async defer></script>`
- client_id meta: `google-signin-client_id`
- App Check (enterprise recaptcha) script: `https://www.google.com/recaptcha/enterprise.js?render=explicit`
- PWA meta/manifest bağları mevcut

Manifestler:
- `web/manifest.webmanifest` ve `web/manifest.json` (ikonlar, renkler, start_url)

Firebase Options (`lib/firebase_options.dart`):
- Web ve Android için ayrı `FirebaseOptions` sabitleri tanımlı.

Firestore Rules (`firestore.rules`):
- `user_preferences/{userId}` → read/write: `isAuthed() && request.auth.uid == userId` (YENİ)
- `trousseaus/{trousseauId}` → canRead/canWrite helper'larla owner/sharedWith/editors kontrol edilir
- `app_versions/{versionId}` → herkese açık read (version check)

---

## 11) Performans & Bellek — Strateji

- Thumbnail-first (200/400px) → liste ve detay için farklı çözünürlükler
- `CachedNetworkImage` + `memCacheWidth/Height` ile bellek azaltma
- Shimmer ile yükleme sırasında iskelet ekranlar
- Network maliyeti: thumbnail kullanımıyla ciddi düşüş (README’de ölçüm notları mevcut)

---

## 12) Hata Yönetimi & Güncelleme Diyaloğu

- Hatalar: provider’larda `error` alanları ve ARB metinleri ile kullanıcı dostu çıktı
- Router’da auth/emailVerified guard’ları hatalı döngüleri önlemek için debounce’lu
- Web versiyon kontrolü: `VersionService.checkVersion()` → `UpdateAvailableDialog.show(...)`
  - Zorunlu güncelleme mesajları ARB’de mevcut (`updateRequired`, `forceUpdateMessage` vb.)

---

## 13) Geliştirici Rehberi — Kurulum, Çalıştırma, Yayın

Gereksinimler:
- Flutter 3.35.x, Dart 3.9.x civarı (SDK uyumlu)
- Firebase Console erişimi
- Android Studio (Android), Chrome (Web)

Kurulum (Windows/cmd):
```cmd
flutter pub get
flutter run
```

APK Build (VS Code Task da var):
```cmd
flutter build apk --release
```

Play için AAB:
```cmd
flutter build appbundle --release
```

Web Build & (ops.) Deploy:
```cmd
flutter build web --release
firebase deploy --only hosting
```

Ortam/Secret Notları:
- `google-services.json` → `android/app/` (kaynak kontrolünde mevcut)
- `key.properties` → yerel imzalama bilgileri (repo’da şablon, gizli değerler local)
- Web Google OAuth → `index.html` client_id ve Firebase OAuth client eşleşmeli

---

## 14) Kod Standartları & Kalite Kapıları

- Lint: `analysis_options.yaml` (temel: `flutter_lints`)
- Yapı: Katmanlar arası bağımlılıklar tek yönde (presentation → data → core)
- Test: Eklenecek öneri
  - Repository: we-mock Firestore (emülatör veya fakes)
  - Provider: basit state değişim testleri
  - Widget: temel render ve etkileşim

Quality Gates (hedef):
- Build: PASS
- Lint/Analyze: PASS
- Test: (eklenmesi önerilir)

---

## 15) Sık Karşılaşılan Sorunlar (Troubleshooting)

- Play Store açılamıyor → `url_launcher`/cihaz yetenekleri
- Email verify döngüsü → Router koşulları + `FirebaseAuth.currentUser.reload()`
- Web Google Sign-In → `index.html` client_id, Firebase Console’da Authorized domain
- App Check başarısız → Web site key, Android debug/release provider, Firebase Console ayarları

---

## 16) Geliştirici Akışı — "Yeni Özellik Nasıl Eklenir?"

Örnek: "Ürün kartına favori ekle"
1) Model: `product_model.dart` → `isFavorite: bool` alanı ekle
2) Firestore: `product_repository.dart` create/update alanlarını güncelle
3) Provider: `product_provider.dart` → `toggleFavorite(productId)` ekle
4) UI: `product_list_screen.dart` ve `product_detail_screen.dart` buton/ikon ekle
5) ARB: `add/remove favorite` metinleri (TR/EN)
6) Test: Provider fonksiyonunun state değişimini teyit et

Örnek: "Yeni ayar ekranı"
1) Ekran dosyası: `presentation/screens/settings/new_setting_screen.dart`
2) Router: `app_router.dart` alt rota ekle (`/settings/new-setting`)
3) Provider: `settings` ile entegre veya yeni provider
4) ARB: Başlık/açıklama metinleri

Gerçek Uygulama: "Çeyiz Sıralama Ekranı" (YENİ - Kasım 2025)
1) Model: `trousseau_model.dart` → `sortOrder: int` alanı eklendi
2) Koleksiyon: `user_preferences/{userId}` → `trousseauOrder: Map<id,order>` eklendi
3) Repository: `trousseau_repository.dart` → `updateTrousseauOrder`, `updateTrousseauOrders`, `getUserTrousseauOrder`, `updateUserTrousseauOrder` eklendi
4) Provider: `trousseau_provider.dart` → `getSortedTrousseaus()`, `updateUserTrousseauOrders(Map)`, `loadUserTrousseauOrder()` eklendi
5) Ekran: `trousseau_management_screen.dart` → ReorderableListView + drag handle, view/edit/delete popup menu
6) Router: `/trousseau/:id/manage` rotası eklendi
7) ARB: 9 yeni anahtar (`trousseauManagement`, `manageTrousseaus`, `reorderTrousseaus`, `holdAndDragToReorder`, `orderUpdated`, `noTrousseausYet`, `items`, `shared`, `view`)
8) Firestore Rules: `user_preferences/{userId}` read/write izni eklendi
9) UI Entegrasyonu: `trousseau_detail_screen.dart` AppBar'da "Düzenle" butonu → "Çeyizleri Yönet" (Icons.reorder) olarak güncellendi

---

## 17) Güvenlik & Gizlilik (Özet)

- App Check açık (Web + Android)
- Firestore Rules: owner/paylaşım bazlı erişim (README’de örnek kural)
- Storage Rules: yalnızca yetkili kullanıcı yükleme/okuma
- Gizlilik & Hizmet Şartları: README’de TR/EN metinleri mevcut

---

## 18) Hızlı Referans

- Giriş: `lib/main.dart`
- Router: `lib/presentation/router/app_router.dart`
- Provider: `lib/presentation/providers/*`
- Model: `lib/data/models/*`
- Repo: `lib/data/repositories/*`
- Servis: `lib/core/services/*`
- Widget: `lib/presentation/widgets/*`
- L10n: `lib/l10n/*`, `l10n.yaml`
- Android: `android/app/build.gradle.kts`
- Web: `web/index.html`, `web/manifest.webmanifest`

---

## 19) Son Değişiklikler (Changelog)

### 2025-11-09b: Kategori Refactoring + Android Yedekleme (Sürüm 1.2.1+35)
**Özet:** "isCustom" alanı kaldırıldı, tüm kategoriler eşit; Android Auto Backup/Restore eklendi.

**Değişiklikler:**
- **BREAKING: CategoryModel Refactoring**
  - `isCustom: bool` alanı KALDIRILDI — artık default/custom ayrımı yok
  - Tüm kategoriler eşit statüde; icon/color her kategori için persist edilir
  - `CategoryProvider`: `defaultCategories` ve `customCategories` getter'ları KALDIRILDI → sadece `allCategories` kullanılıyor
  - `CategoryRepository.addCategory`: `isCustom` parametresi kaldırıldı
  - `CategoryRepository.initializeDefaultCategories`: "starter categories" mantığıyla; isCustom field'ı yok
  - UI: `category_management_screen.dart` → tek liste (default/custom bölümü yok), tüm kategoriler ReorderableListView'da
  - UI: `statistics_screen.dart` → dummy kategori oluştururken isCustom kullanmıyor
- **Android:**
  - `build.gradle.kts` → `packaging.jniLibs.useLegacyPackaging = true`
  - `proguard-rules.pro` → Enhanced Firestore rules, SharedPreferences/SQLite koruma kuralları eklendi
  - `AndroidManifest.xml` → `allowBackup="true"`, `fullBackupContent`, `dataExtractionRules` eklendi
  - **YENİ XML:** `res/xml/backup_rules.xml` ve `data_extraction_rules.xml` — uygulama güncellemelerinde kullanıcı verilerini korur
- **Sürüm:** 1.1.1+34 → 1.2.1+35

**Etkilenen Dosyalar:**
- `pubspec.yaml` (version bump)
- `lib/data/models/category_model.dart` (isCustom kaldırıldı, fromMap/toMap güncellendi)
- `lib/data/repositories/category_repository.dart` (isCustom parametresi kaldırıldı)
- `lib/presentation/providers/category_provider.dart` (defaultCategories/customCategories getters kaldırıldı)
- `lib/presentation/screens/product/category_management_screen.dart` (tek liste UI)
- `lib/presentation/screens/home/statistics_screen.dart` (isCustom kullanımı kaldırıldı)
- `android/app/build.gradle.kts` (packaging)
- `android/app/proguard-rules.pro` (enhanced rules)
- `android/app/src/main/AndroidManifest.xml` (backup config)
- `android/app/src/main/res/xml/backup_rules.xml` (YENİ)
- `android/app/src/main/res/xml/data_extraction_rules.xml` (YENİ)

**Migration Notu:** Mevcut Firestore'daki kategorilerde `isCustom` alanı varsa uygulamada göz ardı edilir; yeni kategoriler bu alan olmadan yazılır. Geriye dönük uyumluluk korundu.

---

### 2025-11-09a: Çeyiz ve Kategori Sıralama Özelliği (Sürüm 1.1.1+34)
**Özet:** Kullanıcılar artık çeyizlerini ve kategorilerini drag-drop ile yeniden sıralayabilir.

**Değişiklikler:**
- **Model:** `TrousseauModel` → `sortOrder: int` alanı eklendi
- **Koleksiyon (YENİ):** `user_preferences/{userId}` → kullanıcıya özel çeyiz sıralaması
- **Repository:**
  - `TrousseauRepository`: `updateTrousseauOrder`, `updateTrousseauOrders`, `getUserTrousseauOrder`, `updateUserTrousseauOrder`
  - `CategoryRepository`: `updateCategoryOrder`, `updateCategoryOrders`
- **Provider:**
  - `TrousseauProvider`: `getSortedTrousseaus()`, `updateUserTrousseauOrders()`, `loadUserTrousseauOrder()`
  - `CategoryProvider`: `updateCategoryOrder()`, `updateCategoryOrders()`
- **Ekran (YENİ):** `trousseau_management_screen.dart` → ReorderableListView, drag handle, view/edit/delete menu
- **Router:** `/trousseau/:id/manage` rotası eklendi
- **UI:** `trousseau_detail_screen.dart` AppBar'da "Düzenle" → "Çeyizleri Yönet" (Icons.reorder)
- **UI:** `category_management_screen.dart` → ReorderableListView ile kategori sıralama
- **Localization:** 9 yeni anahtar (trousseauManagement, manageTrousseaus, reorderTrousseaus, holdAndDragToReorder, orderUpdated, noTrousseausYet, items, shared, view)
- **Firestore Rules:** `user_preferences/{userId}` read/write izni eklendi

**Etkilenen Dosyalar:**
- `lib/data/models/trousseau_model.dart`
- `lib/data/repositories/trousseau_repository.dart`
- `lib/data/repositories/category_repository.dart`
- `lib/presentation/providers/trousseau_provider.dart`
- `lib/presentation/providers/category_provider.dart`
- `lib/presentation/router/app_router.dart`
- `lib/presentation/screens/trousseau/trousseau_management_screen.dart` (YENİ)
- `lib/presentation/screens/trousseau/trousseau_detail_screen.dart`
- `lib/presentation/screens/product/category_management_screen.dart`
- `lib/l10n/app_tr.arb`, `lib/l10n/app_en.arb`
- `firestore.rules`

**Silinen Dosyalar:**
- `PRIVACY_POLICY.md`
- `TERMS_OF_SERVICE.md`

---

### 2025-11-09c: Çeyiz Sıralama Hatasının Düzeltilmesi (v1.2.1+35)

**Sorun:** Çeyiz Yönetim ekranında (`TrousseauManagementScreen`) yapılan sıralama değişiklikleri ana sayfa (`HomeScreen`) ve detay ekranındaki yatay seçicide (`TrousseauDetailScreen`) yansımıyordu. Her iki ekran da `pinnedTrousseaus` listesini doğrudan kullanıyordu, bu liste Firestore'dan gelen sırayla döndüğü için kullanıcının belirlediği özel sıralamayı göstermiyordu.

**Çözüm:**
- `HomeScreen._buildTrousseauTab()`: `pinnedTrousseaus` yerine `getSortedTrousseaus()` metodunu kullanıp ardından pinned olanları filtreledik
- `TrousseauDetailScreen._buildTrousseauSelector()`: Aynı yaklaşım uygulandı

Bu sayede kullanıcının `user_preferences/{userId}` koleksiyonunda tanımladığı sıralama tüm ekranlarda tutarlı şekilde görüntüleniyor.

**Etkilenen Dosyalar:**
- `lib/presentation/screens/home/home_screen.dart`
- `lib/presentation/screens/trousseau/trousseau_detail_screen.dart`

**Commit:** `0386438` (2025-11-09)

---

### 2025-11-09d: Ürün Tarih Bazlı Sıralama Özelliği (v1.2.1+35)

**Özellik:** Ürün listesine iki yeni sıralama seçeneği eklendi ve **tarih bazlı sıralama diğer seçeneklerin en üstüne konumlandırıldı**:
1. **Tarih (Eskiden Yeniye)** - Ürünlerin oluşturulma tarihine göre artan sıralama
2. **Tarih (Yeniden Eskiye)** - Ürünlerin oluşturulma tarihine göre azalan sıralama

**Uygulama:**
- `ProductSortOption` enum'una `dateOldToNew` ve `dateNewToOld` değerleri eklendi (en üstte)
- `ProductProvider._applySorting()` metoduna tarih bazlı sıralama mantığı eklendi (`createdAt` alanı kullanılıyor)
- `SortBottomSheet` widget'ında yeni seçenekler **en üstte** gösteriliyor, bir divider ile diğer seçeneklerden ayrıldı
- İkonlar: `Icons.access_time` (Eskiden Yeniye), `Icons.schedule` (Yeniden Eskiye)

**Sıralama Seçenekleri Sırası (Güncel):**
1. Tarih (Eskiden Yeniye) ⏰
2. Tarih (Yeniden Eskiye) 🕐
3. --- Divider ---
4. Alınanlar Önce ✓
5. Alınmayanlar Önce ○
6. --- Divider ---
7. Fiyat (Yüksek → Düşük) ↓
8. Fiyat (Düşük → Yüksek) ↑
9. --- Divider ---
10. İsim (A → Z) 🔤
11. İsim (Z → A) 🔤

**Etkilenen Dosyalar:**
- `lib/core/enums/sort_option.dart` (2 yeni enum değeri)
- `lib/presentation/providers/product_provider.dart` (sıralama mantığı)
- `lib/presentation/widgets/dialogs/sort_bottom_sheet.dart` (UI seçenekleri)
- `lib/l10n/app_tr.arb`, `lib/l10n/app_en.arb` (4 yeni key: sortDateOldToNew, sortDateNewToOld)
- `lib/l10n/generated/app_localizations*.dart` (auto-generated)

**Lokalizasyon:**
- TR: "Tarih (Eskiden Yeniye)", "Tarih (Yeniden Eskiye)"
- EN: "Date (Oldest First)", "Date (Newest First)"

---

## 20) Ekler

- Build çıktıları:
  - APK: `build/app/outputs/flutter-apk/app-release.apk`
  - AAB: `build/app/outputs/bundle/release/app-release.aab`
- VS Code Görevi: "Flutter run smoke build (apk)"
- Sürüm: `pubspec.yaml` `version: 1.2.1+35`

Bu doküman "tek kaynak" olacak şekilde tasarlandı. Rota/Model/Repo/Provider/Servis/Widget eklemelerinde ilgili alt başlığı kısa notla güncelleyerek her değişiklikte belgeyi güncel tutun.
