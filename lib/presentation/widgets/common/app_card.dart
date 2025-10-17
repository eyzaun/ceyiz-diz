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
  });

  String _normalizeUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;
    final hasScheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://').hasMatch(trimmed);
    return hasScheme ? trimmed : 'https://$trimmed';
  }

  Future<void> _openLink(BuildContext context, String link) async {
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
            content: const Text('Link açılamadı'),
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
            content: const Text('Geçersiz link'),
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

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // ─────────────────────────────────────────────────────────────────
          // SOL: Ürün Görseli veya Kategori İkonu
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
                    if (displayIsPurchased) ...[
                      AppSpacing.xs.horizontalSpace,
                      Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.tertiary,
                        size: AppDimensions.iconSizeSmall,
                      ),
                    ],
                  ],
                ),

                // Açıklama (eğer varsa)
                if (displayDescription.isNotEmpty) ...[
                  AppSpacing.xs.verticalSpace,
                  Text(
                    displayDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: AppTypography.sizeSM,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                AppSpacing.xs.verticalSpace,

                // Kategori Badge + Adet Bilgisi + Link İkonu
                Row(
                  children: [
                    _buildCategoryBadge(context),
                    if (displayQuantity > 1) ...[
                      AppSpacing.sm.horizontalSpace,
                      Text(
                        '$displayQuantity adet',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: AppTypography.sizeXS,
                        ),
                      ),
                    ],
                    // Link İkonu (eğer link varsa)
                    if (displayLink.isNotEmpty) ...[
                      AppSpacing.sm.horizontalSpace,
                      GestureDetector(
                        onTap: () => _openLink(context, displayLink),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.link,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
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
              // Birim Fiyat
              Text(
                CurrencyFormatter.formatWithSymbol(displayPrice),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: AppTypography.bold,
                  fontSize: AppTypography.sizeMD,
                ),
              ),

              // Toplam Fiyat (eğer adet > 1)
              if (displayQuantity > 1) ...[
                AppSpacing.xs.verticalSpace,
                Text(
                  'Top: ${CurrencyFormatter.formatWithSymbol(displayPrice * displayQuantity)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: AppTypography.sizeXS,
                  ),
                ),
              ],

              // Checkbox (eğer düzenleme izni varsa)
              if (canEdit) ...[
                AppSpacing.xs.verticalSpace,
                // FITTS YASASI: 48x48dp touch area
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
                        : theme.colorScheme.onSurfaceVariant,
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
        ],
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, List<String> images) {
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
                imageUrl: images.first,
                fit: BoxFit.cover,
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
                    color: theme.colorScheme.onSurfaceVariant,
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
                color: theme.colorScheme.onSurfaceVariant,
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
