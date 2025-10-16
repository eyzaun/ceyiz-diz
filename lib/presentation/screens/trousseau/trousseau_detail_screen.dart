import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../providers/trousseau_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/category_chip.dart';
import '../../widgets/common/draggable_fab.dart';
import '../../../data/models/trousseau_model.dart';
import '../../providers/category_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
      // Bind dynamic categories to this trousseau
    final trProv = Provider.of<TrousseauProvider>(context, listen: false);
    Provider.of<CategoryProvider>(context, listen: false)
      .bind(_currentTrousseauId, userId: trProv.currentUserId ?? '');
    });
  }

  @override
  void didUpdateWidget(TrousseauDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Widget parametresi değiştiğinde _currentTrousseauId'yi güncelle (deep link vs.)
    if (widget.trousseauId != oldWidget.trousseauId && widget.trousseauId != _currentTrousseauId) {
      setState(() {
        _currentTrousseauId = widget.trousseauId;
      });
      Provider.of<ProductProvider>(context, listen: false).loadProducts(_currentTrousseauId);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trousseauProvider = Provider.of<TrousseauProvider>(context);
    // Avoid rebuilding entire screen on product provider updates; we'll use Consumer where needed
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    return StreamBuilder<TrousseauModel?>(
      key: ValueKey(_currentTrousseauId), // Prevent unnecessary rebuilds
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

    // Compact spacing on web/wide screens
    final isCompact = kIsWeb || MediaQuery.of(context).size.width >= 1000;

        return Scaffold(
          appBar: AppBar(
            title: Text(trousseau.name),
            actions: [
              if (trousseau.canEdit(trousseauProvider.currentUserId ?? ''))
                IconButton(
                  icon: const Icon(Icons.category_outlined),
                  tooltip: 'Kategorileri Yönet',
                  onPressed: () => context.push('/trousseau/$_currentTrousseauId/products/categories'),
                ),
              if (trousseau.canEdit(trousseauProvider.currentUserId ?? ''))
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.push('/trousseau/$_currentTrousseauId/edit'),
                ),
              if (trousseau.ownerId == trousseauProvider.currentUserId)
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => context.push('/trousseau/$_currentTrousseauId/share'),
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
                // Trousseau Selector (horizontal scrolling tabs)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverToBoxAdapter(
                    child: _constrain(
                      context,
                      _buildTrousseauSelector(context, trousseauProvider, isCompact),
                    ),
                  ),
                ),
                // Search bar
                SliverToBoxAdapter(
                  child: _constrain(
                    context,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: theme.cardColor,
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _searchController,
                        builder: (context, value, _) {
                          return Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Ürün ara...',
                                hintStyle: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                prefixIcon: Icon(Icons.search, size: 20, color: theme.colorScheme.onSurfaceVariant),
                                suffixIcon: value.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.clear, size: 18, color: theme.colorScheme.onSurfaceVariant),
                                        onPressed: () {
                                          _searchController.clear();
                                          productProvider.setSearchQuery('');
                                          if (!_searchFocusNode.hasFocus) {
                                            _searchFocusNode.requestFocus();
                                          }
                                          _searchController.selection = const TextSelection.collapsed(offset: 0);
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      )
                                    : null,
                                border: InputBorder.none,
                              ),
                              onChanged: (v) {
                                _debounce?.cancel();
                                _debounce = Timer(const Duration(milliseconds: 300), () {
                                  if (!mounted) return;
                                  productProvider.setSearchQuery(v);
                                  if (!_searchFocusNode.hasFocus) {
                                    _searchFocusNode.requestFocus();
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Filter chips row (Tümü/Alınanlar/Alınmayanlar)
                SliverToBoxAdapter(
                  child: _constrain(
                    context,
                    Consumer<ProductProvider>(
                      builder: (context, productProvider, _) {
                        return Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildFilterChip(
                                context,
                                'Tümü',
                                productProvider.currentFilter == ProductFilter.all,
                                () => productProvider.setFilter(ProductFilter.all),
                                count: productProvider.products.length,
                              ),
                              const SizedBox(width: 6),
                              _buildFilterChip(
                                context,
                                'Alınanlar',
                                productProvider.currentFilter == ProductFilter.purchased,
                                () => productProvider.setFilter(ProductFilter.purchased),
                                count: productProvider.getPurchasedCount(),
                                color: theme.colorScheme.tertiary,
                              ),
                              const SizedBox(width: 6),
                              _buildFilterChip(
                                context,
                                'Alınmayanlar',
                                productProvider.currentFilter == ProductFilter.notPurchased,
                                () => productProvider.setFilter(ProductFilter.notPurchased),
                                count: productProvider.getNotPurchasedCount(),
                                color: theme.colorScheme.secondary,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Dynamic category chips row (inactive grey, active colored)
                SliverToBoxAdapter(
                  child: _constrain(
                    context,
                    Consumer<CategoryProvider>(
                      builder: (context, categoryProvider, _) {
                        return Consumer<ProductProvider>(
                          builder: (context, productProvider, _) {
                            return Container(
                              height: 36,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: categoryProvider.allCategories.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 6),
                                itemBuilder: (context, index) {
                                  final category = categoryProvider.allCategories[index];
                                  final isSelected = productProvider.selectedCategories.contains(category.id);
                                  final count = productProvider.products
                                      .where((p) => p.category == category.id)
                                      .length;
                                  return CategoryChip(
                                    category: category,
                                    isSelected: isSelected,
                                    colorful: isSelected,
                                    showCount: count > 0,
                                    count: count,
                                    onTap: () => productProvider.toggleCategory(category.id),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                // Product list / empty / loading - MUST use Consumer to react to product changes
                Consumer<ProductProvider>(
                  builder: (context, productProvider, _) {
                    if (productProvider.products.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: EmptyStateWidget(
                            icon: Icons.shopping_bag_outlined,
                            title: 'Henüz ürün eklenmemiş',
                            subtitle: 'İlk ürününüzü ekleyerek başlayın',
                            action: trousseau.canEdit(trousseauProvider.currentUserId ?? '')
                                ? ElevatedButton.icon(
                                    onPressed: () => context.push('/trousseau/$_currentTrousseauId/products/add'),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Ürün Ekle'),
                                  )
                                : null,
                          ),
                        ),
                      );
                    }

                    // Keep list sliver constant; overlay states separately to avoid scroll jumps
                      return SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16, vertical: isCompact ? 8 : 12),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index >= productProvider.filteredProducts.length) {
                                return const SizedBox.shrink();
                              }
                              final product = productProvider.filteredProducts[index];
                              return Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 1100),
                                  child: _buildProductCard(
                                    context,
                                    product,
                                    trousseau.canEdit(trousseauProvider.currentUserId ?? ''),
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
                // Summary bar (same as ProductListScreen bottom bar)
                SliverToBoxAdapter(
                  child: _constrain(
                    context,
                    Consumer<ProductProvider>(
                      builder: (context, productProvider, _) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 3,
                                offset: const Offset(0, -1),
                              ),
                            ],
                          ),
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
                        );
                      },
                    ),
                  ),
                ),
                  ],
                ),
              ),
              // Overlay states to avoid layout jumps
              Consumer<ProductProvider>(
                builder: (context, productProvider, _) {
                  return Stack(
                    children: [
                      if (productProvider.isLoading)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: LinearProgressIndicator(
                            minHeight: 2,
                            color: theme.colorScheme.primary,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          ),
                        ),
                      if (!productProvider.isLoading && productProvider.filteredProducts.isEmpty && productProvider.products.isNotEmpty)
                        Positioned.fill(
                          child: IgnorePointer(
                            ignoring: true,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: EmptyStateWidget(
                                  icon: Icons.search_off,
                                  title: 'Ürün bulunamadı',
                                  subtitle: 'Farklı filtreler deneyebilirsiniz',
                                  action: null,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              if (trousseau.canEdit(trousseauProvider.currentUserId ?? ''))
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: false,
                    child: DraggableFAB(
                      heroTag: 'fab-trousseau-add-${trousseau.id}',
                      tooltip: 'Ürün Ekle',
                      icon: Icons.add,
                      onPressed: () => context.push('/trousseau/$_currentTrousseauId/products/add'),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // Constrain wide web layout to improve readability and reduce perceived size
  Widget _constrain(BuildContext context, Widget child) {
    final isCompact = kIsWeb || MediaQuery.of(context).size.width >= 1000;
    if (!isCompact) return child;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: child,
      ),
    );
  }

  // Reused helpers from ProductListScreen
  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap, {
    int? count,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return Material(
      color: isSelected ? chipColor : chipColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? Colors.white : chipColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : chipColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white : chipColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic product, bool canEdit) {
    final theme = Theme.of(context);
    final category = Provider.of<CategoryProvider>(context, listen: false)
        .getById(product.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.push(
          '/trousseau/$_currentTrousseauId/products/${product.id}',
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Product Image or Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: product.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: product.images.first,
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
                            size: 24,
                          ),
                        ),
                      )
                    : Icon(
                        category.icon,
                        color: category.color,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 10),
              
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (product.isPurchased)
                          Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.tertiary,
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (product.description.isNotEmpty) ...[
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                    ],
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: category.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                category.icon,
                                size: 10,
                                color: category.color,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                category.displayName,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: category.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (product.quantity > 1)
                          Text(
                            '${product.quantity} adet',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              
              // Price and Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '₺${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (product.quantity > 1) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Toplam: ₺${product.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (canEdit) ...[
                    const SizedBox(height: 4),
                    IconButton(
                      icon: Icon(
                        product.isPurchased
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: product.isPurchased ? theme.colorScheme.tertiary : theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onPressed: () async {
                        final provider = Provider.of<ProductProvider>(
                          context,
                          listen: false,
                        );
                        await provider.togglePurchaseStatus(product.id);
                      },
                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTrousseauSelector(
    BuildContext context,
    TrousseauProvider trousseauProvider,
    bool isCompact,
  ) {
    final theme = Theme.of(context);
    // Include both owned and pinned shared trousseaus
    final myTrousseaus = trousseauProvider.pinnedTrousseaus;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: myTrousseaus.length,
              separatorBuilder: (_, __) => const SizedBox(width: 4),
              itemBuilder: (context, index) {
                final trousseau = myTrousseaus[index];
                final isSelected = trousseau.id == _currentTrousseauId;

                return Material(
                  color: isSelected 
                      ? theme.colorScheme.primaryContainer 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    onTap: () {
                      if (trousseau.id != _currentTrousseauId) {
                        setState(() {
                          _currentTrousseauId = trousseau.id;
                        });
                        
                        final productProvider = Provider.of<ProductProvider>(context, listen: false);
                        productProvider.loadProducts(_currentTrousseauId);
                        
                        final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
                        categoryProvider.bind(_currentTrousseauId, userId: trousseauProvider.currentUserId ?? '');
                      }
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Show icon for shared trousseaus
                          if (trousseau.ownerId != trousseauProvider.currentUserId) ...[
                            Icon(
                              Icons.people_outline,
                              size: 14,
                              color: isSelected
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            trousseau.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
          const SizedBox(width: 4),
          Material(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: () => context.push('/create-trousseau'),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // removed legacy filter dialog (dynamic category chips are inline now)
}
