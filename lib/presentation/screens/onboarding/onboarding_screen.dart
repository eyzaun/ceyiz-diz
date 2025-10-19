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
    // Ensure SharedPreferences is updated before navigating
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      final currentLoc = GoRouterState.of(context).uri.toString();
      if (currentLoc != '/login') {
        context.go('/login');
      }
    }
  }

  void _nextPage() {
    if (_currentPage < 5) {
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
                  _buildDetailedPage(
                    icon: Icons.waving_hand_outlined,
                    iconColor: const Color(0xFF6C63FF),
                    title: 'Hoş Geldiniz!',
                    subtitle: 'Çeyiz hazırlığını kolaylaştıran uygulama',
                    description:
                        'Çeyiz Diz ile çeyiz alışverişinizi dijital ortamda takip edin, bütçenizi yönetin ve hangi ürünü aldığınızı asla unutmayın!',
                    features: [
                      '📦 Ürünleri kategorilere ayırın',
                      '💰 Harcamalarınızı takip edin',
                      '⏱️ Çalışma saatine çevirin',
                      '🔗 Link\'lerle kolay alışveriş',
                    ],
                    theme: theme,
                  ),
                  _buildDetailedPage(
                    icon: Icons.add_circle_outline,
                    iconColor: const Color(0xFF00BFA5),
                    title: 'Ürün Ekleyin',
                    subtitle: 'Adım 1: Çeyiz listesi oluşturun',
                    description:
                        'Ana ekranda "+" butonuna dokunarak yeni ürün ekleyin. Fotoğraf, fiyat, kategori ve notlar ekleyebilirsiniz.',
                    features: [
                      '1️⃣ Ana ekranda + butonuna tıklayın',
                      '2️⃣ Ürün fotoğrafı ve bilgilerini ekleyin',
                      '3️⃣ Kategori seçin (Ev Tekstili, Mutfak, vb.)',
                      '4️⃣ Link ekleyerek daha sonra satın alın',
                    ],
                    theme: theme,
                  ),
                  _buildDetailedPage(
                    icon: Icons.category_outlined,
                    iconColor: const Color(0xFFFF6B6B),
                    title: 'Kategorilere Ayırın',
                    subtitle: 'Adım 2: Düzenli bir liste',
                    description:
                        'Ürünlerinizi kategorilere ayırarak kolayca bulun. Ev Tekstili, Mutfak, Züccaciye, Elektronik ve daha fazlası!',
                    features: [
                      '🏠 Ev Tekstili: Havlu, çarşaf, yorgan',
                      '🍳 Mutfak: Tencere, tabak, bardak',
                      '💎 Züccaciye: Vazo, çerçeve, aksesuar',
                      '📱 Elektronik: Beyaz eşya, küçük ev aletleri',
                    ],
                    theme: theme,
                  ),
                  _buildDetailedPage(
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: const Color(0xFFFFB74D),
                    title: 'Bütçe Takibi',
                    subtitle: 'Adım 3: Harcamalarınızı kontrol edin',
                    description:
                        'Ana ekranda bütçe kartını göreceksiniz. Hedef bütçe belirleyin, ne kadar harcadığınızı ve ne kadar kaldığını takip edin.',
                    features: [
                      '💵 Toplam harcama: Tüm ürünlerin toplamı',
                      '🎯 Hedef bütçe: İstediğiniz tutarı belirleyin',
                      '📊 Kalan bütçe: Ne kadar daha harcayabilirsiniz',
                      '📈 İlerleme çubuğu: Görsel takip',
                    ],
                    theme: theme,
                  ),
                  _buildDetailedPage(
                    icon: Icons.timer_outlined,
                    iconColor: const Color(0xFF9C27B0),
                    title: 'Çalışma Saati Hesabı',
                    subtitle: 'Ürünlerin gerçek maliyetini görün',
                    description:
                        'Ayarlar\'dan maaşınızı girin. Her ürünün kaç saatlik çalışmanıza denk geldiğini görün ve daha bilinçli alışveriş yapın!',
                    features: [
                      '⚙️ Ayarlar > Maaş Bilgisi\'ne gidin',
                      '💰 Aylık maaşınızı girin',
                      '⏱️ Her üründe çalışma saati göreceksiniz',
                      '🧮 Otomatik hesaplama: Fiyat ÷ Saatlik ücret',
                    ],
                    theme: theme,
                  ),
                  _buildDetailedPage(
                    icon: Icons.check_circle_outline,
                    iconColor: const Color(0xFF4CAF50),
                    title: 'Hazırsınız!',
                    subtitle: 'Çeyiz alışverişi artık çok kolay',
                    description:
                        'Tüm özellikleri keşfetmek için uygulamayı kullanmaya başlayın. Ürün ekleyin, kategorilere ayırın ve bütçenizi yönetin!',
                    features: [
                      '✨ İpucu: Ürün linklerini kaydedin',
                      '📸 İpucu: Mağazada gördüğünüz ürünlerin fotoğrafını çekin',
                      '🔔 İpucu: Satın aldığınız ürünleri işaretleyin',
                      '💡 İpucu: Notlar ekleyerek detayları unutmayın',
                    ],
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
                count: 6,
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
                    _currentPage == 5 ? 'Başlayalım' : 'Devam',
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

  Widget _buildDetailedPage({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String description,
    required List<String> features,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.xl),

          // Icon with gradient background
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iconColor.withValues(alpha: 0.2),
                  iconColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 56,
              color: iconColor,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              fontFamily: AppTypography.fontFamily,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xs),

          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              fontSize: AppTypography.sizeSM,
              fontWeight: FontWeight.w500,
              color: iconColor,
              fontFamily: AppTypography.fontFamily,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: AppTypography.sizeMD,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
              fontFamily: AppTypography.fontFamily,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xl),

          // Features list
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: features.map((feature) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: AppTypography.sizeSM,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                            height: 1.5,
                            fontFamily: AppTypography.fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
