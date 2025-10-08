import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/trousseau_provider.dart';
import '../../providers/category_provider.dart';
import '../../../data/models/category_model.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String? _boundTrousseauId;

  @override
  void initState() {
    super.initState();
    // Defer provider access to first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensureCategoryBinding();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureCategoryBinding();
  }

  void _ensureCategoryBinding() {
    final trProv = Provider.of<TrousseauProvider>(context, listen: false);
    final myId = trProv.myTrousseauId();
    if (myId == null) return;
    final catProv = Provider.of<CategoryProvider>(context, listen: false);
    if (_boundTrousseauId != myId || catProv.currentTrousseauId != myId) {
      _boundTrousseauId = myId;
      catProv.bind(myId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trousseauProvider = Provider.of<TrousseauProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    // Show ONLY the current user's own (single) trousseau statistics
    final myTrousseau = trousseauProvider.trousseaus.isNotEmpty
        ? trousseauProvider.trousseaus.first
        : null;

    if (myTrousseau == null) {
      return const Center(child: Text('İstatistik bulunmuyor'));
    }

    final categoryStats = Map<String, int>.from(myTrousseau.categoryCounts);
    final double totalBudget = myTrousseau.totalBudget;
    final double totalSpent = myTrousseau.spentAmount;
    final int totalProducts = myTrousseau.totalProducts;
    final int purchasedProducts = myTrousseau.purchasedProducts;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _metricCard(
                context,
                'Toplam Bütçe',
                '₺${totalBudget.toStringAsFixed(0)}',
                theme.colorScheme.primary,
                Icons.account_balance_wallet,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                context,
                'Harcanan',
                '₺${totalSpent.toStringAsFixed(0)}',
                theme.colorScheme.tertiary,
                Icons.shopping_cart,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                context,
                'Toplam Ürün',
                totalProducts.toString(),
                theme.colorScheme.tertiary,
                Icons.inventory,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                context,
                'Tamamlanan',
                '$purchasedProducts/$totalProducts',
                theme.colorScheme.tertiary,
                Icons.check_circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Kategori Dağılımı', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        ..._buildCategoryBreakdown(context, categoryStats, categoryProvider),
      ],
    );
  }

  List<Widget> _buildCategoryBreakdown(
    BuildContext context,
    Map<String, int> categoryStats,
    CategoryProvider categoryProvider,
  ) {
    final theme = Theme.of(context);
    final total = categoryStats.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return [const Text('Kategori verisi yok')];

    final entries = categoryStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final allCats = categoryProvider.allCategories;

    return entries.map((e) {
      final id = e.key;
      final count = e.value;

      // Prefer dynamic/custom categories; fall back to defaults; finally derive
      CategoryModel? found;
      try {
        found = allCats.firstWhere((c) => c.id == id);
      } catch (_) {
        found = null;
      }

      final category = found ?? _deriveCategory(id);
      final percent = total > 0 ? count / total : 0.0;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(category.icon, color: category.color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(category.displayName),
                      Text('$count ürün'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percent,
                    minHeight: 8,
                    backgroundColor: theme.dividerColor,
                    color: category.color,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  CategoryModel _deriveCategory(String id) {
    // If id matches a known default, use it; else create a derived custom-looking category
    final defaults = CategoryModel.defaultCategories;
    try {
      final def = defaults.firstWhere((c) => c.id == id);
      return def;
    } catch (_) {
      return CategoryModel(
        id: id,
        name: id,
        displayName: _humanizeId(id),
        icon: Icons.category,
        color: CategoryModel.colorFromString(id),
        sortOrder: 1000,
        isCustom: true,
      );
    }
  }

  String _humanizeId(String id) {
    final s = id.replaceAll('-', ' ').replaceAll('_', ' ');
    if (s.isEmpty) return 'Diğer';
    return s[0].toUpperCase() + s.substring(1);
  }

  Widget _metricCard(
    BuildContext context,
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bool isPrimary = color.toARGB32() == cs.primary.toARGB32();
    final bool isSecondary = color.toARGB32() == cs.secondary.toARGB32();
    final bool isTertiary = color.toARGB32() == cs.tertiary.toARGB32();

    final Color backgroundColor = isPrimary
        ? cs.primaryContainer
        : isSecondary
            ? cs.secondaryContainer
            : isTertiary
                ? cs.tertiaryContainer
                : color.withValues(alpha: 0.12);

    final Color borderColor = isPrimary
        ? cs.primary
        : isSecondary
            ? cs.secondary
            : isTertiary
                ? cs.tertiary
                : color.withValues(alpha: 0.35);

    final Color textColor = isPrimary
        ? cs.onPrimaryContainer
        : isSecondary
            ? cs.onSecondaryContainer
            : isTertiary
                ? cs.onTertiaryContainer
                : cs.onSurface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: theme.textTheme.bodySmall?.copyWith(color: textColor)),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
