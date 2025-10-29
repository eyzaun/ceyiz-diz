import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/theme_provider.dart';
import '../../../core/themes/design_system.dart';
import '../../../l10n/generated/app_localizations.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
  // ignore: unused_local_variable
  final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.themeSettings ?? 'Theme Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n?.themeSelection ?? 'Theme Selection',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.customizeAppearance ?? 'Customize the app\'s appearance',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 24),
          
          // Theme Options
          _buildThemeOption(
            context,
            l10n?.defaultTheme ?? 'Default',
            l10n?.modernVibrantColors ?? 'Modern and vibrant colors',
            DesignSystem.palettes[AppThemeType.defaultTheme]!.primary,
            DesignSystem.palettes[AppThemeType.defaultTheme]!.secondary,
            DesignSystem.palettes[AppThemeType.defaultTheme]!.tertiary,
            AppThemeType.defaultTheme,
            false,
          ),
          _buildThemeOption(
            context,
            l10n?.monochromeTheme ?? 'Monochrome',
            l10n?.pureBlackWhiteAccent ?? 'Pure black with white accents',
            DesignSystem.palettes[AppThemeType.modern]!.primary,
            DesignSystem.palettes[AppThemeType.modern]!.secondary,
            DesignSystem.palettes[AppThemeType.modern]!.tertiary,
            AppThemeType.modern,
            true,
          ),
          _buildThemeOption(
            context,
            l10n?.purpleOcean ?? 'Purple Ocean',
            l10n?.darkGreyPurpleAccents ?? 'Dark grey background, purple accents',
            DesignSystem.palettes[AppThemeType.ocean]!.primary,
            DesignSystem.palettes[AppThemeType.ocean]!.secondary,
            DesignSystem.palettes[AppThemeType.ocean]!.tertiary,
            AppThemeType.ocean,
            true,
          ),
          _buildThemeOption(
            context,
            l10n?.forestGreen ?? 'Forest Green',
            l10n?.naturalGreenTones ?? 'Natural green tones',
            DesignSystem.palettes[AppThemeType.forest]!.primary,
            DesignSystem.palettes[AppThemeType.forest]!.secondary,
            DesignSystem.palettes[AppThemeType.forest]!.tertiary,
            AppThemeType.forest,
            true,
          ),
          _buildThemeOption(
            context,
            l10n?.sunset ?? 'Sunset',
            l10n?.warmOrangePinkPurple ?? 'Warm orange, pink and purple tones',
            DesignSystem.palettes[AppThemeType.sunset]!.primary,
            DesignSystem.palettes[AppThemeType.sunset]!.secondary,
            DesignSystem.palettes[AppThemeType.sunset]!.tertiary,
            AppThemeType.sunset,
            true,
          ),
          // Not showing deprecated themes (rose/night)
          
          const SizedBox(height: 32),
          
          // Preview Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.preview ?? 'Preview',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Text(l10n?.primaryButton ?? 'Primary Button'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: Text(l10n?.secondaryButton ?? 'Secondary Button'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: l10n?.exampleInputField ?? 'Example Input Field',
                    hintText: l10n?.enterText ?? 'Enter text',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(value: true, onChanged: (_) {}),
                    Text(l10n?.checkbox ?? 'Checkbox'),
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
    final l10n = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isSelected = themeProvider.currentThemeType == type;
    
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
                            child: Text(
                              l10n?.dark ?? 'Dark',
                              style: const TextStyle(fontSize: 10),
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
              
              // Selection Indicator (avoid deprecated Radio API)
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).iconTheme.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}