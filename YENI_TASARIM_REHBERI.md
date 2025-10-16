# 🎨 ÇEYIZ DİZ - YENİ TASARIM SİSTEMİ KULLANIM REHBERİ

> **Tarih:** 17 Ekim 2025
> **Versiyon:** 2.0.0
> **Amaç:** Evrensel tasarım kurallarına %100 uyumlu UI/UX

---

## 📚 İÇİNDEKİLER

1. [Tasarım Prensipleri](#tasarım-prensipleri)
2. [Dosya Yapısı](#dosya-yapısı)
3. [Temel Bileşenler](#temel-bileşenler)
4. [Ekran Örnekleri](#ekran-örnekleri)
5. [Önce ve Sonra Karşılaştırması](#önce-ve-sonra)
6. [Sık Yapılan Hatalar](#sık-yapılan-hatalar)

---

## 🎯 TASARIM PRENSİPLERİ

### 1. **JAKOB YASASI** - Kullanıcı Beklentileri
> Kullanıcılar zamanlarının çoğunu DİĞER uygulamalarda geçirir.

**UYULMASI GEREKEN KURALLAR:**
- ✅ Standart ikonları kullan (⚙️ ayarlar, 🗑️ sil, 👤 profil)
- ✅ Navigasyon standart yerlerde (bottom nav, app bar)
- ✅ Standart etkileşimler (swipe to delete, pull to refresh)

**ÖRNEKLER:**
```dart
// ❌ YANLIŞ: Özel icon
Icon(Icons.settings_applications) // Kullanıcı tanımaz

// ✅ DOĞRU: Standart icon
Icon(Icons.settings) // Evrensel
```

---

### 2. **FITTS YASASI** - Erişilebilirlik
> Büyük ve yakın hedefler daha kolay basılır.

**UYULMASI GEREKEN KURALLAR:**
- ✅ Minimum 48dp x 48dp touch area
- ✅ Önemli butonlar sağ alt köşede (baş parmak erişimi)
- ✅ İlgili eylemler birbirine yakın

**ÖRNEKLER:**
```dart
// ❌ YANLIŞ: Küçük touch area
IconButton(
  icon: Icon(Icons.delete, size: 16),
  onPressed: () {},
) // Dokunması zor!

// ✅ DOĞRU: Minimum 48x48
AppIconButton(
  icon: Icons.delete,
  onPressed: () {},
) // constraints: BoxConstraints(minWidth: 48, minHeight: 48)
```

---

### 3. **HICK YASASI** - Seçim Paradoksu
> Ne kadar çok seçenek, o kadar uzun karar süresi.

**UYULMASI GEREKEN KURALLAR:**
- ✅ Her ekranda MAX 1 primary action
- ✅ MAX 2 secondary action
- ✅ Diğerleri "⋮" menüsünde gizli
- ✅ Bottom nav MAX 4 sekme

**ÖRNEKLER:**
```dart
// ❌ YANLIŞ: 5 buton yan yana
Row(
  children: [
    ElevatedButton(...),  // Kaydet
    ElevatedButton(...),  // İptal
    ElevatedButton(...),  // Sil
    ElevatedButton(...),  // Paylaş
    ElevatedButton(...),  // Kopyala
  ],
) // Kullanıcı kafası karışır!

// ✅ DOĞRU: 1 primary + 1 secondary + menü
AppButtonGroup(
  primaryButton: AppPrimaryButton(label: 'Kaydet'),
  secondaryButton: AppSecondaryButton(label: 'İptal'),
),
IconButton(icon: Icons.more_vert) // Diğerleri menüde
```

---

### 4. **MILLER YASASI** - Bilişsel Yük
> İnsan beyni aynı anda 7±2 öğeyi işleyebilir.

**UYULMASI GEREKEN KURALLAR:**
- ✅ Bilgiyi MAX 5 gruba böl
- ✅ Form'ları MAX 5 alana sınırla (fazlası için adımlara böl)
- ✅ Listelerde MAX 5-7 öğe göster (kalanı scroll)

**ÖRNEKLER:**
```dart
// ❌ YANLIŞ: 10 alan tek ekranda
Column(
  children: [
    TextField(), TextField(), TextField(),
    TextField(), TextField(), TextField(),
    TextField(), TextField(), TextField(),
    TextField(), // 10 alan - aşırı yük!
  ],
)

// ✅ DOĞRU: 3 gruba bölünmüş
AppFormSection(
  title: 'Temel Bilgiler',
  children: [
    AppTextInput(label: 'Ad'),
    AppTextInput(label: 'Email'),
  ],
),
AppFormSection(
  title: 'Adres Bilgileri',
  children: [
    AppTextInput(label: 'Şehir'),
    AppTextInput(label: 'İlçe'),
  ],
),
```

---

### 5. **GESTALT PRENSİPLERİ** - Görsel Algı

#### A) YAKINLIK (Proximity)
> İlgili öğeler birbirine yakın olmalı.

```dart
// ❌ YANLIŞ: İlgisiz spacing
Column(
  children: [
    Text('Ürün Adı'),
    SizedBox(height: 32), // Çok uzak!
    Text('Fiyat'),
  ],
)

// ✅ DOĞRU: İlgili öğeler yakın
Column(
  children: [
    Text('Ürün Adı'),
    AppSpacing.xs.verticalSpace, // 4dp
    Text('Fiyat'),
  ],
)
```

#### B) BENZERLİK (Similarity)
> Aynı türdeki öğeler aynı görünmeli.

```dart
// ❌ YANLIŞ: Farklı buton stilleri
ElevatedButton(...)
OutlinedButton(...)
TextButton(...)
// Hepsi farklı yükseklik ve padding!

// ✅ DOĞRU: Tutarlı buton sistemi
AppPrimaryButton(...)    // 56dp, primary color
AppSecondaryButton(...)  // 48dp, outlined
AppTextButton(...)       // 48dp, text only
```

#### C) ORTAK ALAN (Common Region)
> Aynı card/container içindekiler bir grup.

```dart
// ✅ DOĞRU: Card içinde gruplama
AppCard(
  child: Column(
    children: [
      Text('Başlık'),
      Text('Açıklama'),
      Text('Fiyat'),
      // Hepsi aynı gruba ait
    ],
  ),
)
```

---

## 📂 DOSYA YAPISI

```
lib/
├── core/
│   └── theme/
│       ├── design_tokens.dart      # 👈 TÜM DEĞERLER BURADA
│       ├── design_system.dart      # (ESKİ - kullanma!)
│       └── app_theme.dart
│
└── presentation/
    └── widgets/
        └── common/
            ├── app_button.dart     # 👈 TÜM BUTONLAR
            ├── app_card.dart       # 👈 TÜM KARTLAR
            ├── app_input.dart      # 👈 TÜM INPUT'LAR
            └── ...
```

---

## 🧩 TEMEL BİLEŞENLER

### 1. DESIGN TOKENS (Değerler)

**Kullanım:** Hard-coded değer YASAK! Her zaman token kullan.

```dart
import 'package:ceyiz_diz/core/theme/design_tokens.dart';

// ❌ YANLIŞ: Hard-coded
Container(
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.only(bottom: 8),
  child: Text('Merhaba', style: TextStyle(fontSize: 14)),
)

// ✅ DOĞRU: Token kullanımı
Container(
  padding: AppSpacing.paddingMD,          // 16dp
  margin: EdgeInsets.only(bottom: AppSpacing.sm), // 8dp
  child: Text(
    'Merhaba',
    style: TextStyle(fontSize: AppTypography.sizeBase), // 14dp
  ),
)
```

**Tüm Token Kategorileri:**
- `AppSpacing` - Boşluklar
- `AppDimensions` - Boyutlar (buton, icon, touch area)
- `AppRadius` - Border radius
- `AppTypography` - Yazı boyutları ve ağırlıkları
- `AppDurations` - Animasyon süreleri
- `AppLimits` - UI kısıtlamaları

---

### 2. BUTONLAR

#### Primary Button (Ana Eylem)
```dart
AppPrimaryButton(
  label: 'Kaydet',
  icon: Icons.save,          // Opsiyonel
  onPressed: () {},
  isLoading: false,          // true yapınca loading gösterir
  isFullWidth: false,        // true yapınca tam genişlik
)
```

**NE ZAMAN KULLAN:**
- Ekranın EN ÖNEMLİ eylemi (Hick Yasası - max 1 tane!)
- Örnekler: Giriş Yap, Kaydet, Onayla, Satın Al

#### Secondary Button (İkincil Eylem)
```dart
AppSecondaryButton(
  label: 'İptal',
  onPressed: () {},
)
```

**NE ZAMAN KULLAN:**
- Primary'den daha az önemli eylemler
- Örnekler: İptal, Geri, Atla

#### Icon Button (Sadece İkon)
```dart
AppIconButton(
  icon: Icons.delete,
  onPressed: () {},
  tooltip: 'Sil',           // Erişilebilirlik için önemli!
)
```

**NE ZAMAN KULLAN:**
- AppBar actions
- Card içinde küçük eylemler
- Liste öğelerinde inline actions

#### Danger Button (Tehlikeli Eylem)
```dart
AppDangerButton(
  label: 'Sil',
  icon: Icons.delete,
  onPressed: () {},
  isOutlined: true,        // false = filled (daha tehlikeli vurgu)
)
```

**NE ZAMAN KULLAN:**
- Silme işlemleri
- Çıkış yapma
- Geri alınamaz eylemler

#### FAB (Floating Action Button)
```dart
AppFAB(
  icon: Icons.add,
  label: 'Ürün Ekle',      // Opsiyonel (extended FAB)
  onPressed: () {},
  tooltip: 'Yeni ürün ekle',
)
```

**NE ZAMAN KULLAN:**
- Ekranın PRIMARY action'ı (Ürün ekle, Çeyiz oluştur)
- Fitts Yasası: Sağ alt köşe - baş parmak için ideal

---

### 3. KARTLAR

#### Product Card
```dart
AppProductCard(
  name: 'Buzdolabı',
  description: 'LG marka, inox',
  price: 15000.0,
  quantity: 1,
  isPurchased: false,
  images: ['https://...'],
  category: CategoryModel.furniture,
  onTap: () {},
  onTogglePurchase: () {},
  canEdit: true,
)
```

**NE ZAMAN KULLAN:**
- Ürün listelerinde
- Her card tutarlı: 64x64 thumbnail, aynı layout

#### Statistics Card
```dart
AppStatCard(
  icon: Icons.attach_money,
  title: 'Toplam Bütçe',
  value: '₺50,000',
  subtitle: '12 ürün',
  color: theme.colorScheme.primary,
  onTap: () {},
)
```

**NE ZAMAN KULLAN:**
- İstatistik ekranında
- Dashboard'larda
- Özet bilgiler (Miller Yasası: max 3-4 kart yan yana)

#### Info Card
```dart
AppInfoCard(
  type: InfoCardType.warning,
  title: 'Dikkat!',
  message: 'Bu işlem geri alınamaz.',
  onDismiss: () {},
)
```

**Tipler:**
- `InfoCardType.info` - Mavi
- `InfoCardType.success` - Yeşil
- `InfoCardType.warning` - Turuncu
- `InfoCardType.error` - Kırmızı

---

### 4. INPUT'LAR

#### Text Input
```dart
AppTextInput(
  label: 'Email',
  hint: 'ornek@email.com',
  helperText: 'Geçerli bir email adresi girin',
  errorText: _emailError,
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Bu alan zorunludur';
    }
    return null;
  },
  prefixIcon: Icon(Icons.email),
)
```

#### Password Input
```dart
AppPasswordInput(
  label: 'Şifre',
  controller: _passwordController,
  validator: (value) => value!.length < 6 ? 'Min 6 karakter' : null,
)
```
**Otomatik Features:**
- Görünürlük toggle (göz ikonu)
- Obscure text

#### Search Input
```dart
AppSearchInput(
  controller: _searchController,
  hint: 'Ürün ara...',
  onChanged: (query) {
    // Arama yap
  },
  onClear: () {
    // Temizleme
  },
)
```

#### Dropdown
```dart
AppDropdown<String>(
  label: 'Kategori',
  value: _selectedCategory,
  items: categories.map((cat) {
    return DropdownMenuItem(
      value: cat.id,
      child: Text(cat.displayName),
    );
  }).toList(),
  onChanged: (value) {
    setState(() => _selectedCategory = value);
  },
)
```

#### Form Section (Miller Yasası)
```dart
AppFormSection(
  title: 'Temel Bilgiler',
  subtitle: 'Ürün hakkında genel bilgiler',
  children: [
    AppTextInput(label: 'Ürün Adı'),
    AppTextInput(label: 'Açıklama', maxLines: 3),
    AppDropdown(label: 'Kategori', items: [...]),
  ],
)
```

**NEDEN ÖNEMLİ:**
- Miller Yasası: Form'ları max 5 alanlık gruplara ayır
- Gestalt (Yakınlık): İlgili alanlar bir arada

---

## 📱 EKRAN ÖRNEKLERİ

### LOGIN SCREEN (Yeni Tasarım)

```dart
import 'package:ceyiz_diz/core/theme/design_tokens.dart';
import 'package:ceyiz_diz/presentation/widgets/common/app_button.dart';
import 'package:ceyiz_diz/presentation/widgets/common/app_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: ConstrainedBox(
              // Responsive: Web'de max genişlik
              constraints: BoxConstraints(
                maxWidth: AppBreakpoints.maxFormWidth,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ─────────────────────────────────────────────────────
                    // LOGO + BAŞLIK
                    // ─────────────────────────────────────────────────────
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                    ),

                    AppSpacing.lg.verticalSpace,

                    Text(
                      'Çeyiz Diz',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: AppTypography.bold,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    AppSpacing.xs.verticalSpace,

                    Text(
                      'Çeyizinizi dijital ortamda yönetin',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    AppSpacing.xl.verticalSpace,

                    // ─────────────────────────────────────────────────────
                    // FORM ALANLARI
                    // Miller Yasası: 2 alan = ideal
                    // ─────────────────────────────────────────────────────
                    AppTextInput(
                      label: 'Email',
                      hint: 'ornek@email.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icon(Icons.email_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email gereklidir';
                        }
                        if (!value.contains('@')) {
                          return 'Geçersiz email';
                        }
                        return null;
                      },
                    ),

                    AppSpacing.md.verticalSpace,

                    AppPasswordInput(
                      label: 'Şifre',
                      controller: _passwordController,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Şifre gereklidir';
                        }
                        if (value.length < 6) {
                          return 'Şifre en az 6 karakter olmalı';
                        }
                        return null;
                      },
                    ),

                    AppSpacing.sm.verticalSpace,

                    // Şifremi Unuttum
                    Align(
                      alignment: Alignment.centerRight,
                      child: AppTextButton(
                        label: 'Şifremi Unuttum',
                        onPressed: () => context.push('/forgot-password'),
                      ),
                    ),

                    AppSpacing.xl.verticalSpace,

                    // ─────────────────────────────────────────────────────
                    // ANA EYLEM - HICK YASASI: Sadece 1 primary button
                    // FITTS YASASI: Full width, 56dp height
                    // ─────────────────────────────────────────────────────
                    AppPrimaryButton(
                      label: 'Giriş Yap',
                      icon: Icons.login,
                      isFullWidth: true,
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                    ),

                    AppSpacing.md.verticalSpace,

                    // İkincil eylem (daha az vurgu)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hesabınız yok mu?',
                          style: theme.textTheme.bodyMedium,
                        ),
                        AppSpacing.xs.horizontalSpace,
                        AppTextButton(
                          label: 'Kayıt Olun',
                          onPressed: () => context.push('/register'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signIn(
        _emailController.text,
        _passwordController.text,
      );
      // Navigation otomatik (GoRouter auth guard)
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giriş başarısız: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

**TASARIM KURALLARI UYGULAMASI:**
- ✅ Jakob Yasası: Standart login layout
- ✅ Fitts Yasası: Primary button full width, 56dp
- ✅ Hick Yasası: 1 primary action (Giriş Yap)
- ✅ Miller Yasası: 2 form alanı (ideal)
- ✅ Gestalt: İlgili alanlar gruplanmış (form section)

---

## 🔄 ÖNCE VE SONRA

### BUTON KULLANIMI

#### ❌ ESKİ (Tutarsız)
```dart
// Her ekranda farklı yükseklik ve padding
ElevatedButton(
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
  ),
  child: Text('Kaydet'),
  onPressed: () {},
)

// Başka ekranda:
ElevatedButton(
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.all(16),
  ),
  child: Text('Kaydet'),
  onPressed: () {},
)
```

#### ✅ YENİ (Tutarlı)
```dart
// TÜM ekranlarda aynı
AppPrimaryButton(
  label: 'Kaydet',
  onPressed: () {},
)
// Otomatik: 56dp height, standart padding, primary color
```

---

### CARD KULLANIMI

#### ❌ ESKİ (Tutarsız spacing)
```dart
Card(
  margin: EdgeInsets.all(12), // Bir ekranda 12
  child: Padding(
    padding: EdgeInsets.all(10), // Padding 10
    child: Row(...),
  ),
)

// Başka ekranda:
Card(
  margin: EdgeInsets.symmetric(vertical: 8), // Burada 8
  child: Padding(
    padding: EdgeInsets.all(16), // Padding 16
    child: Row(...),
  ),
)
```

#### ✅ YENİ (Tutarlı)
```dart
AppProductCard(
  name: product.name,
  price: product.price,
  ...
)
// Otomatik: 8dp margin, 16dp padding (HER ZAMAN AYNI)
```

---

### FORM KULLANIMI

#### ❌ ESKİ (10 alan tek ekranda - Miller ihlali)
```dart
Column(
  children: [
    TextField(...),
    TextField(...),
    TextField(...),
    TextField(...),
    TextField(...),
    TextField(...),
    TextField(...),
    TextField(...),
    TextField(...),
    TextField(...), // 10 alan - aşırı bilişsel yük!
  ],
)
```

#### ✅ YENİ (Gruplara bölünmüş)
```dart
Column(
  children: [
    AppFormSection(
      title: 'Temel Bilgiler',
      children: [
        AppTextInput(label: 'Ad'),
        AppTextInput(label: 'Email'),
        AppTextInput(label: 'Telefon'),
      ],
    ),
    AppSpacing.lg.verticalSpace,
    AppFormSection(
      title: 'Adres Bilgileri',
      children: [
        AppTextInput(label: 'Şehir'),
        AppTextInput(label: 'İlçe'),
      ],
    ),
    // Maksimum 5 alan per grup
  ],
)
```

---

## ⚠️ SIK YAPILAN HATALAR

### 1. Hard-Coded Değerler
```dart
// ❌ YANLIŞ
padding: EdgeInsets.all(16),
fontSize: 14,
height: 48,

// ✅ DOĞRU
padding: AppSpacing.paddingMD,
fontSize: AppTypography.sizeBase,
height: AppDimensions.buttonHeightMedium,
```

---

### 2. Tutarsız Buton Kullanımı
```dart
// ❌ YANLIŞ: Her ekranda farklı stil
ElevatedButton(...)
OutlinedButton(...)
Container(...) // Custom buton!

// ✅ DOĞRU: Standart buton sistemi
AppPrimaryButton(...)
AppSecondaryButton(...)
AppTextButton(...)
```

---

### 3. Çok Fazla Seçenek (Hick İhlali)
```dart
// ❌ YANLIŞ: 5 primary button
Row(
  children: [
    AppPrimaryButton(label: 'Kaydet'),
    AppPrimaryButton(label: 'İptal'),
    AppPrimaryButton(label: 'Sil'),
    AppPrimaryButton(label: 'Paylaş'),
    AppPrimaryButton(label: 'Kopyala'),
  ],
)

// ✅ DOĞRU: 1 primary + diğerleri gizli
AppButtonGroup(
  primaryButton: AppPrimaryButton(label: 'Kaydet'),
  secondaryButton: AppSecondaryButton(label: 'İptal'),
),
// Sil, Paylaş, Kopyala => PopupMenuButton'da
```

---

### 4. Küçük Touch Area (Fitts İhlali)
```dart
// ❌ YANLIŞ: Çok küçük
IconButton(
  icon: Icon(Icons.delete, size: 16),
  constraints: BoxConstraints(), // Touch area yok!
  padding: EdgeInsets.zero,
  onPressed: () {},
)

// ✅ DOĞRU: Minimum 48x48
AppIconButton(
  icon: Icons.delete,
  onPressed: () {},
) // Otomatik constraints: minWidth/Height 48dp
```

---

### 5. Gruplandırılmamış Bilgi (Gestalt İhlali)
```dart
// ❌ YANLIŞ: İlişkisiz spacing
Column(
  children: [
    Text('Ürün Adı'),
    SizedBox(height: 24),
    Text('Fiyat'), // Fiyat üründen çok uzak!
    SizedBox(height: 4),
    Text('Kategori'),
  ],
)

// ✅ DOĞRU: İlgili bilgiler yakın
Column(
  children: [
    Text('Ürün Adı'),
    AppSpacing.xs.verticalSpace, // 4dp
    Text('Fiyat'),              // Fiyat ürüne yakın
    AppSpacing.xs.verticalSpace,
    Text('Kategori'),
  ],
)
```

---

## 🚀 BAŞLANGIÇ

### Adım 1: Import'ları ekle
```dart
import 'package:ceyiz_diz/core/theme/design_tokens.dart';
import 'package:ceyiz_diz/presentation/widgets/common/app_button.dart';
import 'package:ceyiz_diz/presentation/widgets/common/app_card.dart';
import 'package:ceyiz_diz/presentation/widgets/common/app_input.dart';
```

### Adım 2: Eski bileşenleri değiştir
```dart
// ESKİ
ElevatedButton(...) → AppPrimaryButton(...)
TextField(...)      → AppTextInput(...)
Card(...)           → AppCard(...) veya AppProductCard(...)
```

### Adım 3: Hard-coded değerleri token'lara çevir
```dart
// ESKİ
padding: EdgeInsets.all(16)

// YENİ
padding: AppSpacing.paddingMD
```

### Adım 4: Test et
- ✅ Touch area minimum 48dp mı?
- ✅ Aynı türdeki bileşenler aynı görünüyor mu?
- ✅ Bilgi gruplanmış mı?
- ✅ Max 5 form alanı mı?

---

## 📞 YARDIM

Sorun yaşarsan:
1. Bu rehberi tekrar oku
2. Örnek kodları incele
3. Tasarım prensiplerini kontrol et

**Unutma:** Bu kurallar EVRENSEL - Google, Apple, Microsoft hepsi kullanıyor!
