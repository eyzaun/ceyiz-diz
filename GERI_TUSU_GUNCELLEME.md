# Geri Tuşu Davranışı Güncelleme

**Tarih:** 18 Ekim 2025  
**Versiyon:** 1.0.17+24

## Sorun

Uygulamada geri tuşuna basıldığında direkt çıkıyordu. Bu kullanıcı deneyimi açısından sorunluydu çünkü:
- ❌ Kazara geri tuşuna basıldığında uygulama kapanıyordu
- ❌ Kullanıcı onay vermeden çıkış yapılıyordu
- ❌ Diğer ekranlardan ana ekrana dönüş yoktu

---

## Çözüm

### 🎯 Akıllı Geri Tuşu Kontrolü

**Dosya:** `lib/presentation/screens/home/home_screen.dart`

#### 1. **Ana Çeyiz Ekranında (İlk Sekme)**
```
Kullanıcı Akışı:
┌─────────────────────────────────────┐
│  Ana Çeyiz Ekranı (Sekme 1)         │
│                                     │
│  [Geri Tuşu - 1. Tıklama]         │
│  ↓                                  │
│  SnackBar: "Çıkmak için tekrar    │
│             basın" (2 saniye)      │
│                                     │
│  [Geri Tuşu - 2. Tıklama]         │
│  (2 saniye içinde)                 │
│  ↓                                  │
│  ✅ Uygulamadan Çık                │
└─────────────────────────────────────┘
```

**Özellikler:**
- ✅ İlk geri tuşunda uyarı mesajı gösterilir
- ✅ 2 saniye içinde tekrar basılırsa uygulama kapanır
- ✅ 2 saniye geçerse timer sıfırlanır
- ✅ Kazara çıkışların önüne geçilir

#### 2. **Diğer Sekmelerde (İstatistikler, Ayarlar)**
```
Kullanıcı Akışı:
┌─────────────────────────────────────┐
│  İstatistikler Sekmesi (Sekme 2)   │
│  veya                               │
│  Ayarlar Sekmesi (Sekme 3)         │
│                                     │
│  [Geri Tuşu]                       │
│  ↓                                  │
│  ✅ Ana Çeyiz Sekmesine Dön        │
│     (Sekme 1)                      │
└─────────────────────────────────────┘
```

**Özellikler:**
- ✅ Geri tuşu ile otomatik olarak ilk sekmeye (Çeyiz) döner
- ✅ Sekme geçişleri smooth ve doğal
- ✅ Uygulamadan çıkmaz

#### 3. **Alt Ekranlar (Ürün Detay, Ayarlar vb.)**
```
Kullanıcı Akışı:
┌─────────────────────────────────────┐
│  Ürün Detay Ekranı                  │
│  Ayarlar Alt Ekranı                 │
│  Profil Düzenleme vb.               │
│                                     │
│  [Geri Tuşu]                       │
│  ↓                                  │
│  ✅ Bir Önceki Ekrana Dön          │
│     (Normal navigasyon)             │
└─────────────────────────────────────┘
```

**Özellikler:**
- ✅ GoRouter normal navigasyon davranışı korunur
- ✅ Adım adım geri gelir
- ✅ Ana ekrana ulaşınca yukarıdaki kurallar devreye girer

---

## Teknik Detaylar

### Kullanılan Widget
**PopScope** - Flutter 3.x'te WillPopScope'un yerini aldı

```dart
PopScope(
  canPop: false, // Manuel kontrol
  onPopInvokedWithResult: (didPop, result) async {
    if (didPop) return;
    
    final shouldPop = await _onWillPop();
    if (shouldPop) {
      // GoRouter ile çalışırken SystemNavigator.pop() kullan
      SystemNavigator.pop(); // ✅ Uygulamayı düzgün şekilde kapat
    }
  },
  child: Scaffold(...)
)
```

**Önemli:** GoRouter kullanıldığı için `Navigator.of(context).pop()` yerine `SystemNavigator.pop()` kullanılıyor. Bu, GoRouter'ın navigation stack'ini karıştırmadan doğrudan Android sistem seviyesinde uygulamayı kapatır.

### Mantık Akışı

```dart
Future<bool> _onWillPop() async {
  // 1. Diğer sekmelerdeyse → Çeyiz sekmesine dön
  if (_selectedIndex != 0) {
    setState(() {
      _selectedIndex = 0;
    });
    return false; // Çıkma
  }

  // 2. Çeyiz sekmesindeyse → Çift tıklama kontrolü
  final now = DateTime.now();
  if (_lastBackPressTime == null || 
      now.difference(_lastBackPressTime!) > Duration(seconds: 2)) {
    // İlk tıklama - uyarı göster
    _lastBackPressTime = now;
    ScaffoldMessenger.of(context).showSnackBar(...);
    return false; // Çıkma
  }
  
  // 3. 2 saniye içinde ikinci tıklama → Çık
  return true; // ✅ Uygulamadan çık
}
```

---

## State Management

### Yeni State Değişkenleri

```dart
class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;              // Mevcut (sekme kontrolü için)
  bool _hasShownUpdateDialog = false;  // Mevcut
  DateTime? _lastBackPressTime;        // YENİ - Geri tuşu zamanlaması
  
  ...
}
```

### Import Eklentisi
```dart
import 'package:flutter/services.dart'; // SystemNavigator için
```

### Timer Mantığı
- **İlk tıklama:** `_lastBackPressTime = DateTime.now()`
- **İkinci tıklama kontrolü:** `now.difference(_lastBackPressTime!) > 2 saniye`
- **2 saniye geçtiyse:** Timer sıfırlanır, yeniden uyarı gösterilir
- **2 saniye içindeyse:** Uygulama kapanır

---

## Kullanıcı Deneyimi İyileştirmeleri

### Önce vs Sonra

| Önceki Durum | Yeni Durum |
|--------------|------------|
| ❌ Geri tuşu → Direkt çıkış | ✅ İlk geri → Uyarı mesajı |
| ❌ Kazara çıkış riski yüksek | ✅ Kazara çıkış önlenir |
| ❌ Diğer sekmelerden çıkış | ✅ Çeyiz sekmesine döner |
| ❌ Alt ekranlardan direkt çıkış | ✅ Adım adım geri gelir |
| ❌ Kullanıcı kontrolü yok | ✅ Bilinçli çıkış |

### UX Kuralları

✅ **Jakob Yasası:** Diğer uygulamalardaki çift-tıklama çıkış patternine uygun  
✅ **Fitts Yasası:** SnackBar alt kısımda, kolay fark edilir  
✅ **Hick Yasası:** Basit karar: "Çıkmak istiyor muyum?"  
✅ **Gestalt:** Tutarlı davranış - tüm sekmeler aynı mantıkla çalışır  

---

## Test Senaryoları

### ✅ Test Edilmesi Gerekenler

1. **Çeyiz Sekmesinde:**
   - [ ] İlk geri tuşu → Uyarı mesajı gösteriliyor mu?
   - [ ] İkinci geri tuşu (2 saniye içinde) → Uygulama kapanıyor mu?
   - [ ] 2 saniyeden sonra geri tuşu → Yeniden uyarı gösteriliyor mu?

2. **İstatistikler Sekmesinde:**
   - [ ] Geri tuşu → Çeyiz sekmesine dönüyor mu?
   - [ ] Uygulama kapanmıyor mu?

3. **Ayarlar Sekmesinde:**
   - [ ] Geri tuşu → Çeyiz sekmesine dönüyor mu?
   - [ ] Uygulama kapanmıyor mu?

4. **Alt Ekranlar (Ürün Detay, Profil vb.):**
   - [ ] Geri tuşu → Bir önceki ekrana dönüyor mu?
   - [ ] Ana ekrana ulaşınca çift-tıklama aktif oluyor mu?

5. **SnackBar Mesajı:**
   - [ ] Mesaj 2 saniye görünüyor mu?
   - [ ] Floating davranış (alt kısmda) çalışıyor mu?
   - [ ] Rounded corner tasarımı doğru mu?

6. **Edge Cases:**
   - [ ] Hızlı sekme geçişlerinde sorun var mı?
   - [ ] SnackBar gösterilirken sekme değiştirilirse ne oluyor?
   - [ ] Uygulama arka plana alınıp geri getirilirse timer sıfırlanıyor mu?

---

## Kod Değişiklikleri Özeti

### Değiştirilen Dosyalar
1. **lib/presentation/screens/home/home_screen.dart**
   - `import 'package:flutter/services.dart'` eklendi (SystemNavigator için)
   - `_lastBackPressTime` state değişkeni eklendi
   - `_onWillPop()` metodu eklendi
   - `PopScope` widget'ı ile Scaffold sarmalandı
   - Sekme kontrolü ve timer mantığı implementasyonu
   - `SystemNavigator.pop()` ile doğru çıkış yöntemi

### Eklenen Satırlar: ~45 satır
### Değiştirilen Satırlar: ~15 satır

---

## Sorun Giderme

### ❌ Eski Hatalı Kod (GoRouter ile çakışıyor)
```dart
if (shouldPop && context.mounted) {
  Navigator.of(context).pop(); // ❌ GoRouter stack'ini bozuyor
}
```

**Hata:**
```
E/flutter: Unhandled Exception: 'package:go_router/src/delegate.dart': 
Failed assertion: 'currentConfiguration.isNotEmpty': 
You have popped the last page off of the stack
```

### ✅ Doğru Kod (Sistem seviyesinde çıkış)
```dart
if (shouldPop) {
  SystemNavigator.pop(); // ✅ Uygulamayı düzgün kapatır
}
```

**Çözüm:**
- `Navigator.of(context).pop()` → GoRouter'ın navigation stack'ini manipüle eder
- `SystemNavigator.pop()` → Android sistem seviyesinde uygulamayı kapatır
- GoRouter ile çalışırken sistem çıkışı için `SystemNavigator.pop()` tercih edilmeli

---

## SnackBar Mesajı Detayları

```dart
SnackBar(
  content: const Text('Çıkmak için tekrar basın'),
  duration: const Duration(seconds: 2),
  behavior: SnackBarBehavior.floating,
  shape: RoundedRectangleBorder(
    borderRadius: AppRadius.radiusMD,
  ),
  margin: const EdgeInsets.all(AppSpacing.md),
)
```

**Özellikler:**
- ✅ **2 saniye görünür:** Timer ile senkronize
- ✅ **Floating behavior:** Alt kısmda, modern görünüm
- ✅ **Rounded corners:** Tutarlı design system
- ✅ **Margin:** Ekran kenarlarından boşluk

---

## Sonuç

Bu güncelleme ile:
- ✅ Kazara çıkış engellendi
- ✅ Kullanıcı bilinçli çıkış yapıyor
- ✅ Sekme navigasyonu akıllı hale geldi
- ✅ Alt ekranlardan adım adım geri geliş sağlandı
- ✅ Standart mobil UX patternlerine uygun davranış

**Kullanıcı deneyimi ve kontrol önemli ölçüde iyileştirildi! 🎉**
