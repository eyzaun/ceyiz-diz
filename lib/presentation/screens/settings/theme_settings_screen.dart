import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/theme_provider.dart';
import '../../../core/constants/app_colors.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  // ignore: unused_local_variable
  final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tema Ayarları'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Tema Seçimi',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Uygulamanın görünümünü kişiselleştirin',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 24),
          
          // Theme Options
          _buildThemeOption(
            context,
            'Varsayılan',
            'Modern ve canlı renkler',
            AppColors.primaryDefault,
            AppColors.secondaryDefault,
            AppColors.accentDefault,
            AppThemeType.defaultTheme,
            false,
          ),
          _buildThemeOption(
            context,
            'Gece Mavisi',
            'Koyu ve şık: lacivert-mavi tonlar',
            const Color(0xFF3B82F6), // primary
            const Color(0xFF60A5FA), // secondary
            const Color(0xFF334155), // accent
            AppThemeType.modern,
            true,
          ),
          _buildThemeOption(
            context,
            'Monokrom',
            'Saf siyah üzerine beyaz vurgu',
            const Color(0xFFFFFFFF), // primary on black
            const Color(0xFFCCCCCC), // secondary
            const Color(0xFF1A1A1A), // accent/border
            AppThemeType.ocean,
            true,
          ),
          _buildThemeOption(
            context,
            'Orman',
            'Doğal yeşil tonlar',
            AppColors.primaryForest,
            AppColors.secondaryForest,
            AppColors.accentForest,
            AppThemeType.forest,
            true,
          ),
          // Not showing additional duplicates (rose/night) to keep the list concise
          
          const SizedBox(height: 32),
          
          // Preview Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Önizleme',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Birincil Buton'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('İkincil Buton'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Örnek Giriş Alanı',
                    hintText: 'Metin girin',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(value: true, onChanged: (_) {}),
                    const Text('Seçim Kutusu'),
                    const Spacer(),
                    Switch(value: true, onChanged: (_) {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildThemeOption(
    BuildContext context,
    String title,
    String description,
    Color primary,
    Color secondary,
    Color accent,
    AppThemeType type,
    bool isDark,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);
  // final isSelected = themeProvider.currentThemeType == type;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => themeProvider.setTheme(type),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Color Preview
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              
              // Theme Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(width: 8),
                        if (isDark)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Koyu',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              
              // Selection Indicator
              Radio<AppThemeType>(
                value: type,
                groupValue: themeProvider.currentThemeType,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setTheme(value);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}