library;

/// App Card - Tutarlı Kart Tasarımları
///
/// GESTALT PRENSİPLERİ:
/// - ORTAK ALAN: Card içindeki öğeler aynı gruba ait
/// - YAKINLIK: İlgili bilgiler birbirine yakın
/// - BENZERLİK: Tüm card'lar aynı padding/radius kullanır

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/services/kac_saat_calculator.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// BASE CARD - Temel Kart Bileşeni
/// ═══════════════════════════════════════════════════════════════════════════
///
/// TÜM CARD'LAR AYNI:
/// - Padding: 16dp (AppSpacing.md)
/// - Border Radius: 16dp (AppRadius.lg)
/// - Margin: 8dp vertical
///
/// Bu tutarlılık Gestalt Prensibi'ni sağlar

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? backgroundColor; // Alias for color

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: margin ?? const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      color: backgroundColor ?? color, // Use backgroundColor first, fallback to color
      elevation: theme.brightness == Brightness.light
          ? AppElevation.subtle
          : AppElevation.flat,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLG,
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(
            alpha: theme.brightness == Brightness.light ? 0.5 : 0.3,
          ),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusLG,
        child: Padding(
          padding: padding ?? AppSpacing.paddingMD,
          child: child,
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// PRODUCT CARD - Ürün Kartı
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Görsel Hiyerarşi:
/// 1. Görsel (64x64) - Sol
/// 2. İsim + Açıklama + Kategori - Orta (Expanded)
/// 3. Fiyat + Durum - Sağ
///
/// FITTS YASASI: Tüm kart tıklanabilir (48dp+ yükseklik)

class AppProductCard extends StatelessWidget {
  // Accept product directly or individual fields (backwards compatibility)
  final ProductModel? product;
  final String? name;
  final String? description;
  final double? price;
  final int? quantity;
  final bool? isPurchased;
  final List<String>? images;
  final CategoryModel category;
  final VoidCallback? onTap;
  final VoidCallback? onTogglePurchase;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool canEdit;
  final bool showKacSaat;
  final KacSaatSettings? kacSaatSettings;

  const AppProductCard({
    super.key,
    this.product,
    this.name,
    this.description,
    this.price,
    this.quantity,
    this.isPurchased,
    this.images,
    required this.category,
    this.onTap,
    this.onTogglePurchase,
    this.onEdit,
    this.onDelete,
    this.canEdit = false,
    this.showKacSaat = true,
    this.kacSaatSettings,
  });

  String _normalizeUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;
    final hasScheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://').hasMatch(trimmed);
    return hasScheme ? trimmed : 'https://$trimmed';
  }

  Future<void> _openLink(BuildContext context, String link) async {
    final l10n = AppLocalizations.of(context);
    try {
      final normalized = _normalizeUrl(link);
      if (normalized.isEmpty) return;
      final uri = Uri.parse(normalized);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.cantOpenLink ?? 'Link açılamadı'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.radiusMD,
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.invalidLink ?? 'Geçersiz link'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.radiusMD,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use product if provided, otherwise use individual fields
    final String displayName = product?.name ?? name ?? '';
    final String displayDescription = product?.description ?? description ?? '';
    final double displayPrice = product?.price ?? price ?? 0.0;
    final int displayQuantity = product?.quantity ?? quantity ?? 1;
    final bool displayIsPurchased = product?.isPurchased ?? isPurchased ?? false;
    final List<String> displayImages = product?.images ?? images ?? [];
    final String displayLink = product?.link ?? '';
    final String displayLink2 = product?.link2 ?? '';
    final String displayLink3 = product?.link3 ?? '';

    // Tüm linkleri listeye al
    final List<String> allLinks = [
      if (displayLink.isNotEmpty) displayLink,
      if (displayLink2.isNotEmpty) displayLink2,
      if (displayLink3.isNotEmpty) displayLink3,
    ];

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // ─────────────────────────────────────────────────────────────────
          // SOL: Ürün Görseli veya Kategori İkonu (Checkmark kaldırıldı)
          // ─────────────────────────────────────────────────────────────────
          _buildThumbnail(context, displayImages),

          AppSpacing.md.horizontalSpace,

          // ─────────────────────────────────────────────────────────────────
          // ORTA: Ürün Bilgileri (Expanded)
          // ─────────────────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ürün Adı + Satın Alındı İkonu
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: AppTypography.semiBold,
                          fontSize: AppTypography.sizeMD,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Açıklama (eğer varsa)
                if (displayDescription.isNotEmpty) ...[
                  AppSpacing.xs.verticalSpace,
                  Text(
                    displayDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: AppTypography.sizeSM,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                AppSpacing.xs.verticalSpace,

                // Kategori Badge + Adet Bilgisi + Link İkonu (Wrap ile taşma önlenir)
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildCategoryBadge(context),
                    if (displayQuantity > 1)
                      Text(
                        '$displayQuantity adet',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontSize: AppTypography.sizeXS,
                        ),
                      ),
                    // Link İkonları (tüm linkler için)
                    ...allLinks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final link = entry.value;
                      return GestureDetector(
                        onTap: () => _openLink(context, link),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.link,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                              if (allLinks.length > 1) ...[
                                const SizedBox(width: 2),
                                Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: theme.colorScheme.primary,
                                    fontWeight: AppTypography.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),

                // Kaç Saat Bilgisi (sadece enabled ise göster)
                if (product != null && showKacSaat) ...[
                  AppSpacing.xs.verticalSpace,
                  _buildKacSaatBadge(context, theme),
                ],
              ],
            ),
          ),

          AppSpacing.md.horizontalSpace,

          // ─────────────────────────────────────────────────────────────────
          // SAĞ: Fiyat + Checkbox
          // ─────────────────────────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
                // Fiyat ve Checkbox yatayda hizalı
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      CurrencyFormatter.formatWithSymbol(displayPrice),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: AppTypography.bold,
                        fontSize: AppTypography.sizeMD,
                      ),
                    ),
                    if (canEdit) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: AppDimensions.touchTargetSize,
                        height: AppDimensions.touchTargetSize,
                        child: IconButton(
                          icon: Icon(
                            displayIsPurchased
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            size: AppDimensions.iconSizeMedium,
                          ),
                          color: displayIsPurchased
                              ? theme.colorScheme.tertiary
                              : theme.colorScheme.onSurface,
                          onPressed: onTogglePurchase,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: AppDimensions.touchTargetSize,
                            minHeight: AppDimensions.touchTargetSize,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Toplam Fiyat (eğer adet > 1)
                if (displayQuantity > 1) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Top: ${CurrencyFormatter.formatWithSymbol(displayPrice * displayQuantity)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: AppTypography.sizeSM,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, List<String> images) {
    // 🚀 OPTIMIZATION: Device pixel ratio için cache boyutu hesapla
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheSize = (AppDimensions.cardImageSize * devicePixelRatio * 2).toInt();
    
    return Container(
      width: AppDimensions.cardImageSize,
      height: AppDimensions.cardImageSize,
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.1),
        borderRadius: AppRadius.radiusMD,
      ),
      child: images.isNotEmpty
          ? ClipRRect(
              borderRadius: AppRadius.radiusMD,
              child: CachedNetworkImage(
                // 🚀 OPTIMIZATION: 200x200 thumbnail kullan (Firebase Extension)
                // Original: 2.5 MB → Thumbnail: ~15 KB (166x daha küçük!)
                imageUrl: _getOptimizedImageUrl(images.first, '200x200'),
                fit: BoxFit.cover,
                // 🚀 OPTIMIZATION: Memory cache boyutunu sınırla
                memCacheWidth: cacheSize,
                memCacheHeight: cacheSize,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    color: category.color,
                    strokeWidth: 2,
                  ),
                ),
                errorWidget: (context, url, error) => Icon(
                  category.icon,
                  color: category.color,
                  size: AppDimensions.iconSizeLarge,
                ),
              ),
            )
          : Icon(
              category.icon,
              color: category.color,
              size: AppDimensions.iconSizeLarge,
            ),
    );
  }
  
  /// Firebase Storage Resize Extension ile oluşturulan thumbnail URL'ini döndürür
  String _getOptimizedImageUrl(String originalUrl, String size) {
    if (originalUrl.isEmpty) return originalUrl;
    
    try {
      final uri = Uri.parse(originalUrl);
      
      // Firebase Storage URL değilse direkt döndür
      if (!uri.host.contains('firebasestorage.googleapis.com')) {
        return originalUrl;
      }
      
      // Path'i decode et
      final pathSegments = uri.pathSegments;
      if (pathSegments.length < 4) return originalUrl;
      
      final encodedPath = pathSegments[3];
      final decodedPath = Uri.decodeComponent(encodedPath);
      
      // Dosya adı ve uzantısını ayır
      final lastSlash = decodedPath.lastIndexOf('/');
      final fileName = lastSlash >= 0 ? decodedPath.substring(lastSlash + 1) : decodedPath;
      final lastDot = fileName.lastIndexOf('.');
      
      if (lastDot < 0) return originalUrl;
      
      final nameWithoutExt = fileName.substring(0, lastDot);
      final extension = fileName.substring(lastDot);
      
      // Thumbnail dosya adı oluştur (Firebase Extension pattern)
      final thumbnailFileName = '${nameWithoutExt}_thumb@$size$extension';
      
      // Path'i yeniden oluştur
      final directory = lastSlash >= 0 ? decodedPath.substring(0, lastSlash + 1) : '';
      final thumbnailPath = '$directory$thumbnailFileName';
      
      // Encode ve URL'i yeniden oluştur
      final encodedThumbnailPath = Uri.encodeComponent(thumbnailPath);
      
      // Token'ı koru
      final token = uri.queryParameters['token'];
      final queryParams = token != null ? '?alt=media&token=$token' : '?alt=media';
      
      return 'https://firebasestorage.googleapis.com/v0/b/${pathSegments[1]}/o/$encodedThumbnailPath$queryParams';
    } catch (e) {
      // Hata durumunda original URL döndür
      return originalUrl;
    }
  }

  Widget _buildCategoryBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.1),
        borderRadius: AppRadius.radiusSM,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            category.icon,
            size: 10,
            color: category.color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            category.displayName,
            style: TextStyle(
              fontSize: AppTypography.sizeXS,
              color: category.color,
              fontWeight: AppTypography.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKacSaatBadge(BuildContext context, ThemeData theme) {
    if (product == null) return const SizedBox.shrink();

    // Kullanıcı ayarlarını kullan, yoksa varsayılan değerler
    final settings = kacSaatSettings ?? const KacSaatSettings();

    // Calculator oluştur
    final calculator = settings.toCalculator();

    // Hesaplama geçerliyse kullan, değilse varsayılan (125 TL/saat)
    final double hours;
    if (calculator.isValid) {
      hours = calculator.calculateHoursForPrice(product!.price);
    } else {
      // Varsayılan: Asgari ücret 20,002.5 TL, 5 gün x 8 saat = 160 saat/ay
      const defaultHourlyRate = 125.0;
      hours = product!.price / defaultHourlyRate;
    }

    final roundedHours = hours.round();

    // Renk kategorileri: < 8 saat = yeşil, 8-40 = sarı, > 40 = kırmızı
    final Color color;
    if (hours < 8) {
      color = const Color(0xFF10B981); // Yeşil
    } else if (hours <= 40) {
      color = const Color(0xFFF59E0B); // Sarı
    } else {
      color = theme.colorScheme.error; // Kırmızı
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.radiusSM,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 10,
            color: color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$roundedHours saat',
            style: TextStyle(
              fontSize: AppTypography.sizeXS,
              color: color,
              fontWeight: AppTypography.medium,
            ),
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// STATISTICS CARD - İstatistik Kartı
/// ═══════════════════════════════════════════════════════════════════════════
///
/// MILLER YASASI: Max 3 bilgi göster
/// Kullanım: Ana sayfa özet istatistikleri

class AppStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final Color? color;
  final VoidCallback? onTap;

  const AppStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = color ?? theme.colorScheme.primary;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.radiusSM,
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: AppDimensions.iconSizeMedium,
                ),
              ),
              AppSpacing.sm.horizontalSpace,
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: AppTypography.sizeBase,
                  ),
                ),
              ),
            ],
          ),

          AppSpacing.md.verticalSpace,

          // Value (Ana Değer)
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: accentColor,
              fontWeight: AppTypography.bold,
              fontSize: AppTypography.size3XL,
            ),
          ),

          // Subtitle (Alt bilgi)
          if (subtitle != null) ...[
            AppSpacing.xs.verticalSpace,
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontSize: AppTypography.sizeSM,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// INFO CARD - Bilgilendirme Kartı
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Kullanım: Uyarılar, bildirimler, ipuçları

enum InfoCardType { info, success, warning, error }

class AppInfoCard extends StatelessWidget {
  final String title;
  final String? message;
  final String? subtitle; // Alias for message
  final InfoCardType type;
  final VoidCallback? onDismiss;
  final IconData? icon; // Custom icon (overrides type-based icon)
  final Color? color; // Custom color (overrides type-based color)
  final Color? backgroundColor; // Custom background color

  const AppInfoCard({
    super.key,
    required this.title,
    this.message,
    this.subtitle,
    this.type = InfoCardType.info,
    this.onDismiss,
    this.icon,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _getConfig(theme);

    // Use custom values if provided, otherwise use config from type
    final displayIcon = icon ?? config.icon;
    final displayColor = color ?? config.color;
    final displayMessage = message ?? subtitle;
    final displayBackgroundColor = backgroundColor ?? displayColor.withValues(alpha: 0.1);

    return AppCard(
      color: displayBackgroundColor,
      child: Row(
        children: [
          Icon(
            displayIcon,
            color: displayColor,
            size: AppDimensions.iconSizeMedium,
          ),
          AppSpacing.md.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: displayColor,
                    fontWeight: AppTypography.semiBold,
                  ),
                ),
                if (displayMessage != null) ...[
                  AppSpacing.xs.verticalSpace,
                  Text(
                    displayMessage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null) ...[
            AppSpacing.sm.horizontalSpace,
            IconButton(
              icon: const Icon(Icons.close),
              iconSize: AppDimensions.iconSizeSmall,
              color: displayColor,
              onPressed: onDismiss,
              constraints: const BoxConstraints(
                minWidth: AppDimensions.touchTargetSize,
                minHeight: AppDimensions.touchTargetSize,
              ),
            ),
          ],
        ],
      ),
    );
  }

  ({IconData icon, Color color}) _getConfig(ThemeData theme) {
    return switch (type) {
      InfoCardType.info => (
          icon: Icons.info_outline,
          color: theme.colorScheme.primary,
        ),
      InfoCardType.success => (
          icon: Icons.check_circle_outline,
          color: const Color(0xFF10B981),
        ),
      InfoCardType.warning => (
          icon: Icons.warning_amber_outlined,
          color: const Color(0xFFF59E0B),
        ),
      InfoCardType.error => (
          icon: Icons.error_outline,
          color: theme.colorScheme.error,
        ),
    };
  }
}
