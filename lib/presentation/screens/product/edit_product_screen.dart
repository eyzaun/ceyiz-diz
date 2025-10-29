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
import 'package:cached_network_image/cached_network_image.dart';
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
import '../../../l10n/generated/app_localizations.dart';

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
      // Fiyat 0 ise boş bırak (opsiyonel), değilse formatla
      _priceController = TextEditingController(
        text: product.price > 0 ? CurrencyFormatter.format(product.price) : '',
      );
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

  String? _validateName(String? value, AppLocalizations? l10n) {
    if (value == null || value.isEmpty) {
      return l10n?.productNameRequired ?? 'Product name is required';
    }
    return null;
  }

  String? _validatePrice(String? value, AppLocalizations? l10n) {
    if (value == null || value.trim().isEmpty) return null; // Opsiyonel
    final price = CurrencyFormatter.parse(value.trim());
    if (price == null || price <= 0) {
      return l10n?.enterValidPrice ?? 'Enter a valid price';
    }
    return null;
  }

  String? _validateQuantity(String? value, AppLocalizations? l10n) {
    if (value == null || value.isEmpty) {
      return l10n?.required ?? 'Required';
    }
    final quantity = int.tryParse(value);
    if (quantity == null || quantity < 1) {
      return l10n?.invalid ?? 'Invalid';
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // IMAGE OPTIMIZATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// 🚀 Firebase Storage Resize Extension thumbnail URL'ini döndürür
  String _getOptimizedImageUrl(String originalUrl, String size) {
    if (originalUrl.isEmpty) return originalUrl;
    
    try {
      final uri = Uri.parse(originalUrl);
      
      // Firebase Storage URL değilse direkt döndür
      if (!uri.host.contains('firebasestorage.googleapis.com')) {
        return originalUrl;
      }
      
      // Path'i decode et
      final pathSegments = uri.pathSegments;
      if (pathSegments.length < 4) return originalUrl;
      
      final encodedPath = pathSegments[3];
      final decodedPath = Uri.decodeComponent(encodedPath);
      
      // Dosya adı ve uzantısını ayır
      final lastSlash = decodedPath.lastIndexOf('/');
      final fileName = lastSlash >= 0 ? decodedPath.substring(lastSlash + 1) : decodedPath;
      final lastDot = fileName.lastIndexOf('.');
      
      if (lastDot < 0) return originalUrl;
      
      final nameWithoutExt = fileName.substring(0, lastDot);
      final extension = fileName.substring(lastDot);
      
      // Thumbnail dosya adı oluştur (Firebase Extension pattern)
      final thumbnailFileName = '${nameWithoutExt}_thumb@$size$extension';
      
      // Path'i yeniden oluştur
      final directory = lastSlash >= 0 ? decodedPath.substring(0, lastSlash + 1) : '';
      final thumbnailPath = '$directory$thumbnailFileName';
      
      // Encode ve URL'i yeniden oluştur
      final encodedThumbnailPath = Uri.encodeComponent(thumbnailPath);
      
      // Token'ı koru
      final token = uri.queryParameters['token'];
      final queryParams = token != null ? '?alt=media&token=$token' : '?alt=media';
      
      return 'https://firebasestorage.googleapis.com/v0/b/${pathSegments[1]}/o/$encodedThumbnailPath$queryParams';
    } catch (e) {
      // Hata durumunda original URL döndür
      return originalUrl;
    }
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
    
    // Fiyat opsiyonel - boş ise 0 olarak kaydet
    final priceText = _priceController.text.trim();
    final price = priceText.isEmpty ? 0.0 : (CurrencyFormatter.parse(priceText) ?? 0.0);
    
    final success = await productProvider.updateProduct(
      productId: widget.productId,
      name: _nameController.text,
      description: _descriptionController.text,
      price: price,
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
    
    final l10n = AppLocalizations.of(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.productUpdatedSuccessfully ?? 'Product updated successfully'),
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
    final l10n = AppLocalizations.of(context);

    // Confirmation Dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.deleteProduct ?? 'Delete Product'),
        content: Text(
          l10n?.deleteProductWarning ?? 'Are you sure you want to delete this product? This action cannot be undone.',
        ),
        actions: [
          AppTextButton(
            label: l10n?.giveUp ?? 'Cancel',
            onPressed: () => Navigator.pop(ctx, false),
          ),
          AppDangerButton(
            label: l10n?.delete ?? 'Delete',
            icon: Icons.delete,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final success = await productProvider.deleteProduct(widget.productId);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;
    
    final l10nMsg = AppLocalizations.of(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10nMsg?.productDeletedSuccessfully ?? 'Product deleted successfully'),
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
    final l10n = AppLocalizations.of(context);
    IconData selIcon = Icons.category;
    Color selColor = const Color(0xFF607D8B);

    final result = await showDialog<String>(
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
                    CircleAvatar(
                      backgroundColor: selColor.withValues(alpha: 0.15),
                      child: Icon(selIcon, color: selColor),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppSecondaryButton(
                        label: l10n?.selectSymbolAndColor ?? 'Select Symbol and Color',
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
              label: l10n?.giveUp ?? 'Cancel',
              onPressed: () => Navigator.pop(ctx, null),
            ),
            AppPrimaryButton(
              label: l10n?.add ?? 'Add',
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
      message: l10n?.processing ?? 'Processing...',
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n?.editProduct ?? 'Edit Product'),
          // FITTS YASASI: Back button 48x48 (default IconButton)
          leading: AppIconButton(
            icon: Icons.arrow_back,
            onPressed: () => context.pop(),
            tooltip: l10n?.back ?? 'Back',
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
                        l10n?.existingPhotos ?? 'Existing Photos',
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
                                  // 🚀 OPTIMIZATION: CachedNetworkImage ile 200x200 thumbnail
                                  child: CachedNetworkImage(
                                    imageUrl: _getOptimizedImageUrl(imageUrl, '200x200'),
                                    fit: BoxFit.cover,
                                    memCacheWidth: 200,
                                    memCacheHeight: 200,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    errorWidget: (context, url, error) => const Center(
                                      child: Icon(Icons.error_outline, color: Colors.red),
                                    ),
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
                        l10n?.addNewPhoto ?? 'Add New Photo',
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
                      title: l10n?.basicInformation ?? 'Basic Information',
                      children: [
                        // Product Name
                        AppTextInput(
                          label: l10n?.productName ?? 'Product Name',
                          controller: _nameController,
                          prefixIcon: const Icon(Icons.label_outline),
                          textInputAction: TextInputAction.next,
                          validator: (value) => _validateName(value, l10n),
                        ),

                        // Category Dropdown
                        AppDropdown<String>(
                          label: l10n?.category ?? 'Category',
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
                                  const Icon(Icons.add),
                                  const SizedBox(width: 8),
                                  Text(l10n?.addNewCategory ?? 'Add new category...'),
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
                                label: l10n?.price ?? 'Price (₺)',
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                prefixIcon: const Icon(Icons.attach_money),
                                inputFormatters: [CurrencyInputFormatter()],
                                validator: (value) => _validatePrice(value, l10n),
                              ),
                            ),
                            AppSpacing.md.horizontalSpace,
                            Expanded(
                              child: AppTextInput(
                                label: l10n?.quantity ?? 'Quantity',
                                controller: _quantityController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                prefixIcon: const Icon(Icons.numbers),
                                validator: (value) => _validateQuantity(value, l10n),
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
                      title: l10n?.additionalInformation ?? 'Additional Information',
                      subtitle: l10n?.optional ?? 'Optional',
                      children: [
                        // Description
                        AppTextInput(
                          label: l10n?.description ?? 'Description',
                          controller: _descriptionController,
                          maxLines: 3,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.description_outlined),
                        ),

                        // Product Link
                        AppTextInput(
                          label: l10n?.productLink ?? 'Product Link 1',
                          controller: _linkController,
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.link),
                        ),

                        // Product Link 2
                        AppTextInput(
                          label: l10n?.productLink2 ?? 'Product Link 2',
                          controller: _link2Controller,
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.link),
                        ),

                        // Product Link 3
                        AppTextInput(
                          label: l10n?.productLink3 ?? 'Product Link 3',
                          controller: _link3Controller,
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.link),
                        ),

                        // Purchased Status
                        // FITTS YASASI: SwitchListTile has large touch area
                        SwitchListTile(
                          title: Text(l10n?.productPurchased ?? 'Product Purchased'),
                          subtitle: Text(l10n?.isProductPurchased ?? 'Is this product purchased?'),
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
                        label: l10n?.update ?? 'Update',
                        icon: Icons.save,
                        isFullWidth: true,
                        onPressed: _updateProduct,
                        isLoading: _isLoading,
                      ),
                      secondaryButton: AppSecondaryButton(
                        label: l10n?.cancel ?? 'Cancel',
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
                      label: l10n?.deleteProduct ?? 'Delete Product',
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
