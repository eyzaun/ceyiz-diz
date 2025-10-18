import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/design_tokens.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final onboardingProvider = Provider.of<OnboardingProvider>(context, listen: false);
    await onboardingProvider.completeOnboarding();
    if (mounted) {
      context.go('/login');
    }
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Atla',
                    style: TextStyle(
                      fontSize: AppTypography.sizeMD,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildPage(
                    icon: Icons.inventory_2_outlined,
                    iconColor: const Color(0xFF6C63FF),
                    title: 'Çeyizini Dijitalleştir',
                    description:
                        'Tüm çeyiz ürünlerini tek bir yerde topla, kategorilere ayır ve kolayca yönet. Artık hangi ürünü aldığını unutma!',
                    theme: theme,
                  ),
                  _buildPage(
                    icon: Icons.attach_money_outlined,
                    iconColor: const Color(0xFF00BFA5),
                    title: 'Bütçeni Kontrol Et',
                    description:
                        'Hedef bütçeni belirle, harcamalarını takip et ve tasarruf fırsatlarını yakala. Çeyiz alışverişi artık daha ekonomik!',
                    theme: theme,
                  ),
                  _buildPage(
                    icon: Icons.access_time_outlined,
                    iconColor: const Color(0xFFFF6B6B),
                    title: 'Kaç Saat Çalışmalısın?',
                    description:
                        'Ürünlerin fiyatını çalışma saatine çevir. Maaşını gir, her ürünün kaç saatlik emeğe denk geldiğini gör!',
                    theme: theme,
                  ),
                  _buildPage(
                    icon: Icons.share_outlined,
                    iconColor: const Color(0xFFFFB74D),
                    title: 'Paylaş ve İşbirliği Yap',
                    description:
                        'Çeyiz listeni ailen ve arkadaşlarınla paylaş. Birlikte planlayın, öneriler alın ve alışveriş listesini günceleyin!',
                    theme: theme,
                  ),
                ],
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 4,
                effect: WormEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  spacing: 16,
                  activeDotColor: colorScheme.primary,
                  dotColor: colorScheme.surfaceContainerHighest,
                ),
              ),
            ),

            // Next/Start button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _nextPage,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Text(
                    _currentPage == 3 ? 'Başlayalım' : 'Devam',
                    style: TextStyle(
                      fontSize: AppTypography.sizeBase,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: iconColor,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: AppTypography.sizeXL,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              fontFamily: AppTypography.fontFamily,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.md),

          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: AppTypography.sizeMD,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
              fontFamily: AppTypography.fontFamily,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
