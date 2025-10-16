# 🚀 HIZLI GÜNCELLEME ŞABLONU

> Kalan 11 ekranı hızlıca güncellemek için bu şablonu kullan

---

## ✅ TAMAMLANAN (4/15)
1. ✅ Login Screen
2. ✅ Register Screen
3. ✅ Home Screen
4. ✅ Statistics Screen

---

## 📝 KALAN EKRANLAR İÇİN ADIMLAR

Her ekran için bu 5 adımı takip et:

### ADIM 1: Import'ları Güncelle

```dart
// ESKİ import'ları SİL
// import '../../core/themes/design_system.dart'; // SİL
// import '../../widgets/common/responsive_container.dart'; // SİL

// YENİ import'ları EKLE
import '../../../core/theme/design_tokens.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_input.dart';
```

### ADIM 2: Butonları Değiştir

```dart
// ❌ ESKİ
ElevatedButton(
  child: Text('Kaydet'),
  onPressed: () {},
)

// ✅ YENİ
AppPrimaryButton(
  label: 'Kaydet',
  onPressed: () {},
)

// ❌ ESKİ
OutlinedButton(
  child: Text('İptal'),
  onPressed: () {},
)

// ✅ YENİ
AppSecondaryButton(
  label: 'İptal',
  onPressed: () {},
)

// ❌ ESKİ
IconButton(
  icon: Icon(Icons.delete),
  onPressed: () {},
)

// ✅ YENİ
AppIconButton(
  icon: Icons.delete,
  onPressed: () {},
  tooltip: 'Sil',
)
```

### ADIM 3: Input'ları Değiştir

```dart
// ❌ ESKİ
TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'ornek@email.com',
  ),
  controller: _emailController,
)

// ✅ YENİ
AppTextInput(
  label: 'Email',
  hint: 'ornek@email.com',
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
)

// ❌ ESKİ - Şifre
TextField(
  obscureText: !_isPasswordVisible,
  decoration: InputDecoration(
    labelText: 'Şifre',
    suffixIcon: IconButton(...),
  ),
)

// ✅ YENİ - Şifre (otomatik visibility toggle)
AppPasswordInput(
  label: 'Şifre',
  controller: _passwordController,
)
```

### ADIM 4: Spacing'i Değiştir

```dart
// ❌ ESKİ
SizedBox(height: 16)
SizedBox(width: 8)
EdgeInsets.all(16)
EdgeInsets.symmetric(horizontal: 24)

// ✅ YENİ
AppSpacing.md.verticalSpace
AppSpacing.sm.horizontalSpace
AppSpacing.paddingMD
EdgeInsets.symmetric(horizontal: AppSpacing.lg)
```

### ADIM 5: Card'ları Değiştir

```dart
// ❌ ESKİ
Card(
  margin: EdgeInsets.all(8),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: ...,
  ),
)

// ✅ YENİ
AppCard(
  child: ...,
)
```

---

## 📋 EKRAN BAZINDA DETAYLAR

### 5. ADD PRODUCT SCREEN

**Dosya:** `lib/presentation/screens/product/add_product_screen.dart`

**Değişiklikler:**
```dart
// Dosya başı comment
/// Add Product Screen - Yeni Tasarım Sistemi v2.0
///
/// TASARIM KURALLARI:
/// ✅ Miller Yasası: 2 bölüme ayrılmış (Temel Bilgiler + Ek Bilgiler)
/// ✅ Fitts Yasası: Primary button 56dp, full width
/// ✅ Hick Yasası: 1 primary (Kaydet) + 1 secondary (İptal)

// Form'u böl
AppFormSection(
  title: 'Temel Bilgiler',
  children: [
    AppTextInput(label: 'Ürün Adı', ...),
    AppDropdown(label: 'Kategori', ...),
    AppTextInput(label: 'Fiyat', keyboardType: TextInputType.number, ...),
    AppTextInput(label: 'Adet', keyboardType: TextInputType.number, ...),
  ],
),

AppSpacing.lg.verticalSpace,

AppFormSection(
  title: 'Ek Bilgiler',
  children: [
    AppTextInput(label: 'Açıklama', maxLines: 3, ...),
    AppTextInput(label: 'Link', ...),
    // Image picker widget
  ],
),

AppSpacing.xl.verticalSpace,

// Butonlar
AppButtonGroup(
  primaryButton: AppPrimaryButton(
    label: 'Kaydet',
    isFullWidth: true,
    onPressed: _handleSave,
  ),
  secondaryButton: AppSecondaryButton(
    label: 'İptal',
    onPressed: () => context.pop(),
  ),
)
```

### 6. EDIT PRODUCT SCREEN

**Dosya:** `lib/presentation/screens/product/edit_product_screen.dart`

**Değişiklikler:**
- Add Product ile aynı yapı
- Ek: Sil butonu ekle:

```dart
AppDangerButton(
  label: 'Ürünü Sil',
  icon: Icons.delete,
  isOutlined: true,
  onPressed: _handleDelete,
)
```

### 7. PRODUCT DETAIL SCREEN

**Dosya:** `lib/presentation/screens/product/product_detail_screen.dart`

**Değişiklikler:**
```dart
// AppBar actions - Hick Yasası: Max 2 action
AppBar(
  actions: [
    AppIconButton(icon: Icons.edit, onPressed: ...),
    AppIconButton(icon: Icons.more_vert, onPressed: _showMenu), // Diğerleri menüde
  ],
)

// Primary Action
AppPrimaryButton(
  label: product.isPurchased ? 'Satın Alındı İşaretle' : 'Satın Al',
  icon: product.isPurchased ? Icons.check_circle : Icons.shopping_cart,
  isFullWidth: true,
  onPressed: _togglePurchase,
)
```

### 8-9. CREATE/EDIT TROUSSEAU SCREENS

**Dosyalar:**
- `lib/presentation/screens/trousseau/create_trousseau_screen.dart`
- `lib/presentation/screens/trousseau/edit_trousseau_screen.dart`

**Değişiklikler:**
```dart
AppFormSection(
  title: 'Çeyiz Bilgileri',
  children: [
    AppTextInput(label: 'Çeyiz Adı', ...),
    AppTextInput(label: 'Açıklama', maxLines: 3, ...),
    AppTextInput(label: 'Toplam Bütçe', keyboardType: TextInputType.number, ...),
  ],
)

AppButtonGroup(
  primaryButton: AppPrimaryButton(label: 'Kaydet', isFullWidth: true, ...),
  secondaryButton: AppSecondaryButton(label: 'İptal', ...),
)
```

### 10. SHARE TROUSSEAU SCREEN

**Dosya:** `lib/presentation/screens/trousseau/share_trousseau_screen.dart`

**Değişiklikler:**
```dart
AppTextInput(
  label: 'Email',
  hint: 'Paylaşmak istediğiniz kişinin emaili',
  keyboardType: TextInputType.emailAddress,
  ...
)

AppDropdown<String>(
  label: 'İzin Seviyesi',
  items: [
    DropdownMenuItem(value: 'viewer', child: Text('Görüntüleyici')),
    DropdownMenuItem(value: 'editor', child: Text('Editör')),
  ],
  ...
)

AppPrimaryButton(label: 'Paylaş', ...)
```

### 11-13. SETTINGS SCREENS

**Dosyalar:**
- `lib/presentation/screens/settings/profile_screen.dart`
- `lib/presentation/screens/settings/theme_settings_screen.dart`
- `lib/presentation/screens/settings/change_password_screen.dart`

**Değişiklikler:**
```dart
// Profile Screen
AppTextInput(label: 'Ad Soyad', ...)
AppTextInput(label: 'Email', enabled: false, ...) // Read-only

// Theme Settings
// Mevcut UI iyi, sadece butonları değiştir

// Change Password
AppPasswordInput(label: 'Mevcut Şifre', ...)
AppPasswordInput(label: 'Yeni Şifre', ...)
AppPasswordInput(label: 'Yeni Şifre (Tekrar)', ...)
```

### 14. FEEDBACK SCREEN

**Dosya:** `lib/presentation/screens/settings/feedback_screen.dart`

**Değişiklikler:**
```dart
AppTextInput(
  label: 'Mesajınız',
  hint: 'Görüş ve önerilerinizi buraya yazın...',
  maxLines: 5,
  maxLength: 500,
  ...
)

// Rating widget aynı kalabilir

AppPrimaryButton(
  label: 'Gönder',
  icon: Icons.send,
  isFullWidth: true,
  ...
)
```

### 15. TROUSSEAU DETAIL SCREEN (EN KARMAŞIK!)

**Dosya:** `lib/presentation/screens/trousseau/trousseau_detail_screen.dart`

**ÖNEMLİ DEĞİŞİKLİKLER:**

```dart
// 1. Search Input
AppSearchInput(
  controller: _searchController,
  hint: 'Ürün ara...',
  onChanged: (v) => productProvider.setSearchQuery(v),
  onClear: () => productProvider.setSearchQuery(''),
)

// 2. Product Card
// Mevcut custom card yerine AppProductCard kullan
AppProductCard(
  name: product.name,
  description: product.description,
  price: product.price,
  quantity: product.quantity,
  isPurchased: product.isPurchased,
  images: product.images,
  category: category,
  onTap: () => context.push('/product/${product.id}'),
  onTogglePurchase: () => _togglePurchase(product),
  canEdit: trousseau.canEdit(userId),
)

// 3. FAB
AppFAB(
  icon: Icons.add,
  label: 'Ürün Ekle',
  onPressed: () => context.push('/trousseau/$trousseauId/products/add'),
)
```

---

## 🎯 ÖNCELİK SIRASI

Eğer hepsini yapamıyorsan, bu sıraya göre yap:

1. **Yüksek Öncelik** (Kullanıcı en çok kullanır):
   - Add Product Screen
   - Edit Product Screen
   - Product Detail Screen
   - Trousseau Detail Screen

2. **Orta Öncelik**:
   - Create/Edit Trousseau Screens
   - Share Trousseau Screen

3. **Düşük Öncelik** (Az kullanılır):
   - Settings Screens
   - Feedback Screen

---

## ✅ HER EKRAN İÇİN KONTROL LİSTESİ

- [ ] Dosya başında yorum var mı? (/// Screen Name - Yeni Tasarım Sistemi v2.0)
- [ ] Import'lar düzeltilmiş mi?
- [ ] Tüm butonlar değiştirilmiş mi?
- [ ] Tüm input'lar değiştirilmiş mi?
- [ ] Spacing'ler token kullanıyor mu?
- [ ] Card'lar AppCard kullanıyor mu?
- [ ] Hard-coded değer kalmamış mı?

---

## 🚀 HIZLI İPUÇLARI

**Ctrl+F ile bul ve değiştir:**

1. `ElevatedButton(` → `AppPrimaryButton(`
2. `OutlinedButton(` → `AppSecondaryButton(`
3. `IconButton(` → `AppIconButton(`
4. `TextField(` → `AppTextInput(`
5. `SizedBox(height: 16)` → `AppSpacing.md.verticalSpace`
6. `SizedBox(width: 8)` → `AppSpacing.sm.horizontalSpace`
7. `EdgeInsets.all(16)` → `AppSpacing.paddingMD`

**UYARI:** Bul-değiştir yaparken dikkatli ol! Her durumda aynen uygulanmayabilir.

---

## 📊 İLERLEME TAKİBİ

```
✅ Login Screen
✅ Register Screen
✅ Home Screen
✅ Statistics Screen
⬜ Add Product Screen
⬜ Edit Product Screen
⬜ Product Detail Screen
⬜ Create Trousseau Screen
⬜ Edit Trousseau Screen
⬜ Share Trousseau Screen
⬜ Profile Screen
⬜ Theme Settings Screen
⬜ Change Password Screen
⬜ Feedback Screen
⬜ Trousseau Detail Screen

İlerleme: 4/15 (27%)
```
