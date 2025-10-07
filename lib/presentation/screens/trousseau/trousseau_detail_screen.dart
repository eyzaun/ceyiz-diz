import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../providers/trousseau_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/category_chip.dart';
import '../../widgets/common/draggable_fab.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/trousseau_model.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<ProductProvider>(context, listen: false)
          .loadProducts(widget.trousseauId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trousseauProvider = Provider.of<TrousseauProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

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

        final progress = trousseau.totalProducts > 0
            ? trousseau.purchasedProducts / trousseau.totalProducts
            : 0.0;
        final budgetProgress = trousseau.totalBudget > 0
            ? trousseau.spentAmount / trousseau.totalBudget
            : 0.0;

        // Compact spacing on web/wide screens
  final isCompact = kIsWeb || MediaQuery.of(context).size.width >= 1000;
  final sectionGap = isCompact ? 6.0 : 10.0;

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
                  slivers: [
                SliverPadding(
                  padding: EdgeInsets.all(isCompact ? 12 : 16),
                  sliver: SliverToBoxAdapter(
                    child: _constrain(
                      context,
                      _buildProgressSection(context, trousseau, progress, budgetProgress),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: sectionGap, key: UniqueKey())),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16),
                  sliver: SliverToBoxAdapter(
                    child: _constrain(
                      context,
                      _buildStatisticsGrid(context, trousseau),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: sectionGap, key: UniqueKey())),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16),
                  sliver: SliverToBoxAdapter(
                    child: _constrain(
                      context,
                      _buildCategoriesSection(context, trousseau),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: sectionGap, key: UniqueKey())),
                // Header row (kept as is)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16),
                  sliver: SliverToBoxAdapter(
                    child: _constrain(
                      context,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Ürünler', style: isCompact ? theme.textTheme.titleLarge : theme.textTheme.headlineSmall),
                          TextButton.icon(
                            onPressed: () => context.push('/trousseau/${widget.trousseauId}/products'),
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Tümünü Gör'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Search bar (same as ProductListScreen)
                SliverToBoxAdapter(
                  child: _constrain(
                    context,
                    Container(
                    padding: EdgeInsets.all(isCompact ? 6 : 10),
                    color: theme.cardColor,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Ürün ara...',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: isCompact ? 8 : 10),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  productProvider.setSearchQuery('');
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (v) {
                        productProvider.setSearchQuery(v);
                        // trigger rebuild to update clear icon visibility
                        setState(() {});
                      },
                    ),
                  ),
                ),
                ),
                // Filter chips row
                SliverToBoxAdapter(
                  child: _constrain(
                    context,
                    Container(
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
                        const SizedBox(width: 8),
                        // Open same filter dialog used on list screen
                        OutlinedButton.icon(
                          onPressed: () => _showFilterDialog(context),
                          icon: const Icon(Icons.filter_list, size: 18),
                          label: const Text('Filtreler'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: isCompact ? 4 : 6),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize: const Size(0, 0),
                            visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
                // Selected categories row (if any)
                if (productProvider.selectedCategories.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _constrain(
                      context,
                      Container(
                      height: isCompact ? 28 : 32,
                      padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16),
                      child: Row(
                        children: [
                          Text('Kategoriler:', style: theme.textTheme.bodySmall),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: productProvider.selectedCategories.map((categoryId) {
                                final category = CategoryModel.getCategoryById(categoryId);
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: CategoryChip(
                                    category: category,
                                    isSelected: true,
                                    onTap: () => productProvider.toggleCategory(categoryId),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          TextButton(
                            onPressed: productProvider.clearCategoryFilter,
                            child: const Text('Temizle'),
                          ),
                        ],
                      ),
                      ),
                    ),
                  ),
                // Product list / empty / loading
                if (productProvider.isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (productProvider.filteredProducts.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: EmptyStateWidget(
                        icon: Icons.shopping_bag_outlined,
                        title: productProvider.products.isEmpty
                            ? 'Henüz ürün eklenmemiş'
                            : 'Ürün bulunamadı',
                        subtitle: productProvider.products.isEmpty
                            ? 'İlk ürününüzü ekleyerek başlayın'
                            : 'Farklı filtreler deneyebilirsiniz',
                        action: productProvider.products.isEmpty && trousseau.canEdit(trousseauProvider.currentUserId ?? '')
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
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16, vertical: isCompact ? 8 : 12),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
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
                  ),
                // Summary bar (same as ProductListScreen bottom bar)
                SliverToBoxAdapter(
                  child: _constrain(
                    context,
                    Container(
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
                    ),
                  ),
                ),
                  ],
                ),
              ),
              if (trousseau.canEdit(trousseauProvider.currentUserId ?? ''))
                Positioned.fill(
                  child: DraggableFAB(
                    heroTag: 'fab-trousseau-add-${trousseau.id}',
                    tooltip: 'Ürün Ekle',
                    icon: Icons.add,
                    onPressed: () => context.push('/trousseau/${widget.trousseauId}/products/add'),
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
    final category = CategoryModel.getCategoryById(product.category);

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

  void _showFilterDialog(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategoriler',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CategoryModel.defaultCategories.map((category) {
                      final isSelected = productProvider.selectedCategories
                          .contains(category.id);
                      return CategoryChip(
                        category: category,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            productProvider.toggleCategory(category.id);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            productProvider.clearCategoryFilter();
                            Navigator.pop(context);
                          },
                          child: const Text('Temizle'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Uygula'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProgressSection(
      BuildContext context, TrousseauModel trousseau, double progress, double budgetProgress) {
    final theme = Theme.of(context);
    final isCompact = kIsWeb || MediaQuery.of(context).size.width >= 1000;
    
    Widget buildBlock({
      required String title,
      required double percent,
      required Color color,
      required String subtitle,
    }) {
      return Container(
        padding: EdgeInsets.all(isCompact ? 8 : 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(isCompact ? 10 : 12),
          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
                Text(
                  '${(percent * 100).toInt()}%',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: isCompact ? 4 : 6),
            LinearProgressIndicator(
              value: percent > 1 ? 1 : percent,
              minHeight: isCompact ? 4 : 5,
              backgroundColor: theme.dividerColor,
              color: percent > 1 && title == 'Bütçe' ? theme.colorScheme.error : color,
            ),
            SizedBox(height: isCompact ? 2 : 4),
            Text(subtitle, style: theme.textTheme.bodySmall),
          ],
        ),
      );
    }

    if (isCompact) {
      return Row(
        children: [
          Expanded(
            child: buildBlock(
              title: 'İlerleme',
              percent: progress,
              color: theme.colorScheme.primary,
              subtitle: '${trousseau.purchasedProducts} alındı • ${trousseau.totalProducts - trousseau.purchasedProducts} kaldı',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: buildBlock(
              title: 'Bütçe',
              percent: budgetProgress,
              color: budgetProgress > 1 ? theme.colorScheme.error : theme.colorScheme.secondary,
              subtitle: '₺${trousseau.spentAmount.toStringAsFixed(0)} harcandı • ₺${trousseau.totalBudget.toStringAsFixed(0)} bütçe',
            ),
          ),
        ],
      );
    }

    // Fallback vertical stack for narrow screens
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildBlock(
          title: 'İlerleme',
          percent: progress,
          color: theme.colorScheme.primary,
          subtitle: '${trousseau.purchasedProducts} alındı • ${trousseau.totalProducts - trousseau.purchasedProducts} kaldı',
        ),
        const SizedBox(height: 8),
        buildBlock(
          title: 'Bütçe',
          percent: budgetProgress,
          color: budgetProgress > 1 ? theme.colorScheme.error : theme.colorScheme.secondary,
          subtitle: '₺${trousseau.spentAmount.toStringAsFixed(0)} harcandı • ₺${trousseau.totalBudget.toStringAsFixed(0)} bütçe',
        ),
      ],
    );
  }

  Widget _buildStatisticsGrid(BuildContext context, TrousseauModel trousseau) {
    // Replace large cards with compact pills to reduce both horizontal and vertical space.
    final theme = Theme.of(context);
    final isCompact = kIsWeb || MediaQuery.of(context).size.width >= 1000;
    final pillPadding = EdgeInsets.symmetric(horizontal: isCompact ? 10 : 12, vertical: isCompact ? 6 : 8);
    final spacing = isCompact ? 8.0 : 10.0;

    Widget pill(IconData icon, Color color, String label, String value) {
      return Container(
        padding: pillPadding,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: isCompact ? 16 : 18, color: color),
            SizedBox(width: isCompact ? 6 : 8),
            Text(label, style: theme.textTheme.bodySmall),
            SizedBox(width: isCompact ? 6 : 8),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        pill(Icons.inventory, theme.colorScheme.primary, 'Toplam', trousseau.totalProducts.toString()),
        pill(Icons.check_circle, theme.colorScheme.tertiary, 'Alınan', trousseau.purchasedProducts.toString()),
        pill(Icons.shopping_cart, theme.colorScheme.secondary, 'Harcanan', '₺${trousseau.spentAmount.toStringAsFixed(0)}'),
        pill(Icons.savings, theme.colorScheme.secondaryContainer, 'Kalan', '₺${(trousseau.totalBudget - trousseau.spentAmount).toStringAsFixed(0)}'),
      ],
    );
  }

  // Removed old _buildStatCard; stats now use compact pills.

  Widget _buildCategoriesSection(BuildContext context, TrousseauModel trousseau) {
    final theme = Theme.of(context);
    final isCompact = kIsWeb || MediaQuery.of(context).size.width >= 1000;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategoriler',
          style: theme.textTheme.headlineSmall,
        ),
        SizedBox(height: isCompact ? 8 : 12),
        Wrap(
          spacing: isCompact ? 6 : 8,
          runSpacing: isCompact ? 6 : 8,
          children: CategoryModel.defaultCategories.map((category) {
            final count = trousseau.categoryCounts[category.id] ?? 0;
            
            return Container(
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 12, vertical: isCompact ? 4 : 6),
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: category.color.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category.icon,
                    size: isCompact ? 14 : 16,
                    color: category.color,
                  ),
                  SizedBox(width: isCompact ? 4 : 6),
                  Text(
                    category.displayName,
                    style: TextStyle(
                      fontSize: isCompact ? 11 : 12,
                      color: category.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: isCompact ? 3 : 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: isCompact ? 5 : 6, vertical: isCompact ? 1.5 : 2),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: isCompact ? 9 : 10,
                        color: category.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
