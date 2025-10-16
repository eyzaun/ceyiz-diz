/// Add Product Screen - Yeni Tasarım Sistemi v2.0
///
/// TASARIM KURALLARI:
/// ✅ Jakob Yasası: Standart form layout
/// ✅ Fitts Yasası: Primary button 56dp, full width, tüm input'lar 56dp height
/// ✅ Hick Yasası: 1 primary action (Ürün Ekle), 1 secondary (İptal - AppBar back)
/// ✅ Miller Yasası: 8 alan → 2 bölüme ayrılmış (Temel Bilgiler 4 alan + Ek Bilgiler 4 alan)
/// ✅ Gestalt: Form bölümleri gruplanmış, ilgili alanlar yakın (fiyat+adet)

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

class AddProductScreen extends StatefulWidget {
  final String trousseauId;

  const AddProductScreen({
    super.key,
    required this.trousseauId,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _linkController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  String _selectedCategory = 'other';
  List<XFile> _selectedImages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _linkController.dispose();
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
    if (value == null || value.trim().isEmpty) return null; // Opsiyonel
    final price = CurrencyFormatter.parse(value.trim());
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
  // ADD PRODUCT HANDLER
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final success = await productProvider.addProduct(
      trousseauId: widget.trousseauId,
      name: _nameController.text,
      description: _descriptionController.text,
      price: CurrencyFormatter.parse(_priceController.text.trim()) ?? 0.0,
      category: _selectedCategory,
      imageFiles: _selectedImages,
      link: _linkController.text,
      quantity: int.parse(_quantityController.text),
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ürün başarıyla eklendi'),
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
      message: 'Ürün ekleniyor...',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ürün Ekle'),
          // FITTS YASASI: Back button 48x48 (default IconButton)
          leading: AppIconButton(
            icon: Icons.arrow_back,
            onPressed: () => context.pop(),
            tooltip: 'Geri',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: context.safePaddingHorizontal.horizontalSpace,
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
                    // IMAGE PICKER
                    // ─────────────────────────────────────────────────────
                    ImagePickerWidget(
                      selectedImages: _selectedImages,
                      onImagesSelected: (images) {
                        setState(() {
                          _selectedImages = images;
                        });
                      },
                      maxImages: 5,
                    ),

                    AppSpacing.xl.verticalSpace,

                    // ─────────────────────────────────────────────────────
                    // FORM BÖLÜM 1: TEMEL BİLGİLER
                    // Miller Yasası: 4 alan (Ad, Kategori, Fiyat+Adet row)
                    // ─────────────────────────────────────────────────────
                    AppFormSection(
                      title: 'Temel Bilgiler',
                      children: [
                        // Product Name
                        AppTextInput(
                          label: 'Ürün Adı',
                          hint: 'Örn: Çatal Bıçak Takımı',
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
                          onChanged: (value) {
                            if (value == '__add_new__') {
                              _promptAddQuickCategory(context, categoryProvider);
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
                    // Miller Yasası: 2 alan (Açıklama, Link)
                    // ─────────────────────────────────────────────────────
                    AppFormSection(
                      title: 'Ek Bilgiler',
                      subtitle: 'Opsiyonel',
                      children: [
                        // Description
                        AppTextInput(
                          label: 'Açıklama',
                          hint: 'Ürün hakkında detaylar',
                          controller: _descriptionController,
                          maxLines: 3,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.description_outlined),
                        ),

                        // Product Link
                        AppTextInput(
                          label: 'Ürün Linki',
                          hint: 'https://...',
                          controller: _linkController,
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.link),
                        ),
                      ],
                    ),

                    AppSpacing.xl2.verticalSpace,

                    // ─────────────────────────────────────────────────────
                    // PRIMARY ACTION - HICK YASASI: Sadece 1 primary button
                    // FITTS YASASI: 56dp height, full width
                    // ─────────────────────────────────────────────────────
                    AppButtonGroup(
                      primaryButton: AppPrimaryButton(
                        label: 'Ürün Ekle',
                        icon: Icons.add_shopping_cart,
                        isFullWidth: true,
                        onPressed: _addProduct,
                        isLoading: _isLoading,
                      ),
                      secondaryButton: AppSecondaryButton(
                        label: 'İptal',
                        onPressed: () => context.pop(),
                      ),
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
