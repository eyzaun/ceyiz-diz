library;

/// Kaç Saat Ayarları Ekranı
///
/// Kullanıcıların maaş, çalışma günleri ve saatlerini girerek
/// ürün fiyatlarının kaç saatlik çalışmaya denk geldiğini görmelerini sağlar.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/services/kac_saat_calculator.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/generated/app_localizations.dart';
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

  List<String> _selectedDays = ['pazartesi', 'salı', 'çarşamba', 'perşembe', 'cuma'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    // Text değişikliklerini dinle ve otomatik kaydet
    _salaryController.addListener(_saveDraft);
    _hoursController.addListener(_saveDraft);
    _quarterlyPrimController.addListener(_saveDraft);
    _yearlyPrimController.addListener(_saveDraft);
  }

  Future<void> _loadSettings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settings = authProvider.currentUser?.kacSaatSettings ?? const KacSaatSettings();

    // Önce draft verileri yükle (varsa)
    final prefs = await SharedPreferences.getInstance();
    final hasDraft = prefs.containsKey('kacSaat_draft_salary');

    setState(() {
      _enabled = settings.enabled;
      
      // Draft varsa draft'tan yükle, yoksa settings'den yükle
      if (hasDraft) {
        _salaryController.text = prefs.getString('kacSaat_draft_salary') ?? '';
        _hoursController.text = prefs.getString('kacSaat_draft_hours') ?? '8';
        _quarterlyPrimController.text = prefs.getString('kacSaat_draft_quarterlyPrim') ?? '';
        _yearlyPrimController.text = prefs.getString('kacSaat_draft_yearlyPrim') ?? '';
        _selectedDays = prefs.getStringList('kacSaat_draft_days') ?? settings.workingDays;
        _hasPrim = prefs.getBool('kacSaat_draft_hasPrim') ?? settings.hasPrim;
        _quarterlyPrim = prefs.getBool('kacSaat_draft_quarterlyPrimEnabled') ?? settings.quarterlyPrim;
        _yearlyPrim = prefs.getBool('kacSaat_draft_yearlyPrimEnabled') ?? settings.yearlyPrim;
      } else {
        _salaryController.text = settings.monthlySalary > 0 ? CurrencyFormatter.format(settings.monthlySalary) : '';
        _hoursController.text = settings.dailyHours > 0 ? settings.dailyHours.toString() : '8';
        _selectedDays = List.from(settings.workingDays);
        _hasPrim = settings.hasPrim;
        _quarterlyPrim = settings.quarterlyPrim;
        _yearlyPrim = settings.yearlyPrim;
        _quarterlyPrimController.text = settings.quarterlyPrimAmount > 0 ? CurrencyFormatter.format(settings.quarterlyPrimAmount) : '';
        _yearlyPrimController.text = settings.yearlyPrimAmount > 0 ? CurrencyFormatter.format(settings.yearlyPrimAmount) : '';
      }
    });
  }

  // Draft verileri kaydet (otomatik)
  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kacSaat_draft_salary', _salaryController.text);
    await prefs.setString('kacSaat_draft_hours', _hoursController.text);
    await prefs.setString('kacSaat_draft_quarterlyPrim', _quarterlyPrimController.text);
    await prefs.setString('kacSaat_draft_yearlyPrim', _yearlyPrimController.text);
    await prefs.setStringList('kacSaat_draft_days', _selectedDays);
    await prefs.setBool('kacSaat_draft_hasPrim', _hasPrim);
    await prefs.setBool('kacSaat_draft_quarterlyPrimEnabled', _quarterlyPrim);
    await prefs.setBool('kacSaat_draft_yearlyPrimEnabled', _yearlyPrim);
  }

  // Draft verileri temizle (kayıt başarılı olduğunda)
  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('kacSaat_draft_salary');
    await prefs.remove('kacSaat_draft_hours');
    await prefs.remove('kacSaat_draft_quarterlyPrim');
    await prefs.remove('kacSaat_draft_yearlyPrim');
    await prefs.remove('kacSaat_draft_days');
    await prefs.remove('kacSaat_draft_hasPrim');
    await prefs.remove('kacSaat_draft_quarterlyPrimEnabled');
    await prefs.remove('kacSaat_draft_yearlyPrimEnabled');
  }

  @override
  void dispose() {
    _salaryController.removeListener(_saveDraft);
    _hoursController.removeListener(_saveDraft);
    _quarterlyPrimController.removeListener(_saveDraft);
    _yearlyPrimController.removeListener(_saveDraft);
    _salaryController.dispose();
    _hoursController.dispose();
    _quarterlyPrimController.dispose();
    _yearlyPrimController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final l10n = AppLocalizations.of(context);
    
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
        SnackBar(
          content: Text(l10n?.selectAtLeastOneDay ?? 'You must select at least one day'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_hasPrim && !_quarterlyPrim && !_yearlyPrim) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.selectBonusFrequency ?? 'If you receive bonus, you must select bonus frequency'),
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
        monthlySalary: CurrencyFormatter.parse(_salaryController.text) ?? 0,
        workingDays: _selectedDays,
        dailyHours: double.tryParse(_hoursController.text) ?? 8,
        hasPrim: _hasPrim,
        quarterlyPrim: _quarterlyPrim,
        quarterlyPrimAmount: _quarterlyPrim ? (CurrencyFormatter.parse(_quarterlyPrimController.text) ?? 0) : 0,
        yearlyPrim: _yearlyPrim,
        yearlyPrimAmount: _yearlyPrim ? (CurrencyFormatter.parse(_yearlyPrimController.text) ?? 0) : 0,
      );

      await authProvider.updateKacSaatSettings(settings);

      // Başarılı kayıttan sonra draft'ı temizle
      await _clearDraft();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.settingsSaved ?? 'Settings saved'),
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.kacSaatSettings ?? 'Work Hours Settings'),
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
                        l10n?.kacSaatFeatureInfo ?? 'This feature shows how many hours of work product prices are equivalent to',
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
                title: Text(l10n?.useKacSaatFeature ?? 'Use Work Hours Feature'),
                subtitle: Text(l10n?.showWorkHoursPrices ?? 'Show work hours next to product prices'),
                value: _enabled,
                onChanged: (value) {
                  setState(() => _enabled = value);
                  _saveDraft(); // Draft kaydet
                },
              ),
            ),

            AppSpacing.lg.verticalSpace,

            if (_enabled) ...[
              // Salary Input
              Text(
                l10n?.monthlySalaryTL ?? 'Monthly Salary (TL)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppTypography.semiBold,
                ),
              ),
              AppSpacing.sm.verticalSpace,
              AppTextInput(
                controller: _salaryController,
                label: l10n?.monthlySalary ?? 'Monthly Salary',
                hint: l10n?.forExample17000 ?? 'For example: 17.000',
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n?.salaryRequired ?? 'Salary is required';
                  }
                  final salary = CurrencyFormatter.parse(value);
                  if (salary == null || salary <= 0) {
                    return l10n?.enterValidSalary ?? 'Enter a valid salary';
                  }
                  return null;
                },
                prefixIcon: const Icon(Icons.attach_money),
              ),

              AppSpacing.lg.verticalSpace,

              // Working Days
              Text(
                l10n?.workingDays ?? 'Working Days',
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
                      final dayName = day == 'pazartesi' ? (l10n?.monday ?? 'Monday')
                        : day == 'salı' ? (l10n?.tuesday ?? 'Tuesday')
                        : day == 'çarşamba' ? (l10n?.wednesday ?? 'Wednesday')
                        : day == 'perşembe' ? (l10n?.thursday ?? 'Thursday')
                        : day == 'cuma' ? (l10n?.friday ?? 'Friday')
                        : day == 'cumartesi' ? (l10n?.saturday ?? 'Saturday')
                        : (l10n?.sunday ?? 'Sunday');
                      return FilterChip(
                        label: Text(dayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDays.add(day);
                            } else {
                              _selectedDays.remove(day);
                            }
                          });
                          _saveDraft(); // Draft kaydet
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
                l10n?.dailyWorkHours ?? 'Daily Work Hours',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppTypography.semiBold,
                ),
              ),
              AppSpacing.sm.verticalSpace,
              AppTextInput(
                controller: _hoursController,
                label: l10n?.dailyHours ?? 'Daily Hours',
                hint: l10n?.forExample8 ?? 'For example: 8',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n?.workHoursRequired ?? 'Work hours are required';
                  }
                  final hours = double.tryParse(value);
                  if (hours == null || hours <= 0 || hours > 24) {
                    return l10n?.enterValidHours024 ?? 'Enter valid hours (0-24)';
                  }
                  return null;
                },
                prefixIcon: const Icon(Icons.access_time),
              ),

              AppSpacing.lg.verticalSpace,

              // Prim Section
              Text(
                l10n?.bonusInfo ?? 'Bonus Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppTypography.semiBold,
                ),
              ),
              AppSpacing.sm.verticalSpace,
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(l10n?.iReceiveBonus ?? 'I Receive Bonus'),
                      value: _hasPrim,
                      onChanged: (value) {
                        setState(() {
                          _hasPrim = value;
                          if (!value) {
                            _quarterlyPrim = false;
                            _yearlyPrim = false;
                          }
                        });
                        _saveDraft(); // Draft kaydet
                      },
                    ),
                    if (_hasPrim) ...[
                      const Divider(height: 1),
                      CheckboxListTile(
                        title: Text(l10n?.every3Months ?? 'Every 3 Months'),
                        value: _quarterlyPrim,
                        onChanged: (value) {
                          setState(() {
                            _quarterlyPrim = value ?? false;
                            if (value == true && _quarterlyPrimController.text.isEmpty) {
                              _quarterlyPrimController.text = _salaryController.text;
                            }
                          });
                          _saveDraft(); // Draft kaydet
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
                            label: l10n?.quarterlyBonusAmountTL ?? 'Quarterly Bonus Amount (TL)',
                            hint: l10n?.sameAsSalary ?? 'Same as salary',
                            keyboardType: TextInputType.number,
                            inputFormatters: [CurrencyInputFormatter()],
                            validator: _quarterlyPrim
                                ? (value) {
                                    if (value == null || value.isEmpty) {
                                      return l10n?.bonusAmountRequired ?? 'Bonus amount is required';
                                    }
                                    return null;
                                  }
                                : null,
                            prefixIcon: const Icon(Icons.payments),
                          ),
                        ),
                      const Divider(height: 1),
                      CheckboxListTile(
                        title: Text(l10n?.every12Months ?? 'Every 12 Months'),
                        value: _yearlyPrim,
                        onChanged: (value) {
                          setState(() {
                            _yearlyPrim = value ?? false;
                            if (value == true && _yearlyPrimController.text.isEmpty) {
                              _yearlyPrimController.text = _salaryController.text;
                            }
                          });
                          _saveDraft(); // Draft kaydet
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
                            label: l10n?.yearlyBonusAmountTL ?? 'Yearly Bonus Amount (TL)',
                            hint: l10n?.sameAsSalary ?? 'Same as salary',
                            keyboardType: TextInputType.number,
                            inputFormatters: [CurrencyInputFormatter()],
                            validator: _yearlyPrim
                                ? (value) {
                                    if (value == null || value.isEmpty) {
                                      return l10n?.bonusAmountRequired ?? 'Bonus amount is required';
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
              label: l10n?.save ?? 'Save',
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
