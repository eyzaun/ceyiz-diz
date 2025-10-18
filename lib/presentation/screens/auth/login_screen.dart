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
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/loading_overlay.dart';

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
      print('🔐 Loading Remember Me: $rememberMe');
      if (rememberMe) {
        final email = prefs.getString('saved_email') ?? '';
        final password = prefs.getString('saved_password') ?? '';
        print('✅ Loaded email: $email');
        setState(() {
          _rememberMe = rememberMe;
          _emailController.text = email;
          _passwordController.text = password;
        });
      }
    } catch (e) {
      print('❌ Error loading Remember Me: $e');
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
      return 'Şifre en az 6 karakter olmalı';
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOGIN HANDLER
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    print('🔑 Login attempt - Remember Me: $_rememberMe');

    // Save Remember Me BEFORE login to avoid mounted issues
    try {
      print('💾 Saving Remember Me BEFORE login - Value: $_rememberMe');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', _rememberMe);

      if (_rememberMe) {
        await prefs.setString('saved_email', _emailController.text.trim());
        await prefs.setString('saved_password', _passwordController.text);
        print('💾 Remember Me credentials saved: ${_emailController.text.trim()}');
      } else {
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
        print('🗑️ Remember Me credentials cleared');
      }

      // Verify save
      final saved = prefs.getBool('remember_me');
      print('✅ Remember Me saved and verified: $saved');
    } catch (e) {
      print('❌ Error saving Remember Me: $e');
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    print('🔑 Login result: $success');

    if (success) {
      if (!mounted) return;
      context.go('/');
    } else {
      // Check if error is email not verified
      if (authProvider.errorMessage == 'email-not-verified') {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.radiusXL,
            ),
            title: const Text('E-posta Doğrulanmadı'),
            content: const Text(
              'Hesabınıza giriş yapmak için e-posta adresinizi doğrulamanız gerekmektedir. '
              'E-posta adresinize gönderilen bağlantıya tıklayın.',
            ),
            actions: [
              AppTextButton(
                label: 'İptal',
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              AppPrimaryButton(
                label: 'Doğrulama Sayfasına Git',
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  final encodedEmail = Uri.encodeComponent(_emailController.text.trim());
                  context.go('/verify-email/$encodedEmail');
                },
              ),
            ],
          ),
        );
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
                    ? 'Güncelleme Gerekli!'
                    : 'Yeni Versiyon Mevcut',
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

    // Listen for update flag changes
    if (authProvider.updateAvailable && !_hasShownUpdateDialog && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForUpdateOnce();
      });
    }

    return LoadingOverlay(
      isLoading: authProvider.status == AuthStatus.loading,
      child: Scaffold(
        body: SafeArea(
          child: FadeTransition(
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
                        _buildHeader(theme),

                        AppSpacing.xl.verticalSpace,

                        // ─────────────────────────────────────────────────────
                        // FORM ALANLARI
                        // Miller Yasası: 2 alan = ideal (email + şifre)
                        // ─────────────────────────────────────────────────────
                        AppTextInput(
                          label: 'Email',
                          hint: 'ornek@email.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: _validateEmail,
                        ),

                        AppSpacing.md.verticalSpace,

                        AppPasswordInput(
                          label: 'Şifre',
                          hint: 'En az 6 karakter',
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
                                    print('✔️ Remember Me checkbox changed to: $_rememberMe');
                                  });
                                },
                                title: const Text('Beni Hatırla'),
                                contentPadding: EdgeInsets.zero,
                                controlAffinity: ListTileControlAffinity.leading,
                              ),
                            ),
                            // Şifremi Unuttum (Secondary action)
                            AppTextButton(
                              label: 'Şifremi Unuttum',
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
                          label: 'Giriş Yap',
                          icon: Icons.login,
                          isFullWidth: true,
                          onPressed: _handleLogin,
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
                              'Hesabınız yok mu?',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: AppTypography.sizeBase,
                              ),
                            ),
                            AppSpacing.xs.horizontalSpace,
                            AppTextButton(
                              label: 'Kayıt Olun',
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
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADER WIDGET (Logo + Başlık)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(ThemeData theme) {
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
          'Hayalinizdeki çeyizi kolayca yönetin',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: AppTypography.sizeMD,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
