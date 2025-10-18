# ÇEYİZ DİZ - KAPSAMLI PROJE ÖZETİ

**v1.0.17+24** • **18 Ekim 2025** • **Flutter 3.35.5 / Dart 3.9.2** • **Production Ready**

---

## 📱 PROJE TANITIMI

**Çeyiz Diz**, evlilik çeyizlerini dijital ortamda organize etme, bütçe takibi ve paylaşım uygulamasıdır.

**Ana Özellikler:**
- 📦 Çoklu çeyiz yönetimi (CRUD işlemleri)
- 💰 Bütçe takibi ve harcama kontrolü
- 📸 Ürün fotoğraf galerisi (max 5/ürün, tam ekran görüntüleme)
- 🤝 Email ile paylaşım (3 yetki seviyesi)
- 📊 Kategori bazlı istatistikler ve ilerleme takibi
- 🎨 5 tema seçeneği
- 🔍 Arama ve filtreleme sistemi
- 📱 Android, iOS ve Web desteği

---

## 🗂 PROJE YAPISI

### Ana Klasör Yapısı

```
ceyiz_diz/
├── lib/
│   ├── main.dart                    # Uygulama giriş noktası
│   ├── firebase_options.dart        # Firebase yapılandırması
│   ├── core/                        # Çekirdek katman
│   ├── data/                        # Veri katmanı
│   ├── presentation/                # Sunum katmanı
│   └── l10n/                        # Lokalizasyon dosyaları
├── android/                         # Android platform dosyaları
├── ios/                             # iOS platform dosyaları
├── web/                             # Web platform dosyaları
├── pubspec.yaml                     # Dependencies ve proje bilgileri
└── README.md                        # Ana dokümantasyon
```

### core/ Klasörü (Çekirdek Katman)

```
core/
├── constants/
│   ├── app_constants.dart           # Uygulama sabitleri
│   ├── app_strings.dart             # String sabitleri
│   └── app_colors.dart              # Renk sabitleri
├── errors/
│   └── exceptions.dart              # Custom exception sınıfları
├── localization/
│   └── locale_provider.dart         # Dil yönetimi provider
├── services/
│   ├── version_service.dart         # Güncelleme kontrol servisi
│   ├── version_service_web.dart     # Web için version servis
│   ├── version_service_stub.dart    # Stub implementation
│   ├── excel_export_service.dart    # Excel export servisi
│   └── kac_saat_calculator.dart     # Kaç saat kaldı hesaplama
├── theme/
│   └── design_tokens.dart           # Tasarım token'ları (eski)
├── themes/
│   ├── app_theme.dart               # Tema konfigürasyonu
│   ├── design_system.dart           # 5 tema tanımı
│   └── theme_provider.dart          # Tema state management
└── utils/
    ├── validators.dart              # Form validasyon fonksiyonları
    ├── formatters.dart              # Genel formatter'lar
    └── currency_formatter.dart      # TL formatı (₺)
```

### data/ Klasörü (Veri Katmanı)

```
data/
├── models/                          # Veri modelleri
│   ├── user_model.dart              # Kullanıcı (id, email, name, photoUrl, createdAt, preferences)
│   ├── trousseau_model.dart         # Çeyiz (id, userId, title, budget, createdAt, products list)
│   ├── product_model.dart           # Ürün (id, name, category, price, quantity, imageUrl, purchaseDate)
│   ├── category_model.dart          # Kategori (id, name, icon, createdBy, isDefault, order)
│   └── feedback_model.dart          # Geri bildirim (id, userId, message, rating, createdAt, status)
├── repositories/                    # Firebase CRUD işlemleri
│   ├── auth_repository.dart         # Login, register, logout, resetPassword, updateProfile
│   ├── trousseau_repository.dart    # Çeyiz CRUD + getTotalBudget, getSharedTrousseaus
│   ├── product_repository.dart      # Ürün CRUD + getPurchased, getByCategory, getTotalSpent
│   ├── category_repository.dart     # Kategori CRUD + getDefault, getUserCategories
│   └── feedback_repository.dart     # Geri bildirim create, read, getUserFeedbacks
└── services/                        # Veri servisleri
    ├── firebase_service.dart        # Firebase initialization ve config
    └── storage_service.dart         # Firebase Storage (upload, delete, cache yönetimi)
```

### presentation/ Klasörü (Sunum Katmanı)

```
presentation/
├── providers/                       # State management (Provider pattern)
│   ├── auth_provider.dart           # Kimlik doğrulama state (login, register, logout)
│   ├── trousseau_provider.dart      # Çeyiz state (CRUD, filtering, sorting)
│   ├── product_provider.dart        # Ürün state (CRUD, kategori filtreleme)
│   ├── category_provider.dart       # Kategori state (CRUD, default kategoriler)
│   ├── feedback_provider.dart       # Geri bildirim state (create, read)
│   ├── onboarding_provider.dart     # Onboarding state (sayfa kontrolü)
│   └── locale_provider.dart         # Dil state (TR/EN) - core/localization'dan re-export
├── router/                          # Routing yapılandırması
│   └── app_router.dart              # GoRouter tanımları (21 route, guards, redirects)
├── screens/                         # Ekran bileşenleri (21 ekran)
│   ├── auth/                        # 4 kimlik doğrulama ekranı
│   │   ├── login_screen.dart        # Giriş ekranı (email/password, remember me)
│   │   ├── register_screen.dart     # Kayıt ekranı (email, password, name)
│   │   ├── forgot_password_screen.dart  # Şifre sıfırlama
│   │   └── phone_verification_screen.dart  # Telefon doğrulama (gelecek)
│   ├── home/                        # 2 ana ekran
│   │   ├── home_screen.dart         # Ana sayfa (4 tab: çeyiz, ürün, istatistik, ayarlar)
│   │   └── statistics_screen.dart   # İstatistikler (kategori grafikleri, bütçe)
│   ├── trousseau/                   # 5 çeyiz yönetim ekranı
│   │   ├── create_trousseau_screen.dart     # Çeyiz oluştur
│   │   ├── edit_trousseau_screen.dart       # Çeyiz düzenle
│   │   ├── trousseau_detail_screen.dart     # Çeyiz detay (ürün listesi)
│   │   ├── share_trousseau_screen.dart      # Çeyiz paylaş (3 yetki: view, edit, full)
│   │   └── shared_trousseau_list_screen.dart # Paylaşılanlar listesi
│   ├── product/                     # 5 ürün yönetim ekranı
│   │   ├── create_product_screen.dart       # Ürün oluştur (5 fotoğraf, kategori)
│   │   ├── edit_product_screen.dart         # Ürün düzenle
│   │   ├── product_detail_screen.dart       # Ürün detay (tam ekran foto, swipe)
│   │   ├── product_list_screen.dart         # Ürün listesi (filtreleme, sıralama)
│   │   └── category_management_screen.dart  # Kategori yönetimi (CRUD)
│   ├── settings/                    # 4 ayar ekranı
│   │   ├── settings_screen.dart             # Ana ayarlar (profil, tema, dil, about)
│   │   ├── theme_settings_screen.dart       # Tema seçimi (5 tema preview)
│   │   ├── feedback_screen.dart             # Geri bildirim gönder
│   │   ├── feedback_history_screen.dart     # Geri bildirim geçmişi
│   │   ├── change_password_screen.dart      # Şifre değiştir
│   │   └── kac_saat_settings_screen.dart    # Kaç saat ayarları
│   └── onboarding/                  # 1 onboarding ekranı
│       └── onboarding_screen.dart   # 3 sayfa tanıtım
└── widgets/                         # Yeniden kullanılabilir widget'lar
    ├── common/                      # 16 genel widget
    │   ├── app_button.dart          # Custom button (primary, secondary, text)
    │   ├── app_card.dart            # Custom card (elevation, padding variants)
    │   ├── app_input.dart           # Custom text field (validation, formatters)
    │   ├── category_chip.dart       # Kategori chip (icon + label)
    │   ├── custom_app_bar.dart      # Custom AppBar (actions, title)
    │   ├── custom_dialog.dart       # Custom dialog (title, message, actions)
    │   ├── draggable_fab.dart       # Sürüklenebilir FAB
    │   ├── empty_state_widget.dart  # Boş durum widget (icon, message, action)
    │   ├── filter_pill.dart         # Filtre pill (aktif/pasif state)
    │   ├── fullscreen_image_viewer.dart # Tam ekran fotoğraf (swipe, zoom)
    │   ├── icon_color_picker.dart   # Icon ve renk seçici
    │   ├── image_picker_widget.dart # Fotoğraf seçme widget (5 fotoğraf)
    │   ├── loading_overlay.dart     # Yükleniyor overlay (shimmer)
    │   ├── responsive_app_bar.dart  # Responsive AppBar (web/mobile)
    │   ├── responsive_container.dart # Responsive container (max width)
    │   └── web_frame.dart           # Web frame (max 1200px)
    └── dialogs/                     # 1 dialog
        └── update_available_dialog.dart # Güncelleme dialog
```

---

## � EKRANLAR VE ROUTE'LAR

### 21 Ekran ve Route Path'leri

**🔐 Auth (4 Ekran)**
| Ekran | Route | Açıklama |
|-------|-------|----------|
| LoginScreen | `/login` | Email/password ile giriş, "Beni hatırla" |
| RegisterScreen | `/register` | Yeni kullanıcı kaydı (email, şifre, ad) |
| ForgotPasswordScreen | `/forgot-password` | Şifre sıfırlama email gönder |
| EmailVerificationScreen | `/verify-email/:email` | Email doğrulama bekleme ekranı |

**🏠 Home (2 Ekran)**
| Ekran | Route | Açıklama |
|-------|-------|----------|
| HomeScreen | `/` | Ana sayfa (4 tab: çeyizler, ürünler, istatistikler, ayarlar) |
| StatisticsScreen | `/` (Tab 3) | Kategori grafikleri, bütçe analizi |

**👗 Trousseau (5 Ekran)**
| Ekran | Route | Açıklama |
|-------|-------|----------|
| CreateTrousseauScreen | `/create-trousseau` | Yeni çeyiz oluştur (başlık, bütçe) |
| TrousseauDetailScreen | `/trousseau/:id` | Çeyiz detay (ürün listesi, ilerleme) |
| EditTrousseauScreen | `/trousseau/:id/edit` | Çeyiz düzenle |
| ShareTrousseauScreen | `/trousseau/:id/share` | Email ile paylaş (3 yetki seviyesi) |
| SharedTrousseauListScreen | `/shared-trousseaus` | Benimle paylaşılan çeyizler listesi |

**📦 Product (5 Ekran)**
| Ekran | Route | Açıklama |
|-------|-------|----------|
| ProductListScreen | `/trousseau/:id/products` | Çeyizdeki ürünler (filtreleme, sıralama) |
| AddProductScreen | `/trousseau/:id/products/add` | Yeni ürün ekle (5 fotoğraf, kategori, fiyat) |
| ProductDetailScreen | `/trousseau/:id/products/:productId` | Ürün detay (tam ekran foto, swipe) |
| EditProductScreen | `/trousseau/:id/products/:productId/edit` | Ürün düzenle |
| CategoryManagementScreen | `/trousseau/:id/products/categories` | Kategori CRUD (özel kategoriler) |

**⚙️ Settings (4 Ekran)**
| Ekran | Route | Açıklama |
|-------|-------|----------|
| SettingsScreen | `/settings` | Ana ayarlar (profil, tema, dil, hakkında) |
| ThemeSettingsScreen | `/settings/theme` | 5 tema preview ve seçim |
| ChangePasswordScreen | `/settings/change-password` | Şifre değiştir |
| FeedbackScreen | `/settings/feedback` | Geri bildirim gönder (rating, mesaj) |
| FeedbackHistoryScreen | `/settings/feedback/history` | Gönderilen geri bildirimler |
| KacSaatSettingsScreen | `/settings/kac-saat` | Kaç saat hesaplama ayarları |

**🚀 Onboarding (1 Ekran)**
| Ekran | Route | Açıklama |
|-------|-------|----------|
| OnboardingScreen | `/onboarding` | 3 sayfa tanıtım (ilk açılışta) |

**Route Özellikleri:**
- **Guards:** Onboarding → Auth → Email verification → Home
- **Redirect Logic:** Unauthenticated → `/login`, Authenticated → `/`
- **Debounce:** 500ms (aynı redirect tekrarlanmaz)
- **Nested Routes:** Trousseau ve Product ekranları iç içe
- **Error Handling:** 404 sayfası + "Ana Sayfaya Dön" butonu

---

## 🎯 PROVIDER'LAR (STATE MANAGEMENT)

### 5 Provider ve Sorumlulukları

#### 1. **AuthProvider** (Kimlik Doğrulama)
**Sorumluluk:** Kullanıcı oturumu, profil yönetimi, email doğrulama

**Ana Metodlar:**
- `signIn(email, password)` - Giriş yap, "Beni hatırla" desteği
- `signUp(email, password, name)` - Yeni kullanıcı kaydı + Firestore dokümanı
- `signOut()` - Çıkış yap, cache temizle
- `resetPassword(email)` - Şifre sıfırlama email gönder
- `updateProfile(name, photoUrl)` - Profil güncelle (ad, fotoğraf)
- `changePassword(oldPassword, newPassword)` - Şifre değiştir (re-authentication)
- `deleteAccount(password)` - Hesap sil (Firestore + Storage + Auth)
- `sendEmailVerification()` - Email doğrulama gönder
- `checkEmailVerified()` - Email doğrulandı mı kontrol et
- `updateKacSaatSettings(settings)` - "Kaç saat" ayarlarını güncelle
- `_checkForUpdates()` - Remote Config ile versiyon kontrolü

**Kullanım:** Login, Register, Settings, Email Verification ekranları

---

#### 2. **TrousseauProvider** (Çeyiz Yönetimi)
**Sorumluluk:** Çeyiz CRUD, paylaşım, filtreleme, sıralama

**Ana Metodlar:**
- `loadTrousseaus()` - Kullanıcı çeyizlerini yükle (owned + shared)
- `createTrousseau(title, budget)` - Yeni çeyiz oluştur
- `updateTrousseau(id, title, budget)` - Çeyiz güncelle
- `deleteTrousseau(id)` - Çeyiz sil (products cascade)
- `shareTrousseau(id, email, permission)` - Email ile paylaş (view/edit/full)
- `removeShare(id, email)` - Paylaşımı kaldır
- `getTrousseauStream(userId)` - Realtime çeyiz stream
- `getSingleTrousseauStream(id)` - Tekil çeyiz stream
- `pinSharedTrousseau(id)` - Paylaşılan çeyizi sabitle
- `unpinSharedTrousseau(id)` - Sabitlemeyi kaldır
- `togglePinSharedTrousseau(id)` - Pin durumunu değiştir

**State:**
- `filteredTrousseaus` - Filtrelenmiş çeyiz listesi
- `selectedSortOption` - Seçili sıralama (date/name/budget)
- `selectedFilter` - Seçili filtre (all/owned/shared)

**Kullanım:** Home, Trousseau Detail, Create, Edit, Share ekranları

---

#### 3. **ProductProvider** (Ürün Yönetimi)
**Sorumluluk:** Ürün CRUD, fotoğraf yönetimi, kategori filtreleme

**Ana Metodlar:**
- `loadProducts(trousseauId)` - Çeyizdeki ürünleri yükle
- `addProduct(name, category, price, quantity, images)` - Yeni ürün ekle (5 fotoğraf)
- `updateProduct(id, name, category, price, quantity, images)` - Ürün güncelle
- `deleteProduct(id)` - Ürün sil (Storage'dan fotoğraflar cascade)
- `cloneProductToTrousseau(productId, targetTrousseauId)` - Ürün kopyala
- `togglePurchaseStatus(id)` - Satın alındı durumunu değiştir
- `getProductStream(trousseauId)` - Realtime ürün stream
- `_updateTrousseauStats(trousseauId)` - Çeyiz istatistiklerini güncelle

**State:**
- `filteredProducts` - Filtrelenmiş ürün listesi
- `selectedCategory` - Seçili kategori filtresi
- `searchQuery` - Arama sorgusu
- `selectedSortOption` - Seçili sıralama (date/name/price)

**Kullanım:** Product List, Add, Edit, Detail, Category Management ekranları

---

#### 4. **CategoryProvider** (Kategori Yönetimi)
**Sorumluluk:** Varsayılan + özel kategoriler, CRUD işlemleri

**Ana Metodlar:**
- `bind(trousseauId, userId)` - Trousseau'ya bağlan (8 varsayılan + özel kategoriler)
- `disposeBinding()` - Bağlantıyı kopar (stream kapat)
- `addCustom(id, name, icon, color, sortOrder)` - Özel kategori ekle
- `removeCategory(id)` - Kategori sil (varsayılanlar silinemez)
- `updateCategory(id, name, icon, color)` - Kategori güncelle

**Varsayılan Kategoriler (8):**
1. 🪑 Mobilya
2. 🍳 Mutfak
3. 🛏️ Yatak
4. 📱 Elektronik
5. ✨ Dekorasyon
6. 👗 Tekstil
7. 🚿 Banyo
8. � Diğer

**State:**
- `categories` - Tüm kategoriler (default + custom)
- `isBound` - Trousseau'ya bağlı mı?
- `_subscription` - Firestore stream subscription

**Kullanım:** Product Add/Edit, Category Management ekranları

---

#### 5. **ThemeProvider** (Tema Yönetimi)
**Sorumluluk:** 5 tema seçimi, SharedPreferences persistency

**Ana Metodlar:**
- `setTheme(AppThemeType)` - Temayı değiştir (persist to SharedPreferences)
- `_loadTheme()` - Kaydedilmiş temayı yükle

**Temalar (5):**
1. `defaultTheme` - Varsayılan (Açık Mavi) #2563EB
2. `modern` - Monochrome (Siyah-Beyaz) - Yüksek kontrast
3. `ocean` - Mor Okyanus (Koyu Mor) #A78BFA
4. `forest` - Orman Yeşili (Koyu Yeşil) #34D399
5. `sunset` - Gün Batımı (Koyu Turuncu) #FB923C

**State:**
- `currentThemeType` - Aktif tema enum değeri
- `currentTheme` - ThemeData instance (Material 3)

**Kullanım:** Settings, Theme Settings ekranları, main.dart

---

## � MODELLER (DATA MODELS)

### 5 Veri Modeli ve Field'leri

#### 1. **UserModel** (Kullanıcı)
**Firestore Collection:** `users/`

**Field'ler:**
- `uid` (String) - Firebase Auth UID (primary key)
- `email` (String) - Email adresi
- `emailLower` (String) - Normalized email (case-insensitive arama)
- `displayName` (String) - Kullanıcı adı
- `photoURL` (String?) - Profil fotoğrafı URL'i
- `createdAt` (DateTime) - Kayıt tarihi
- `lastLoginAt` (DateTime) - Son giriş tarihi
- `trousseauIds` (List<String>) - Sahip olunan çeyiz ID'leri
- `sharedTrousseauIds` (List<String>) - Paylaşılan çeyiz ID'leri
- `pinnedSharedTrousseauIds` (List<String>) - Sabitlenmiş paylaşılan çeyiz ID'leri
- `kacSaatSettings` (KacSaatSettings) - "Kaç saat" hesaplama ayarları

**İlişkiler:** 1-N (User → Trousseau), M-N (User ↔ SharedTrousseau)

**Kullanım:** AuthProvider, Settings ekranları

---

#### 2. **TrousseauModel** (Çeyiz)
**Firestore Collection:** `trousseaus/`

**Field'ler:**
- `id` (String) - Çeyiz ID (primary key)
- `name` (String) - Çeyiz adı
- `description` (String) - Açıklama
- `ownerId` (String) - Sahip kullanıcı ID (foreign key)
- `sharedWith` (List<String>) - Paylaşılan kullanıcı email listesi
- `editors` (List<String>) - Edit yetkisi olan email'ler
- `createdAt` (DateTime) - Oluşturma tarihi
- `updatedAt` (DateTime) - Güncelleme tarihi
- `categoryCounts` (Map<String, int>) - Kategori başına ürün sayıları
- `totalProducts` (int) - Toplam ürün sayısı
- `purchasedProducts` (int) - Satın alınan ürün sayısı
- `totalBudget` (double) - Toplam bütçe
- `spentAmount` (double) - Harcanan miktar
- `coverImage` (String) - Kapak fotoğrafı URL'i
- `settings` (Map<String, dynamic>) - Özel ayarlar

**İlişkiler:** N-1 (Trousseau → User), 1-N (Trousseau → Product)

**Kullanım:** TrousseauProvider, Home, Create/Edit Trousseau ekranları

---

#### 3. **ProductModel** (Ürün)
**Firestore Collection:** `products/`

**Field'ler:**
- `id` (String) - Ürün ID (primary key)
- `trousseauId` (String) - Bağlı çeyiz ID (foreign key)
- `name` (String) - Ürün adı
- `description` (String) - Açıklama
- `price` (double) - Fiyat
- `category` (String) - Kategori ID
- `images` (List<String>) - Fotoğraf URL'leri (max 5)
- `link` (String) - Satın alma linki 1
- `link2` (String) - Satın alma linki 2
- `link3` (String) - Satın alma linki 3
- `isPurchased` (bool) - Satın alındı mı?
- `purchaseDate` (DateTime?) - Satın alma tarihi
- `purchasedBy` (String) - Satın alan kullanıcı
- `quantity` (int) - Miktar
- `addedBy` (String) - Ekleyen kullanıcı ID
- `createdAt` (DateTime) - Oluşturma tarihi
- `updatedAt` (DateTime) - Güncelleme tarihi
- `customFields` (Map<String, dynamic>) - Özel alanlar

**İlişkiler:** N-1 (Product → Trousseau), N-1 (Product → Category)

**Kullanım:** ProductProvider, Product List/Add/Edit/Detail ekranları

---

#### 4. **CategoryModel** (Kategori)
**Firestore Collection:** `categories/` (özel kategoriler için)

**Field'ler:**
- `id` (String) - Kategori ID (primary key)
- `name` (String) - Kategori slug (livingroom, kitchen, etc.)
- `displayName` (String) - Görünen ad (Salon, Mutfak, etc.)
- `icon` (IconData) - Material Icon
- `color` (Color) - Kategori rengi
- `sortOrder` (int) - Sıralama önceliği
- `isCustom` (bool) - Özel kategori mi?

**Varsayılan Kategoriler (6):**
1. Salon (livingroom) - 🪑 #6B4EFF
2. Mutfak (kitchen) - 🍳 #FF6B9D
3. Banyo (bathroom) - 🚿 #00C896
4. Yatak Odası (bedroom) - 🛏️ #2196F3
5. Kıyafet (clothing) - 👗 #9C27B0
6. Diğer (other) - 📦 #607D8B

**İlişkiler:** 1-N (Category → Product)

**Kullanım:** CategoryProvider, Product Add/Edit, Category Management ekranları

---

#### 5. **FeedbackModel** (Geri Bildirim)
**Firestore Collection:** `feedbacks/`

**Field'ler:**
- `id` (String) - Geri bildirim ID (primary key)
- `message` (String) - Geri bildirim mesajı
- `userId` (String?) - Gönderen kullanıcı ID (nullable - anonymous)
- `email` (String?) - Gönderen email
- `rating` (int?) - Değerlendirme (1-5)
- `appVersion` (String?) - Uygulama versiyonu (1.0.17+24)
- `platform` (String?) - Platform (Android/iOS/Web)
- `createdAt` (DateTime) - Gönderim tarihi
- `adminReply` (String?) - Admin yanıtı
- `repliedAt` (DateTime?) - Yanıt tarihi
- `repliedBy` (String?) - Yanıtlayan admin ID

**İlişkiler:** N-1 (Feedback → User, optional)

**Computed Properties:**
- `hasReply` (bool) - Admin yanıtı var mı?

**Kullanım:** FeedbackProvider, Feedback/Feedback History ekranları

---

## 🧩 WIDGET'LAR

### 17 Yeniden Kullanılabilir Widget

#### 🎨 UI Components (6)
| Widget | Dosya | Açıklama |
|--------|-------|----------|
| AppButton | app_button.dart | Custom button (primary, secondary, text variants) |
| AppCard | app_card.dart | Custom card (elevation, padding variants) |
| AppInput | app_input.dart | Custom text field (validation, formatters) |
| CategoryChip | category_chip.dart | Kategori chip (icon + label, aktif/pasif state) |
| FilterPill | filter_pill.dart | Filtre pill (aktif/pasif state, counter badge) |
| IconColorPicker | icon_color_picker.dart | Icon ve renk seçici dialog |

#### 📱 Layout & Navigation (4)
| Widget | Dosya | Açıklama |
|--------|-------|----------|
| CustomAppBar | custom_app_bar.dart | Custom AppBar (actions, title, back button) |
| ResponsiveAppBar | responsive_app_bar.dart | Responsive AppBar (web/mobile farklı layout) |
| ResponsiveContainer | responsive_container.dart | Responsive container (max width 1200px) |
| WebFrame | web_frame.dart | Web frame (merkezi max-width container) |

#### 🖼️ Media & Images (2)
| Widget | Dosya | Açıklama |
|--------|-------|----------|
| ImagePickerWidget | image_picker_widget.dart | Fotoğraf seçme (5 fotoğraf, grid layout) |
| FullscreenImageViewer | fullscreen_image_viewer.dart | Tam ekran fotoğraf (swipe, zoom, dismissable) |

#### � Dialogs & Overlays (3)
| Widget | Dosya | Açıklama |
|--------|-------|----------|
| CustomDialog | custom_dialog.dart | Custom dialog (title, message, actions) |
| UpdateAvailableDialog | update_available_dialog.dart | Güncelleme uyarısı dialog |
| LoadingOverlay | loading_overlay.dart | Yükleniyor overlay (shimmer effect) |

#### 🎯 Special Purpose (2)
| Widget | Dosya | Açıklama |
|--------|-------|----------|
| EmptyStateWidget | empty_state_widget.dart | Boş durum (icon, message, CTA button) |
| DraggableFab | draggable_fab.dart | Sürüklenebilir FAB (long press to drag) |

**Widget Kullanım İstatistikleri:**
- En çok kullanılan: AppButton, AppCard, AppInput, LoadingOverlay
- En az kullanılan: DraggableFab, IconColorPicker
- Responsive: 3 widget (ResponsiveAppBar, ResponsiveContainer, WebFrame)
- Platform-specific: FullscreenImageViewer (gesture farklılıkları)

---

## � FIREBASE KOLEKSIYONLARI

### 5 Firestore Collection Şeması

#### 1. **users/** (Kullanıcılar)
```typescript
{
  uid: string,                    // Primary Key (Firebase Auth UID)
  email: string,
  emailLower: string,             // Normalized (case-insensitive search)
  displayName: string,
  photoURL: string | null,
  createdAt: Timestamp,
  lastLoginAt: Timestamp,
  trousseauIds: string[],         // Owned trousseau IDs
  sharedTrousseauIds: string[],   // Shared trousseau IDs
  pinnedSharedTrousseauIds: string[],
  kacSaatSettings: {
    enabled: boolean,
    targetDate: Timestamp | null,
    notificationEnabled: boolean
  }
}
```
**İndeksler:** `email`, `emailLower`

---

#### 2. **trousseaus/** (Çeyizler)
```typescript
{
  id: string,                     // Primary Key (auto-generated)
  name: string,
  description: string,
  ownerId: string,                // Foreign Key → users.uid
  sharedWith: string[],           // Email list (view permission)
  editors: string[],              // Email list (edit permission)
  createdAt: Timestamp,
  updatedAt: Timestamp,
  categoryCounts: {               // { "kitchen": 12, "livingroom": 8, ... }
    [categoryId: string]: number
  },
  totalProducts: number,
  purchasedProducts: number,
  totalBudget: number,            // TL
  spentAmount: number,            // TL
  coverImage: string,             // Storage URL
  settings: {
    visibility: "private" | "shared",
    allowComments: boolean,
    currency: "TRY" | "USD" | "EUR" | "GBP"
  }
}
```
**İndeksler:** `ownerId`, `sharedWith`, `createdAt`

**Queries:**
- Owned: `where('ownerId', '==', userId)`
- Shared: `where('sharedWith', 'array-contains', email)`

---

#### 3. **products/** (Ürünler)
```typescript
{
  id: string,                     // Primary Key (auto-generated)
  trousseauId: string,            // Foreign Key → trousseaus.id
  name: string,
  description: string,
  price: number,                  // TL
  category: string,               // Category ID (e.g., "kitchen")
  images: string[],               // Storage URLs (max 5)
  link: string,                   // Purchase link 1
  link2: string,                  // Purchase link 2
  link3: string,                  // Purchase link 3
  isPurchased: boolean,
  purchaseDate: Timestamp | null,
  purchasedBy: string,            // User ID
  quantity: number,
  addedBy: string,                // User ID
  createdAt: Timestamp,
  updatedAt: Timestamp,
  customFields: {                 // User-defined fields
    [key: string]: any
  }
}
```
**İndeksler:** `trousseauId`, `category`, `isPurchased`, `createdAt`

**Queries:**
- By Trousseau: `where('trousseauId', '==', trousseauId)`
- By Category: `where('category', '==', categoryId)`
- Purchased: `where('isPurchased', '==', true)`

---

#### 4. **feedbacks/** (Geri Bildirimler)
```typescript
{
  id: string,                     // Primary Key (auto-generated)
  message: string,
  userId: string | null,          // Foreign Key → users.uid (nullable)
  email: string | null,
  rating: number | null,          // 1-5
  appVersion: string | null,      // "1.0.17+24"
  platform: string | null,        // "Android" | "iOS" | "Web"
  createdAt: Timestamp,
  
  // Admin reply fields
  adminReply: string | null,
  repliedAt: Timestamp | null,
  repliedBy: string | null        // Admin user ID
}
```
**İndeksler:** `userId`, `createdAt`, `rating`

**Queries:**
- By User: `where('userId', '==', userId)`
- Recent: `orderBy('createdAt', 'desc')`

---

#### 5. **app_versions/** (Uygulama Versiyonları)
```typescript
{
  id: string,                     // Version string (e.g., "1.0.17")
  minimumVersion: string,         // Minimum required version
  latestVersion: string,          // Latest available version
  isForceUpdate: boolean,         // Force update required?
  updateMessage: string,          // Update message (Turkish)
  updateMessageEn: string,        // Update message (English)
  releaseNotes: string[],         // Release notes (Turkish)
  releaseNotesEn: string[],       // Release notes (English)
  createdAt: Timestamp,
  platform: "android" | "ios" | "web"
}
```
**İndeksler:** `platform`, `createdAt`

**Kullanım:** RemoteConfig + VersionService (app startup version check)

---

**Firebase Rules (Özet):**
- `users/`: Read (own doc), Write (own doc)
- `trousseaus/`: Read (owner or sharedWith), Write (owner or editors)
- `products/`: Read (trousseau access), Write (trousseau edit access)
- `feedbacks/`: Create (authenticated), Read (own docs)
- `app_versions/`: Read (all), Write (admin only)

**Storage Structure:**
```
users/
  {userId}/
    profile.jpg
trousseaus/
  {trousseauId}/
    products/
      {productId}/
        image_0.jpg
        image_1.jpg
        ...
```

---

##  TEKNOLOJİ VE BAĞIMLILIKLAR

### Framework & SDK
- **Flutter:** 3.35.5 (Stable)
- **Dart:** 3.9.2
- **Material Design:** Material 3

### 📦 Dependencies (Kategorize)

#### 🔥 Firebase (5)
| Package | Version | Kullanım |
|---------|---------|----------|
| firebase_core | ^3.8.0 | Firebase initialization |
| firebase_auth | ^5.3.3 | Email/password authentication |
| cloud_firestore | ^5.5.0 | Database (users, trousseaus, products, feedbacks) |
| firebase_storage | ^12.3.7 | Fotoğraf depolama (profile pics, product images) |
| firebase_app_check | ^0.3.2+10 | Bot koruması, API güvenliği |

#### 🎯 State Management (1)
| Package | Version | Kullanım |
|---------|---------|----------|
| provider | ^6.1.2 | State management (5 provider: Auth, Trousseau, Product, Category, Theme) |

#### 🧭 UI & Navigation (4)
| Package | Version | Kullanım |
|---------|---------|----------|
| go_router | ^14.6.2 | Declarative routing (21 route, guards, nested routes) |
| flutter_svg | ^2.0.10 | SVG rendering (icons, logos) |
| cached_network_image | ^3.4.1 | Image caching (product photos, profile pics) |
| cupertino_icons | ^1.0.8 | iOS-style icons |

#### 🛠️ Utilities (8)
| Package | Version | Kullanım |
|---------|---------|----------|
| image_picker | ^1.1.2 | Fotoğraf seçme (gallery, camera - max 5/product) |
| uuid | ^4.5.1 | Unique ID generation (products, temp files) |
| shared_preferences | ^2.3.3 | Local storage (theme, onboarding, remember me) |
| intl | ^0.20.2 | Internationalization (TR/EN, date formatting) |
| url_launcher | ^6.3.1 | External link opening (product links, email) |
| package_info_plus | ^8.0.2 | App version info (version check, about screen) |
| excel | ^4.0.6 | Excel export (trousseau lists) |
| share_plus | ^10.1.3 | Share functionality (trousseau sharing) |
| path_provider | ^2.1.5 | File path access (temp files, cache) |

#### 🎨 UI Components (3)
| Package | Version | Kullanım |
|---------|---------|----------|
| shimmer | ^3.0.0 | Loading shimmer effect (skeleton screens) |
| flutter_staggered_grid_view | ^0.7.0 | Staggered grid layout (product gallery) |
| smooth_page_indicator | ^1.2.0+3 | Page indicator (onboarding, image carousel) |

#### 🧪 Dev Dependencies (3)
| Package | Version | Kullanım |
|---------|---------|----------|
| flutter_test | SDK | Unit/widget testing |
| flutter_lints | ^5.0.0 | Linting rules (code quality) |
| flutter_launcher_icons | ^0.13.1 | App icon generation |

**Toplam:** 24 dependency (5 Firebase + 1 State + 4 UI/Nav + 8 Utility + 3 UI Component + 3 Dev)

---

## 🎨 DESIGN SYSTEM

### 5 Tema Paleti

#### 1. **Varsayılan (defaultTheme)** - Açık Tema
```dart
Primary:    #2563EB  // Professional blue
Secondary:  #3B82F6  // Bright blue
Tertiary:   #60A5FA  // Light blue
Background: #F8FAFC  // Very light gray-blue
Surface:    #FFFFFF  // Pure white
Outline:    #E2E8F0  // Soft gray border
```
**Kullanım:** Standart kullanıcılar, profesyonel görünüm

---

#### 2. **Monokrom (modern)** - Koyu Tema
```dart
Primary:    #FFFFFF  // Pure white (primary text/accent)
Secondary:  #B3B3B3  // Light gray (secondary actions)
Tertiary:   #CCCCCC  // Lighter gray (tertiary elements)
Background: #000000  // Pure black background
Surface:    #1A1A1A  // Dark gray surface (cards)
Outline:    #333333  // Medium gray border
```
**Özellik:** Gerçek monokrom (sadece siyah-beyaz-gri tonları), yüksek kontrast  
**Kullanım:** Görsel netlik, minimalist tercih

---

#### 3. **Mor Okyanus (ocean)** - Koyu Tema
```dart
Primary:    #A78BFA  // Soft purple (desaturated)
Secondary:  #C4B5FD  // Light purple
Tertiary:   #DDD6FE  // Very light purple
Background: #0F0F14  // Very dark gray
Surface:    #1A1A23  // Dark gray-purple tint
Outline:    #2D2D3D  // Subtle purple-gray border
```
**İlham:** Discord renk sistemi  
**Kullanım:** Sakin, gizemli atmosfer

---

#### 4. **Orman Yeşili (forest)** - Koyu Tema
```dart
Primary:    #34D399  // Emerald green (desaturated)
Secondary:  #6EE7B7  // Light emerald
Tertiary:   #A7F3D0  // Mint green
Background: #0A0E0D  // Very dark gray
Surface:    #1A1F1E  // Dark gray-green tint
Outline:    #2D3432  // Subtle green-gray border
```
**İlham:** Material Design yeşil tonları  
**Kullanım:** Doğal, huzurlu hissettirir

---

#### 5. **Gün Batımı (sunset)** - Koyu Tema
```dart
Primary:    #F59E0B  // Warm orange
Secondary:  #EC4899  // Pink
Tertiary:   #A855F7  // Purple
Background: #0F0A14  // Very dark purple-tinted
Surface:    #1A1420  // Dark purple-gray
Outline:    #3D2D45  // Purple-tinted border
```
**İlham:** Gün batımı renkleri (turuncu, pembe, mor)  
**Kullanım:** Sıcak, enerji dolu, romantik

---

### Design Tokens

#### 📐 Spacing (5 boyut)
```dart
spaceXs:  4px   // Minimal padding/margin
spaceSm:  8px   // Small padding
spaceMd:  16px  // Medium padding (default)
spaceLg:  24px  // Large padding
spaceXl:  32px  // Extra large padding
```

#### 🔲 Radius (4 boyut)
```dart
radiusSm: 8px   // Small corners (chips, pills)
radiusMd: 12px  // Medium corners (buttons, cards)
radiusLg: 16px  // Large corners (modals, sheets)
radiusXl: 24px  // Extra large (hero images)
```

#### 🌑 Elevation (4 seviye)
```dart
elev1: 0   // Flat (no shadow)
elev2: 1   // Subtle shadow (cards)
elev4: 3   // Medium shadow (dialogs)
elev8: 6   // Strong shadow (FAB, alerts)
```

#### ⏱️ Animation Durations
```dart
fast:   150ms  // Hover effects
normal: 250ms  // Button press, page transitions
slow:   350ms  // Complex animations
```

#### 🔤 Typography (Inter Font Family)
```dart
displayLarge:   36px / w700 / -0.8 letter-spacing
displayMedium:  32px / w700 / -0.6 letter-spacing
displaySmall:   28px / w600 / -0.4 letter-spacing
headlineLarge:  24px / w600 / -0.2 letter-spacing
headlineMedium: 22px / w600
headlineSmall:  20px / w600
titleLarge:     18px / w600
titleMedium:    16px / w600
titleSmall:     14px / w600
bodyLarge:      16px / w400
bodyMedium:     14px / w400
bodySmall:      12px / w400
labelLarge:     14px / w600 / +0.2 letter-spacing
labelMedium:    12px / w600 / +0.3 letter-spacing
labelSmall:     11px / w500 / +0.4 letter-spacing
```

#### 🎯 Semantic Colors (Tüm temalarda sabit)
```dart
Success: #10B981  // Green (başarılı işlemler)
Warning: #F59E0B  // Orange (uyarılar)
Danger:  #EF4444  // Red (hatalar, silme)
Info:    #3B82F6  // Blue (bilgi mesajları)
```

#### 📊 Statistics Tile Colors
```dart
Budget:    Theme primary (dinamik)
Spent:     Theme secondary (dinamik)
Total:     Theme tertiary (dinamik)
Completed: Success color (sabit)
```

**Platform-Aware Alphas:**
- Web: Light 0.08, Dark 0.15 (daha transparan)
- Mobile: Light 0.10, Dark 0.18 (daha opak)

---

## � FEATURE FLOW'LARI

### Ana Kullanıcı Senaryoları

#### Senaryo 1: Yeni Kullanıcı Kaydı ve İlk Çeyiz
```
1. Onboarding Screen (3 sayfa)
   └─> Swipe ile özellik tanıtımı
   
2. Register Screen
   └─> Email, şifre, ad gir
   └─> Firebase Auth: createUserWithEmailAndPassword()
   └─> Firestore: users/ collection'a doküman ekle
   └─> Email doğrulama gönder
   
3. Email Verification Screen
   └─> Email'i kontrol et mesajı
   └─> "Tekrar Gönder" butonu (throttled)
   └─> Email doğrulandı → Home'a redirect
   
4. Home Screen (Çeyiz Sekmesi)
   └─> Empty state: "Henüz çeyiziniz yok"
   └─> + FAB tıkla
   
5. Create Trousseau Screen
   └─> Çeyiz adı gir (ör: "Evlilik Çeyizim")
   └─> Bütçe belirle (ör: 150,000 TL)
   └─> Kaydet → Firestore: trousseaus/ collection'a ekle
   └─> Home'a dön → Çeyiz kartı görünür
```

---

#### Senaryo 2: Ürün Ekleme ve Fotoğraf Yükleme
```
1. Trousseau Detail Screen
   └─> Çeyiz kartına tıkla
   └─> Ürün listesi boş → "Ürün ekle" butonu
   
2. Add Product Screen
   └─> Ürün adı gir (ör: "Beyaz Halı")
   └─> Kategori seç (ör: "Salon")
   └─> Fiyat gir (ör: 8,500 TL)
   └─> Miktar belirle (ör: 1 adet)
   └─> 📷 Fotoğraf ekle (max 5):
       - Gallery'den seç veya kameradan çek
       - ImagePickerWidget: Grid layout (2x3)
       - Her fotoğraf 56dp thumbnail
   └─> Link ekle (opsiyonel)
   └─> Kaydet:
       - Storage'a upload (users/{uid}/trousseaus/{id}/products/{productId}/image_0.jpg)
       - Firestore: products/ collection'a ekle
       - TrousseauModel.totalBudget ve categoryCounts güncelle
   
3. Product Detail Screen
   └─> Ürün kartına tıkla
   └─> Fotoğraflara tıkla → FullscreenImageViewer
   └─> Swipe ile fotoğraflar arasında geç
   └─> Pinch to zoom
   └─> Aşağı kaydır → Dismiss
```

---

#### Senaryo 3: Çeyiz Paylaşımı
```
1. Trousseau Detail Screen
   └─> Share icon tıkla (AppBar actions)
   
2. Share Trousseau Screen
   └─> Email adresi gir (ör: "anne@gmail.com")
   └─> Yetki seviyesi seç:
       - 👁 View Only: Sadece görüntüle
       - ✏️ Edit: Ürün ekle/düzenle
       - 🔓 Full Access: Silme + paylaşım yetkileri
   └─> Paylaş:
       - Firestore: trousseaus/{id}.sharedWith array'e email ekle
       - Email'e yetki seviyesine göre ekle (.editors veya değil)
       - Target user'ın sharedTrousseauIds array'ine trousseau ID ekle
       - Email bildirimi gönder (opsiyonel)
   
3. Home Screen (Paylaşılan Kullanıcının)
   └─> "Benimle Paylaşılanlar" sekmesi
   └─> Paylaşılan çeyiz görünür
   └─> Yetki seviyesine göre işlemler:
       - View: Sadece okuma
       - Edit: Ürün CRUD
       - Full: Tüm işlemler (silme hariç owner-only)
```

---

#### Senaryo 4: Bütçe Takibi ve İstatistikler
```
1. Product List Screen
   └─> Ürünleri satın al checkbox'larını işaretle
   └─> ProductProvider.togglePurchaseStatus()
   └─> Firestore: product.isPurchased = true, purchaseDate = now
   └─> TrousseauModel.spentAmount ve purchasedProducts otomatik güncelle
   
2. Statistics Screen (Home Tab 3)
   └─> Kategori grafikleri:
       - Pie chart: Kategori başına ürün dağılımı
       - Bar chart: Kategori başına harcama
   └─> Bütçe kartları:
       - Toplam Bütçe: 150,000 TL
       - Harcanan: 45,200 TL (30%)
       - Kalan: 104,800 TL (70%)
       - Progress bar
   └─> Realtime güncelleme (Firestore stream)
   
3. Excel Export
   └─> Settings → Export butonu
   └─> ExcelExportService:
       - Tüm ürünler için satırlar oluştur
       - Kategoriye göre grupla
       - Toplam/harcama hesapla
       - excel paketi ile .xlsx dosyası oluştur
       - share_plus ile paylaş
```

---

## �📊 YAPI

**21 Ekran:** 4 Auth • 2 Ana • 5 Çeyiz • 5 Ürün • 4 Ayarlar • 1 Onboarding

**5 Model:** User, Trousseau, Product, Category, Feedback

**5 Provider:** AuthProvider, TrousseauProvider, ProductProvider, CategoryProvider, ThemeProvider

**Firebase:** users, trousseaus, products, feedbacks, app_versions collections

---

## 🎨 TASARIM

**5 Tema:**
1. Varsayılan (Açık Mavi) - #2563EB
2. Monochrome (Siyah-Beyaz) - Yüksek kontrast
3. Mor Okyanus (Koyu Mor) - #A78BFA
4. Orman Yeşili (Koyu Yeşil) - #34D399
5. Gün Batımı (Koyu Turuncu) - #FB923C

**8 Kategori:** 🪑 Mobilya • 🍳 Mutfak • 🛏️ Yatak • 📱 Elektronik • ✨ Dekorasyon • 👗 Tekstil • 🚿 Banyo • 📦 Diğer

---

## 🔄 SON GÜNCELLEMELER

### v1.0.17+24 (18 Ekim 2025)

#### ✨ Yeni Özellikler

**1. Tam Ekran Fotoğraf Görüntüleyici**
- **Dosya:** `lib/presentation/widgets/common/fullscreen_image_viewer.dart`
- **Özellikler:**
  - Fotoğrafa tıkla → Tam ekran açılır
  - Swipe ile fotoğraflar arasında geç
  - Pinch to zoom (interaktif büyütme)
  - Aşağı kaydır → Dismiss (gesture detector)
  - Hero animation (smooth transition)
- **Kullanım:** Product Detail Screen
- **Commit:** dcf3bf2

**2. Thumbnail Büyütme (+43%)**
- **Değişiklik:** Product Detail fotoğraf thumbnail'leri
- **Eski:** 56dp x 56dp
- **Yeni:** 80dp x 80dp
- **Neden:** Fotoğrafları daha net görmek için
- **Commit:** dcf3bf2

**3. Monochrome Tema Düzeltmesi**
- **Problem:** Monochrome tema'da mavi tonlar vardı (gerçek monokrom değildi)
- **Çözüm:** Sadece siyah (#000000), beyaz (#FFFFFF), gri (#1A1A1A, #333333, #B3B3B3, #CCCCCC)
- **Dosya:** `lib/core/themes/design_system.dart`
- **Etki:** Yüksek kontrast, gerçek monokrom deneyim
- **Commit:** 8c41194

**4. Akıllı Geri Tuşu (Android)**
- **Davranış:**
  - Ana sayfa (Tab 0) → Çift tıkla çık (2 saniye içinde)
  - Diğer tablar → Çeyiz sekmesine (Tab 0) dön
  - Snackbar uyarısı: "Çıkmak için tekrar basın"
- **Dosya:** `lib/presentation/screens/home/home_screen.dart`
- **Platform:** Android (PopScope widget)
- **Commit:** 74a35be

---

#### 🐛 Düzeltmeler

**1. BuildContext Mounted Checks (5 dosya)**
- **Problem:** `context` kullanımında async sonrası mounted check yoktu
- **Çözüm:** `if (!mounted) return;` ekle (Flutter 3.35+ best practice)
- **Dosyalar:**
  - `lib/presentation/screens/auth/login_screen.dart`
  - `lib/presentation/screens/auth/register_screen.dart`
  - `lib/presentation/screens/trousseau/create_trousseau_screen.dart`
  - `lib/presentation/screens/product/add_product_screen.dart`
  - `lib/presentation/screens/settings/settings_screen.dart`
- **Commit:** 8c41194

**2. Deprecated API Düzeltmeleri**
- **Problem:** `Color.withOpacity()` deprecated (Flutter 3.35+)
- **Çözüm:** `Color.withValues(alpha: 0.5)` kullan
- **Dosyalar:** 12 dosyada değişiklik
- **Commit:** 8c41194

**3. GoRouter Geri Tuşu Crash**
- **Problem:** Geri tuşu `setState()` çağrısında crash
- **Çözüm:** PopScope ile kontrollü geri tuş yönetimi
- **Dosya:** `lib/presentation/screens/home/home_screen.dart`
- **Commit:** 74a35be

---

#### 🧹 Kod Temizliği

**1. Debug Print Temizliği (66 adet kaldırıldı)**
- **Dosyalar:**
  - `lib/main.dart` - App Check debug prints (25+ satır)
  - `lib/presentation/screens/auth/login_screen.dart` - Remember Me logs (11 adet)
  - `lib/presentation/screens/settings/settings_screen.dart` - Photo upload logs (10 adet)
  - `lib/presentation/providers/product_provider.dart` - Loading logs
  - `lib/presentation/providers/auth_provider.dart` - Auth logs (9 adet)
  - `lib/presentation/providers/onboarding_provider.dart` - 2 adet
  - `lib/presentation/providers/category_provider.dart` - 1 adet
- **Durum:** Production-ready (sıfır debug output)
- **Commit:** Multiple commits

**2. Dokümantasyon Temizliği**
- **Silinen:** 11 eski markdown dosyası (duplicates, drafts)
- **Korunan:** README.md, PROJE_OZETI.md, OZET.md
- **Neden:** Git repo boyutunu azaltmak

**3. Analyzer Warnings**
- **Önceki:** ~15 warning
- **Sonrası:** 0 warning
- **Kategoriler:** Unused imports, deprecated APIs, missing returns

---

#### 📊 Versiyon Karşılaştırması

| Metrik | v1.0.16+23 | v1.0.17+24 | Değişim |
|--------|------------|------------|---------|
| Debug Prints | 66 | 0 | -100% ✅ |
| Analyzer Warnings | 15 | 0 | -100% ✅ |
| Thumbnail Size | 56dp | 80dp | +43% 📈 |
| Tema Accuracy | 90% | 100% | +10% ✅ |
| UX Features | 18 | 22 | +4 🎉 |

---

#### 🔮 Gelecek Güncellemeler (Backlog)

**v1.1.0 (Planlanan)**
- iOS optimize (SafeArea, haptics)
- Offline mode (local cache)
- Product grid view (alternative layout)
- Bulk operations (multi-select delete/move)

**v1.2.0 (Orta Vadeli)**
- QR code sharing
- PDF export (Trousseau report)
- Push notifications
- In-app messaging (collaboration)

**v2.0.0 (Uzun Vadeli)**
- Multi-language (EN, TR, AR)
- AI-powered suggestions (smart categorization)
- Store integration (shopping links)
- Advanced charts & analytics

---

## 🚀 KURULUM

```bash
git clone https://github.com/eyzaun/ceyiz-diz.git
cd ceyiz-diz
flutter pub get
flutter run
```

**Firebase:** Auth + Firestore + Storage + App Check + app_versions collection

---

## 📈 İSTATİSTİKLER

21 ekran • 5 provider • 5 model • 15+ widget • ~15K kod • 5 tema • 8 kategori

---

## 🔮 GELECEK

**Yakın:** iOS optimize • Offline mode • Grid view • Bulk işlemler

**Orta:** QR paylaşım • Export • Push notification • Mesajlaşma

**Uzun:** i18n • AI öneriler • Mağaza entegrasyonu • Charts

---

**Developer:** eyzaun • **Repo:** github.com/eyzaun/ceyiz-diz
