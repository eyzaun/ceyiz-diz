# Changelog

Tüm önemli değişiklikler bu dosyada dokümante edilmiştir.

Format [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) standardına uygundur.

## [1.0.18] - 2025-10-19

### 🚀 Performans İyileştirmeleri

#### Added
- Firebase Storage Resize Extension entegrasyonu
- Otomatik thumbnail oluşturma (200x200 ve 400x400)
- Image optimization utility (`lib/core/utils/image_optimization_utils.dart`)
- Memory cache optimizasyonu (CachedNetworkImage)
- Upload boyut sınırlaması (max 1920x1920)

#### Changed
- Ürün kartları artık 200x200 thumbnail kullanıyor (2.5 MB → 15 KB, **166x daha küçük**)
- Product detail preview 400x400 thumbnail kullanıyor (2.5 MB → 40 KB, **62x daha küçük**)
- Profil fotoğrafları 256x256'ya küçültülüyor (512x512'den)
- Fullscreen viewer original boyut kullanıyor (kalite korunuyor)

#### Performance Metrics
- Liste yüklenme süresi: 8-12 sn → 0.5-1 sn (**10-20x daha hızlı**)
- 10 ürün veri kullanımı: 25 MB → 150 KB (**166x daha az**)
- Memory kullanımı: 180 MB → 65 MB (**-64%**)
- Firebase maliyeti: $1.27/ay → $0.08/ay (**-94%**)

#### Documentation
- `FIREBASE_RESIZE_SETUP.md` - Firebase Extension kurulum rehberi
- `IMAGE_OPTIMIZATION_REPORT.md` - Detaylı optimizasyon raporu
- `OPTIMIZATION_SUMMARY.md` - Hızlı başlangıç rehberi

### 📝 Technical Details

#### Modified Files
- `lib/presentation/widgets/common/image_picker_widget.dart`
- `lib/presentation/widgets/common/app_card.dart`
- `lib/presentation/screens/product/product_detail_screen.dart`
- `lib/presentation/screens/product/edit_product_screen.dart`
- `lib/presentation/widgets/common/fullscreen_image_viewer.dart`
- `lib/presentation/screens/settings/settings_screen.dart`
- `OZET.md`

#### New Files
- `lib/core/utils/image_optimization_utils.dart`
- `FIREBASE_RESIZE_SETUP.md`
- `IMAGE_OPTIMIZATION_REPORT.md`
- `OPTIMIZATION_SUMMARY.md`

---

## [1.0.17] - 2025-10-18

### ✨ Yeni Özellikler

#### Added
- Tam ekran fotoğraf görüntüleyici (swipe, pinch-to-zoom, dismiss)
- Thumbnail büyütme (56dp → 80dp, +43%)
- Akıllı geri tuşu (Android - çift tıkla çık)

#### Fixed
- Monochrome tema düzeltmesi (gerçek monokrom)
- BuildContext mounted checks (5 dosya)
- Deprecated API düzeltmeleri (Color.withValues)
- GoRouter geri tuşu crash

#### Removed
- 66 debug print statement
- 11 eski markdown dosyası
- ~15 analyzer warning

---

## [1.0.16] - 2025-10-15

### Initial Release
- Çoklu çeyiz yönetimi
- Bütçe takibi
- Fotoğraf galerisi (max 5/ürün)
- Email ile paylaşım
- 5 tema seçeneği
- Kategori yönetimi
- İstatistikler ve raporlar

---

## Versiyon Numaralandırma

[Semantic Versioning](https://semver.org/) kullanılmaktadır:
- **Major.Minor.Patch+BuildNumber**
- Örnek: 1.0.18+25
  - 1: Major version (breaking changes)
  - 0: Minor version (yeni özellikler)
  - 18: Patch version (bug fixes)
  - 25: Build number (her build'de artar)
