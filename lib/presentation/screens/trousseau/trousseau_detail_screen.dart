import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/trousseau_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../../data/models/category_model.dart';
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
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ProductProvider>(context, listen: false)
          .loadProducts(widget.trousseauId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trousseauProvider = Provider.of<TrousseauProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final trousseau = trousseauProvider.getTrousseauById(widget.trousseauId);
    
    if (trousseau == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Çeyiz bulunamadı'),
        ),
      );
    }
    
    final progress = trousseau.totalProducts > 0
        ? trousseau.purchasedProducts / trousseau.totalProducts
        : 0.0;
    final budgetProgress = trousseau.totalBudget > 0
        ? trousseau.spentAmount / trousseau.totalBudget
        : 0.0;
    
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
      body: RefreshIndicator(
        onRefresh: () => productProvider.loadProducts(widget.trousseauId),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (trousseau.description.isNotEmpty) ...[
                      Text(
                        trousseau.description,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildProgressSection(context, trousseau, progress, budgetProgress),
                    const SizedBox(height: 24),
                    _buildStatisticsGrid(context, trousseau),
                    const SizedBox(height: 24),
                    _buildCategoriesSection(context, trousseau),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ürünler',
                          style: theme.textTheme.headlineSmall,
                        ),
                        TextButton.icon(
                          onPressed: () => context.push('/trousseau/${widget.trousseauId}/products'),
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Tümünü Gör'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (productProvider.products.isEmpty)
              SliverFillRemaining(
                child: EmptyStateWidget(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Henüz ürün eklenmemiş',
                  subtitle: 'Çeyizinize ürün ekleyerek başlayın',
                  action: ElevatedButton.icon(
                    onPressed: () => context.push('/trousseau/${widget.trousseauId}/products/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('İlk Ürünü Ekle'),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = productProvider.products[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: CategoryModel.getCategoryById(product.category).color,
                            child: Icon(
                              CategoryModel.getCategoryById(product.category).icon,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(product.name),
                          subtitle: Text('₺${product.price.toStringAsFixed(2)}'),
                          trailing: product.isPurchased
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : const Icon(Icons.circle_outlined),
                          onTap: () => context.push(
                            '/trousseau/${widget.trousseauId}/products/${product.id}',
                          ),
                        ),
                      );
                    },
                    childCount: productProvider.products.length > 5
                        ? 5
                        : productProvider.products.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: trousseau.canEdit(trousseauProvider.currentUserId ?? '')
          ? FloatingActionButton(
              onPressed: () => context.push('/trousseau/${widget.trousseauId}/products/add'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildProgressSection(
      BuildContext context, TrousseauModel trousseau, double progress, double budgetProgress) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
  color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'İlerleme',
                style: theme.textTheme.titleMedium,
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: theme.dividerColor,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${trousseau.purchasedProducts} alındı',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                '${trousseau.totalProducts - trousseau.purchasedProducts} kaldı',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bütçe',
                style: theme.textTheme.titleMedium,
              ),
              Text(
                '${(budgetProgress * 100).toInt()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: budgetProgress > 1
                      ? Colors.red
                      : theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: budgetProgress > 1 ? 1 : budgetProgress,
            minHeight: 8,
            backgroundColor: theme.dividerColor,
            color: budgetProgress > 1 ? Colors.red : theme.colorScheme.secondary,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₺${trousseau.spentAmount.toStringAsFixed(0)} harcandı',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                '₺${trousseau.totalBudget.toStringAsFixed(0)} bütçe',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(BuildContext context, TrousseauModel trousseau) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildStatCard(
          context,
          'Toplam Ürün',
          trousseau.totalProducts.toString(),
          Icons.inventory,
          Theme.of(context).colorScheme.primary,
        ),
        _buildStatCard(
          context,
          'Alınan Ürün',
          trousseau.purchasedProducts.toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          context,
          'Harcanan',
          '₺${trousseau.spentAmount.toStringAsFixed(0)}',
          Icons.shopping_cart,
          Theme.of(context).colorScheme.secondary,
        ),
        _buildStatCard(
          context,
          'Kalan Bütçe',
          '₺${(trousseau.totalBudget - trousseau.spentAmount).toStringAsFixed(0)}',
          Icons.savings,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, TrousseauModel trousseau) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategoriler',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CategoryModel.defaultCategories.map((category) {
            final count = trousseau.categoryCounts[category.id] ?? 0;
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: category.color.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category.icon,
                    size: 16,
                    color: category.color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: category.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 10,
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
