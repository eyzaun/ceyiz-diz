import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/image_picker_widget.dart';
import '../../providers/category_provider.dart';
import '../../providers/trousseau_provider.dart';
import '../../widgets/common/icon_color_picker.dart';

class EditProductScreen extends StatefulWidget {
  final String trousseauId;
  final String productId;

  const EditProductScreen({
    super.key,
    required this.trousseauId,
    required this.productId,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _linkController;
  late TextEditingController _quantityController;
  late TextEditingController _notesController;
  
  String _selectedCategory = 'other';
  List<XFile> _selectedImages = [];
  List<String> _existingImages = [];
  bool _isLoading = false;
  bool _isPurchased = false;

  @override
  void initState() {
    super.initState();
    final product = Provider.of<ProductProvider>(context, listen: false)
        .getProductById(widget.productId);
    
    if (product != null) {
      _nameController = TextEditingController(text: product.name);
      _descriptionController = TextEditingController(text: product.description);
      _priceController = TextEditingController(text: product.price.toString());
      _linkController = TextEditingController(text: product.link);
      _quantityController = TextEditingController(text: product.quantity.toString());
      _notesController = TextEditingController(text: product.notes);
      _selectedCategory = product.category;
      _existingImages = product.images;
      _isPurchased = product.isPurchased;
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _priceController = TextEditingController();
      _linkController = TextEditingController();
      _quantityController = TextEditingController();
      _notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _linkController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final success = await productProvider.updateProduct(
      productId: widget.productId,
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text),
      category: _selectedCategory,
      newImageFiles: _selectedImages,
      existingImages: _existingImages,
      link: _linkController.text,
      quantity: int.parse(_quantityController.text),
      notes: _notesController.text,
      isPurchased: _isPurchased,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ürün başarıyla güncellendi'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(productProvider.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    if (categoryProvider.currentTrousseauId != widget.trousseauId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final trProv = Provider.of<TrousseauProvider>(context, listen: false);
          Provider.of<CategoryProvider>(context, listen: false)
              .bind(widget.trousseauId, userId: trProv.currentUserId ?? '');
        }
      });
    }
    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Ürün güncelleniyor...',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ürünü Düzenle'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ImagePickerWidget(
                  selectedImages: _selectedImages,
                  onImagesSelected: (images) {
                    setState(() {
                      _selectedImages = images;
                    });
                  },
                  maxImages: 5,
                ),
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Ürün Adı',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ürün adı gereklidir';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    prefixIcon: Icon(Icons.description_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Fiyat (₺)',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Fiyat gereklidir';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Geçerli bir fiyat girin';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Adet',
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Gerekli';
                          }
                          final quantity = int.tryParse(value);
                          if (quantity == null || quantity < 1) {
                            return 'Geçersiz';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: [
                    ...categoryProvider.allCategories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Row(
                          children: [
                            Icon(category.icon, size: 20, color: category.color),
                            const SizedBox(width: 8),
                            Text(category.displayName),
                          ],
                        ),
                      );
                    }),
                    const DropdownMenuItem(
                      value: '__add_new__',
                      child: Row(
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: 8),
                          Text('Yeni kategori ekle...'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) async {
                    if (value == '__add_new__') {
                      await _promptAddQuickCategory(context, categoryProvider);
                    } else if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _linkController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Ürün Linki',
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notlar',
                    prefixIcon: Icon(Icons.note_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                
                SwitchListTile(
                  title: const Text('Ürün Alındı'),
                  subtitle: const Text('Bu ürün satın alındı mı?'),
                  value: _isPurchased,
                  onChanged: (value) {
                    setState(() {
                      _isPurchased = value;
                    });
                  },
                ),
                const SizedBox(height: 32),
                
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _updateProduct,
                    child: const Text('Güncelle'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _promptAddQuickCategory(BuildContext context, CategoryProvider provider) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    IconData selIcon = Icons.category;
    Color selColor = const Color(0xFF607D8B);
    final result = await showDialog<String>(
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
                            setLocalState(() { selIcon = res.icon; selColor = res.color; });
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
            TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Vazgeç')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final name = controller.text.trim();
                String id = name
                    .toLowerCase()
                    .replaceAll(RegExp(r'[^a-z0-9ğüşöçı\s-]', caseSensitive: false), '')
                    .replaceAll(RegExp(r'\s+'), '-');
                if (id.isEmpty) id = 'kategori';
                var base = id;
                int i = 1;
                while (provider.allCategories.any((c) => c.displayName.toLowerCase() == id.toLowerCase())) {
                  id = '$base-$i';
                  i++;
                }
                final ok = await provider.addCustom(id, name, icon: selIcon, color: selColor);
                if (!ctx.mounted) return;
                if (ok) {
                  final created = provider.allCategories.firstWhere(
                    (c) => c.displayName.toLowerCase() == name.toLowerCase(),
                    orElse: () => provider.getById('other'),
                  );
                  Navigator.pop(ctx, created.id);
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedCategory = result;
      });
    }
  }
}