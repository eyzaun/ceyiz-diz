/// Image Optimization Utilities
/// 
/// Firebase Storage Resize Extension ile otomatik oluşturulan
/// thumbnail URL'lerini yönetir
/// 
/// Extension ayarları:
/// - 200x200: Ürün kartları için (küçük thumbnail)
/// - 400x400: Product detail için (medium thumbnail)
/// - Original: Tam ekran görünüm için
/// 
/// ÖNEMLI: Firebase Extension Konfigürasyonu
/// Extension'ın doğru çalışması için şu ayarlar yapılmalı:
/// 
/// 1. Resize Mode: "Cover" (fotoğrafın en-boy oranını koruyarak crop eder)
///    - NOT: "Contain" kullanılırsa fotoğraf sığdırılır (beyaz kenarlıklar oluşur)
///    - NOT: "Fill" kullanılırsa fotoğraf deforme olur (oranlar bozulur)
/// 
/// 2. Monitored Paths: /profile_photos,/products
/// 
/// 3. Sizes: 200x200,400x400
/// 
/// 4. Delete Original: false (original'i koru, thumbnail oluştur)
/// 
/// Cover mode ile:
/// - Fotoğrafın merkezinden crop alınır (center crop)
/// - En-boy oranı bozulmaz
/// - 200x200 kare thumbnail tam olarak 200x200 px olur
/// - Profil fotoğrafları ve ürün fotoğrafları için ideal
library;

class ImageOptimizationUtils {
  ImageOptimizationUtils._();

  /// Thumbnail boyutları
  static const String smallThumbnail = '200x200'; // Ürün kartları (80x80dp gösterim)
  static const String mediumThumbnail = '400x400'; // Product detail preview
  
  /// Firebase Storage Resize Extension tarafından oluşturulan
  /// thumbnail URL'ini döndürür
  /// 
  /// Örnek:
  /// ```dart
  /// // Original URL
  /// gs://bucket/path/image_123.jpg
  /// 
  /// // Small thumbnail (200x200)
  /// gs://bucket/path/image_123_thumb@200x200_uuid.jpg
  /// 
  /// // Medium thumbnail (400x400)
  /// gs://bucket/path/image_123_thumb@400x400_uuid.jpg
  /// ```
  /// 
  /// [originalUrl] Original fotoğraf URL'i (Firebase Storage download URL)
  /// [size] Thumbnail boyutu ('200x200' veya '400x400')
  /// 
  /// Returns: Thumbnail URL'i (eğer extension henüz çalışmadıysa original döner)
  static String getThumbnailUrl(String originalUrl, String size) {
    if (originalUrl.isEmpty) return originalUrl;
    
    // URL'den path çıkar
    // https://firebasestorage.googleapis.com/v0/b/bucket/o/path%2Fimage.jpg?alt=media&token=xxx
    // → path/image.jpg
    
    try {
      final uri = Uri.parse(originalUrl);
      
      // Firebase Storage download URL formatı mı kontrol et
      if (!uri.host.contains('firebasestorage.googleapis.com')) {
        return originalUrl; // Firebase Storage URL değilse direkt döndür
      }
      
      // Path'i decode et
      final pathSegments = uri.pathSegments;
      if (pathSegments.length < 4) return originalUrl; // Geçersiz format
      
      // /v0/b/{bucket}/o/{encodedPath}
      final encodedPath = pathSegments[3];
      final decodedPath = Uri.decodeComponent(encodedPath);
      
      // Dosya adı ve uzantısını ayır
      // trousseaus/id/products/id/image_123.jpg
      final lastSlash = decodedPath.lastIndexOf('/');
      final fileName = lastSlash >= 0 ? decodedPath.substring(lastSlash + 1) : decodedPath;
      final lastDot = fileName.lastIndexOf('.');
      
      if (lastDot < 0) return originalUrl; // Uzantı yok
      
      final nameWithoutExt = fileName.substring(0, lastDot);
      final extension = fileName.substring(lastDot); // .jpg
      
      // Thumbnail dosya adı oluştur
      // Firebase Extension default pattern: {original}_{size}{extension}
      // Örnek: image_200x200.jpg veya image_400x400.jpg
      final thumbnailFileName = '${nameWithoutExt}_$size$extension';
      
      // Path'i yeniden oluştur
      final directory = lastSlash >= 0 ? decodedPath.substring(0, lastSlash + 1) : '';
      final thumbnailPath = '$directory$thumbnailFileName';
      
      // Encode ve URL'i yeniden oluştur
      final encodedThumbnailPath = Uri.encodeComponent(thumbnailPath);
      
      // Token'ı koru (eğer varsa)
      final token = uri.queryParameters['token'];
      final queryParams = token != null ? '?alt=media&token=$token' : '?alt=media';
      
      final thumbnailUrl = 'https://firebasestorage.googleapis.com/v0/b/${pathSegments[1]}/o/$encodedThumbnailPath$queryParams';
      
      return thumbnailUrl;
    } catch (e) {
      // Parse hatası durumunda original URL'i döndür
      return originalUrl;
    }
  }
  
  /// Küçük thumbnail URL'i döndürür (200x200)
  /// Ürün kartları için kullanılır
  static String getSmallThumbnail(String originalUrl) {
    return getThumbnailUrl(originalUrl, smallThumbnail);
  }
  
  /// Orta boyut thumbnail URL'i döndürür (400x400)
  /// Product detail preview için kullanılır
  static String getMediumThumbnail(String originalUrl) {
    return getThumbnailUrl(originalUrl, mediumThumbnail);
  }
  
  /// Birden fazla URL için thumbnail URL'leri döndürür
  static List<String> getThumbnailUrls(List<String> originalUrls, String size) {
    return originalUrls.map((url) => getThumbnailUrl(url, size)).toList();
  }
  
  /// Memory cache boyutu hesaplama
  /// CachedNetworkImage memCacheWidth/Height için kullanılır
  /// 
  /// [displaySize] Widget'ın ekrandaki boyutu (dp)
  /// [devicePixelRatio] Cihazın pixel ratio'su (genelde 2-3)
  /// 
  /// Returns: Cache'de tutulacak pixel boyutu
  static int getMemoryCacheSize(double displaySize, double devicePixelRatio) {
    // Display size'ı pixel'e çevir ve 2x buffer ekle (retina displays için)
    return (displaySize * devicePixelRatio * 2).toInt();
  }
}
