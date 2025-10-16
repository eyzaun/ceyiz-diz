/// App Card - Tutarlı Kart Tasarımları
///
/// GESTALT PRENSİPLERİ:
/// - ORTAK ALAN: Card içindeki öğeler aynı gruba ait
/// - YAKINLIK: İlgili bilgiler birbirine yakın
/// - BENZERLİK: Tüm card'lar aynı padding/radius kullanır

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../data/models/category_model.dart';

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

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: margin ?? const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      color: color,
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
  final String name;
  final String description;
  final double price;
  final int quantity;
  final bool isPurchased;
  final List<String> images;
  final CategoryModel category;
  final VoidCallback? onTap;
  final VoidCallback? onTogglePurchase;
  final bool canEdit;

  const AppProductCard({
    super.key,
    required this.name,
    required this.description,
    required this.price,
    this.quantity = 1,
    this.isPurchased = false,
    required this.images,
    required this.category,
    this.onTap,
    this.onTogglePurchase,
    this.canEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // ─────────────────────────────────────────────────────────────────
          // SOL: Ürün Görseli veya Kategori İkonu
          // ─────────────────────────────────────────────────────────────────
          _buildThumbnail(context),

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
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: AppTypography.semiBold,
                          fontSize: AppTypography.sizeMD,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isPurchased) ...[
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
                if (description.isNotEmpty) ...[
                  AppSpacing.xs.verticalSpace,
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: AppTypography.sizeSM,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                AppSpacing.xs.verticalSpace,

                // Kategori Badge + Adet Bilgisi
                Row(
                  children: [
                    _buildCategoryBadge(context),
                    if (quantity > 1) ...[
                      AppSpacing.sm.horizontalSpace,
                      Text(
                        '$quantity adet',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: AppTypography.sizeXS,
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
                '₺${price.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: AppTypography.bold,
                  fontSize: AppTypography.sizeMD,
                ),
              ),

              // Toplam Fiyat (eğer adet > 1)
              if (quantity > 1) ...[
                AppSpacing.xs.verticalSpace,
                Text(
                  'Top: ₺${(price * quantity).toStringAsFixed(2)}',
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
                      isPurchased
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: AppDimensions.iconSizeMedium,
                    ),
                    color: isPurchased
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

  Widget _buildThumbnail(BuildContext context) {
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
  final InfoCardType type;
  final VoidCallback? onDismiss;

  const AppInfoCard({
    super.key,
    required this.title,
    this.message,
    this.type = InfoCardType.info,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _getConfig(theme);

    return AppCard(
      color: config.color.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(
            config.icon,
            color: config.color,
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
                    color: config.color,
                    fontWeight: AppTypography.semiBold,
                  ),
                ),
                if (message != null) ...[
                  AppSpacing.xs.verticalSpace,
                  Text(
                    message!,
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
              color: config.color,
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
