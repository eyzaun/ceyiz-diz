// Trousseau Detail Screen - Yeni Tasarım Sistemi v2.0
//
// TASARIM KURALLARI:
// ✅ Jakob Yasası: Standart list + tab selector layout
// ✅ Fitts Yasası: FAB 56dp, filter chips 48dp, product cards 48dp touch
// ✅ Hick Yasası: Max 3 AppBar actions, max 3 filter pills
// ✅ Miller Yasası: Trousseau selector shows max 5 at once, scrollable
// ✅ Gestalt: İlgili öğeler gruplanmış (selector, filters, products)

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_tokens.dart';
import '../../providers/trousseau_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/filter_pill.dart';
import '../../../data/models/trousseau_model.dart';

class TrousseauDetailScreen extends StatefulWidget {
  final String trousseauId;

  const TrousseauDetailScreen({
    super.key,
    required this.trousseauId,
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
      Provider.of<ProductProvider>(context, listen: false)
          .loadProducts(_currentTrousseauId);
      final trProv = Provider.of<TrousseauProvider>(context, listen: false);
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
      Provider.of<ProductProvider>(context, listen: false)
          .loadProducts(_currentTrousseauId);
      final trProv = Provider.of<TrousseauProvider>(context, listen: false);
      Provider.of<CategoryProvider>(context, listen: false)
          .bind(_currentTrousseauId, userId: trProv.currentUserId ?? '');
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trousseauProvider = Provider.of<TrousseauProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    return StreamBuilder<TrousseauModel?>(
      key: ValueKey(_currentTrousseauId),
      stream: trousseauProvider.getSingleTrousseauStream(_currentTrousseauId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final trousseau = snapshot.data;
        if (trousseau == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Çeyiz bulunamadı')),
          );
        }

        final canEdit = trousseau.canEdit(trousseauProvider.currentUserId ?? '');
        final isOwner = trousseau.ownerId == trousseauProvider.currentUserId;

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
                  tooltip: 'Kategorileri Yönet',
                ),
              if (canEdit)
                AppIconButton(
                  icon: Icons.edit,
                  onPressed: () =>
                      context.push('/trousseau/$_currentTrousseauId/edit'),
                  tooltip: 'Düzenle',
                ),
              if (isOwner)
                AppIconButton(
                  icon: Icons.share,
                  onPressed: () =>
                      context.push('/trousseau/$_currentTrousseauId/share'),
                  tooltip: 'Paylaş',
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
                    // ─────────────────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: _buildTrousseauSelector(context, trousseauProvider),
                      ),
                    ),

                    // ─────────────────────────────────────────────────────
                    // SEARCH BAR
                    // FITTS YASASI: 56dp height
                    // ─────────────────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: context.safePaddingHorizontal),
                        color: theme.cardColor,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                          child: AppSearchInput(
                            controller: _searchController,
                            hint: 'Ürün ara...',
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
                                  selected: productProvider.currentFilter ==
                                      ProductFilter.all,
                                  onTap: () =>
                                      productProvider.setFilter(ProductFilter.all),
                                  count: productProvider.products.length,
                                ),
                                AppSpacing.sm.horizontalSpace,
                                FilterPill(
                                  label: 'Alınanlar',
                                  selected: productProvider.currentFilter ==
                                      ProductFilter.purchased,
                                  onTap: () => productProvider
                                      .setFilter(ProductFilter.purchased),
                                  count: productProvider.getPurchasedCount(),
                                  color: theme.colorScheme.tertiary,
                                ),
                                AppSpacing.sm.horizontalSpace,
                                FilterPill(
                                  label: 'Alınmayanlar',
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
                                height: 48,
                                padding: EdgeInsets.only(
                                  left: AppSpacing.md,
                                  right: AppSpacing.md,
                                  bottom: AppSpacing.sm,
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
                                title: 'Henüz ürün eklenmemiş',
                                subtitle: 'İlk ürününüzü ekleyerek başlayın',
                                action: canEdit
                                    ? AppPrimaryButton(
                                        label: 'Ürün Ekle',
                                        icon: Icons.add,
                                        onPressed: () => context.push(
                                            '/trousseau/$_currentTrousseauId/products/add'),
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }

                        if (productProvider.filteredProducts.isEmpty) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.lg),
                              child: EmptyStateWidget(
                                icon: Icons.search_off,
                                title: 'Ürün bulunamadı',
                                subtitle: 'Farklı filtreler deneyebilirsiniz',
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
                                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                                  child: AppProductCard(
                                    product: product,
                                    category: category,
                                    canEdit: canEdit,
                                    onTap: () => context.push(
                                      '/trousseau/$_currentTrousseauId/products/${product.id}',
                                    ),
                                    onTogglePurchase: canEdit
                                        ? () async {
                                            await productProvider
                                                .togglePurchaseStatus(product.id);
                                          }
                                        : null,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
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
                  label: 'Ürün Ekle',
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
    final myTrousseaus = trousseauProvider.pinnedTrousseaus;

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

                        final productProvider =
                            Provider.of<ProductProvider>(context, listen: false);
                        productProvider.loadProducts(_currentTrousseauId);

                        final categoryProvider =
                            Provider.of<CategoryProvider>(context, listen: false);
                        categoryProvider.bind(_currentTrousseauId,
                            userId: trousseauProvider.currentUserId ?? '');
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
                                  ? AppTypography.semibold
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
