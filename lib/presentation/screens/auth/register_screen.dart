library;

/// Register Screen - Yeni Tasarım Sistemi v2.0
///
/// TASARIM KURALLARI:
/// ✅ Jakob Yasası: Standart kayıt formu layout
/// ✅ Fitts Yasası: Primary button 56dp, checkbox 48x48dp touch area
/// ✅ Hick Yasası: 1 primary action (Kayıt Ol)
/// ✅ Miller Yasası: 4 alan ama 2 gruba bölünmüş (Kişisel + Güvenlik)
/// ✅ Gestalt: Form bölümleri gruplanmış, ilgili alanlar yakın

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
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
      return '❌ Ad Soyad boş bırakılamaz';
    }
    if (value.trim().length < 3) {
      return '❌ En az 3 karakter olmalı';
    }
    if (!value.contains(' ')) {
      return '💡 Ad ve soyadınızı girin (örn: Ahmet Yılmaz)';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '❌ E-posta adresi boş bırakılamaz';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return '❌ Geçerli bir e-posta adresi girin (örn: ornek@email.com)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '❌ Şifre boş bırakılamaz';
    }
    if (value.length < 6) {
      return '❌ En az 6 karakter olmalı';
    }
    
    // Check individual requirements
    bool hasUpperCase = value.contains(RegExp(r'[A-Z]'));
    bool hasLowerCase = value.contains(RegExp(r'[a-z]'));
    bool hasDigit = value.contains(RegExp(r'\d'));
    
    if (!hasUpperCase) {
      return '❌ En az 1 büyük harf içermeli (A-Z)';
    }
    if (!hasLowerCase) {
      return '❌ En az 1 küçük harf içermeli (a-z)';
    }
    if (!hasDigit) {
      return '❌ En az 1 rakam içermeli (0-9)';
    }
    
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '❌ Şifre tekrarı boş bırakılamaz';
    }
    if (value != _passwordController.text) {
      return '❌ Şifreler eşleşmiyor. Lütfen aynı şifreyi girin';
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REGISTER HANDLER
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      _showWarningSnackBar('⚠️ Kullanım koşullarını kabul etmelisiniz\n💡 Devam etmek için onay kutusunu işaretleyin');
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
      final encodedEmail = Uri.encodeComponent(_emailController.text.trim());
      context.go('/verify-email/$encodedEmail');
    } else {
      _showErrorSnackBar(authProvider.errorMessage);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GOOGLE SIGN-IN HANDLER
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signInWithGoogle();

    if (!mounted) return;

    if (success) {
      if (!mounted) return;
      context.go('/');
    } else {
      if (!mounted) return;
      _showErrorSnackBar(authProvider.errorMessage);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SNACKBAR HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  void _showErrorSnackBar(String message) {
    final theme = Theme.of(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: AppDimensions.iconSizeMedium,
            ),
            AppSpacing.sm.horizontalSpace,
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppTypography.sizeSM,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMD,
        ),
        duration: const Duration(seconds: 5),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150,
          left: AppSpacing.md,
          right: AppSpacing.md,
        ),
        action: SnackBarAction(
          label: 'Tamam',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: AppDimensions.iconSizeMedium,
            ),
            AppSpacing.sm.horizontalSpace,
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppTypography.sizeSM,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMD,
        ),
        duration: const Duration(seconds: 4),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150,
          left: AppSpacing.md,
          right: AppSpacing.md,
        ),
        action: SnackBarAction(
          label: 'Tamam',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final l10n = AppLocalizations.of(context);

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
                        // ─────────────────────────────────────────────────────
                        // LOGO VE BAŞLIK
                        // ─────────────────────────────────────────────────────
                        Text(
                          l10n?.registerTitle ?? 'Hesap Oluştur',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: AppTypography.bold,
                            fontSize: AppTypography.size3XL,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),

                        AppSpacing.xs.verticalSpace,

                        Text(
                          l10n?.createAccountSubtitle ?? 'Yeni hesabınızı oluşturun',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: AppTypography.sizeBase,
                          ),
                          textAlign: TextAlign.center,
                        ),                        AppSpacing.xl.verticalSpace,

                        // ─────────────────────────────────────────────────────
                        // FORM SECTIONS
                        // Miller Yasası: 4 alan ama 2 gruba bölünmüş
                        // ─────────────────────────────────────────────────────
                        // Kişisel Bilgiler Section
                        Text(
                          l10n?.personalInfo ?? 'Kişisel Bilgiler',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AppSpacing.sm.verticalSpace,
                        AppTextInput(
                          label: l10n?.displayName ?? 'Ad Soyad',
                          hint: 'Ahmet Yılmaz',
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.person_outline),
                          validator: _validateName,
                        ),
                        AppSpacing.md.verticalSpace,
                        AppTextInput(
                          label: l10n?.email ?? 'Email',
                          hint: 'ornek@email.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: _validateEmail,
                        ),

                        AppSpacing.lg.verticalSpace,

                        // Security Section
                        Text(
                          l10n?.security ?? 'Güvenlik',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AppSpacing.xs.verticalSpace,
                        Text(
                          l10n?.securityRequirements ?? 'En az 6 karakter, 1 büyük harf, 1 küçük harf ve 1 rakam',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        AppSpacing.sm.verticalSpace,
                        AppPasswordInput(
                          label: l10n?.password ?? 'Şifre',
                          hint: 'Güçlü bir şifre oluşturun',
                          controller: _passwordController,
                          textInputAction: TextInputAction.next,
                          validator: _validatePassword,
                        ),
                        AppSpacing.md.verticalSpace,
                        AppPasswordInput(
                          label: l10n?.confirmPassword ?? 'Şifre Tekrarı',
                          hint: l10n?.confirmPasswordHint ?? 'Şifrenizi tekrar girin',
                          controller: _confirmPasswordController,
                          textInputAction: TextInputAction.done,
                          validator: _validateConfirmPassword,
                        ),                        AppSpacing.md.verticalSpace,

                        // ─────────────────────────────────────────────────────
                        // TERMS CHECKBOX
                        // FITTS YASASI: Checkbox + text 48dp touch area
                        // ─────────────────────────────────────────────────────
                        _buildTermsCheckbox(theme, l10n),

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

                        // Primary Action Button
                        AppPrimaryButton(
                          label: l10n?.createAccount ?? 'Kayıt Ol',
                          icon: Icons.person_add,
                          isFullWidth: true,
                          onPressed: _handleRegister,
                          isLoading: authProvider.status == AuthStatus.loading,
                        ),

                        AppSpacing.lg.verticalSpace,

                        // ─────────────────────────────────────────────────────
                        // Divider
                        // ─────────────────────────────────────────────────────
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              child: Text(
                                l10n?.or ?? 'veya',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),

                        AppSpacing.lg.verticalSpace,

                        // Google Sign-In Button
                        AppSecondaryButton(
                          label: l10n?.registerWithGoogle ?? 'Google ile Kayıt Ol',
                          icon: Icons.g_mobiledata_rounded,
                          isFullWidth: true,
                          onPressed: _handleGoogleSignIn,
                        ),

                        AppSpacing.lg.verticalSpace,

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n?.alreadyHaveAccount ?? 'Zaten hesabınız var mı?',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: AppTypography.sizeBase,
                              ),
                            ),
                            AppSpacing.xs.horizontalSpace,
                            AppTextButton(
                              label: l10n?.login ?? 'Giriş Yapın',
                              onPressed: () => context.push('/login'),
                            ),
                          ],
                        ),                        // ─────────────────────────────────────────────────────
                        // GOOGLE SIGN-IN BUTTON
                        // Material 3 uyumlu, outlined style
                        // ─────────────────────────────────────────────────────
                        AppSecondaryButton(
                          label: l10n?.registerWithGoogle ?? 'Google ile Kayıt Ol',
                          icon: Icons.g_mobiledata_rounded,
                          isFullWidth: true,
                          onPressed: _handleGoogleSignIn,
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

  Widget _buildTermsCheckbox(ThemeData theme, AppLocalizations? l10n) {
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
                l10n?.acceptTerms ?? 'Kullanım koşullarını ve gizlilik politikasını kabul ediyorum',
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
