library;

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
import '../../../l10n/generated/app_localizations.dart';
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
  final _quantityController = TextEditingController(text: '1');

  final List<TextEditingController> _linkControllers = [TextEditingController()];

  String _selectedCategory = 'other';
  List<XFile> _selectedImages = [];
  bool _isLoading = false;
  bool _isPurchased = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    for (var controller in _linkControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addLinkField() {
    if (_linkControllers.length < 5) {
      setState(() {
        _linkControllers.add(TextEditingController());
      });
    }
  }

  void _removeLinkField(int index) {
    if (_linkControllers.length > 1) {
      setState(() {
        _linkControllers[index].dispose();
        _linkControllers.removeAt(index);
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VALIDATION
  // ═══════════════════════════════════════════════════════════════════════════

  String? _validateName(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return l10n?.productNameRequired ?? 'Ürün adı gereklidir';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) return null; // Opsiyonel
    final price = CurrencyFormatter.parse(value.trim());
    if (price == null || price <= 0) {
      return l10n?.enterValidPrice ?? 'Geçerli bir fiyat girin';
    }
    return null;
  }

  String? _validateQuantity(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return l10n?.required ?? 'Gerekli';
    }
    final quantity = int.tryParse(value);
    if (quantity == null || quantity < 1) {
      return l10n?.invalid ?? 'Geçersiz';
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
      link: _linkControllers.isNotEmpty ? _linkControllers[0].text.trim() : '',
      link2: _linkControllers.length > 1 ? _linkControllers[1].text.trim() : '',
      link3: _linkControllers.length > 2 ? _linkControllers[2].text.trim() : '',
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
    final l10n = AppLocalizations.of(context);
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
      message: l10n?.addingProduct ?? 'Ürün ekleniyor...',
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n?.addProduct ?? 'Ürün Ekle'),
          // FITTS YASASI: Back button 48x48 (default IconButton)
          leading: AppIconButton(
            icon: Icons.arrow_back,
            onPressed: () => context.pop(),
            tooltip: l10n?.back ?? 'Geri',
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
                    AppSpacing.sm.verticalSpace,

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

                    AppSpacing.lg.verticalSpace,

                    // ─────────────────────────────────────────────────────
                    // FORM BÖLÜM 1: TEMEL BİLGİLER
                    // Miller Yasası: 4 alan (Ad, Kategori, Fiyat+Adet row)
                    // ─────────────────────────────────────────────────────
                    AppFormSection(
                      title: l10n?.basicInformation ?? 'Temel Bilgiler',
                      children: [
                        // Product Name
                        AppTextInput(
                          label: l10n?.productName ?? 'Ürün Adı',
                          hint: l10n?.productNameExample ?? 'Örn: Çatal Bıçak Takımı',
                          controller: _nameController,
                          prefixIcon: const Icon(Icons.label_outline),
                          textInputAction: TextInputAction.next,
                          validator: _validateName,
                        ),

                        // Category Dropdown
                        AppDropdown<String>(
                          label: l10n?.category ?? 'Kategori',
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
                            DropdownMenuItem(
                              value: '__add_new__',
                              child: Row(
                                children: [
                                  Icon(Icons.add),
                                  SizedBox(width: 8),
                                  Text(l10n?.addNewCategory ?? 'Yeni kategori ekle...'),
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

                        // Price, Quantity, and Purchased Row
                        // GESTALT: İlgili alanlar yakın (fiyat + adet + alındı)
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: AppTextInput(
                                label: l10n?.price ?? 'Fiyat (₺)',
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
                                label: l10n?.quantity ?? 'Adet',
                                controller: _quantityController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                prefixIcon: const Icon(Icons.numbers),
                                validator: _validateQuantity,
                              ),
                            ),
                            AppSpacing.sm.horizontalSpace,
                            // Purchased Checkbox - Material 3 style, aligned with inputs
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _isPurchased = !_isPurchased;
                                  });
                                },
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _isPurchased
                                        ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                    border: Border.all(
                                      color: _isPurchased
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                                      width: _isPurchased ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isPurchased ? Icons.check_box : Icons.check_box_outline_blank,
                                        size: 20,
                                        color: _isPurchased
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        l10n?.purchased ?? 'Alındı',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: _isPurchased ? FontWeight.w600 : FontWeight.w500,
                                          color: _isPurchased
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    AppSpacing.lg.verticalSpace,

                    // ─────────────────────────────────────────────────────
                    // FORM BÖLÜM 2: EK BİLGİLER
                    // Miller Yasası: 2 alan (Açıklama, Link)
                    // ─────────────────────────────────────────────────────
                    AppFormSection(
                      title: l10n?.additionalInformation ?? 'Ek Bilgiler',
                      subtitle: l10n?.optional ?? 'Opsiyonel',
                      children: [
                        // Description
                        AppTextInput(
                          label: l10n?.description ?? 'Açıklama',
                          hint: l10n?.productDetailsHint ?? 'Ürün hakkında detaylar',
                          controller: _descriptionController,
                          maxLines: 3,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.description_outlined),
                        ),

                        // Dynamic Product Links
                        ..._linkControllers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final controller = entry.value;
                          final isLast = index == _linkControllers.length - 1;

                          // Get link label based on index
                          String linkLabel;
                          if (index == 0) {
                            linkLabel = l10n?.productLink ?? 'Ürün Linki';
                          } else if (index == 1) {
                            linkLabel = l10n?.productLink2 ?? 'Ürün Linki 2';
                          } else if (index == 2) {
                            linkLabel = l10n?.productLink3 ?? 'Ürün Linki 3';
                          } else {
                            linkLabel = '${l10n?.productLink ?? 'Ürün Linki'} ${index + 1}';
                          }

                          return Padding(
                            padding: EdgeInsets.only(bottom: index < _linkControllers.length - 1 ? AppSpacing.sm : 0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: AppTextInput(
                                    label: linkLabel,
                                    hint: 'https://...',
                                    controller: controller,
                                    keyboardType: TextInputType.url,
                                    textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
                                    prefixIcon: const Icon(Icons.link),
                                    onChanged: (value) {
                                      // Auto-add new field when typing in last field
                                      if (isLast && value.isNotEmpty && _linkControllers.length < 5) {
                                        _addLinkField();
                                      }
                                    },
                                  ),
                                ),
                                if (_linkControllers.length > 1)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8, top: 20),
                                    child: IconButton(
                                      icon: const Icon(Icons.close, size: 20),
                                      onPressed: () => _removeLinkField(index),
                                      color: Theme.of(context).colorScheme.error,
                                      style: IconButton.styleFrom(
                                        padding: const EdgeInsets.all(8),
                                        minimumSize: const Size(36, 36),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),

                    AppSpacing.lg.verticalSpace,

                    // ─────────────────────────────────────────────────────
                    // PRIMARY ACTION - HICK YASASI: Sadece 1 primary button
                    // FITTS YASASI: 56dp height, full width
                    // ─────────────────────────────────────────────────────
                    AppButtonGroup(
                      primaryButton: AppPrimaryButton(
                        label: l10n?.addProduct ?? 'Ürün Ekle',
                        icon: Icons.add_shopping_cart,
                        isFullWidth: true,
                        onPressed: _addProduct,
                        isLoading: _isLoading,
                      ),
                      secondaryButton: AppSecondaryButton(
                        label: l10n?.cancel ?? 'İptal',
                        onPressed: () => context.pop(),
                      ),
                    ),

                    AppSpacing.md.verticalSpace,
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
