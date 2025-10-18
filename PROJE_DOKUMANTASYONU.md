# 🎯 ÇEYİZ DİZ - PROJE DOKÜMANTASYONU

> **Versiyon:** 1.0.17+24  
> **Güncelleme:** 18 Ekim 2025  
> **Geliştirici Seviyesi:** Orta-İleri  
> **Framework:** Flutter 3.x / Dart 3.x

---

## 📋 İÇİNDEKİLER

1. [Proje Hakkında](#-proje-hakkında)
2. [Teknoloji Stack](#-teknoloji-stack)
3. [Proje Yapısı](#-proje-yapısı)
4. [Mimari ve Pattern'ler](#️-mimari-ve-patternler)
5. [Veri Modelleri](#-veri-modelleri)
6. [Ekranlar](#-ekranlar)
7. [Başlangıç Kılavuzu](#-başlangıç-kılavuzu)
8. [Geliştirme Kuralları](#-geliştirme-kuralları)

---

## 🎯 PROJE HAKKINDA

**Çeyiz Diz**, kullanıcıların evlilik çeyizlerini dijital ortamda yönetmelerini sağlayan bir mobil ve web uygulamasıdır.

### Temel Özellikler

✅ **Çeyiz Yönetimi**
- Çoklu çeyiz desteği
- Ürün ekleme/düzenleme/silme
- Kategori bazlı organizasyon
- Fotoğraf yönetimi (max 5/ürün)

✅ **Bütçe Takibi**
- Toplam bütçe belirleme
- Harcama takibi
- İstatistik ve raporlar
- Excel export

✅ **Paylaşım Sistemi**
- Çeyizleri başkalarıyla paylaşma
- Yetki yönetimi (Görüntüleyici/Editör)
- Pin özelliği (paylaşılan çeyizleri ana sayfaya sabitleme)

✅ **Kullanıcı Deneyimi**
- 4 farklı tema
- Onboarding ekranı
- Email doğrulama
- Geri bildirim sistemi
- Otomatik güncelleme kontrolü

---

## 🛠 TEKNOLOJİ STACK

### Frontend
```yaml
Flutter SDK: 3.x
Dart SDK: 3.x
Material Design: Material 3
```

### Backend (Firebase)
```yaml
Firebase Auth: Email/Password kimlik doğrulama
Cloud Firestore: NoSQL veritabanı
Firebase Storage: Fotoğraf depolama
Firebase App Check: Güvenlik (ReCAPTCHA + Play Integrity)
```

### State Management
```yaml
Provider: 6.1.2 (Ana state yönetimi)
ChangeNotifier: Provider pattern
```

### Routing
```yaml
GoRouter: 14.6.2 (Deklaratif routing + deep linking)
```

### Önemli Paketler
```yaml
cached_network_image: 3.4.1    # Performanslı image caching
image_picker: 1.1.2            # Kamera/galeri erişimi
excel: 4.0.6                   # Excel export
share_plus: 10.1.3             # Paylaşım
shimmer: 3.0.0                 # Loading efektleri
smooth_page_indicator: 1.2.0   # Onboarding indicators
```

---

## 📁 PROJE YAPISI

```
lib/
├── main.dart                          # Uygulama giriş noktası
├── firebase_options.dart              # Firebase config (auto-generated)
│
├── core/                              # Temel/paylaşılan kod
│   ├── constants/
│   │   ├── app_colors.dart           # Renk tanımları
│   │   ├── app_constants.dart        # Sabit değerler
│   │   └── app_strings.dart          # Metin sabitleri
│   │
│   ├── theme/
│   │   └── design_tokens.dart        # ⭐ Yeni Tasarım Sistemi v2.0
│   │                                 # Spacing, dimensions, typography
│   │
│   ├── themes/
│   │   ├── app_theme.dart            # Tema factory
│   │   ├── design_system.dart        # Eski tasarım sistemi (deprecated)
│   │   └── theme_provider.dart       # Tema state yönetimi
│   │
│   ├── services/
│   │   ├── excel_export_service.dart # Excel export işlemleri
│   │   └── kac_saat_calculator.dart  # "Kaç Saat" hesaplama servisi
│   │
│   ├── utils/
│   │   ├── currency_formatter.dart   # TL formatı
│   │   ├── formatters.dart           # Genel formatlayıcılar
│   │   └── validators.dart           # Form validasyonları
│   │
│   ├── errors/
│   │   └── exceptions.dart           # Custom exception'lar
│   │
│   └── localization/
│       └── locale_provider.dart      # Dil yönetimi provider
│
├── data/                              # Veri katmanı
│   ├── models/                        # Veri modelleri
│   │   ├── user_model.dart           # Kullanıcı modeli
│   │   ├── trousseau_model.dart      # Çeyiz modeli
│   │   ├── product_model.dart        # Ürün modeli
│   │   ├── category_model.dart       # Kategori modeli
│   │   └── feedback_model.dart       # Geri bildirim modeli
│   │
│   ├── repositories/                  # Repository pattern
│   │   ├── auth_repository.dart      # Auth CRUD
│   │   ├── trousseau_repository.dart # Çeyiz CRUD
│   │   ├── product_repository.dart   # Ürün CRUD
│   │   ├── category_repository.dart  # Kategori CRUD
│   │   └── feedback_repository.dart  # Feedback CRUD
│   │
│   └── services/
│       ├── firebase_service.dart     # Firebase helper
│       └── storage_service.dart      # Firebase Storage helper
│
├── presentation/                      # UI katmanı
│   ├── providers/                     # State management
│   │   ├── auth_provider.dart        # Auth + update check
│   │   ├── trousseau_provider.dart   # Çeyiz CRUD + paylaşım
│   │   ├── product_provider.dart     # Ürün CRUD + filtreleme
│   │   ├── category_provider.dart    # Kategori yönetimi
│   │   ├── feedback_provider.dart    # Geri bildirim
│   │   ├── onboarding_provider.dart  # Onboarding state
│   │   └── locale_provider.dart      # Dil seçimi (kullanılmıyor)
│   │
│   ├── router/
│   │   └── app_router.dart           # GoRouter config + guards
│   │
│   ├── screens/                       # Tüm ekranlar
│   │   ├── auth/
│   │   │   ├── login_screen.dart                # Giriş
│   │   │   ├── register_screen.dart             # Kayıt
│   │   │   ├── forgot_password_screen.dart      # Şifre sıfırlama
│   │   │   └── email_verification_screen.dart   # Email doğrulama
│   │   │
│   │   ├── onboarding/
│   │   │   └── onboarding_screen.dart           # İlk açılış tanıtımı
│   │   │
│   │   ├── home/
│   │   │   ├── home_screen.dart                 # Ana sayfa (3 tab)
│   │   │   └── statistics_screen.dart           # İstatistikler tab
│   │   │
│   │   ├── trousseau/
│   │   │   ├── create_trousseau_screen.dart     # Yeni çeyiz
│   │   │   ├── edit_trousseau_screen.dart       # Düzenle + Sil
│   │   │   ├── trousseau_detail_screen.dart     # Detay + ürün listesi
│   │   │   ├── share_trousseau_screen.dart      # Paylaşım yönetimi
│   │   │   └── shared_trousseau_list_screen.dart # Paylaşılanlar
│   │   │
│   │   ├── product/
│   │   │   ├── product_list_screen.dart         # Ürün listesi (kullanılmıyor)
│   │   │   ├── add_product_screen.dart          # Yeni ürün
│   │   │   ├── edit_product_screen.dart         # Düzenle
│   │   │   ├── product_detail_screen.dart       # Detay
│   │   │   └── category_management_screen.dart  # Kategori yönetimi
│   │   │
│   │   └── settings/
│   │       ├── settings_screen.dart             # Profil tab
│   │       ├── theme_settings_screen.dart       # Tema seçimi
│   │       ├── change_password_screen.dart      # Şifre değiştir
│   │       ├── feedback_screen.dart             # Geri bildirim gönder
│   │       ├── feedback_history_screen.dart     # Gönderilen feedbackler
│   │       ├── kac_saat_settings_screen.dart    # "Kaç Saat" ayarları
│   │       └── settings_screen_old.dart         # Eski versiyon (unused)
│   │
│   └── widgets/
│       └── common/                    # Yeniden kullanılabilir widget'lar
│           ├── app_button.dart       # ⭐ Buton sistemi (7 çeşit)
│           ├── app_input.dart        # ⭐ Input sistemi (5 çeşit)
│           ├── app_card.dart         # ⭐ Card sistemi (4 çeşit)
│           ├── loading_overlay.dart  # Loading göstergesi
│           ├── empty_state_widget.dart # Boş durum gösterimi
│           ├── custom_dialog.dart    # Dialog helper
│           ├── custom_app_bar.dart   # AppBar wrapper
│           ├── category_chip.dart    # Kategori chip
│           ├── filter_pill.dart      # Filtre chip
│           ├── draggable_fab.dart    # Sürüklenebilir FAB
│           ├── image_picker_widget.dart # Fotoğraf seçici
│           ├── icon_color_picker.dart   # Icon+renk seçici
│           ├── web_frame.dart        # Web için frame
│           ├── responsive_container.dart # Responsive wrapper
│           └── responsive_app_bar.dart  # Responsive AppBar
│
└── l10n/                              # Lokalizasyon
    ├── app_localizations.dart        # Manuel tanımlar
    ├── app_localizations_tr.dart     # Türkçe
    ├── app_localizations_en.dart     # İngilizce
    └── generated/                    # Auto-generated
        └── app_localizations*.dart
```

---

## 🏗️ MİMARİ VE PATTERN'LER

### 1. Clean Architecture (Basitleştirilmiş)

```
┌─────────────────────────────────────────┐
│         PRESENTATION LAYER              │
│  (Screens + Widgets + Providers)        │
└──────────────┬──────────────────────────┘
               │
               │ Providers çağırır
               ▼
┌─────────────────────────────────────────┐
│           DATA LAYER                    │
│  (Repositories + Models)                │
└──────────────┬──────────────────────────┘
               │
               │ Repositories çağırır
               ▼
┌─────────────────────────────────────────┐
│         FIREBASE SERVICES               │
│  (Firestore, Auth, Storage)             │
└─────────────────────────────────────────┘
```

### 2. State Management Pattern

**Provider + ChangeNotifier**

```dart
// 1. Provider tanımla (main.dart)
ChangeNotifierProvider(create: (_) => AuthProvider())

// 2. UI'da kullan
final authProvider = Provider.of<AuthProvider>(context);
// veya
context.watch<AuthProvider>()

// 3. State değiştir (Provider içinde)
notifyListeners(); // UI otomatik güncellenir
```

### 3. Repository Pattern

```dart
// Provider -> Repository -> Firebase
class ProductProvider {
  final ProductRepository _repository = ProductRepository();
  
  Future<void> addProduct(ProductModel product) async {
    await _repository.create(product); // Repository çağrısı
    notifyListeners();
  }
}

class ProductRepository {
  Future<void> create(ProductModel product) async {
    await FirebaseFirestore.instance
        .collection('products')
        .add(product.toFirestore()); // Firebase çağrısı
  }
}
```

### 4. Navigation Pattern

**GoRouter (Deklaratif + Guards)**

```dart
// Otomatik yönlendirme
redirect: (context, state) async {
  final user = FirebaseAuth.instance.currentUser;
  
  if (user == null && !isAuthRoute) {
    return '/login'; // Login'e yönlendir
  }
  
  if (user != null && !user.emailVerified) {
    return '/verify-email'; // Email doğrulama
  }
  
  return null; // Devam et
}
```

---

## 📊 VERİ MODELLERİ

### 1. UserModel
```dart
class UserModel {
  final String uid;                     // Firebase Auth UID
  final String email;
  final String displayName;
  final DateTime createdAt;
  final List<String> sharedTrousseauIds;       // Paylaşılan çeyizler
  final List<String> pinnedSharedTrousseauIds; // Pinlenmiş paylaşımlar
  final KacSaatSettings kacSaatSettings;       // "Kaç Saat" ayarları
}
```

### 2. TrousseauModel
```dart
class TrousseauModel {
  final String id;
  final String name;
  final String description;
  final String ownerId;                 // Sahibi
  final List<String> sharedWith;        // Görüntüleyiciler
  final List<String> editors;           // Editörler
  final double totalBudget;
  final double spentAmount;
  final int totalProducts;
  final int purchasedProducts;
  final Map<String, int> categoryCounts; // Kategori başına ürün sayısı
  
  // Helper metodlar
  bool canEdit(String userId);  // Düzenleyebilir mi?
  bool canView(String userId);  // Görüntüleyebilir mi?
}
```

### 3. ProductModel
```dart
class ProductModel {
  final String id;
  final String trousseauId;
  final String name;
  final double price;
  final int quantity;
  final String category;               // CategoryModel.id
  final List<String> images;           // Firebase Storage URLs (max 5)
  final String link, link2, link3;     // Ürün linkleri
  final bool isPurchased;
  final DateTime? purchaseDate;
  
  double get totalPrice => price * quantity; // Hesaplanan
}
```

### 4. CategoryModel
```dart
class CategoryModel {
  final String id;
  final String displayName;
  final IconData icon;
  final Color color;
  final bool isCustom;                 // Varsayılan mı, kullanıcı özel mi?
  
  // 6 varsayılan kategori (Salon, Mutfak, Banyo, Yatak Odası, Kıyafet, Diğer)
  static const List<CategoryModel> defaultCategories = [...];
}
```

### 5. FeedbackModel
```dart
class FeedbackModel {
  final String id;
  final String message;
  final int? rating;                   // 1-5 yıldız
  final String? userId;
  final String? adminReply;            // Admin cevabı
  final DateTime? repliedAt;
  
  bool get hasReply => adminReply != null;
}
```

---

## 🖥 EKRANLAR

### Kimlik Doğrulama (4 ekran)

**LoginScreen** - Email/şifre girişi + güncelleme kontrolü  
**RegisterScreen** - Kayıt formu (ad, email, şifre)  
**ForgotPasswordScreen** - Şifre sıfırlama linki gönderme  
**EmailVerificationScreen** - Email doğrulama bekleme

### Onboarding (1 ekran)

**OnboardingScreen** - İlk açılış tanıtımı (3 sayfa)

### Ana Uygulama (3 tab)

**HomeScreen** - Bottom navigation container
- Tab 0: İlk pinlenmiş çeyiz detayı
- Tab 1: İstatistikler (StatisticsScreen)
- Tab 2: Profil menüsü

**StatisticsScreen** - Bütçe analizi, kategori dağılımı, istatistikler

### Çeyiz Yönetimi (5 ekran)

**TrousseauDetailScreen** - Çeyiz detayı + ürün listesi (EN KARMAŞIK)  
**CreateTrousseauScreen** - Yeni çeyiz oluşturma  
**EditTrousseauScreen** - Düzenleme + silme  
**ShareTrousseauScreen** - Email ile paylaşım + yetki yönetimi  
**SharedTrousseauListScreen** - Benimle paylaşılan çeyizler + pin yönetimi

### Ürün Yönetimi (4 ekran)

**AddProductScreen** - Yeni ürün ekleme (fotoğraf, kategori, fiyat)  
**EditProductScreen** - Ürün düzenleme + fotoğraf yönetimi  
**ProductDetailScreen** - Ürün detayı + satın alma toggle  
**CategoryManagementScreen** - Özel kategori ekleme/düzenleme/silme

### Ayarlar (5 ekran)

**SettingsScreen** - Profil bilgileri + menü (Tab 2'de gösteriliyor)  
**ThemeSettingsScreen** - 4 tema seçimi  
**ChangePasswordScreen** - Şifre değiştirme  
**FeedbackScreen** - Geri bildirim gönderme (yıldız + mesaj)  
**FeedbackHistoryScreen** - Gönderilen geri bildirimler + admin cevapları  
**KacSaatSettingsScreen** - "Kaç Saat" özelliği ayarları

---

## 🚀 BAŞLANGIÇ KILAVUZU

### 1. Gereksinimler

```bash
Flutter SDK: >=3.0.0
Dart SDK: >=3.0.0
Firebase CLI (opsiyonel)
```

### 2. Kurulum

```bash
# 1. Bağımlılıkları yükle
flutter pub get

# 2. Firebase config oluştur (eğer yoksa)
flutterfire configure

# 3. Localization generate
flutter gen-l10n

# 4. Çalıştır
flutter run
```

### 3. Firebase Ayarları

**Firestore Collections:**
```
users/
  - {userId}/
      email, displayName, sharedTrousseauIds, pinnedSharedTrousseauIds

trousseaus/
  - {trousseauId}/
      name, ownerId, sharedWith, editors, totalBudget, spentAmount

products/
  - {productId}/
      trousseauId, name, price, category, images[], isPurchased

feedbacks/
  - {feedbackId}/
      userId, message, rating, adminReply

app_versions/
  - android/
      minVersion, currentVersion, forceUpdate, updateUrl
```

**Storage:**
```
products/{productId}/image_0.jpg
products/{productId}/image_1.jpg
...
```

### 4. Ortam Değişkenleri

Firebase config otomatik `firebase_options.dart` dosyasında.

---

## 📐 GELİŞTİRME KURALLARI

### 1. Yeni Tasarım Sistemi v2.0 (ZORUNLU)

**❌ YAPMA:**
```dart
padding: EdgeInsets.all(16),
fontSize: 14,
ElevatedButton(...)
```

**✅ YAP:**
```dart
import 'package:ceyiz_diz/core/theme/design_tokens.dart';
import 'package:ceyiz_diz/presentation/widgets/common/app_button.dart';

padding: AppSpacing.paddingMD,
fontSize: AppTypography.sizeBase,
AppPrimaryButton(label: 'Kaydet', onPressed: ...)
```

### 2. Widget Kullanımı

**Butonlar:**
```dart
AppPrimaryButton(...)    // Ana eylem (56dp)
AppSecondaryButton(...)  // İkincil (48dp)
AppTextButton(...)       // Metin button
AppIconButton(...)       // Sadece icon
AppDangerButton(...)     // Silme vb.
AppFAB(...)             // Floating action button
```

**Input'lar:**
```dart
AppTextInput(...)        // Standart input
AppPasswordInput(...)    // Şifre (otomatik visibility toggle)
AppSearchInput(...)      // Arama
AppDropdown<T>(...)     // Dropdown
AppFormSection(...)     // Form gruplaması
```

**Kartlar:**
```dart
AppCard(...)            // Genel kart
AppProductCard(...)     // Ürün kartı
AppStatCard(...)        // İstatistik kartı
AppInfoCard(...)        // Bilgi mesajı
```

### 3. Tasarım Prensipleri

**Jakob Yasası:** Standart UI pattern'leri kullan (settings icon ⚙️, delete 🗑️)  
**Fitts Yasası:** Minimum 48x48dp touch area  
**Hick Yasası:** Max 1 primary button/ekran  
**Miller Yasası:** Form'ları max 5 alana böl  
**Gestalt:** İlgili öğeleri yakın tut (4-8dp), grupları ayır (24-32dp)

### 4. State Management

```dart
// Provider kullan
final provider = Provider.of<XProvider>(context);

// Dinlemeyen erişim
Provider.of<XProvider>(context, listen: false);

// Extension kullan
context.watch<XProvider>();
context.read<XProvider>();

// State değiştir
void updateData() {
  // ... değişiklik yap
  notifyListeners(); // UI'ı güncelle
}
```

### 5. Navigation

```dart
// Git
context.push('/path');

// Git ve geri gelme
context.go('/path');

// Geri dön
context.pop();

// Parametreli
context.push('/trousseau/${trousseauId}');
```

### 6. Firebase İşlemleri

```dart
// DOĞRU: Repository kullan
await ProductRepository().create(product);

// YANLIŞ: Direkt Firebase çağrısı
await FirebaseFirestore.instance... // YAPMA!
```

### 7. Dosya İsimlendirme

```dart
// Ekranlar
xxx_screen.dart          // LoginScreen, HomeScreen

// Widget'lar
xxx_widget.dart          // ProductWidget (eğer özel ise)

// Provider'lar
xxx_provider.dart        // AuthProvider

// Model'ler
xxx_model.dart           // UserModel

// Repository
xxx_repository.dart      // ProductRepository
```

### 8. Yorum Standardı

```dart
/// Screen Name - Yeni Tasarım Sistemi v2.0
///
/// TASARIM KURALLARI:
/// ✅ Jakob Yasası: ...açıklama...
/// ✅ Fitts Yasası: ...açıklama...
/// ✅ Hick Yasası: ...açıklama...
/// ✅ Miller Yasası: ...açıklama...
/// ✅ Gestalt: ...açıklama...
```

### 9. Error Handling

```dart
try {
  await provider.someAction();
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Hata: $e'),
      backgroundColor: Colors.red,
    ),
  );
}
```

### 10. Loading State

```dart
bool _isLoading = false;

Future<void> _action() async {
  setState(() => _isLoading = true);
  try {
    // ... işlem
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

// UI'da
LoadingOverlay(
  isLoading: _isLoading,
  child: ...,
)
```

---

## 📝 NOTLAR

### Kullanılmayan Dosyalar
- `settings_screen_old.dart` - Eski versiyon (silinebilir)
- `product_list_screen.dart` - TrousseauDetailScreen kullanılıyor
- `design_system.dart` - Eski tasarım sistemi (design_tokens.dart kullan)

### Önemli Provider'lar
- **AuthProvider:** Login, register, update check
- **TrousseauProvider:** Çeyiz CRUD, paylaşım, pinleme
- **ProductProvider:** Ürün CRUD, filtreleme, arama
- **CategoryProvider:** Kategori yönetimi

### Firebase Güvenlik
- App Check aktif (Android: Play Integrity, Web: ReCAPTCHA)
- Firestore Rules dosyası: `firestore.rules`
- Storage Rules dosyası: `storage.rules`

### Localization
- Türkçe (tr) ve İngilizce (en) desteği
- Aktif dil: Türkçe (uygulama genelinde)
- `l10n.yaml` dosyası ile yapılandırılmış

---

## 🎓 ÖNERİLEN OKUMA SIRASI

1. `main.dart` - Uygulama başlangıcı
2. `app_router.dart` - Navigation yapısı
3. `design_tokens.dart` - Tasarım sistemi
4. `auth_provider.dart` - State management örneği
5. `login_screen.dart` - Ekran yapısı örneği
6. `app_button.dart` - Widget sistemi örneği
7. Kendi ekranını geliştir!

---

## 📞 YARDIM

Bir sorunla karşılaşırsan:
1. `YENI_TASARIM_REHBERI.md` dosyasına bak
2. Mevcut ekranlardaki örnekleri incele
3. Provider pattern'i anladığından emin ol
4. Design tokens kullanmayı unutma!

**Başarılar! 🚀**
