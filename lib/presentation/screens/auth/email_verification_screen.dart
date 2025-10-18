import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../core/theme/design_tokens.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResending = false;
  bool _isChecking = false;
  Timer? _pollTimer;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    // Start polling for email verification every 3 seconds
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isVerified = await authProvider.checkEmailVerified();

      if (isVerified && mounted) {
        _pollTimer?.cancel();
        // Show success message and navigate to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-posta adresiniz doğrulandı! Giriş yapabilirsiniz.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        final currentLoc = GoRouterState.of(context).uri.toString();
        if (mounted && currentLoc != '/login') {
          context.go('/login');
        }
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    if (_resendCooldown > 0) return;

    setState(() => _isResending = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.sendEmailVerification();

    setState(() => _isResending = false);

    if (success && mounted) {
      // Start cooldown
      setState(() => _resendCooldown = 60);
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_resendCooldown > 0) {
          setState(() => _resendCooldown--);
        } else {
          timer.cancel();
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Doğrulama e-postası tekrar gönderildi'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final isVerified = await authProvider.checkEmailVerified();

    setState(() => _isChecking = false);

    if (isVerified && mounted) {
      _pollTimer?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-posta adresiniz doğrulandı! Giriş yapabilirsiniz.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      final currentLoc = GoRouterState.of(context).uri.toString();
      if (mounted && currentLoc != '/login') {
        context.go('/login');
      }
    } else if (!isVerified && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-posta henüz doğrulanmadı. Lütfen gelen kutunuzu kontrol edin.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    _pollTimer?.cancel();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      final currentLoc = GoRouterState.of(context).uri.toString();
      if (currentLoc != '/login') {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-posta Doğrulama'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email Icon
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_unread_outlined,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
              ),

              AppSpacing.xl2.verticalSpace,

              // Title
              Text(
                'E-postanızı Doğrulayın',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: AppTypography.bold,
                ),
                textAlign: TextAlign.center,
              ),

              AppSpacing.md.verticalSpace,

              // Description
              Text(
                '${widget.email} adresine bir doğrulama e-postası gönderdik.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              AppSpacing.sm.verticalSpace,

              Text(
                'Lütfen e-postanızdaki bağlantıya tıklayarak hesabınızı doğrulayın.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              AppSpacing.xl2.verticalSpace,

              // Check Verification Button
              AppPrimaryButton(
                label: 'Doğrulamayı Kontrol Et',
                icon: Icons.refresh,
                onPressed: _isChecking ? null : _checkVerification,
                isLoading: _isChecking,
              ),

              AppSpacing.md.verticalSpace,

              // Resend Email Button
              AppSecondaryButton(
                label: _resendCooldown > 0
                    ? 'Tekrar Gönder ($_resendCooldown saniye)'
                    : 'Doğrulama E-postasını Tekrar Gönder',
                icon: Icons.email_outlined,
                onPressed: _resendCooldown > 0 || _isResending ? null : _resendVerificationEmail,
                isLoading: _isResending,
              ),

              AppSpacing.xl.verticalSpace,

              // Info Card
              Card(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          AppSpacing.sm.horizontalSpace,
                          Text(
                            'İpuçları',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: AppTypography.semiBold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.sm.verticalSpace,
                      Text(
                        '• E-postayı bulamıyorsanız spam klasörünü kontrol edin\n'
                        '• E-posta birkaç dakika içinde gelmezse "Tekrar Gönder" butonunu kullanın\n'
                        '• Doğrulama tamamlandığında otomatik olarak giriş sayfasına yönlendirileceksiniz',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
