import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/product_provider.dart';
import '../../providers/trousseau_provider.dart';
import '../../widgets/common/custom_dialog.dart';
import '../../providers/category_provider.dart';
import '../../../core/themes/design_system.dart';
import '../../widgets/common/responsive_container.dart';

class ProductDetailScreen extends StatelessWidget {
  final String trousseauId;
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.trousseauId,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<AppSemanticColors>();
    final productProvider = Provider.of<ProductProvider>(context);
    final trousseauProvider = Provider.of<TrousseauProvider>(context);
    final product = productProvider.getProductById(productId);
    final trousseau = trousseauProvider.getTrousseauById(trousseauId);

    if (product == null || trousseau == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Ürün bulunamadı'),
        ),
      );
    }

  final canEdit = trousseau.canEdit(trousseauProvider.currentUserId ?? '');
  final category = Provider.of<CategoryProvider>(context).getById(product.category);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          if (canEdit) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push(
                '/trousseau/$trousseauId/products/$productId/edit',
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirmed = await CustomDialog.showConfirmation(
                  context: context,
                  title: 'Ürünü Sil',
                  subtitle: 'Bu ürünü silmek istediğinizden emin misiniz?',
                  confirmText: 'Sil',
                  confirmColor: Colors.red,
                );
                
                if (confirmed == true) {
                  await productProvider.deleteProduct(productId);
                  if (context.mounted) {
                    context.pop();
                  }
                }
              },
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          padding: EdgeInsets.zero,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            if (product.images.isNotEmpty)
              LayoutBuilder(
                builder: (context, constraints) {
                  // Make image taller on large screens for better presence
                  final isWide = constraints.maxWidth >= 900;
                  final height = isWide ? 460.0 : 300.0;
                  return SizedBox(
                    height: height,
                child: PageView.builder(
                  itemCount: product.images.length,
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: product.images[index],
                      fit: BoxFit.cover,
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
                  );
                },
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: theme.textTheme.headlineMedium,
                        ),
                      ),
                      if (product.isPurchased)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: (semantics?.success ?? theme.colorScheme.tertiary).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: semantics?.success ?? theme.colorScheme.tertiary),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Alındı',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
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
                            color: category.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Price and Quantity
                  Container(
                    padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Birim Fiyat',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              '₺${product.price.toStringAsFixed(2)}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Adet',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              product.quantity.toString(),
                              style: theme.textTheme.titleLarge,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Toplam',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              '₺${product.totalPrice.toStringAsFixed(2)}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  if (product.description.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Açıklama',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                  
                  if (product.notes.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Notlar',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (semantics?.warning ?? theme.colorScheme.secondary).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (semantics?.warning ?? theme.colorScheme.secondary).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        product.notes,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                  
                  if (product.link.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse(product.link);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Ürün Linkini Aç'),
                      ),
                    ),
                  ],
                  
                  if (product.isPurchased && product.purchaseDate != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (semantics?.success ?? theme.colorScheme.tertiary).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: semantics?.success ?? theme.colorScheme.tertiary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Satın Alındı',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: semantics?.success ?? theme.colorScheme.tertiary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${product.purchaseDate!.day}/${product.purchaseDate!.month}/${product.purchaseDate!.year}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      ),
      bottomNavigationBar: canEdit
          ? Container(
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
              child: ElevatedButton(
                onPressed: () async {
                  await productProvider.togglePurchaseStatus(productId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: product.isPurchased
                      ? (semantics?.warning ?? theme.colorScheme.secondary)
                      : (semantics?.success ?? theme.colorScheme.tertiary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  product.isPurchased
                      ? 'Alınmadı Olarak İşaretle'
                      : 'Alındı Olarak İşaretle',
                  style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary),
                ),
              ),
            )
          : null,
    );
  }
}