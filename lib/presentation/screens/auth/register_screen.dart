// Register Screen - Yeni Tasarım Sistemi v2.0
//
// TASARIM KURALLARI:
// ✅ Jakob Yasası: Standart kayıt formu layout
// ✅ Fitts Yasası: Primary button 56dp, checkbox 48x48dp touch area
// ✅ Hick Yasası: 1 primary action (Kayıt Ol)
// ✅ Miller Yasası: 4 alan ama 2 gruba bölünmüş (Kişisel + Güvenlik)
// ✅ Gestalt: Form bölümleri gruplanmış, ilgili alanlar yakın

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_tokens.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/loading_overlay.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _acceptTerms = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Fade-in animation
    _animationController = AnimationController(
      duration: AppDurations.slow,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VALIDATION
  // ═══════════════════════════════════════════════════════════════════════════

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ad Soyad gereklidir';
    }
    if (value.length < 3) {
      return 'En az 3 karakter olmalı';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email adresi gereklidir';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'Geçerli bir email adresi girin';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gereklidir';
    }
    if (value.length < 6) {
      return 'En az 6 karakter olmalı';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$').hasMatch(value)) {
      return 'En az 1 büyük harf, 1 küçük harf ve 1 rakam içermeli';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı gereklidir';
    }
    if (value != _passwordController.text) {
      return 'Şifreler eşleşmiyor';
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REGISTER HANDLER
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kullanım koşullarını kabul etmelisiniz'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMD,
          ),
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage),
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
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return LoadingOverlay(
      isLoading: authProvider.status == AuthStatus.loading,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          // FITTS YASASI: Back button 48x48 touch area (default IconButton)
          leading: AppIconButton(
            icon: Icons.arrow_back,
            onPressed: () => context.pop(),
            tooltip: 'Geri',
          ),
        ),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: context.safePaddingHorizontal),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: AppBreakpoints.maxFormWidth,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ─────────────────────────────────────────────────────
                        // BAŞLIK
                        // ─────────────────────────────────────────────────────
                        Text(
                          'Hesap Oluştur',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: AppTypography.bold,
                            fontSize: AppTypography.size4XL,
                          ),
                        ),

                        AppSpacing.xs.verticalSpace,

                        Text(
                          'Çeyiz planlamanıza hemen başlayın',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: AppTypography.sizeMD,
                          ),
                        ),

                        AppSpacing.xl.verticalSpace,

                        // ─────────────────────────────────────────────────────
                        // FORM BÖLÜM 1: KİŞİSEL BİLGİLER
                        // Miller Yasası: 2 alan per grup
                        // ─────────────────────────────────────────────────────
                        AppFormSection(
                          title: 'Kişisel Bilgiler',
                          children: [
                            AppTextInput(
                              label: 'Ad Soyad',
                              hint: 'Adınızı ve soyadınızı girin',
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              prefixIcon: const Icon(Icons.person_outline),
                              validator: _validateName,
                            ),
                            AppTextInput(
                              label: 'Email',
                              hint: 'ornek@email.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              prefixIcon: const Icon(Icons.email_outlined),
                              validator: _validateEmail,
                            ),
                          ],
                        ),

                        AppSpacing.lg.verticalSpace,

                        // ─────────────────────────────────────────────────────
                        // FORM BÖLÜM 2: GÜVENLİK BİLGİLERİ
                        // Miller Yasası: 2 alan per grup
                        // Gestalt: İlgili alanlar (şifre + tekrar) birlikte
                        // ─────────────────────────────────────────────────────
                        AppFormSection(
                          title: 'Güvenlik',
                          subtitle: 'En az 6 karakter, 1 büyük harf, 1 küçük harf ve 1 rakam',
                          children: [
                            AppPasswordInput(
                              label: 'Şifre',
                              hint: 'Güçlü bir şifre oluşturun',
                              controller: _passwordController,
                              textInputAction: TextInputAction.next,
                              validator: _validatePassword,
                            ),
                            AppPasswordInput(
                              label: 'Şifre Tekrarı',
                              hint: 'Şifrenizi tekrar girin',
                              controller: _confirmPasswordController,
                              textInputAction: TextInputAction.done,
                              validator: _validateConfirmPassword,
                            ),
                          ],
                        ),

                        AppSpacing.md.verticalSpace,

                        // ─────────────────────────────────────────────────────
                        // TERMS CHECKBOX
                        // FITTS YASASI: Checkbox + text 48dp touch area
                        // ─────────────────────────────────────────────────────
                        _buildTermsCheckbox(theme),

                        AppSpacing.xl.verticalSpace,

                        // ─────────────────────────────────────────────────────
                        // PRIMARY ACTION - HICK YASASI: Sadece 1 primary button
                        // FITTS YASASI: 56dp height, full width
                        // ─────────────────────────────────────────────────────
                        AppPrimaryButton(
                          label: 'Kayıt Ol',
                          icon: Icons.person_add,
                          isFullWidth: true,
                          onPressed: _handleRegister,
                          isLoading: authProvider.status == AuthStatus.loading,
                        ),

                        AppSpacing.lg.verticalSpace,

                        // ─────────────────────────────────────────────────────
                        // SECONDARY LINK (Giriş Yapın)
                        // ─────────────────────────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Zaten hesabınız var mı?',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: AppTypography.sizeBase,
                              ),
                            ),
                            AppSpacing.xs.horizontalSpace,
                            AppTextButton(
                              label: 'Giriş Yapın',
                              onPressed: () => context.push('/login'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TERMS CHECKBOX WIDGET
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTermsCheckbox(ThemeData theme) {
    return InkWell(
      onTap: () {
        setState(() {
          _acceptTerms = !_acceptTerms;
        });
      },
      borderRadius: AppRadius.radiusMD,
      // FITTS YASASI: Tüm satır tıklanabilir, 48dp minimum yükseklik
      child: Container(
        constraints: const BoxConstraints(
          minHeight: AppDimensions.touchTargetSize,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Checkbox
            SizedBox(
              width: AppDimensions.touchTargetSize,
              height: AppDimensions.touchTargetSize,
              child: Checkbox(
                value: _acceptTerms,
                onChanged: (value) {
                  setState(() {
                    _acceptTerms = value ?? false;
                  });
                },
                // Gestalt: Checkbox rengi primary (benzerlik prensibi)
                activeColor: theme.colorScheme.primary,
              ),
            ),

            AppSpacing.sm.horizontalSpace,

            // Text
            Expanded(
              child: Text(
                'Kullanım koşullarını ve gizlilik politikasını kabul ediyorum',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: AppTypography.sizeBase,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
