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
import '../../../l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return l10n?.trousseauNameRequired ?? 'Çeyiz adı gereklidir';
    }
    if (value.length < 3) {
      return l10n?.minThreeCharacters ?? 'En az 3 karakter olmalıdır';
    }
    return null;
  }

  String? _validateBudget(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value != null && value.isNotEmpty) {
      final budget = CurrencyFormatter.parse(value);
      if (budget == null || budget < 0) {
        return l10n?.enterValidAmount ?? 'Geçerli bir tutar girin';
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
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.trousseauCreatedSuccessfully ?? 'Çeyiz başarıyla oluşturuldu'),
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
    final l10n = AppLocalizations.of(context);

    return LoadingOverlay(
      isLoading: _isLoading,
      message: l10n?.creating ?? 'Oluşturuluyor...',
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n?.createTrousseau ?? 'Yeni Çeyiz Oluştur'),
          // FITTS YASASI: Back button 48x48
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
                    AppSpacing.md.verticalSpace,

                    // ─────────────────────────────────────────────────────
                    // INFO CARD
                    // GESTALT: Görsel olarak ayrı bilgilendirme kutusu
                    // ─────────────────────────────────────────────────────
                    AppInfoCard(
                      icon: Icons.home_work,
                      title: l10n?.startPlanningDream ?? 'Hayalinizdeki çeyizi planlamaya başlayın',
                      color: theme.colorScheme.primary,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.05),
                    ),

                    AppSpacing.xl.verticalSpace,

                    // ─────────────────────────────────────────────────────
                    // FORM SECTION
                    // MILLER YASASI: 3 alan (ideal)
                    // ─────────────────────────────────────────────────────
                    AppFormSection(
                      title: l10n?.trousseauInfo ?? 'Çeyiz Bilgileri',
                      children: [
                        // Trousseau Name
                        AppTextInput(
                          label: l10n?.trousseauName ?? 'Çeyiz Adı',
                          hint: l10n?.trousseauNameExample ?? 'Örn: Evlilik Çeyizim',
                          controller: _nameController,
                          prefixIcon: const Icon(Icons.label_outline),
                          textInputAction: TextInputAction.next,
                          validator: _validateName,
                        ),

                        // Description
                        AppTextInput(
                          label: l10n?.description ?? 'Açıklama',
                          hint: l10n?.descriptionHint ?? 'Çeyiziniz hakkında notlar ekleyin (Opsiyonel)',
                          controller: _descriptionController,
                          maxLines: 3,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.description_outlined),
                        ),

                        // Budget
                        AppTextInput(
                          label: l10n?.budgetOptional ?? 'Toplam Bütçe (₺)',
                          hint: l10n?.budgetExample ?? 'Örn: 50.000 (Opsiyonel)',
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
                        label: l10n?.createTrousseau ?? 'Çeyiz Oluştur',
                        icon: Icons.add,
                        isFullWidth: true,
                        onPressed: _createTrousseau,
                        isLoading: _isLoading,
                      ),
                      secondaryButton: AppSecondaryButton(
                        label: l10n?.cancel ?? 'İptal',
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
