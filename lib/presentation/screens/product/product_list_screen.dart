import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/product_provider.dart';
import '../../providers/trousseau_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/category_chip.dart';
import '../../../data/models/product_model.dart';
import '../../providers/category_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final productProv = Provider.of<ProductProvider>(context, listen: false);
      productProv.loadProducts(widget.trousseauId);
      // Bind category provider for dynamic categories of this trousseau
      final catProv = Provider.of<CategoryProvider>(context, listen: false);
      catProv.bind(widget.trousseauId);
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
        actions: [
          if (canEdit)
            IconButton(
              tooltip: 'Kategorileri Yönet',
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push('/trousseau/${widget.trousseauId}/products/categories'),
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.cardColor,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Ürün ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          productProvider.setSearchQuery('');
                        },
                      )
                    : null,
              ),
              onChanged: productProvider.setSearchQuery,
            ),
          ),
          
          // Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
          ),

          // Category filter row (only categories; grey when inactive, colored when active)
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categoryProvider.allCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categoryProvider.allCategories[index];
                final isSelected = productProvider.selectedCategories.contains(category.id);
                final count = productProvider.products.where((p) => p.category == category.id).length;
                return CategoryChip(
                  category: category,
                  isSelected: isSelected,
                  onTap: () => productProvider.toggleCategory(category.id),
                  colorful: isSelected, // inactive grey, active colorful
                  showCount: count > 0,
                  count: count,
                );
              },
            ),
          ),
          
          // Products List
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : productProvider.filteredProducts.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.shopping_bag_outlined,
                        title: productProvider.products.isEmpty
                            ? 'Henüz ürün eklenmemiş'
                            : 'Ürün bulunamadı',
                        subtitle: productProvider.products.isEmpty
                            ? 'İlk ürününüzü ekleyerek başlayın'
                            : 'Farklı filtreler deneyebilirsiniz',
                        action: productProvider.products.isEmpty && canEdit
                            ? ElevatedButton.icon(
                                onPressed: () => context.push(
                                  '/trousseau/${widget.trousseauId}/products/add',
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text('Ürün Ekle'),
                              )
                            : null,
                      )
                    : RefreshIndicator(
                        onRefresh: () => productProvider.loadProducts(widget.trousseauId),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: productProvider.filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = productProvider.filteredProducts[index];
                            return _buildProductCard(context, product, canEdit);
                          },
                        ),
                      ),
          ),
          
          // Summary Bar
          Container(
            padding: const EdgeInsets.all(16),
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
        ],
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: () => context.push(
                '/trousseau/${widget.trousseauId}/products/add',
              ),
              icon: const Icon(Icons.add),
              label: const Text('Ürün Ekle'),
            )
          : null,
    );
  }

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

  Widget _buildProductCard(BuildContext context, ProductModel product, bool canEdit) {
    final theme = Theme.of(context);
  final category = Provider.of<CategoryProvider>(context, listen: false)
    .getById(product.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push(
          '/trousseau/${widget.trousseauId}/products/${product.id}',
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image or Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: product.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
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
                            size: 32,
                          ),
                        ),
                      )
                    : Icon(
                        category.icon,
                        color: category.color,
                        size: 32,
                      ),
              ),
              const SizedBox(width: 12),
              
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
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (product.description.isNotEmpty) ...[
                      Text(
                        product.description,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: category.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                category.icon,
                                size: 12,
                                color: category.color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                category.displayName,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: category.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
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
              const SizedBox(width: 12),
              
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
                    const SizedBox(height: 4),
                    Text(
                      'Toplam: ₺${product.totalPrice.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  if (canEdit) ...[
                    const SizedBox(height: 8),
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
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final trousseauProvider = Provider.of<TrousseauProvider>(context, listen: false);
    final trousseau = trousseauProvider.getTrousseauById(widget.trousseauId);
    final canEdit = trousseau != null && trousseau.canEdit(trousseauProvider.currentUserId ?? '');
    
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Kategoriler',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      if (canEdit)
                        IconButton(
                          tooltip: 'Kategori Ekle',
                          onPressed: () async {
                            final result = await _promptAddCategory(context, categoryProvider);
                            if (result) setState(() {});
                          },
                          icon: const Icon(Icons.add),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categoryProvider.allCategories.map((category) {
                      final isSelected = productProvider.selectedCategories
                          .contains(category.id);
                      return Stack(
                        alignment: Alignment.topRight,
                        children: [
                          CategoryChip(
                            category: category,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                productProvider.toggleCategory(category.id);
                              });
                            },
                          ),
                          if (canEdit && category.isCustom)
                            Positioned(
                              right: -6,
                              top: -6,
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                splashRadius: 14,
                                onPressed: () async {
                                  final confirmed = await _confirmDeleteCategory(context, category.displayName);
                                  if (confirmed) {
                                    await categoryProvider.removeCustom(category.id);
                                    if (productProvider.selectedCategories.contains(category.id)) {
                                      productProvider.toggleCategory(category.id);
                                    }
                                    setState(() {});
                                  }
                                },
                              ),
                            ),
                        ],
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

  Future<bool> _promptAddCategory(BuildContext context, CategoryProvider provider) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni Kategori'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Kategori adı (örn. Balkon)'),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ad gerekli';
              if (provider.allCategories.any((c) => c.displayName.toLowerCase() == v.trim().toLowerCase())) {
                return 'Bu ad kullanılıyor';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final name = controller.text.trim();
              final id = _slugify(name, provider);
              final ok = await provider.addCustom(id, name);
              if (!ctx.mounted) return;
              Navigator.pop(ctx, ok);
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  String _slugify(String name, CategoryProvider provider) {
    String slug = name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9ğüşöçı\s-]', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), '-');
    if (slug.isEmpty) slug = 'kategori';
    var base = slug;
    int i = 1;
    while (provider.allCategories.any((c) => c.id == slug)) {
      slug = '$base-$i';
      i++;
    }
    return slug;
  }

  Future<bool> _confirmDeleteCategory(BuildContext context, String displayName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kategoriyi Sil'),
        content: Text('"$displayName" kategorisini silmek istediğinize emin misiniz? Ürünler silinmez, kategori görünümü Diğer olarak değişebilir.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil')),
        ],
      ),
    );
    return result ?? false;
  }
}
