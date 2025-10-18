library;

/// Edit Product Screen - Yeni Tasarım Sistemi v2.0
///
/// TASARIM KURALLARI:
/// ✅ Jakob Yasası: Standart edit form layout
/// ✅ Fitts Yasası: Primary button 56dp, full width, tüm input'lar 56dp height
/// ✅ Hick Yasası: 1 primary (Güncelle), 2 secondary (İptal, Sil)
/// ✅ Miller Yasası: 8 alan → 2 bölüme ayrılmış (Temel Bilgiler + Ek Bilgiler)
/// ✅ Gestalt: Form bölümleri gruplanmış, ilgili alanlar yakın, danger action ayrı

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/design_tokens.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/trousseau_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/image_picker_widget.dart';
import '../../widgets/common/icon_color_picker.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';
import '../../../core/utils/currency_formatter.dart';

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
  late TextEditingController _link2Controller;
  late TextEditingController _link3Controller;
  late TextEditingController _quantityController;

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
      _priceController = TextEditingController(text: CurrencyFormatter.format(product.price));
      _linkController = TextEditingController(text: product.link);
      _link2Controller = TextEditingController(text: product.link2);
      _link3Controller = TextEditingController(text: product.link3);
      _quantityController = TextEditingController(text: product.quantity.toString());
      _selectedCategory = product.category;
      _existingImages = product.images;
      _isPurchased = product.isPurchased;
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _priceController = TextEditingController();
      _linkController = TextEditingController();
      _link2Controller = TextEditingController();
      _link3Controller = TextEditingController();
      _quantityController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _linkController.dispose();
    _link2Controller.dispose();
    _link3Controller.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VALIDATION
  // ═══════════════════════════════════════════════════════════════════════════

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ürün adı gereklidir';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Fiyat gereklidir';
    }
    final price = CurrencyFormatter.parse(value);
    if (price == null || price <= 0) {
      return 'Geçerli bir fiyat girin';
    }
    return null;
  }

  String? _validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Gerekli';
    }
    final quantity = int.tryParse(value);
    if (quantity == null || quantity < 1) {
      return 'Geçersiz';
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UPDATE PRODUCT HANDLER
  // ═══════════════════════════════════════════════════════════════════════════

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
      price: CurrencyFormatter.parse(_priceController.text),
      category: _selectedCategory,
      newImageFiles: _selectedImages,
      existingImages: _existingImages,
      link: _linkController.text.trim(),
      link2: _link2Controller.text.trim(),
      link3: _link3Controller.text.trim(),
      quantity: int.parse(_quantityController.text),
      isPurchased: _isPurchased,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ürün başarıyla güncellendi'),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMD,
          ),
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(productProvider.errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMD,
          ),
        ),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DELETE PRODUCT HANDLER
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _deleteProduct() async {
    final theme = Theme.of(context);

    // Confirmation Dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ürünü Sil'),
        content: const Text(
          'Bu ürünü silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          AppTextButton(
            label: 'Vazgeç',
            onPressed: () => Navigator.pop(ctx, false),
          ),
          AppDangerButton(
            label: 'Sil',
            icon: Icons.delete,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final success = await productProvider.deleteProduct(widget.productId);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ürün başarıyla silindi'),
          backgroundColor: theme.colorScheme.tertiary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMD,
          ),
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(productProvider.errorMessage),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMD,
          ),
        ),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // QUICK ADD CATEGORY DIALOG
  // ═══════════════════════════════════════════════════════════════════════════

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
                    CircleAvatar(
                      backgroundColor: selColor.withValues(alpha: 0.15),
                      child: Icon(selIcon, color: selColor),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppSecondaryButton(
                        label: 'Sembol ve Renk Seç',
                        icon: Icons.palette_outlined,
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
            AppTextButton(
              label: 'Vazgeç',
              onPressed: () => Navigator.pop(ctx, null),
            ),
            AppPrimaryButton(
              label: 'Ekle',
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

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    // Ensure selected category exists in current categories
    if (categoryProvider.allCategories.isNotEmpty &&
        !categoryProvider.allCategories.any((c) => c.id == _selectedCategory)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedCategory = categoryProvider.allCategories.first.id;
          });
        }
      });
    }

    // Ensure bound (idempotent)
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
      message: 'İşlem yapılıyor...',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ürünü Düzenle'),
          // FITTS YASASI: Back button 48x48 (default IconButton)
          leading: AppIconButton(
            icon: Icons.arrow_back,
            onPressed: () => context.pop(),
            tooltip: 'Geri',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: context.safePaddingHorizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: AppBreakpoints.maxFormWidth,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppSpacing.md.verticalSpace,

                    // ─────────────────────────────────────────────────────
                    // EXISTING IMAGES SECTION
                    // ─────────────────────────────────────────────────────
                    if (_existingImages.isNotEmpty) ...[
                      Text(
                        'Mevcut Fotoğraflar',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: AppTypography.bold,
                          fontSize: AppTypography.sizeLG,
                        ),
                      ),
                      AppSpacing.sm.verticalSpace,
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: _existingImages.map((imageUrl) {
                          return Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: AppRadius.radiusMD,
                                  border: Border.all(
                                    color: theme.colorScheme.outline,
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: AppRadius.radiusMD,
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(Icons.error_outline, color: Colors.red),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // FITTS YASASI: Delete button 48x48 touch area
                              Positioned(
                                top: 0,
                                right: 0,
                                child: AppIconButton(
                                  icon: Icons.close,
                                  onPressed: () {
                                    setState(() {
                                      _existingImages.remove(imageUrl);
                                    });
                                  },
                                  tooltip: 'Kaldır',
                                  backgroundColor: theme.colorScheme.error,
                                  iconColor: Colors.white,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                      AppSpacing.lg.verticalSpace,
                    ],

                    // ─────────────────────────────────────────────────────
                    // NEW IMAGES SECTION
                    // ─────────────────────────────────────────────────────
                    if (_existingImages.length + _selectedImages.length < 5) ...[
                      Text(
                        'Yeni Fotoğraf Ekle',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: AppTypography.bold,
                          fontSize: AppTypography.sizeLG,
                        ),
                      ),
                      AppSpacing.sm.verticalSpace,
                    ],
                    ImagePickerWidget(
                      selectedImages: _selectedImages,
                      onImagesSelected: (images) {
                        setState(() {
                          _selectedImages = images;
                        });
                      },
                      maxImages: 5 - _existingImages.length,
                    ),

                    AppSpacing.xl.verticalSpace,

                    // ─────────────────────────────────────────────────────
                    // FORM BÖLÜM 1: TEMEL BİLGİLER
                    // Miller Yasası: 4 alan (Ad, Kategori, Fiyat+Adet)
                    // ─────────────────────────────────────────────────────
                    AppFormSection(
                      title: 'Temel Bilgiler',
                      children: [
                        // Product Name
                        AppTextInput(
                          label: 'Ürün Adı',
                          controller: _nameController,
                          prefixIcon: const Icon(Icons.label_outline),
                          textInputAction: TextInputAction.next,
                          validator: _validateName,
                        ),

                        // Category Dropdown
                        AppDropdown<String>(
                          label: 'Kategori',
                          value: _selectedCategory,
                          prefixIcon: const Icon(Icons.category_outlined),
                          items: [
                            ...categoryProvider.allCategories.map((category) {
                              return DropdownMenuItem(
                                value: category.id,
                                child: Row(
                                  children: [
                                    Icon(category.icon, size: 20, color: category.color),
                                    AppSpacing.sm.horizontalSpace,
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

                        // Price and Quantity Row
                        // GESTALT: İlgili alanlar yakın (fiyat + adet)
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: AppTextInput(
                                label: 'Fiyat (₺)',
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                prefixIcon: const Icon(Icons.attach_money),
                                inputFormatters: [CurrencyInputFormatter()],
                                validator: _validatePrice,
                              ),
                            ),
                            AppSpacing.md.horizontalSpace,
                            Expanded(
                              child: AppTextInput(
                                label: 'Adet',
                                controller: _quantityController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                prefixIcon: const Icon(Icons.numbers),
                                validator: _validateQuantity,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    AppSpacing.xl.verticalSpace,

                    // ─────────────────────────────────────────────────────
                    // FORM BÖLÜM 2: EK BİLGİLER
                    // Miller Yasası: 3 alan (Açıklama, Link, Satın Alındı)
                    // ─────────────────────────────────────────────────────
                    AppFormSection(
                      title: 'Ek Bilgiler',
                      subtitle: 'Opsiyonel',
                      children: [
                        // Description
                        AppTextInput(
                          label: 'Açıklama',
                          controller: _descriptionController,
                          maxLines: 3,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.description_outlined),
                        ),

                        // Product Link
                        AppTextInput(
                          label: 'Ürün Linki 1',
                          controller: _linkController,
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.link),
                        ),

                        // Product Link 2
                        AppTextInput(
                          label: 'Ürün Linki 2',
                          controller: _link2Controller,
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.link),
                        ),

                        // Product Link 3
                        AppTextInput(
                          label: 'Ürün Linki 3',
                          controller: _link3Controller,
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.link),
                        ),

                        // Purchased Status
                        // FITTS YASASI: SwitchListTile has large touch area
                        SwitchListTile(
                          title: const Text('Ürün Alındı'),
                          subtitle: const Text('Bu ürün satın alındı mı?'),
                          value: _isPurchased,
                          onChanged: (value) {
                            setState(() {
                              _isPurchased = value;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),

                    AppSpacing.xl2.verticalSpace,

                    // ─────────────────────────────────────────────────────
                    // PRIMARY ACTION - HICK YASASI: 1 primary button
                    // FITTS YASASI: 56dp height, full width
                    // ─────────────────────────────────────────────────────
                    AppButtonGroup(
                      primaryButton: AppPrimaryButton(
                        label: 'Güncelle',
                        icon: Icons.save,
                        isFullWidth: true,
                        onPressed: _updateProduct,
                        isLoading: _isLoading,
                      ),
                      secondaryButton: AppSecondaryButton(
                        label: 'İptal',
                        onPressed: () => context.pop(),
                      ),
                    ),

                    AppSpacing.xl.verticalSpace,

                    // ─────────────────────────────────────────────────────
                    // DANGER ZONE - GESTALT: Görsel olarak ayrı (kırmızı)
                    // ─────────────────────────────────────────────────────
                    Divider(
                      height: AppSpacing.xl2,
                      thickness: 1,
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),

                    AppDangerButton(
                      label: 'Ürünü Sil',
                      icon: Icons.delete_forever,
                      isOutlined: true,
                      onPressed: _deleteProduct,
                    ),

                    AppSpacing.xl.verticalSpace,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
