library;

/// Trousseau Detail Screen - Yeni Tasarım Sistemi v2.0
///
/// TASARIM KURALLARI:
/// ✅ Jakob Yasası: Standart list + tab selector layout
/// ✅ Fitts Yasası: FAB 56dp, filter chips 48dp, product cards 48dp touch
/// ✅ Hick Yasası: Max 3 AppBar actions, max 3 filter pills
/// ✅ Miller Yasası: Trousseau selector shows max 5 at once, scrollable
/// ✅ Gestalt: İlgili öğeler gruplanmış (selector, filters, products)

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/services/excel_export_service_v3.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trousseau_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/filter_pill.dart';
import '../../widgets/dialogs/sort_bottom_sheet.dart';
import '../../../data/models/trousseau_model.dart';

class TrousseauDetailScreen extends StatefulWidget {
  final String trousseauId;
  final bool hideSelector;

  const TrousseauDetailScreen({
    super.key,
    required this.trousseauId,
    this.hideSelector = false,
  });

  @override
  State<TrousseauDetailScreen> createState() => _TrousseauDetailScreenState();
}

class _TrousseauDetailScreenState extends State<TrousseauDetailScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  String _currentTrousseauId = '';

  @override
  void initState() {
    super.initState();
    _currentTrousseauId = widget.trousseauId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final trProv = Provider.of<TrousseauProvider>(context, listen: false);
      // Update selected trousseau ID so statistics screen shows the same trousseau
      trProv.setSelectedTrousseauId(_currentTrousseauId);
      Provider.of<ProductProvider>(context, listen: false)
          .loadProducts(_currentTrousseauId);
      Provider.of<CategoryProvider>(context, listen: false)
          .bind(_currentTrousseauId, userId: trProv.currentUserId ?? '');
    });
  }

  @override
  void didUpdateWidget(TrousseauDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trousseauId != oldWidget.trousseauId &&
        widget.trousseauId != _currentTrousseauId) {
      setState(() {
        _currentTrousseauId = widget.trousseauId;
      });
      // Update selected trousseau ID when switching between trousseaus
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final trProv = Provider.of<TrousseauProvider>(context, listen: false);
        trProv.setSelectedTrousseauId(_currentTrousseauId);
      });
      // Ürünler ve kategoriler stream ile güncellendiği için burada tekrar yüklemeye gerek yok.
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchFocusNode.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _exportToExcel(BuildContext context, TrousseauModel trousseau) async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context);

    // Loading göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Kullanıcı email map'i oluştur (userId -> email)
      final userIds = productProvider.products
          .map((p) => p.addedBy)
          .where((id) => id.isNotEmpty)
          .toSet();

      final Map<String, String> userEmailMap = {};
      for (final userId in userIds) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
          if (userDoc.exists) {
            userEmailMap[userId] = userDoc.data()?['email'] ?? userId;
          }
        } catch (e) {
          userEmailMap[userId] = userId; // Fallback to userId
        }
      }

      await ExcelExportServiceV3.exportAndShareTrousseau(
        trousseau: trousseau,
        products: productProvider.products,
        categories: categoryProvider.allCategories,
        userEmailMap: userEmailMap,
      );

      if (context.mounted) {
        Navigator.of(context).pop(); // Loading'i kapat

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.excelExportSuccess ?? 'Excel dosyası başarıyla oluşturuldu'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.radiusMD,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Loading'i kapat

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.errorWithMessage(e.toString()) ?? 'Hata: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
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
    final trousseauProvider = Provider.of<TrousseauProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context);

  // Kaç Saat ayarını kontrol et
  final kacSaatSettings = authProvider.currentUser?.kacSaatSettings;
  final showKacSaat = kacSaatSettings?.enabled ?? false;

    return StreamBuilder<TrousseauModel?>(
      // key: ValueKey(_currentTrousseauId), // Kaldırıldı, gereksiz tam rebuild engellendi
      stream: trousseauProvider.getSingleTrousseauStream(_currentTrousseauId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final trousseau = snapshot.data;
        if (trousseau == null) {
          final l10n = AppLocalizations.of(context);
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n?.trousseauNotFound ?? 'Çeyiz bulunamadı')),
          );
        }

        final canEdit = trousseau.canEdit(trousseauProvider.currentUserId ?? '');
        final isOwner = trousseau.ownerId == trousseauProvider.currentUserId;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(trousseau.name),
            // HICK YASASI: Max 3 actions
            // FITTS YASASI: 48x48dp touch area
            actions: [
              if (canEdit)
                AppIconButton(
                  icon: Icons.category_outlined,
                  onPressed: () => context.push(
                      '/trousseau/$_currentTrousseauId/products/categories'),
                  tooltip: l10n?.manageCategories ?? 'Kategorileri Yönet',
                ),
              if (canEdit)
                AppIconButton(
                  icon: Icons.reorder,
                  onPressed: () =>
                      context.push('/trousseau/$_currentTrousseauId/manage'),
                  tooltip: l10n?.manageTrousseaus ?? 'Çeyizleri Yönet',
                ),
              if (isOwner)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.share,
                    size: AppDimensions.iconSizeMedium,
                  ),
                  tooltip: l10n?.share ?? 'Paylaş',
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusMD,
                  ),
                  onSelected: (value) async {
                    if (value == 'share_trousseau') {
                      context.push('/trousseau/$_currentTrousseauId/share');
                    } else if (value == 'export_excel') {
                      await _exportToExcel(context, trousseau);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'share_trousseau',
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_add,
                            size: 20,
                            color: theme.colorScheme.onSurface,
                          ),
                          AppSpacing.sm.horizontalSpace,
                          Text(l10n?.shareTrousseau ?? 'Çeyiz Paylaş'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'export_excel',
                      child: Row(
                        children: [
                          Icon(
                            Icons.table_chart,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          AppSpacing.sm.horizontalSpace,
                          Text(l10n?.shareAsExcel ?? 'Excel Olarak Paylaş'),
                        ],
                      ),
                    ),
                  ],
                ),
              if (!isOwner)
                AppIconButton(
                  icon: Icons.person_remove_outlined,
                  tooltip: l10n?.leaveSharing ?? 'Paylaşımdan Çık',
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10n?.leaveSharing ?? 'Paylaşımdan Çık'),
                        content: Text(l10n?.leaveShareConfirm ?? 'Bu çeyizden çıkmak istediğinize emin misiniz? Erişiminiz kaldırılacaktır.'),
                        actions: [
                          AppTextButton(label: l10n?.cancel ?? 'İptal', onPressed: () => Navigator.pop(ctx, false)),
                          AppDangerButton(label: l10n?.exit ?? 'Çık', icon: Icons.exit_to_app, onPressed: () => Navigator.pop(ctx, true)),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      final ok = await trousseauProvider.leaveSharedTrousseau(trousseauId: trousseau.id);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(ok ? (l10n?.leftSharing ?? 'Paylaşımdan çıkıldı') : trousseauProvider.errorMessage)),
                      );
                      if (ok) {
                        // Navigate away to avoid showing removed trousseau
                        if (context.mounted) context.pop();
                      }
                    }
                  },
                ),
            ],
          ),
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () => productProvider.loadProducts(_currentTrousseauId),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // ─────────────────────────────────────────────────────
                    // TROUSSEAU SELECTOR
                    // MILLER YASASI: Max 5 visible, scrollable
                    // GESTALT: Tab-like selector for multiple trousseaus
                    // Hidden in shared trousseau detail screen
                    // ─────────────────────────────────────────────────────
                    if (!widget.hideSelector)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: _buildTrousseauSelector(context, trousseauProvider),
                        ),
                      ),

                    // ─────────────────────────────────────────────────────
                    // SEARCH BAR + SORT BUTTON
                    // FITTS YASASI: 56dp height
                    // ─────────────────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Consumer<ProductProvider>(
                        builder: (context, productProvider, _) {
                          return Container(
                            padding: context.safePaddingHorizontal,
                            color: theme.cardColor,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: AppSearchInput(
                                      controller: _searchController,
                                      hint: l10n?.searchProduct ?? 'Ürün ara...',
                                      onChanged: (v) {
                                        _debounce?.cancel();
                                        _debounce = Timer(
                                            const Duration(milliseconds: 300), () {
                                          if (!mounted) return;
                                          productProvider.setSearchQuery(v);
                                        });
                                      },
                                      onClear: () {
                                        productProvider.setSearchQuery('');
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  // Sort Button
                                  Material(
                                    color: productProvider.currentSort != null
                                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                        : theme.colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                    child: InkWell(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) => SortBottomSheet(
                                            currentSort: productProvider.currentSort,
                                            onSortSelected: (sortOption) {
                                              productProvider.setSort(sortOption);
                                            },
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.sort,
                                          color: productProvider.currentSort != null
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.onSurface,
                                          size: AppDimensions.iconSizeMedium,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // ─────────────────────────────────────────────────────
                    // FILTER PILLS ROW 1: STATUS
                    // HICK YASASI: Max 3 options
                    // ─────────────────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Consumer<ProductProvider>(
                        builder: (context, productProvider, _) {
                          return Container(
                            height: 44,
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                FilterPill(
                                  label: l10n?.all ?? 'Tümü',
                                  selected: productProvider.currentFilter ==
                                      ProductFilter.all,
                                  onTap: () =>
                                      productProvider.setFilter(ProductFilter.all),
                                  count: productProvider.products.length,
                                ),
                                AppSpacing.sm.horizontalSpace,
                                FilterPill(
                                  label: l10n?.purchased ?? 'Alınanlar',
                                  selected: productProvider.currentFilter ==
                                      ProductFilter.purchased,
                                  onTap: () => productProvider
                                      .setFilter(ProductFilter.purchased),
                                  count: productProvider.getPurchasedCount(),
                                  color: theme.colorScheme.tertiary,
                                ),
                                AppSpacing.sm.horizontalSpace,
                                FilterPill(
                                  label: l10n?.notPurchased ?? 'Alınmayanlar',
                                  selected: productProvider.currentFilter ==
                                      ProductFilter.notPurchased,
                                  onTap: () => productProvider
                                      .setFilter(ProductFilter.notPurchased),
                                  count: productProvider.getNotPurchasedCount(),
                                  color: theme.colorScheme.secondary,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // ─────────────────────────────────────────────────────
                    // FILTER PILLS ROW 2: CATEGORIES
                    // MILLER YASASI: Scrollable, max 5 visible
                    // ─────────────────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Consumer<CategoryProvider>(
                        builder: (context, categoryProvider, _) {
                          if (categoryProvider.allCategories.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Consumer<ProductProvider>(
                            builder: (context, productProvider, _) {
                              return Container(
                                height: 40,
                                padding: EdgeInsets.only(
                                  left: AppSpacing.md,
                                  right: AppSpacing.md,
                                  bottom: AppSpacing.xs,
                                ),
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: categoryProvider.allCategories.length,
                                  separatorBuilder: (_, __) =>
                                      AppSpacing.sm.horizontalSpace,
                                  itemBuilder: (context, index) {
                                    final category =
                                        categoryProvider.allCategories[index];
                                    final isSelected = productProvider
                                        .selectedCategories
                                        .contains(category.id);
                                    final count = productProvider.products
                                        .where((p) => p.category == category.id)
                                        .length;
                                    return FilterPill(
                                      label: category.displayName,
                                      selected: isSelected,
                                      onTap: () => productProvider
                                          .toggleCategory(category.id),
                                      count: count > 0 ? count : null,
                                      color: category.color,
                                      leadingIcon: category.icon,
                                      neutralWhenUnselected: true,
                                      dense: true,
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // ─────────────────────────────────────────────────────
                    // PRODUCTS LIST
                    // ─────────────────────────────────────────────────────
                    Consumer<ProductProvider>(
                      builder: (context, productProvider, _) {
                        final categoryProvider =
                            Provider.of<CategoryProvider>(context, listen: false);

                        if (productProvider.products.isEmpty) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.lg),
                              child: EmptyStateWidget(
                                icon: Icons.shopping_bag_outlined,
                                title: l10n?.noProductsYet ?? 'Henüz ürün eklenmemiş',
                                subtitle: l10n?.addFirstProduct ?? 'İlk ürününüzü ekleyerek başlayın',
                                action: canEdit
                                    ? AppPrimaryButton(
                                        label: l10n?.addProduct ?? 'Ürün Ekle',
                                        icon: Icons.add,
                                        onPressed: () => context.push(
                                            '/trousseau/$_currentTrousseauId/products/add'),
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }

                        // Show loading state while products are being fetched
                        if (productProvider.isLoading && productProvider.filteredProducts.isEmpty) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  AppSpacing.md.verticalSpace,
                                  Text(
                                    'Ürünler yükleniyor...',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Show empty state only if NOT loading AND list is empty
                        if (productProvider.filteredProducts.isEmpty) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.lg),
                              child: EmptyStateWidget(
                                icon: Icons.search_off,
                                title: l10n?.noProductsFound ?? 'Ürün bulunamadı',
                                subtitle: l10n?.tryDifferentFilters ?? 'Farklı filtreler deneyebilirsiniz',
                              ),
                            ),
                          );
                        }

                        return SliverPadding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final product =
                                    productProvider.filteredProducts[index];
                                final category =
                                    categoryProvider.getById(product.category);

                                return Padding(
                                  padding: EdgeInsets.only(bottom: 1),
                                  child: canEdit
                                      ? Dismissible(
                                          key: Key(product.id),
                                          background: Container(
                                            margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary,
                                              borderRadius: AppRadius.radiusLG,
                                            ),
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.only(left: AppSpacing.lg),
                                            child: Icon(
                                              Icons.edit,
                                              color: theme.colorScheme.onPrimary,
                                              size: AppDimensions.iconSizeLarge,
                                            ),
                                          ),
                                          secondaryBackground: Container(
                                            margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.error,
                                              borderRadius: AppRadius.radiusLG,
                                            ),
                                            alignment: Alignment.centerRight,
                                            padding: const EdgeInsets.only(right: AppSpacing.lg),
                                            child: Icon(
                                              Icons.delete,
                                              color: theme.colorScheme.onError,
                                              size: AppDimensions.iconSizeLarge,
                                            ),
                                          ),
                                          confirmDismiss: (direction) async {
                                            if (direction == DismissDirection.startToEnd) {
                                              // Sağa kaydır -> Edit
                                              context.push(
                                                '/trousseau/$_currentTrousseauId/products/${product.id}/edit',
                                              );
                                              return false;
                                            } else {
                                              // Sola kaydır -> Delete
                                              final confirmed = await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: Text(l10n?.deleteProduct ?? 'Ürünü Sil'),
                                                  content: Text(
                                                    l10n?.deleteProductConfirm(product.name) ?? '${product.name} ürününü silmek istediğinizden emin misiniz?',
                                                  ),
                                                  actions: [
                                                    AppTextButton(
                                                      label: l10n?.cancel ?? 'İptal',
                                                      onPressed: () => Navigator.pop(ctx, false),
                                                    ),
                                                    AppDangerButton(
                                                      label: l10n?.delete ?? 'Sil',
                                                      icon: Icons.delete,
                                                      onPressed: () => Navigator.pop(ctx, true),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              return confirmed ?? false;
                                            }
                                          },
                                          onDismissed: (direction) async {
                                            if (direction == DismissDirection.endToStart) {
                                              await productProvider.deleteProduct(product.id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(l10n?.productDeleted(product.name) ?? '${product.name} silindi'),
                                                    behavior: SnackBarBehavior.floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: AppRadius.radiusMD,
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          child: AppProductCard(
                                            product: product,
                                            category: category,
                                            canEdit: canEdit,
                                            showKacSaat: showKacSaat,
                                            kacSaatSettings: kacSaatSettings,
                                            onTap: () => context.push(
                                              '/trousseau/$_currentTrousseauId/products/${product.id}',
                                            ),
                                            onTogglePurchase: () async {
                                              await productProvider.togglePurchaseStatus(product.id);
                                            },
                                          ),
                                        )
                                      : AppProductCard(
                                          product: product,
                                          category: category,
                                          canEdit: false,
                                          showKacSaat: showKacSaat,
                                          kacSaatSettings: kacSaatSettings,
                                          onTap: () => context.push(
                                            '/trousseau/$_currentTrousseauId/products/${product.id}',
                                          ),
                                        ),
                                );
                              },
                              childCount: productProvider.filteredProducts.length,
                            ),
                          ),
                        );
                      },
                    ),

                    // ─────────────────────────────────────────────────────
                    // SUMMARY BAR
                    // MILLER YASASI: 3 metrics
                    // ─────────────────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Consumer<ProductProvider>(
                        builder: (context, productProvider, _) {
                          return Container(
                            padding: EdgeInsets.fromLTRB(
                              AppSpacing.md,
                              AppSpacing.xs,
                              AppSpacing.md,
                              AppSpacing.xs,
                            ),
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  _buildSummaryItem(
                                    context,
                                    l10n?.total ?? 'Toplam',
                                    CurrencyFormatter.formatWithSymbol(
                                      productProvider.getTotalPlanned(),
                                    ),
                                    theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: AppSpacing.lg),
                                  _buildSummaryItem(
                                    context,
                                    l10n?.spent ?? 'Harcanan',
                                    CurrencyFormatter.formatWithSymbol(
                                      productProvider.getTotalSpent(),
                                    ),
                                    theme.colorScheme.tertiary,
                                  ),
                                  const SizedBox(width: AppSpacing.lg),
                                  _buildSummaryItem(
                                    context,
                                    l10n?.remaining ?? 'Kalan',
                                    CurrencyFormatter.formatWithSymbol(
                                      productProvider.getTotalPlanned() - productProvider.getTotalSpent(),
                                    ),
                                    theme.colorScheme.secondary,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Loading indicator overlay
              Consumer<ProductProvider>(
                builder: (context, productProvider, _) {
                  if (!productProvider.isLoading) return const SizedBox.shrink();
                  return Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      color: theme.colorScheme.primary,
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  );
                },
              ),
            ],
          ),

          // FITTS YASASI: 56dp FAB
          floatingActionButton: canEdit
              ? AppFAB(
                  label: l10n?.addProduct ?? 'Ürün Ekle',
                  icon: Icons.add,
                  onPressed: () => context.push(
                      '/trousseau/$_currentTrousseauId/products/add'),
                )
              : null,
        );
      },
    );
  }

  Widget _buildTrousseauSelector(
      BuildContext context, TrousseauProvider trousseauProvider) {
    final theme = Theme.of(context);
    // YENİ: Kullanıcı sıralamasına göre sıralanmış çeyizleri al
    final sortedTrousseaus = trousseauProvider.getSortedTrousseaus();
    // Pinned çeyizleri sıralanmış listeden filtrele
    final myTrousseaus = sortedTrousseaus.where((t) => 
      trousseauProvider.pinnedTrousseaus.any((pinned) => pinned.id == t.id)
    ).toList();

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: AppRadius.radiusMD,
      ),
      padding: EdgeInsets.all(AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: myTrousseaus.length,
              separatorBuilder: (_, __) => AppSpacing.xs.horizontalSpace,
              itemBuilder: (context, index) {
                final trousseau = myTrousseaus[index];
                final isSelected = trousseau.id == _currentTrousseauId;

                return Material(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: AppRadius.radiusSM,
                  child: InkWell(
                    onTap: () {
                      if (trousseau.id != _currentTrousseauId) {
                        setState(() {
                          _currentTrousseauId = trousseau.id;
                        });

                        // Update selected trousseau ID for cross-tab synchronization
                        trousseauProvider.setSelectedTrousseauId(trousseau.id);

                        // Yeni çeyiz seçildi, ürünleri yükle
                        final productProv = Provider.of<ProductProvider>(context, listen: false);
                        productProv.loadProducts(trousseau.id);

                        // Kategorileri de güncelle
                        final catProv = Provider.of<CategoryProvider>(context, listen: false);
                        catProv.bind(trousseau.id, userId: trousseauProvider.currentUserId ?? '');
                      }
                    },
                    borderRadius: AppRadius.radiusSM,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (trousseau.ownerId !=
                              trousseauProvider.currentUserId) ...[
                            Icon(
                              Icons.people_outline,
                              size: 16,
                              color: isSelected
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                            ),
                            AppSpacing.xs.horizontalSpace,
                          ],
                          Text(
                            trousseau.name,
                            style: TextStyle(
                              fontSize: AppTypography.sizeSM,
                              fontWeight: isSelected
                                  ? AppTypography.semiBold
                                  : AppTypography.regular,
                              color: isSelected
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          AppSpacing.xs.horizontalSpace,
          Material(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: AppRadius.radiusSM,
            child: InkWell(
              onTap: () => context.push('/create-trousseau'),
              borderRadius: AppRadius.radiusSM,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Icon(
                  Icons.add,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: AppTypography.sizeXS,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: AppTypography.bold,
            fontSize: AppTypography.sizeBase,
          ),
        ),
      ],
    );
  }
}
