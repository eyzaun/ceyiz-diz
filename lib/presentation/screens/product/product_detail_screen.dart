library;

/// Product Detail Screen - Yeni Tasarım Sistemi v2.0
///
/// TASARIM KURALLARI:
/// ✅ Jakob Yasası: Standart product detail layout
/// ✅ Fitts Yasası: Primary button 56dp, AppBar actions 48x48dp
/// ✅ Hick Yasası: 1 primary action (Satın Al/İşaretle), max 2 AppBar actions (Edit, More menu)
/// ✅ Miller Yasası: Bilgiler 3 bölüme ayrılmış (Görsel, Fiyat Bilgisi, Açıklama)
/// ✅ Gestalt: İlgili bilgiler gruplanmış (fiyat+adet+toplam bir kartta)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/design_tokens.dart';
import '../../providers/product_provider.dart';
import '../../providers/trousseau_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/fullscreen_image_viewer.dart';
import '../../../core/utils/currency_formatter.dart';

class ProductDetailScreen extends StatelessWidget {
  final String trousseauId;
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.trousseauId,
    required this.productId,
  });

  String _normalizeUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;
    final hasScheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://').hasMatch(trimmed);
    return hasScheme ? trimmed : 'https://$trimmed';
  }

  /// 🚀 Firebase Storage Resize Extension thumbnail URL'ini döndürür
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

  Future<String?> _selectTargetTrousseau(
    BuildContext context,
    TrousseauProvider trousseauProvider,
  ) async {
    final myTrousseaus = trousseauProvider.trousseaus;

    if (myTrousseaus.isEmpty) {
      return null;
    }

    // Sadece 1 çeyiz varsa doğrudan döndür
    if (myTrousseaus.length == 1) {
      return myTrousseaus.first.id;
    }

    // Birden fazla çeyiz varsa seçim diyalogu göster
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('Hangi Çeyize Eklensin?'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: myTrousseaus.length,
              separatorBuilder: (_, __) => Divider(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final trousseau = myTrousseaus[index];
                final progress = trousseau.totalProducts > 0
                    ? trousseau.purchasedProducts / trousseau.totalProducts
                    : 0.0;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(trousseau.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (trousseau.description.isNotEmpty) ...[
                        AppSpacing.xs.verticalSpace,
                        Text(
                          trousseau.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      AppSpacing.sm.verticalSpace,
                      Row(
                        children: [
                          Text(
                            '${trousseau.totalProducts} ürün',
                            style: theme.textTheme.bodySmall,
                          ),
                          AppSpacing.sm.horizontalSpace,
                          Text(
                            '${(progress * 100).toInt()}% tamamlandı',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).pop(trousseau.id),
                );
              },
            ),
          ),
          actions: [
            AppTextButton(
              label: 'İptal',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showMoreMenu(BuildContext context, bool canEdit) {
    final theme = Theme.of(context);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final product = productProvider.getProductById(productId);

    if (product == null) return;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: AppRadius.radiusSM,
                ),
              ),

              // Open Link Options
              if (product.link.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.open_in_new),
                  title: const Text('Ürün Linki 1\'i Aç'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _openLink(context, product.link);
                  },
                ),

              if (product.link2.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.open_in_new),
                  title: const Text('Ürün Linki 2\'yi Aç'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _openLink(context, product.link2);
                  },
                ),

              if (product.link3.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.open_in_new),
                  title: const Text('Ürün Linki 3\'ü Aç'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _openLink(context, product.link3);
                  },
                ),

              // Delete Option (only if can edit)
              if (canEdit)
                ListTile(
                  leading: Icon(Icons.delete, color: theme.colorScheme.error),
                  title: Text(
                    'Ürünü Sil',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);

                    // Confirmation Dialog
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogCtx) => AlertDialog(
                        title: const Text('Ürünü Sil'),
                        content: const Text(
                          'Bu ürünü silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
                        ),
                        actions: [
                          AppTextButton(
                            label: 'Vazgeç',
                            onPressed: () => Navigator.pop(dialogCtx, false),
                          ),
                          AppDangerButton(
                            label: 'Sil',
                            icon: Icons.delete,
                            onPressed: () => Navigator.pop(dialogCtx, true),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await productProvider.deleteProduct(productId);
                      if (context.mounted) {
                        context.pop();
                      }
                    }
                  },
                ),

              AppSpacing.md.verticalSpace,
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final trousseauProvider = Provider.of<TrousseauProvider>(context, listen: false);
    final product = productProvider.getProductById(productId);
    final trousseau = trousseauProvider.getTrousseauById(trousseauId);

    if (product == null || trousseau == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.pop();
        }
      });
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentUserId = trousseauProvider.currentUserId ?? '';
    final canEdit = trousseau.canEdit(currentUserId);
    final isOwnedByUser = trousseau.ownerId == currentUserId;
    final category = Provider.of<CategoryProvider>(context, listen: false).getById(product.category);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        // HICK YASASI: Max 2 actions (Edit + More menu)
        // FITTS YASASI: 48x48dp touch area for AppIconButton
        actions: [
          if (canEdit) ...[
            AppIconButton(
              icon: Icons.edit,
              onPressed: () => context.push(
                '/trousseau/$trousseauId/products/$productId/edit',
              ),
              tooltip: 'Düzenle',
            ),
          ],
          AppIconButton(
            icon: Icons.more_vert,
            onPressed: () => _showMoreMenu(context, canEdit),
            tooltip: 'Daha Fazla',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─────────────────────────────────────────────────────
            // BÖLÜM 1: GÖRSEL GALERI (Tıklanabilir - Tam Ekran)
            // ─────────────────────────────────────────────────────
            if (product.images.isNotEmpty)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FullscreenImageViewer(
                        imageUrls: product.images, // Original boyut tam ekranda
                        initialIndex: 0,
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  height: 300,
                  child: PageView.builder(
                    itemCount: product.images.length,
                    onPageChanged: (index) {
                      // Sayfa değiştiğinde ilk indexi güncelle
                    },
                    itemBuilder: (context, index) {
                      // 🚀 OPTIMIZATION: Memory cache boyutu hesapla (300dp height için)
                      final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
                      final cacheSize = (300 * devicePixelRatio * 2).toInt();
                      
                      return CachedNetworkImage(
                        // 🚀 OPTIMIZATION: 400x400 medium thumbnail kullan
                        // Original: 2.5 MB → Medium: ~40 KB (62x daha küçük!)
                        imageUrl: _getOptimizedImageUrl(product.images[index], '400x400'),
                        fit: BoxFit.cover,
                        // 🚀 OPTIMIZATION: Memory cache boyutunu sınırla
                        memCacheWidth: cacheSize,
                        memCacheHeight: cacheSize,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            color: category.color,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: category.color.withValues(alpha: 0.1),
                          child: Icon(
                            category.icon,
                            size: 64,
                            color: category.color,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              Container(
                height: 200,
                color: category.color.withValues(alpha: 0.1),
                child: Center(
                  child: Icon(
                    category.icon,
                    size: 64,
                    color: category.color,
                  ),
                ),
              ),

            Padding(
              padding: context.safePaddingHorizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.md.verticalSpace,

                  // Product Name and Status Badge
                  // GESTALT: İlgili öğeler yakın (başlık + badge)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: AppTypography.bold,
                            fontSize: AppTypography.size2XL,
                          ),
                        ),
                      ),
                      if (product.isPurchased)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                            borderRadius: AppRadius.radiusFull,
                            border: Border.all(color: theme.colorScheme.tertiary),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: theme.colorScheme.tertiary,
                                size: 16,
                              ),
                              AppSpacing.xs.horizontalSpace,
                              Text(
                                'Alındı',
                                style: TextStyle(
                                  color: theme.colorScheme.tertiary,
                                  fontWeight: AppTypography.bold,
                                  fontSize: AppTypography.sizeSM,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  AppSpacing.sm.verticalSpace,

                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.1),
                      borderRadius: AppRadius.radiusFull,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category.icon,
                          size: 16,
                          color: category.color,
                        ),
                        AppSpacing.xs.horizontalSpace,
                        Text(
                          category.displayName,
                          style: TextStyle(
                            color: category.color,
                            fontWeight: AppTypography.medium,
                            fontSize: AppTypography.sizeSM,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Ekleyen Bilgisi (Added By)
                  if (product.addedBy.isNotEmpty) ...[
                    AppSpacing.sm.verticalSpace,
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(product.addedBy)
                          .snapshots(),
                      builder: (context, snapshot) {
                        String displayText = 'Ekleyen: Yükleniyor...';

                        if (snapshot.hasData && snapshot.data?.exists == true) {
                          final userData = snapshot.data!.data() as Map<String, dynamic>?;
                          final email = userData?['email'] ?? product.addedBy;
                          displayText = 'Ekleyen: $email';
                        } else if (snapshot.hasError) {
                          displayText = 'Ekleyen: ${product.addedBy}';
                        }

                        return Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 14,
                              color: theme.colorScheme.outline,
                            ),
                            AppSpacing.xs.horizontalSpace,
                            Expanded(
                              child: Text(
                                displayText,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                  fontSize: AppTypography.sizeXS,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],

                  AppSpacing.lg.verticalSpace,

                  // ─────────────────────────────────────────────────────
                  // BÖLÜM 2: FİYAT BİLGİSİ
                  // Miller Yasası: 3 bilgi (Birim Fiyat, Adet, Toplam)
                  // Gestalt: İlgili bilgiler bir kartta gruplanmış
                  // ─────────────────────────────────────────────────────
                  AppCard(
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Birim Fiyat
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Birim Fiyat',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: AppTypography.sizeSM,
                                ),
                              ),
                              AppSpacing.xs.verticalSpace,
                              Text(
                                CurrencyFormatter.formatWithSymbol(product.price),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: AppTypography.bold,
                                  fontSize: AppTypography.sizeXL,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Adet
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Adet',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: AppTypography.sizeSM,
                              ),
                            ),
                            AppSpacing.xs.verticalSpace,
                            Text(
                              product.quantity.toString(),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: AppTypography.sizeXL,
                              ),
                            ),
                          ],
                        ),

                        // Toplam
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Toplam',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: AppTypography.sizeSM,
                                ),
                              ),
                              AppSpacing.xs.verticalSpace,
                              Text(
                                CurrencyFormatter.formatWithSymbol(product.totalPrice),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: AppTypography.bold,
                                  fontSize: AppTypography.sizeXL,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ─────────────────────────────────────────────────────
                  // BÖLÜM 3: AÇIKLAMA VE EK BİLGİLER
                  // ─────────────────────────────────────────────────────
                  if (product.description.isNotEmpty) ...[
                    AppSpacing.lg.verticalSpace,
                    Text(
                      'Açıklama',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: AppTypography.bold,
                        fontSize: AppTypography.sizeLG,
                      ),
                    ),
                    AppSpacing.sm.verticalSpace,
                    Text(
                      product.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: AppTypography.sizeBase,
                      ),
                    ),
                  ],

                  // Purchase Date Info (if purchased)
                  if (product.isPurchased && product.purchaseDate != null) ...[
                    AppSpacing.lg.verticalSpace,
                    AppInfoCard(
                      icon: Icons.check_circle,
                      title: 'Satın Alındı',
                      subtitle: '${product.purchaseDate!.day}/${product.purchaseDate!.month}/${product.purchaseDate!.year}',
                      color: theme.colorScheme.tertiary,
                    ),
                  ],

                  AppSpacing.xl.verticalSpace,
                ],
              ),
            ),
          ],
        ),
      ),

      // ═════════════════════════════════════════════════════════════════════
      // BOTTOM ACTION BAR
      // HICK YASASI: 1 primary action (context-dependent)
      // FITTS YASASI: 56dp button height
      // ═════════════════════════════════════════════════════════════════════
      bottomNavigationBar: () {
        final myId = trousseauProvider.myTrousseauId();
        final canClone = !isOwnedByUser && myId != null;

        if (isOwnedByUser && canEdit) {
          // Owned by user: Primary action is purchase toggle
          return Container(
            padding: context.safePaddingHorizontal,
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: AppPrimaryButton(
                  label: product.isPurchased
                      ? 'Alınmadı Olarak İşaretle'
                      : 'Alındı Olarak İşaretle',
                  icon: product.isPurchased ? Icons.remove_shopping_cart : Icons.shopping_cart,
                  isFullWidth: true,
                  backgroundColor: product.isPurchased
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.tertiary,
                  onPressed: () async {
                    await productProvider.togglePurchaseStatus(productId);
                  },
                ),
              ),
            ),
          );
        }

        if (!isOwnedByUser && canEdit && canClone) {
          // Not owned, but can edit: Show both actions
          // HICK YASASI: 2 buton ama farklı önem seviyesi (primary + secondary)
          return Container(
            padding: context.safePaddingHorizontal,
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppPrimaryButton(
                      label: product.isPurchased
                          ? 'Alınmadı Olarak İşaretle'
                          : 'Alındı Olarak İşaretle',
                      icon: product.isPurchased ? Icons.remove_shopping_cart : Icons.shopping_cart,
                      isFullWidth: true,
                      backgroundColor: product.isPurchased
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.tertiary,
                      onPressed: () async {
                        await productProvider.togglePurchaseStatus(productId);
                      },
                    ),
                    AppSpacing.sm.verticalSpace,
                    AppSecondaryButton(
                      label: 'Kendi Çeyizime Ekle',
                      icon: Icons.content_copy,
                      isFullWidth: true,
                      onPressed: () async {
                        final targetId = await _selectTargetTrousseau(context, trousseauProvider);
                        if (targetId == null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('İşlem iptal edildi'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.radiusMD,
                                ),
                              ),
                            );
                          }
                          return;
                        }

                        final ok = await productProvider.cloneProductToTrousseau(
                          targetTrousseauId: targetId,
                          source: product,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ok
                                  ? 'Ürün çeyizinize eklendi'
                                  : 'Ürün eklenemedi: ${productProvider.errorMessage}'),
                              backgroundColor: ok
                                  ? theme.colorScheme.tertiary
                                  : theme.colorScheme.error,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.radiusMD,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (canClone) {
          // Not owned and cannot edit: Only cloning available
          return Container(
            padding: context.safePaddingHorizontal,
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: AppPrimaryButton(
                  label: 'Kendi Çeyizime Ekle',
                  icon: Icons.content_copy,
                  isFullWidth: true,
                  onPressed: () async {
                    final targetId = await _selectTargetTrousseau(context, trousseauProvider);
                    if (targetId == null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('İşlem iptal edildi'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.radiusMD,
                            ),
                          ),
                        );
                      }
                      return;
                    }

                    final ok = await productProvider.cloneProductToTrousseau(
                      targetTrousseauId: targetId,
                      source: product,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok
                              ? 'Ürün çeyizinize eklendi'
                              : 'Ürün eklenemedi: ${productProvider.errorMessage}'),
                          backgroundColor: ok
                              ? theme.colorScheme.tertiary
                              : theme.colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.radiusMD,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          );
        }

        return null;
      }(),
    );
  }
}
