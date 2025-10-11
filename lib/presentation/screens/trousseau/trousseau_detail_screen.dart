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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<ProductProvider>(context, listen: false)
          .loadProducts(widget.trousseauId);
      // Bind dynamic categories to this trousseau
    final trProv = Provider.of<TrousseauProvider>(context, listen: false);
    Provider.of<CategoryProvider>(context, listen: false)
      .bind(widget.trousseauId, userId: trProv.currentUserId ?? '');
    });
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
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return StreamBuilder<TrousseauModel?>(
      stream: trousseauProvider.getSingleTrousseauStream(widget.trousseauId),
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
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.push('/trousseau/${widget.trousseauId}/edit'),
                ),
              if (trousseau.ownerId == trousseauProvider.currentUserId)
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => context.push('/trousseau/${widget.trousseauId}/share'),
                ),
            ],
          ),
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () => productProvider.loadProducts(widget.trousseauId),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                // Header row
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16),
                  sliver: SliverToBoxAdapter(
                    child: _constrain(
                      context,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ürünler',
                            style: isCompact
                                ? theme.textTheme.titleLarge
                                : theme.textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Search bar
                SliverToBoxAdapter(
                  child: _constrain(
                    context,
                    Container(
                      padding: EdgeInsets.all(isCompact ? 6 : 10),
                      color: theme.cardColor,
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _searchController,
                        builder: (context, value, _) {
                          return TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Ürün ara...',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: isCompact ? 8 : 10),
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: value.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        productProvider.setSearchQuery('');
                                        if (!_searchFocusNode.hasFocus) {
                                          _searchFocusNode.requestFocus();
                                        }
                                        _searchController.selection = const TextSelection.collapsed(offset: 0);
                                      },
                                    )
                                  : null,
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
                          height: isCompact ? 32 : 40,
                          padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16),
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
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                context,
                                'Alınanlar',
                                productProvider.currentFilter == ProductFilter.purchased,
                                () => productProvider.setFilter(ProductFilter.purchased),
                                count: productProvider.getPurchasedCount(),
                                color: theme.colorScheme.tertiary,
                              ),
                              const SizedBox(width: 8),
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
                    Consumer<ProductProvider>(
                      builder: (context, productProvider, _) {
                        return Container(
                          height: isCompact ? 36 : 44,
                          padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 12),
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: categoryProvider.allCategories.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                    ),
                  ),
                ),
                // Product list / empty / loading
                if (productProvider.products.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: EmptyStateWidget(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Henüz ürün eklenmemiş',
                        subtitle: 'İlk ürününüzü ekleyerek başlayın',
                        action: trousseau.canEdit(trousseauProvider.currentUserId ?? '')
                            ? ElevatedButton.icon(
                                onPressed: () => context.push('/trousseau/${widget.trousseauId}/products/add'),
                                icon: const Icon(Icons.add),
                                label: const Text('Ürün Ekle'),
                              )
                            : null,
                      ),
                    ),
                  )
                else
                  // Keep list sliver constant; overlay states separately to avoid scroll jumps
                  Consumer<ProductProvider>(
                    builder: (context, productProvider, _) {
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
                          padding: EdgeInsets.all(isCompact ? 8 : 12),
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
                      onPressed: () => context.push('/trousseau/${widget.trousseauId}/products/add'),
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

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count != null) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
        color: isSelected
          ? Colors.white.withValues(alpha: 0.3)
          : chipColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
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
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic product, bool canEdit) {
    final theme = Theme.of(context);
    final category = Provider.of<CategoryProvider>(context, listen: false)
        .getById(product.category);

    final isCompact = kIsWeb || MediaQuery.of(context).size.width >= 1000;

    return Card(
      margin: EdgeInsets.only(bottom: isCompact ? 8 : 12),
      child: InkWell(
        onTap: () => context.push(
          '/trousseau/${widget.trousseauId}/products/${product.id}',
        ),
        borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 10 : 12),
          child: Row(
            children: [
              // Product Image or Icon
              Container(
                width: isCompact ? 64 : 80,
                height: isCompact ? 64 : 80,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isCompact ? 10 : 12),
                ),
                child: product.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(isCompact ? 10 : 12),
                        child: CachedNetworkImage(
                          imageUrl: product.images.first,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              color: category.color,
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            category.icon,
                            color: category.color,
                            size: isCompact ? 26 : 32,
                          ),
                        ),
                      )
                    : Icon(
                        category.icon,
                        color: category.color,
                        size: isCompact ? 26 : 32,
                      ),
              ),
              SizedBox(width: isCompact ? 10 : 12),
              
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
                            style: theme.textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (product.isPurchased)
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: isCompact ? 18 : 20,
                          ),
                      ],
                    ),
                    SizedBox(height: isCompact ? 3 : 4),
                    if (product.description.isNotEmpty) ...[
                      Text(
                        product.description,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isCompact ? 3 : 4),
                    ],
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: category.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                category.icon,
                                size: isCompact ? 11 : 12,
                                color: category.color,
                              ),
                              SizedBox(width: isCompact ? 3 : 4),
                              Text(
                                category.displayName,
                                style: TextStyle(
                                  fontSize: isCompact ? 10 : 11,
                                  color: category.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: isCompact ? 6 : 8),
                        if (product.quantity > 1)
                          Text(
                            '${product.quantity} adet',
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: isCompact ? 10 : 12),
              
              // Price and Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₺${product.price.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (product.quantity > 1) ...[
                    SizedBox(height: isCompact ? 3 : 4),
                    Text(
                      'Toplam: ₺${product.totalPrice.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  if (canEdit) ...[
                    SizedBox(height: isCompact ? 6 : 8),
                    IconButton(
                      icon: Icon(
                        product.isPurchased
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: product.isPurchased ? Colors.green : null,
                      ),
                      onPressed: () async {
                        final provider = Provider.of<ProductProvider>(
                          context,
                          listen: false,
                        );
                        await provider.togglePurchaseStatus(product.id);
                      },
                      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
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
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // removed legacy filter dialog (dynamic category chips are inline now)
}
