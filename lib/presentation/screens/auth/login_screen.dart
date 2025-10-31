library;

/// Login Screen - Yeni Tasarım Sistemi v2.0
///
/// TASARIM KURALLARI:
/// ✅ Jakob Yasası: Standart login layout (logo + form + alt link)
/// ✅ Fitts Yasası: Primary button 56dp, full width, kolay erişim
/// ✅ Hick Yasası: 1 primary action (Giriş Yap)
/// ✅ Miller Yasası: 2 form alanı (email + şifre) - ideal
/// ✅ Gestalt: İlgili öğeler gruplanmış, tutarlı spacing

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/language_selector.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _hasShownUpdateDialog = false;
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

    // Load saved credentials if Remember Me was enabled
    _loadSavedCredentials();

    // Check for app update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdateOnce();
    });
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('remember_me') ?? false;
      if (rememberMe) {
        final email = prefs.getString('saved_email') ?? '';
        final password = prefs.getString('saved_password') ?? '';
        setState(() {
          _rememberMe = rememberMe;
          _emailController.text = email;
          _passwordController.text = password;
        });
      }
    } catch (e) {
      // Error loading credentials
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VALIDATION
  // ═══════════════════════════════════════════════════════════════════════════

  String? _validateEmail(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return l10n?.emailRequired ?? '❌ E-posta adresi boş bırakılamaz';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return l10n?.emailInvalid ?? '❌ Geçerli bir e-posta adresi girin (örn: ornek@email.com)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return l10n?.passwordRequired ?? '❌ Şifre boş bırakılamaz';
    }
    if (value.length < 6) {
      return l10n?.passwordMinLength ?? '❌ Şifre en az 6 karakter olmalı';
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOGIN HANDLER
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Save Remember Me BEFORE login to avoid mounted issues
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', _rememberMe);

      if (_rememberMe) {
        await prefs.setString('saved_email', _emailController.text.trim());
        await prefs.setString('saved_password', _passwordController.text);
      } else {
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
      }
    } catch (e) {
      // Error saving credentials
    }

    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      if (!mounted) return;
      context.go('/');
    } else {
      // Check if error is email not verified
      if (authProvider.errorMessage == 'email-not-verified') {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context);
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.radiusXL,
            ),
            title: Text(l10n?.emailNotVerified ?? 'E-posta Doğrulanmadı'),
            content: Text(
              l10n?.emailNotVerifiedMessage ?? 
              'Hesabınıza giriş yapmak için e-posta adresinizi doğrulamanız gerekmektedir.',
            ),
            actions: [
              AppTextButton(
                label: l10n?.cancel ?? 'İptal',
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              AppPrimaryButton(
                label: l10n?.goToVerification ?? 'Doğrulama Sayfasına Git',
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  final encodedEmail = Uri.encodeComponent(_emailController.text.trim());
                  // mounted check için state widget kullan
                  if (context.mounted) {
                    context.go('/verify-email/$encodedEmail');
                  }
                },
              ),
            ],
          ),
        );
      } else {
        if (!mounted) return;
        _showErrorSnackBar(authProvider.errorMessage);
      }
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
  // ERROR SNACKBAR HELPER
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

  // ═══════════════════════════════════════════════════════════════════════════
  // UPDATE DIALOG
  // ═══════════════════════════════════════════════════════════════════════════

  void _checkForUpdateOnce() {
    if (_hasShownUpdateDialog) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.updateAvailable) {
      _hasShownUpdateDialog = true;
      _showUpdateDialog();
    }
  }

  void _showUpdateDialog() {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      barrierDismissible: !authProvider.forceUpdate,
      builder: (dialogContext) => PopScope(
        canPop: !authProvider.forceUpdate,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusXL,
          ),
          title: Row(
            children: [
              Container(
                padding: AppSpacing.paddingSM,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: AppRadius.radiusSM,
                ),
                child: Icon(
                  Icons.system_update,
                  color: theme.colorScheme.primary,
                  size: AppDimensions.iconSizeLarge,
                ),
              ),
              AppSpacing.md.horizontalSpace,
              Expanded(
                child: Text(
                  authProvider.forceUpdate
                    ? (l10n?.updateRequiredMessage ?? 'Güncelleme Gerekli!')
                    : (l10n?.newVersionAvailable ?? 'Yeni Versiyon Mevcut'),
                  style: TextStyle(
                    fontSize: AppTypography.sizeLG,
                    fontWeight: AppTypography.bold,
                    color: authProvider.forceUpdate
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                authProvider.updateMessage,
                style: theme.textTheme.bodyMedium,
              ),
              AppSpacing.md.verticalSpace,
              Container(
                padding: AppSpacing.paddingMD,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: AppRadius.radiusMD,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.new_releases,
                      color: theme.colorScheme.primary,
                      size: AppDimensions.iconSizeMedium,
                    ),
                    AppSpacing.sm.horizontalSpace,
                    Text(
                      'Yeni Versiyon: ${authProvider.latestVersion}',
                      style: TextStyle(
                        fontWeight: AppTypography.bold,
                        color: theme.colorScheme.primary,
                        fontSize: AppTypography.sizeBase,
                      ),
                    ),
                  ],
                ),
              ),
              if (authProvider.forceUpdate) ...[
                AppSpacing.md.verticalSpace,
                Container(
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                    borderRadius: AppRadius.radiusMD,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: theme.colorScheme.error,
                        size: AppDimensions.iconSizeMedium,
                      ),
                      AppSpacing.sm.horizontalSpace,
                      Expanded(
                        child: Text(
                          'Bu güncelleme zorunludur. Devam etmek için güncellemeniz gerekiyor.',
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: AppTypography.sizeSM,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (!authProvider.forceUpdate)
              AppTextButton(
                label: 'Daha Sonra',
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            AppPrimaryButton(
              label: 'Şimdi Güncelle',
              icon: Icons.download,
              onPressed: () async {
                const url = 'https://play.google.com/store/apps/details?id=com.Loncagames.ceyizdiz';
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: const Text('Play Store açılamadı.'),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                  }
                }
                if (dialogContext.mounted && !authProvider.forceUpdate) {
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
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

    // Listen to AuthProvider for update checks
    if (authProvider.updateAvailable && !_hasShownUpdateDialog && mounted) {
      _hasShownUpdateDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showUpdateDialog();
      });
    }

    return LoadingOverlay(
      isLoading: authProvider.status == AuthStatus.loading,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: SingleChildScrollView(
                    padding: context.safePaddingHorizontal,
                    child: ConstrainedBox(
                      // Responsive: Web'de maksimum genişlik
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
                        // Gestalt: Gruplama - Logo + Başlık + Subtitle yakın
                        // ─────────────────────────────────────────────────────
                        _buildHeader(theme, l10n),

                        AppSpacing.xl.verticalSpace,

                        // ─────────────────────────────────────────────────────
                        // FORM ALANLARI
                        // Miller Yasası: 2 alan = ideal (email + şifre)
                        // ─────────────────────────────────────────────────────
                        AppTextInput(
                          label: l10n?.email ?? 'Email',
                          hint: 'ornek@email.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: _validateEmail,
                        ),

                        AppSpacing.md.verticalSpace,

                        AppPasswordInput(
                          label: l10n?.password ?? 'Şifre',
                          hint: l10n?.passwordHint ?? 'En az 6 karakter',
                          controller: _passwordController,
                          textInputAction: TextInputAction.done,
                          validator: _validatePassword,
                        ),

                        // Remember Me & Forgot Password Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Remember Me Checkbox
                            Expanded(
                              child: CheckboxListTile(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                title: Text(l10n?.rememberMe ?? 'Beni Hatırla'),
                                contentPadding: EdgeInsets.zero,
                                controlAffinity: ListTileControlAffinity.leading,
                              ),
                            ),
                            // Şifremi Unuttum (Secondary action)
                            AppTextButton(
                              label: l10n?.forgotPassword ?? 'Şifremi Unuttum',
                              onPressed: () => context.push('/forgot-password'),
                            ),
                          ],
                        ),

                        AppSpacing.xl.verticalSpace,

                        // ─────────────────────────────────────────────────────
                        // PRIMARY ACTION - HICK YASASI: Sadece 1 tane
                        // FITTS YASASI: 56dp height, full width, kolay basılır
                        // ─────────────────────────────────────────────────────
                        AppPrimaryButton(
                          label: l10n?.login ?? 'Giriş Yap',
                          icon: Icons.login,
                          isFullWidth: true,
                          onPressed: _handleLogin,
                          isLoading: authProvider.status == AuthStatus.loading,
                        ),

                        AppSpacing.lg.verticalSpace,

                        // ─────────────────────────────────────────────────────
                        // DIVIDER - "veya" text
                        // ─────────────────────────────────────────────────────
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              child: Text(
                                'veya',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),

                        AppSpacing.lg.verticalSpace,

                        // ─────────────────────────────────────────────────────
                        // GOOGLE SIGN-IN BUTTON
                        // Material 3 uyumlu, outlined style
                        // ─────────────────────────────────────────────────────
                        AppSecondaryButton(
                          label: l10n?.googleSignIn ?? 'Google ile Giriş Yap',
                          icon: Icons.g_mobiledata_rounded, // Google "G" icon
                          isFullWidth: true,
                          onPressed: _handleGoogleSignIn,
                          isLoading: authProvider.status == AuthStatus.loading,
                        ),

                        AppSpacing.lg.verticalSpace,

                            // ─────────────────────────────────────────────────────
                            // SECONDARY LINK (Kayıt Olun)
                            // Gestalt: Yakınlık - Soru + Link birlikte
                            // ─────────────────────────────────────────────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n?.noAccount ?? 'Hesabınız yok mu?',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: AppTypography.sizeBase,
                                  ),
                                ),
                                AppSpacing.xs.horizontalSpace,
                                AppTextButton(
                                  label: l10n?.register ?? 'Kayıt Olun',
                                  onPressed: () => context.push('/register'),
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

              // ═══════════════════════════════════════════════════════════════
              // LANGUAGE SELECTOR (Floating, top-right)
              // Allows users to change language before logging in
              // ═══════════════════════════════════════════════════════════════
              const LanguageSelector(
                alignment: Alignment.topRight,
                isFloating: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADER WIDGET (Logo + Başlık)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(ThemeData theme, AppLocalizations? l10n) {
    return Column(
      children: [
        // Logo Container
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset(
              'web/icons/Icon-192.png',
              width: 72,
              height: 72,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) {
                return Icon(
                  Icons.inventory_2,
                  size: 64,
                  color: theme.colorScheme.primary,
                );
              },
            ),
          ),
        ),

        AppSpacing.lg.verticalSpace,

        // Başlık
        Text(
          'Çeyiz Diz',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: AppTypography.bold,
            color: theme.colorScheme.primary,
            fontSize: AppTypography.size4XL,
          ),
          textAlign: TextAlign.center,
        ),

        AppSpacing.xs.verticalSpace,

        // Alt Başlık
        Text(
          l10n?.trousseauSlogan ?? 'Hayalinizdeki çeyizi kolayca yönetin',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontSize: AppTypography.sizeMD,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
