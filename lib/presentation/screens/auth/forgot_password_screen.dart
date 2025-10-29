import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../../l10n/generated/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  
  String? _validateEmail(String? value, AppLocalizations? l10n) {
    if (value == null || value.isEmpty) {
      return l10n?.emailRequired ?? 'E-posta adresi gereklidir';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return l10n?.emailInvalid ?? 'Geçerli bir e-posta adresi girin';
    }
    return null;
  }
  
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resetPassword(_emailController.text);
    
    setState(() {
      _isLoading = false;
      _emailSent = success;
    });
    
    if (success && mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.passwordResetEmailSent ?? 'Şifre sıfırlama e-postası gönderildi'),
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
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: _emailSent ? _buildSuccessContent(theme) : _buildFormContent(theme),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFormContent(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.lock_reset,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            l10n?.forgotPasswordTitle ?? 'Şifrenizi mi Unuttunuz?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.forgotPasswordSubtitle ?? 'Endişelenmeyin! E-posta adresinizi girin, size şifre sıfırlama bağlantısı gönderelim.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _resetPassword(),
            decoration: InputDecoration(
              labelText: l10n?.emailAddress ?? 'E-posta Adresi',
              hintText: 'ornek@email.com',
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            validator: (value) => _validateEmail(value, l10n),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _resetPassword,
              child: Text(l10n?.sendResetLink ?? 'Sıfırlama Bağlantısı Gönder'),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.push('/login'),
            child: Text(l10n?.backToLogin ?? 'Giriş sayfasına dön'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuccessContent(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.mark_email_read,
          size: 80,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          l10n?.emailSentTitle ?? 'E-posta Gönderildi!',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          l10n?.emailSentMessage(_emailController.text) ?? '${_emailController.text} adresine şifre sıfırlama bağlantısı gönderdik. Lütfen e-postanızı kontrol edin.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: _resetPassword,
          child: Text(l10n?.resend ?? 'Tekrar Gönder'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => context.push('/login'),
          child: Text(l10n?.backToLoginPage ?? 'Giriş Sayfasına Dön'),
        ),
      ],
    );
  }
}