library;

/// Create Trousseau Screen - Yeni Tasarım Sistemi v2.0
///
/// TASARIM KURALLARI:
/// ✅ Jakob Yasası: Standart create form layout
/// ✅ Fitts Yasası: Primary button 56dp, inputs 56dp height
/// ✅ Hick Yasası: 1 primary action (Oluştur), 1 secondary (İptal - back button)
/// ✅ Miller Yasası: 3 form alanı (Ad, Açıklama, Bütçe) - ideal
/// ✅ Gestalt: Form alanları gruplanmış, info card ayrı

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_tokens.dart';
import '../../providers/trousseau_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/app_card.dart';
import '../../../core/utils/currency_formatter.dart';

class CreateTrousseauScreen extends StatefulWidget {
  const CreateTrousseauScreen({super.key});

  @override
  State<CreateTrousseauScreen> createState() => _CreateTrousseauScreenState();
}

class _CreateTrousseauScreenState extends State<CreateTrousseauScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  bool _isLoading = false;

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
  // CREATE TROUSSEAU HANDLER
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _createTrousseau() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final trousseauProvider = Provider.of<TrousseauProvider>(context, listen: false);
    final success = await trousseauProvider.createTrousseau(
      name: _nameController.text,
      description: _descriptionController.text,
      totalBudget: CurrencyFormatter.parse(_budgetController.text) ?? 0,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Çeyiz başarıyla oluşturuldu'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Çeyiz oluşturuluyor...',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Yeni Çeyiz Oluştur'),
          // FITTS YASASI: Back button 48x48
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
                    // INFO CARD
                    // GESTALT: Görsel olarak ayrı bilgilendirme kutusu
                    // ─────────────────────────────────────────────────────
                    AppInfoCard(
                      icon: Icons.home_work,
                      title: 'Hayalinizdeki çeyizi planlamaya başlayın',
                      color: theme.colorScheme.primary,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.05),
                    ),

                    AppSpacing.xl.verticalSpace,

                    // ─────────────────────────────────────────────────────
                    // FORM SECTION
                    // MILLER YASASI: 3 alan (ideal)
                    // ─────────────────────────────────────────────────────
                    AppFormSection(
                      title: 'Çeyiz Bilgileri',
                      children: [
                        // Trousseau Name
                        AppTextInput(
                          label: 'Çeyiz Adı',
                          hint: 'Örn: Evlilik Çeyizim',
                          controller: _nameController,
                          prefixIcon: const Icon(Icons.label_outline),
                          textInputAction: TextInputAction.next,
                          validator: _validateName,
                        ),

                        // Description
                        AppTextInput(
                          label: 'Açıklama',
                          hint: 'Çeyiziniz hakkında notlar ekleyin (Opsiyonel)',
                          controller: _descriptionController,
                          maxLines: 3,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.description_outlined),
                        ),

                        // Budget
                        AppTextInput(
                          label: 'Toplam Bütçe (₺)',
                          hint: 'Örn: 50.000 (Opsiyonel)',
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
                    // HICK YASASI: 1 primary action
                    // FITTS YASASI: 56dp button
                    // ─────────────────────────────────────────────────────
                    AppButtonGroup(
                      primaryButton: AppPrimaryButton(
                        label: 'Çeyiz Oluştur',
                        icon: Icons.add,
                        isFullWidth: true,
                        onPressed: _createTrousseau,
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
