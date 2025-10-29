import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/trousseau_provider.dart';
import '../../widgets/common/icon_color_picker.dart';
import '../../../l10n/generated/app_localizations.dart';

class CategoryManagementScreen extends StatefulWidget {
  final String trousseauId;

  const CategoryManagementScreen({super.key, required this.trousseauId});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
  final trProv = context.read<TrousseauProvider>();
  context.read<CategoryProvider>().bind(widget.trousseauId, userId: trProv.currentUserId ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categoryProvider = context.watch<CategoryProvider>();
    final trousseauProvider = context.watch<TrousseauProvider>();
    final trousseau = trousseauProvider.getTrousseauById(widget.trousseauId);
    final canEdit = trousseau?.canEdit(trousseauProvider.currentUserId ?? '') ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.categoryManagement ?? 'Category Management'),
        actions: [
          if (canEdit)
            IconButton(
              tooltip: l10n?.newCategory ?? 'New Category',
              icon: const Icon(Icons.add),
              onPressed: () async {
                await _promptAddCategory(context, categoryProvider);
              },
            ),
        ],
      ),
      body: categoryProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Text(
                    l10n?.defaultCategories ?? 'Default Categories',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                ...categoryProvider.defaultCategories.map((c) => _tile(
                      context,
                      c.displayName,
                      c,
                      canEdit: canEdit,
                    )),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Text(
                    l10n?.customCategories ?? 'Custom Categories',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (categoryProvider.customCategories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      l10n?.noCustomCategoriesYet ?? 'No custom categories yet. You can add them from the top right.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ...categoryProvider.customCategories.map((c) => _tile(
                      context,
                      c.displayName,
                      c,
                      canEdit: canEdit,
                    )),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _tile(BuildContext context, String title, dynamic c, {required bool canEdit}) {
    final l10n = AppLocalizations.of(context);
    
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: c.color.withValues(alpha: 0.15),
          child: Icon(c.icon, color: c.color),
        ),
        title: Text(title),
        subtitle: Text(c.isCustom ? (l10n?.custom ?? 'Custom') : (l10n?.defaultText ?? 'Default')),
        trailing: canEdit
            ? Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    tooltip: l10n?.edit ?? 'Edit',
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      await _promptEdit(context, c);
                    },
                  ),
                  IconButton(
                    tooltip: 'Sil',
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Avoid using BuildContext after an await
                      final provider = context.read<CategoryProvider>();
                      final ok = await _confirmDelete(context, title);
                      if (!mounted) return;
                      if (ok) {
                        await provider.removeCategory(c.id);
                      }
                    },
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Future<void> _promptAddCategory(BuildContext context, CategoryProvider provider) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    IconData selIcon = Icons.category;
    Color selColor = const Color(0xFF607D8B);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          title: Text(l10n?.newCategory ?? 'New Category'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: controller,
                  decoration: InputDecoration(hintText: l10n?.categoryName ?? 'Category name'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n?.nameRequired ?? 'Name required';
                    if (provider.allCategories.any((c) => c.displayName.toLowerCase() == v.trim().toLowerCase())) {
                      return l10n?.nameAlreadyUsed ?? 'This name is already used';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(backgroundColor: selColor.withValues(alpha: 0.15), child: Icon(selIcon, color: selColor)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.palette_outlined),
                        label: Text(l10n?.selectSymbolAndColor ?? 'Select Symbol and Color'),
                        onPressed: () async {
                          final res = await IconColorPicker.pick(context, icon: selIcon, color: selColor);
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
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n?.giveUp ?? 'Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final name = controller.text.trim();
                final id = _slugify(name, provider);
                final res = await provider.addCustom(id, name, icon: selIcon, color: selColor);
                if (!ctx.mounted) return;
                Navigator.pop(ctx, res);
              },
              child: Text(l10n?.add ?? 'Add'),
            ),
          ],
        ),
      ),
    );
    if (ok == true && mounted) setState(() {});
  }

  Future<void> _promptEdit(BuildContext context, dynamic category) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: category.displayName);
    final formKey = GlobalKey<FormState>();
    final provider = context.read<CategoryProvider>();
    IconData selIcon = category.icon;
    Color selColor = category.color;
    
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          title: Text(l10n?.editCategory ?? 'Edit Category'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: l10n?.categoryName ?? 'Category Name',
                    hintText: l10n?.enterCategoryName ?? 'Enter category name',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n?.nameRequired ?? 'Name required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: selColor.withValues(alpha: 0.15),
                      child: Icon(selIcon, color: selColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.palette_outlined),
                        label: Text(l10n?.changeSymbolAndColor ?? 'Change Symbol and Color'),
                        onPressed: () async {
                          final res = await IconColorPicker.pick(
                            context,
                            icon: selIcon,
                            color: selColor,
                          );
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
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n?.giveUp ?? 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final name = controller.text.trim();
                final res = await provider.updateCategory(
                  category.id,
                  name: name,
                  icon: selIcon,
                  color: selColor,
                );
                if (!ctx.mounted) return;
                Navigator.pop(ctx, res);
              },
              child: Text(l10n?.save ?? 'Save'),
            ),
          ],
        ),
      ),
    );
    if (ok == true && mounted) setState(() {});
  }

  Future<bool> _confirmDelete(BuildContext context, String name) async {
    final l10n = AppLocalizations.of(context);
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.deleteCategory ?? 'Delete Category'),
        content: Text(l10n?.deleteCategoryConfirm(name) ?? 'Are you sure you want to delete the "$name" category? Products will not be deleted; category view may be Other.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n?.cancel ?? 'Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n?.delete ?? 'Delete')),
        ],
      ),
    );
    return res ?? false;
  }

  String _slugify(String name, CategoryProvider provider) {
    String slug = name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9ğüşöçı\s-]', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), '-');
    if (slug.isEmpty) slug = 'kategori';
    final base = slug;
    int i = 1;
    while (provider.allCategories.any((c) => c.displayName.toLowerCase() == slug.toLowerCase())) {
      slug = '$base-$i';
      i++;
    }
    return slug;
  }
}
