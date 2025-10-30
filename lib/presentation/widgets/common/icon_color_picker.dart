import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../data/models/category_model.dart';

class IconColorResult {
  final IconData icon;
  final Color color;
  const IconColorResult(this.icon, this.color);
}

class IconColorPicker extends StatefulWidget {
  final IconData initialIcon;
  final Color initialColor;
  const IconColorPicker({super.key, this.initialIcon = Icons.category, this.initialColor = const Color(0xFF607D8B)});

  static Future<IconColorResult?> pick(BuildContext context, {IconData? icon, Color? color}) {
    return showDialog<IconColorResult>(
      context: context,
      builder: (ctx) => Dialog(
        child: SizedBox(
          width: 420,
          child: IconColorPicker(initialIcon: icon ?? Icons.category, initialColor: color ?? const Color(0xFF607D8B)),
        ),
      ),
    );
  }

  @override
  State<IconColorPicker> createState() => _IconColorPickerState();
}

class _IconColorPickerState extends State<IconColorPicker> {
  late IconData _icon;
  late Color _color;

  // Use the full icon catalog from category_model
  static final _iconChoices = kCategoryIcons.values.toList();

  static const _colorChoices = <Color>[
    Color(0xFF6B4EFF),
    Color(0xFFFF6B9D),
    Color(0xFF00C896),
    Color(0xFF2196F3),
    Color(0xFF9C27B0),
    Color(0xFF607D8B),
    Color(0xFFFF9800),
    Color(0xFF4CAF50),
    Color(0xFFE91E63),
    Color(0xFF3F51B5),
    Color(0xFFF44336),
    Color(0xFF673AB7),
    Color(0xFF009688),
    Color(0xFFFFEB3B),
    Color(0xFF795548),
    Color(0xFF9E9E9E),
  ];

  @override
  void initState() {
    super.initState();
    _icon = widget.initialIcon;
    _color = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: _color.withValues(alpha: 0.15), child: Icon(_icon, color: _color)),
              const SizedBox(width: 12),
              Text(l10n?.selectSymbolAndColor ?? 'Sembol ve Renk Seçin', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context, null), icon: const Icon(Icons.close)),
            ],
          ),
        const SizedBox(height: 16),
          Text(l10n?.symbol ?? 'Symbol', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SizedBox(
            height: 320,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: _iconChoices.length,
              itemBuilder: (context, i) {
                final ic = _iconChoices[i];
                final selected = ic.codePoint == _icon.codePoint;
                return InkWell(
                  onTap: () => setState(() => _icon = ic),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: selected ? Theme.of(context).colorScheme.primary : Colors.transparent, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Icon(ic, size: 20, color: selected ? Theme.of(context).colorScheme.primary : null)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n?.color ?? 'Color', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _colorChoices.map((c) {
              final selected = c.toARGB32() == _color.toARGB32();
              return GestureDetector(
                onTap: () => setState(() => _color = c),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(color: selected ? Colors.white : Colors.black12, width: selected ? 3 : 1),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, IconColorResult(_icon, _color)),
              icon: const Icon(Icons.check),
              label: Text(l10n?.save ?? 'Kaydet'),
            ),
          ),
        ],
      ),
    );
  }
}
