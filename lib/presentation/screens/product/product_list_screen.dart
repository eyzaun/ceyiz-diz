/// Product List Screen - Yeni Tasarım Sistemi v2.0
///
/// TASARIM KURALLARI:
/// ✅ Jakob Yasası: Standart list + filter layout
/// ✅ Fitts Yasası: FAB 56dp, filter chips 48dp height, product cards 48dp touch
/// ✅ Hick Yasası: Max 3 filter pills (Tümü, Alınanlar, Alınmayanlar)
/// ✅ Miller Yasası: Filter chips max 5 visible at once
/// ✅ Gestalt: İlgili filter'lar gruplanmış (status + category ayrı rows)

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_tokens.dart';
import '../../providers/product_provider.dart';
import '../../providers/trousseau_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/filter_pill.dart';
import '../../widgets/common/icon_color_picker.dart';
import '../../../data/models/product_model.dart';

class ProductListScreen extends StatefulWidget {
  final String trousseauId;

  const ProductListScreen({
    super.key,
    required this.trousseauId,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _listController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final productProv = Provider.of<ProductProvider>(context, listen: false);
      productProv.loadProducts(widget.trousseauId);

      final catProv = Provider.of<CategoryProvider>(context, listen: false);
      final trProv = Provider.of<TrousseauProvider>(context, listen: false);
      catProv.bind(widget.trousseauId, userId: trProv.currentUserId ?? '');
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchFocusNode.dispose();
    _searchController.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<bool> _promptAddCategory(BuildContext context, CategoryProvider provider) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    IconData selIcon = Icons.category;
    Color selColor = const Color(0xFF607D8B);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          title: const Text('Yeni Kategori'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'Kategori adı'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ad gerekli';
                    if (provider.allCategories.any((c) =>
                        c.displayName.toLowerCase() == v.trim().toLowerCase())) {
                      return 'Bu ad kullanılıyor';
                    }
                    return null;
                  },
                ),
                AppSpacing.sm.verticalSpace,
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: selColor.withValues(alpha: 0.15),
                      child: Icon(selIcon, color: selColor),
                    ),
                    AppSpacing.sm.horizontalSpace,
                    Expanded(
                      child: AppSecondaryButton(
                        label: 'Sembol ve Renk Seç',
                        icon: Icons.palette_outlined,
                        onPressed: () async {
                          final res = await IconColorPicker.pick(
                              context, icon: selIcon, color: selColor);
                          if (res != null) {
                            setLocalState(() {
                              selIcon = res.icon;
                              selColor = res.color;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            AppTextButton(
              label: 'Vazgeç',
              onPressed: () => Navigator.pop(ctx, false),
            ),
            AppPrimaryButton(
              label: 'Ekle',
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final name = controller.text.trim();
                String id = name
                    .toLowerCase()
                    .replaceAll(RegExp(r'[^a-z0-9ğüşöçı\s-]', caseSensitive: false), '')
                    .replaceAll(RegExp(r'\s+'), '-');
                if (id.isEmpty) id = 'kategori';
                var base = id;
                int i = 1;
                while (provider.allCategories.any((c) =>
                    c.displayName.toLowerCase() == id.toLowerCase())) {
                  id = '$base-$i';
                  i++;
                }
                final ok = await provider.addCustom(id, name, icon: selIcon, color: selColor);
                if (!ctx.mounted) return;
                Navigator.pop(ctx, ok);
              },
            ),
          ],
        ),
      ),
    );
    return result ?? false;
  }

  void _showFilterDialog(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final trousseauProvider = Provider.of<TrousseauProvider>(context, listen: false);
    final trousseau = trousseauProvider.getTrousseauById(widget.trousseauId);
    final canEdit = trousseau != null &&
        trousseau.canEdit(trousseauProvider.currentUserId ?? '');

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: AppRadius.radiusXL),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          borderRadius: AppRadius.radiusSM,
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Kategoriler',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: AppTypography.bold,
                            ),
                          ),
                        ),
                        if (canEdit)
                          AppIconButton(
                            icon: Icons.add,
                            onPressed: () async {
                              final result = await _promptAddCategory(context, categoryProvider);
                              if (result) setState(() {});
                            },
                            tooltip: 'Kategori Ekle',
                          ),
                      ],
                    ),

                    AppSpacing.md.verticalSpace,

                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: categoryProvider.allCategories.map((category) {
                        final isSelected = productProvider.selectedCategories
                            .contains(category.id);
                        return FilterPill(
                          label: category.displayName,
                          selected: isSelected,
                          onTap: () {
                            setState(() {
                              productProvider.toggleCategory(category.id);
                            });
                          },
                          color: category.color,
                          leadingIcon: category.icon,
                        );
                      }).toList(),
                    ),

                    AppSpacing.lg.verticalSpace,

                    Row(
                      children: [
                        Expanded(
                          child: AppSecondaryButton(
                            label: 'Temizle',
                            onPressed: () {
                              productProvider.clearCategoryFilter();
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        AppSpacing.md.horizontalSpace,
                        Expanded(
                          child: AppPrimaryButton(
                            label: 'Uygula',
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final trousseauProvider = Provider.of<TrousseauProvider>(context);
    final trousseau = trousseauProvider.getTrousseauById(widget.trousseauId);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    if (trousseau == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Çeyiz bulunamadı'),
        ),
      );
    }

    final canEdit = trousseau.canEdit(trousseauProvider.currentUserId ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürünler'),
        // HICK YASASI: Max 2 actions
        // FITTS YASASI: 48x48dp touch area
        actions: [
          if (canEdit)
            AppIconButton(
              icon: Icons.settings_outlined,
              onPressed: () => context.push(
                  '/trousseau/${widget.trousseauId}/products/categories'),
              tooltip: 'Kategorileri Yönet',
            ),
          AppIconButton(
            icon: Icons.filter_list,
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filtrele',
          ),
        ],
      ),
      body: Column(
        children: [
          // ─────────────────────────────────────────────────────
          // SEARCH BAR
          // FITTS YASASI: 56dp height search input
          // ─────────────────────────────────────────────────────
          Container(
            padding: context.safePaddingHorizontal.horizontalSpace,
            color: theme.cardColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: AppSearchInput(
                controller: _searchController,
                hint: 'Ürün ara...',
                onChanged: (v) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 300), () {
                    if (!mounted) return;
                    productProvider.setSearchQuery(v);
                  });
                },
                onClear: () {
                  productProvider.setSearchQuery('');
                },
              ),
            ),
          ),

          // ─────────────────────────────────────────────────────
          // FILTER PILLS ROW 1: STATUS
          // HICK YASASI: Max 3 options (Tümü, Alınanlar, Alınmayanlar)
          // FITTS YASASI: 48dp height chips
          // ─────────────────────────────────────────────────────
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterPill(
                  label: 'Tümü',
                  selected: productProvider.currentFilter == ProductFilter.all,
                  onTap: () => productProvider.setFilter(ProductFilter.all),
                  count: productProvider.products.length,
                ),
                AppSpacing.sm.horizontalSpace,
                FilterPill(
                  label: 'Alınanlar',
                  selected: productProvider.currentFilter == ProductFilter.purchased,
                  onTap: () => productProvider.setFilter(ProductFilter.purchased),
                  count: productProvider.getPurchasedCount(),
                  color: theme.colorScheme.tertiary,
                ),
                AppSpacing.sm.horizontalSpace,
                FilterPill(
                  label: 'Alınmayanlar',
                  selected: productProvider.currentFilter == ProductFilter.notPurchased,
                  onTap: () => productProvider.setFilter(ProductFilter.notPurchased),
                  count: productProvider.getNotPurchasedCount(),
                  color: theme.colorScheme.secondary,
                ),
              ],
            ),
          ),

          // ─────────────────────────────────────────────────────
          // FILTER PILLS ROW 2: CATEGORIES
          // MILLER YASASI: Scrollable, max 5 visible
          // GESTALT: Ayrı row'da category filter'ları
          // ─────────────────────────────────────────────────────
          if (categoryProvider.allCategories.isNotEmpty)
            Container(
              height: 48,
              padding: EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.sm,
              ),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categoryProvider.allCategories.length,
                separatorBuilder: (_, __) => AppSpacing.sm.horizontalSpace,
                itemBuilder: (context, index) {
                  final category = categoryProvider.allCategories[index];
                  final isSelected = productProvider.selectedCategories
                      .contains(category.id);
                  final count = productProvider.products
                      .where((p) => p.category == category.id)
                      .length;
                  return FilterPill(
                    label: category.displayName,
                    selected: isSelected,
                    onTap: () => productProvider.toggleCategory(category.id),
                    count: count > 0 ? count : null,
                    color: category.color,
                    leadingIcon: category.icon,
                    neutralWhenUnselected: true,
                    dense: true,
                  );
                },
              ),
            ),

          // ─────────────────────────────────────────────────────
          // PRODUCTS LIST
          // ─────────────────────────────────────────────────────
          Expanded(
            child: productProvider.products.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: EmptyStateWidget(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Henüz ürün eklenmemiş',
                      subtitle: 'İlk ürününüzü ekleyerek başlayın',
                      action: canEdit
                          ? AppPrimaryButton(
                              label: 'Ürün Ekle',
                              icon: Icons.add,
                              onPressed: () => context.push(
                                '/trousseau/${widget.trousseauId}/products/add',
                              ),
                            )
                          : null,
                    ),
                  )
                : Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: () =>
                            productProvider.loadProducts(widget.trousseauId),
                        child: ListView.builder(
                          controller: _listController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.all(AppSpacing.md),
                          itemCount: productProvider.filteredProducts.isEmpty
                              ? 1
                              : productProvider.filteredProducts.length,
                          itemBuilder: (context, index) {
                            if (productProvider.filteredProducts.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: AppSpacing.xl2),
                                  child: EmptyStateWidget(
                                    icon: Icons.search_off,
                                    title: 'Ürün bulunamadı',
                                    subtitle: 'Farklı filtreler deneyebilirsiniz',
                                  ),
                                ),
                              );
                            }

                            final product = productProvider.filteredProducts[index];
                            final category = categoryProvider.getById(product.category);

                            // Use AppProductCard from design system
                            return Padding(
                              padding: EdgeInsets.only(bottom: AppSpacing.sm),
                              child: AppProductCard(
                                product: product,
                                category: category,
                                canEdit: canEdit,
                                onTap: () => context.push(
                                  '/trousseau/${widget.trousseauId}/products/${product.id}',
                                ),
                                onTogglePurchase: canEdit
                                    ? () async {
                                        await productProvider
                                            .togglePurchaseStatus(product.id);
                                      }
                                    : null,
                                onEdit: canEdit
                                    ? () => context.push(
                                          '/trousseau/${widget.trousseauId}/products/${product.id}/edit',
                                        )
                                    : null,
                                onDelete: canEdit
                                    ? () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Ürünü Sil'),
                                            content: Text(
                                              '${product.name} ürününü silmek istediğinizden emin misiniz?',
                                            ),
                                            actions: [
                                              AppTextButton(
                                                label: 'İptal',
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                              ),
                                              AppDangerButton(
                                                label: 'Sil',
                                                icon: Icons.delete,
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmed == true) {
                                          await productProvider
                                              .deleteProduct(product.id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content:
                                                    Text('${product.name} silindi'),
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: AppRadius.radiusMD,
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                      if (productProvider.isLoading)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: LinearProgressIndicator(
                            minHeight: 2,
                            color: theme.colorScheme.primary,
                            backgroundColor:
                                theme.colorScheme.primary.withValues(alpha: 0.1),
                          ),
                        ),
                    ],
                  ),
          ),

          // ─────────────────────────────────────────────────────
          // SUMMARY BAR
          // MILLER YASASI: 3 metrics (Toplam, Harcanan, Kalan)
          // GESTALT: İlgili metrikler gruplanmış
          // ─────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    context,
                    'Toplam',
                    '₺${productProvider.getTotalPlanned().toStringAsFixed(0)}',
                    theme.colorScheme.primary,
                  ),
                  _buildSummaryItem(
                    context,
                    'Harcanan',
                    '₺${productProvider.getTotalSpent().toStringAsFixed(0)}',
                    theme.colorScheme.tertiary,
                  ),
                  _buildSummaryItem(
                    context,
                    'Kalan',
                    '₺${(productProvider.getTotalPlanned() - productProvider.getTotalSpent()).toStringAsFixed(0)}',
                    theme.colorScheme.secondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // FITTS YASASI: 56dp FAB
      floatingActionButton: canEdit
          ? AppFAB(
              label: 'Ürün Ekle',
              icon: Icons.add,
              onPressed: () => context.push(
                '/trousseau/${widget.trousseauId}/products/add',
              ),
            )
          : null,
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
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: AppTypography.sizeSM,
          ),
        ),
        AppSpacing.xs.verticalSpace,
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: AppTypography.bold,
            fontSize: AppTypography.sizeLG,
          ),
        ),
      ],
    );
  }
}
