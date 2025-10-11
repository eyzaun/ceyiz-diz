import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/trousseau_provider.dart';
import '../../widgets/common/icon_color_picker.dart';

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
    final categoryProvider = context.watch<CategoryProvider>();
    final trousseauProvider = context.watch<TrousseauProvider>();
    final trousseau = trousseauProvider.getTrousseauById(widget.trousseauId);
    final canEdit = trousseau?.canEdit(trousseauProvider.currentUserId ?? '') ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Yönetimi'),
        actions: [
          if (canEdit)
            IconButton(
              tooltip: 'Yeni Kategori',
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
                    'Varsayılan Kategoriler',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                ...categoryProvider.defaultCategories.map((c) => _tile(
                      context,
                      c.displayName,
                      c,
                      canEdit: false,
                    )),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Text(
                    'Özel Kategoriler',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (categoryProvider.customCategories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Henüz özel kategori yok. Sağ üstten ekleyebilirsiniz.',
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
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: c.color.withValues(alpha: 0.15),
          child: Icon(c.icon, color: c.color),
        ),
        title: Text(title),
        subtitle: Text(c.isCustom ? 'Özel' : 'Varsayılan'),
        trailing: canEdit && c.isCustom
            ? Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    tooltip: 'Yeniden Adlandır',
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      await _promptRename(context, c.id, title);
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
                        await provider.removeCustom(c.id);
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
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    IconData selIcon = Icons.category;
    Color selColor = const Color(0xFF607D8B);
    final ok = await showDialog<bool>(
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
                    if (provider.allCategories.any((c) => c.displayName.toLowerCase() == v.trim().toLowerCase())) {
                      return 'Bu ad kullanılıyor';
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
                        label: const Text('Sembol ve Renk Seç'),
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
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final name = controller.text.trim();
                final id = _slugify(name, provider);
                final res = await provider.addCustom(id, name, icon: selIcon, color: selColor);
                if (!ctx.mounted) return;
                Navigator.pop(ctx, res);
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
    if (ok == true && mounted) setState(() {});
  }

  Future<void> _promptRename(BuildContext context, String id, String current) async {
    final controller = TextEditingController(text: current);
    final formKey = GlobalKey<FormState>();
    final provider = context.read<CategoryProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kategori Yeniden Adlandır'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Yeni ad'),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ad gerekli';
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
              final res = await provider.renameCustom(id, name);
              if (!ctx.mounted) return;
              Navigator.pop(ctx, res);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) setState(() {});
  }

  Future<bool> _confirmDelete(BuildContext context, String name) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kategoriyi Sil'),
        content: Text('"$name" kategorisini silmek istediğinize emin misiniz? Ürünler silinmez; kategori görünümü Diğer olabilir.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil')),
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
