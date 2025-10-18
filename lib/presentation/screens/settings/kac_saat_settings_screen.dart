library;

/// Kaç Saat Ayarları Ekranı
///
/// Kullanıcıların maaş, çalışma günleri ve saatlerini girerek
/// ürün fiyatlarının kaç saatlik çalışmaya denk geldiğini görmelerini sağlar.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/services/kac_saat_calculator.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';

class KacSaatSettingsScreen extends StatefulWidget {
  const KacSaatSettingsScreen({super.key});

  @override
  State<KacSaatSettingsScreen> createState() => _KacSaatSettingsScreenState();
}

class _KacSaatSettingsScreenState extends State<KacSaatSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _salaryController = TextEditingController();
  final _hoursController = TextEditingController();
  final _quarterlyPrimController = TextEditingController();
  final _yearlyPrimController = TextEditingController();

  bool _enabled = false;
  bool _hasPrim = false;
  bool _quarterlyPrim = false;
  bool _yearlyPrim = false;

  final List<String> _allDays = [
    'pazartesi',
    'salı',
    'çarşamba',
    'perşembe',
    'cuma',
    'cumartesi',
    'pazar'
  ];

  final Map<String, String> _dayNames = {
    'pazartesi': 'Pazartesi',
    'salı': 'Salı',
    'çarşamba': 'Çarşamba',
    'perşembe': 'Perşembe',
    'cuma': 'Cuma',
    'cumartesi': 'Cumartesi',
    'pazar': 'Pazar',
  };

  List<String> _selectedDays = ['pazartesi', 'salı', 'çarşamba', 'perşembe', 'cuma'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settings = authProvider.currentUser?.kacSaatSettings ?? const KacSaatSettings();

    setState(() {
      _enabled = settings.enabled;
      _salaryController.text = settings.monthlySalary > 0 ? settings.monthlySalary.toStringAsFixed(0) : '';
      _hoursController.text = settings.dailyHours > 0 ? settings.dailyHours.toString() : '8';
      _selectedDays = List.from(settings.workingDays);
      _hasPrim = settings.hasPrim;
      _quarterlyPrim = settings.quarterlyPrim;
      _yearlyPrim = settings.yearlyPrim;
      _quarterlyPrimController.text = settings.quarterlyPrimAmount > 0 ? settings.quarterlyPrimAmount.toStringAsFixed(0) : '';
      _yearlyPrimController.text = settings.yearlyPrimAmount > 0 ? settings.yearlyPrimAmount.toStringAsFixed(0) : '';
    });
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _hoursController.dispose();
    _quarterlyPrimController.dispose();
    _yearlyPrimController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_enabled) {
      // Sadece enabled durumunu kaydet
      setState(() => _isLoading = true);
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final settings = const KacSaatSettings(enabled: false);
        await authProvider.updateKacSaatSettings(settings);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kaç Saat özelliği kapatıldı'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('En az bir gün seçmelisiniz'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_hasPrim && !_quarterlyPrim && !_yearlyPrim) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prim alıyorsanız, prim sıklığını seçmelisiniz'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final settings = KacSaatSettings(
        enabled: _enabled,
        monthlySalary: double.tryParse(_salaryController.text) ?? 0,
        workingDays: _selectedDays,
        dailyHours: double.tryParse(_hoursController.text) ?? 8,
        hasPrim: _hasPrim,
        quarterlyPrim: _quarterlyPrim,
        quarterlyPrimAmount: _quarterlyPrim ? (double.tryParse(_quarterlyPrimController.text) ?? 0) : 0,
        yearlyPrim: _yearlyPrim,
        yearlyPrimAmount: _yearlyPrim ? (double.tryParse(_yearlyPrimController.text) ?? 0) : 0,
      );

      await authProvider.updateKacSaatSettings(settings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ayarlar kaydedildi'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kaç Saat Ayarları'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Info card
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    AppSpacing.md.horizontalSpace,
                    Expanded(
                      child: Text(
                        'Bu özellik, ürün fiyatlarının kaç saatlik çalışmanıza denk geldiğini gösterir',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            AppSpacing.lg.verticalSpace,

            // Enable/Disable Switch
            Card(
              child: SwitchListTile(
                title: const Text('Kaç Saat Özelliğini Kullan'),
                subtitle: const Text('Ürün fiyatlarının yanında çalışma saati göster'),
                value: _enabled,
                onChanged: (value) {
                  setState(() => _enabled = value);
                },
              ),
            ),

            AppSpacing.lg.verticalSpace,

            if (_enabled) ...[
              // Salary Input
              Text(
                'Aylık Maaş (TL)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppTypography.semiBold,
                ),
              ),
              AppSpacing.sm.verticalSpace,
              AppTextInput(
                controller: _salaryController,
                label: 'Aylık Maaş',
                hint: 'Örneğin: 17000',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Maaş gereklidir';
                  }
                  final salary = double.tryParse(value);
                  if (salary == null || salary <= 0) {
                    return 'Geçerli bir maaş girin';
                  }
                  return null;
                },
                prefixIcon: const Icon(Icons.attach_money),
              ),

              AppSpacing.lg.verticalSpace,

              // Working Days
              Text(
                'Çalışma Günleri',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppTypography.semiBold,
                ),
              ),
              AppSpacing.sm.verticalSpace,
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _allDays.map((day) {
                      final isSelected = _selectedDays.contains(day);
                      return FilterChip(
                        label: Text(_dayNames[day]!),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDays.add(day);
                            } else {
                              _selectedDays.remove(day);
                            }
                          });
                        },
                        selectedColor: theme.colorScheme.primaryContainer,
                        checkmarkColor: theme.colorScheme.onPrimaryContainer,
                      );
                    }).toList(),
                  ),
                ),
              ),

              AppSpacing.lg.verticalSpace,

              // Daily Hours
              Text(
                'Günlük Çalışma Saati',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppTypography.semiBold,
                ),
              ),
              AppSpacing.sm.verticalSpace,
              AppTextInput(
                controller: _hoursController,
                label: 'Günlük Saat',
                hint: 'Örneğin: 8',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Çalışma saati gereklidir';
                  }
                  final hours = double.tryParse(value);
                  if (hours == null || hours <= 0 || hours > 24) {
                    return 'Geçerli bir saat girin (0-24)';
                  }
                  return null;
                },
                prefixIcon: const Icon(Icons.access_time),
              ),

              AppSpacing.lg.verticalSpace,

              // Prim Section
              Text(
                'Prim Bilgisi',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppTypography.semiBold,
                ),
              ),
              AppSpacing.sm.verticalSpace,
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Prim Alıyorum'),
                      value: _hasPrim,
                      onChanged: (value) {
                        setState(() {
                          _hasPrim = value;
                          if (!value) {
                            _quarterlyPrim = false;
                            _yearlyPrim = false;
                          }
                        });
                      },
                    ),
                    if (_hasPrim) ...[
                      const Divider(height: 1),
                      CheckboxListTile(
                        title: const Text('3 Ayda Bir'),
                        value: _quarterlyPrim,
                        onChanged: (value) {
                          setState(() {
                            _quarterlyPrim = value ?? false;
                            if (value == true && _quarterlyPrimController.text.isEmpty) {
                              _quarterlyPrimController.text = _salaryController.text;
                            }
                          });
                        },
                      ),
                      if (_quarterlyPrim)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            0,
                            AppSpacing.lg,
                            AppSpacing.md,
                          ),
                          child: AppTextInput(
                            controller: _quarterlyPrimController,
                            label: '3 Aylık Prim Miktarı (TL)',
                            hint: 'Maaşla aynı',
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: _quarterlyPrim
                                ? (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Prim miktarı gereklidir';
                                    }
                                    return null;
                                  }
                                : null,
                            prefixIcon: const Icon(Icons.payments),
                          ),
                        ),
                      const Divider(height: 1),
                      CheckboxListTile(
                        title: const Text('12 Ayda Bir'),
                        value: _yearlyPrim,
                        onChanged: (value) {
                          setState(() {
                            _yearlyPrim = value ?? false;
                            if (value == true && _yearlyPrimController.text.isEmpty) {
                              _yearlyPrimController.text = _salaryController.text;
                            }
                          });
                        },
                      ),
                      if (_yearlyPrim)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            0,
                            AppSpacing.lg,
                            AppSpacing.md,
                          ),
                          child: AppTextInput(
                            controller: _yearlyPrimController,
                            label: 'Yıllık Prim Miktarı (TL)',
                            hint: 'Maaşla aynı',
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: _yearlyPrim
                                ? (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Prim miktarı gereklidir';
                                    }
                                    return null;
                                  }
                                : null,
                            prefixIcon: const Icon(Icons.payments),
                          ),
                        ),
                    ],
                  ],
                ),
              ),

              AppSpacing.xl2.verticalSpace,
            ],

            // Save Button
            AppPrimaryButton(
              label: 'Kaydet',
              icon: Icons.check,
              onPressed: _isLoading ? null : _saveSettings,
              isLoading: _isLoading,
            ),

            AppSpacing.md.verticalSpace,
          ],
        ),
      ),
    );
  }
}
