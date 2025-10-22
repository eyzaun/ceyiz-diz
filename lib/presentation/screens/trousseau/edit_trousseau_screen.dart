library;

/// Edit Trousseau Screen - Yeni Tasarım Sistemi v2.0
///
/// TASARIM KURALLARI:
/// ✅ Jakob Yasası: Standart edit form layout
/// ✅ Fitts Yasası: Primary button 56dp, inputs 56dp height
/// ✅ Hick Yasası: 1 primary (Güncelle), 2 secondary (İptal, Sil)
/// ✅ Miller Yasası: 3 form alanı (Ad, Açıklama, Bütçe) - ideal
/// ✅ Gestalt: Form alanları gruplanmış, danger zone görsel olarak ayrı

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_tokens.dart';
import '../../providers/trousseau_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';
import '../../../core/utils/currency_formatter.dart';

class EditTrousseauScreen extends StatefulWidget {
  final String trousseauId;

  const EditTrousseauScreen({
    super.key,
    required this.trousseauId,
  });

  @override
  State<EditTrousseauScreen> createState() => _EditTrousseauScreenState();
}

class _EditTrousseauScreenState extends State<EditTrousseauScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _budgetController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _budgetController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trousseau = Provider.of<TrousseauProvider>(context, listen: false)
          .getTrousseauById(widget.trousseauId);
      if (mounted) {
        setState(() {
          _nameController.text = trousseau?.name ?? '';
          _descriptionController.text = trousseau?.description ?? '';
          // Bütçe 0 ise boş bırak (opsiyonel), değilse formatla
          _budgetController.text = trousseau != null && trousseau.totalBudget > 0 
              ? CurrencyFormatter.format(trousseau.totalBudget) 
              : '';
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VALIDATION
  // ═══════════════════════════════════════════════════════════════════════════

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Çeyiz adı gereklidir';
    }
    if (value.length < 3) {
      return 'En az 3 karakter olmalıdır';
    }
    return null;
  }

  String? _validateBudget(String? value) {
    if (value != null && value.isNotEmpty) {
      final budget = CurrencyFormatter.parse(value);
      if (budget == null || budget < 0) {
        return 'Geçerli bir tutar girin';
      }
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UPDATE TROUSSEAU HANDLER
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _updateTrousseau() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final trousseauProvider = Provider.of<TrousseauProvider>(context, listen: false);
    final success = await trousseauProvider.updateTrousseau(
      trousseauId: widget.trousseauId,
      name: _nameController.text,
      description: _descriptionController.text,
      totalBudget: CurrencyFormatter.parse(_budgetController.text),
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Çeyiz başarıyla güncellendi'),
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
          content: Text(trousseauProvider.errorMessage),
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
  // DELETE TROUSSEAU HANDLER
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _deleteTrousseau() async {
    final theme = Theme.of(context);
    final trousseau = Provider.of<TrousseauProvider>(context, listen: false)
        .getTrousseauById(widget.trousseauId);

    if (trousseau == null) return;

    // Confirmation Dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çeyizi Sil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${trousseau.name}" çeyizini silmek istediğinizden emin misiniz?',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            AppSpacing.md.verticalSpace,
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: AppRadius.radiusMD,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: theme.colorScheme.error,
                  ),
                  AppSpacing.sm.horizontalSpace,
                  Expanded(
                    child: Text(
                      'Bu işlem geri alınamaz! Çeyiz içindeki tüm ürünler silinecektir.',
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                        fontSize: AppTypography.sizeSM,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    final trousseauProvider = Provider.of<TrousseauProvider>(context, listen: false);
    final success = await trousseauProvider.deleteTrousseau(widget.trousseauId);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Çeyiz başarıyla silindi'),
          backgroundColor: theme.colorScheme.tertiary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMD,
          ),
        ),
      );
      // Silme sonrası kısa gecikme ile yönlendirme
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(trousseauProvider.errorMessage),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMD,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'İşlem yapılıyor...',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Çeyizi Düzenle'),
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
                    // FORM SECTION
                    // MILLER YASASI: 3 alan (ideal)
                    // ─────────────────────────────────────────────────────
                    AppFormSection(
                      title: 'Çeyiz Bilgileri',
                      children: [
                        AppTextInput(
                          label: 'Çeyiz Adı',
                          controller: _nameController,
                          prefixIcon: const Icon(Icons.label_outline),
                          textInputAction: TextInputAction.next,
                          validator: _validateName,
                        ),

                        AppTextInput(
                          label: 'Açıklama',
                          controller: _descriptionController,
                          maxLines: 3,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.description_outlined),
                        ),

                        AppTextInput(
                          label: 'Toplam Bütçe (₺)',
                          controller: _budgetController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                          inputFormatters: [CurrencyInputFormatter()],
                          validator: _validateBudget,
                        ),
                      ],
                    ),

                    AppSpacing.xl2.verticalSpace,

                    // ─────────────────────────────────────────────────────
                    // PRIMARY ACTION
                    // HICK YASASI: 1 primary + 1 secondary
                    // ─────────────────────────────────────────────────────
                    AppButtonGroup(
                      primaryButton: AppPrimaryButton(
                        label: 'Güncelle',
                        icon: Icons.save,
                        isFullWidth: true,
                        onPressed: _updateTrousseau,
                        isLoading: _isLoading,
                      ),
                      secondaryButton: AppSecondaryButton(
                        label: 'İptal',
                        onPressed: () => context.pop(),
                      ),
                    ),

                    AppSpacing.xl.verticalSpace,

                    // ─────────────────────────────────────────────────────
                    // DANGER ZONE
                    // GESTALT: Görsel olarak ayrı tehlikeli alan (kırmızı)
                    // ─────────────────────────────────────────────────────
                    Divider(
                      height: AppSpacing.xl2,
                      thickness: 1,
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),

                    Container(
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                        borderRadius: AppRadius.radiusMD,
                        border: Border.all(
                          color: theme.colorScheme.error.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: theme.colorScheme.error,
                                size: 20,
                              ),
                              AppSpacing.sm.horizontalSpace,
                              Text(
                                'Tehlikeli Alan',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontWeight: AppTypography.bold,
                                  fontSize: AppTypography.sizeLG,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.sm.verticalSpace,
                          Text(
                            'Çeyizi silmek geri alınamaz bir işlemdir. Tüm ürünler ve veriler kalıcı olarak silinecektir.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                              fontSize: AppTypography.sizeSM,
                            ),
                          ),
                          AppSpacing.md.verticalSpace,
                          AppDangerButton(
                            label: 'Çeyizi Sil',
                            icon: Icons.delete_forever,
                            isOutlined: true,
                            isFullWidth: true,
                            onPressed: _deleteTrousseau,
                          ),
                        ],
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
