library;

/// New Onboarding Screen - Yeni Tasarım Sistemi v2.0
///
/// TASARIM KURALLARI:
/// ✅ Jakob Yasası: Standart onboarding flow (PageView + indicators)
/// ✅ Fitts Yasası: Primary button 56dp, Skip button 48x48dp touch area
/// ✅ Hick Yasası: 2 action (Skip, Next/Başla)
/// ✅ Miller Yasası: 8 sayfa (detaylı bilgi ama yönetilebilir)
/// ✅ Gestalt: Her sayfa kendi içinde gruplanmış, tutarlı layout

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/design_tokens.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/common/app_button.dart';
import 'onboarding_data.dart';
import 'onboarding_page_widget.dart';

class NewOnboardingScreen extends StatefulWidget {
  const NewOnboardingScreen({super.key});

  @override
  State<NewOnboardingScreen> createState() => _NewOnboardingScreenState();
}

class _NewOnboardingScreenState extends State<NewOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Onboarding tamamlama ve login'e yönlendirme
  Future<void> _completeOnboarding() async {
    final onboardingProvider = Provider.of<OnboardingProvider>(context, listen: false);
    await onboardingProvider.completeOnboarding();
    
    // Ensure SharedPreferences is updated before navigating
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (mounted) {
      context.go('/login');
    }
  }

  /// Bir sonraki sayfaya git
  void _nextPage() {
    if (_currentPage < OnboardingContent.pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  /// Onboarding'i geç
  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ═══════════════════════════════════════════════════════════════
            // SKIP BUTTON (Sağ üst)
            // HICK YASASI: 1 secondary action (Skip)
            // FITTS YASASI: 48x48dp touch area
            // ═══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  child: Text(
                    'Geç',
                    style: TextStyle(
                      fontSize: AppTypography.sizeSM,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                ),
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // PAGE VIEW (8 Sayfa)
            // JAKOB YASASI: Standart horizontal swipe pattern
            // ═══════════════════════════════════════════════════════════════
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: OnboardingContent.pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(
                    pageData: OnboardingContent.pages[index],
                  );
                },
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // PAGE INDICATOR
            // smooth_page_indicator package kullanımı
            // ═══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: OnboardingContent.pages.length,
                effect: WormEffect(
                  dotWidth: 10,
                  dotHeight: 10,
                  spacing: 8,
                  activeDotColor: colorScheme.primary,
                  dotColor: colorScheme.outlineVariant,
                ),
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // NEXT / START BUTTON
            // FITTS YASASI: 56dp height, full width (easy tap)
            // HICK YASASI: 1 primary action
            // ═══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: AppBreakpoints.maxFormWidth,
                ),
                child: AppPrimaryButton(
                  label: _currentPage == OnboardingContent.pages.length - 1
                      ? 'Hadi Başlayalım!'
                      : 'İleri',
                  icon: _currentPage == OnboardingContent.pages.length - 1
                      ? Icons.rocket_launch_outlined
                      : Icons.arrow_forward,
                  onPressed: _nextPage,
                  isFullWidth: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
