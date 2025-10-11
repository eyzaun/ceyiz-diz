import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String displayName;
  final IconData icon;
  final Color color;
  final int sortOrder;
  final bool isCustom;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.icon,
    required this.color,
    required this.sortOrder,
    this.isCustom = false,
  });

  static const List<CategoryModel> defaultCategories = [
    CategoryModel(
      id: 'livingroom',
      name: 'livingroom',
      displayName: 'Salon',
      icon: Icons.weekend,
      color: Color(0xFF6B4EFF),
      sortOrder: 1,
    ),
    CategoryModel(
      id: 'kitchen',
      name: 'kitchen',
      displayName: 'Mutfak',
      icon: Icons.kitchen,
      color: Color(0xFFFF6B9D),
      sortOrder: 2,
    ),
    CategoryModel(
      id: 'bathroom',
      name: 'bathroom',
      displayName: 'Banyo',
      icon: Icons.bathtub,
      color: Color(0xFF00C896),
      sortOrder: 3,
    ),
    CategoryModel(
      id: 'bedroom',
      name: 'bedroom',
      displayName: 'Yatak Odası',
      icon: Icons.bed,
      color: Color(0xFF2196F3),
      sortOrder: 4,
    ),
    CategoryModel(
      id: 'clothing',
      name: 'clothing',
      displayName: 'Kıyafet',
      icon: Icons.checkroom,
      color: Color(0xFF9C27B0),
      sortOrder: 5,
    ),
    CategoryModel(
      id: 'other',
      name: 'other',
      displayName: 'Diğer',
      icon: Icons.category,
      color: Color(0xFF607D8B),
      sortOrder: 6,
    ),
  ];

  /// Returns a default category by id, or 'other' if not found.
  static CategoryModel getDefaultById(String id) {
    return defaultCategories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => defaultCategories.last,
    );
  }

  /// Backwards-compatible alias for legacy code.
  static CategoryModel getCategoryById(String id) => getDefaultById(id);

  /// Construct a custom category from Firestore data.
  factory CategoryModel.fromMap(Map<String, dynamic> data, String id) {
    final name = (data['name'] ?? id).toString();
    final displayName = (data['displayName'] ?? name).toString();
    final sortOrder = (data['sortOrder'] is int)
        ? data['sortOrder'] as int
        : int.tryParse('${data['sortOrder']}') ?? 1000;
  // Optional persisted visuals
  final String? iconKey = data['iconKey'] as String?;
  final int? iconCode = data['iconCode'] is int
    ? data['iconCode'] as int
    : int.tryParse('${data['iconCode']}');
  final int? colorValue = data['colorValue'] is int
    ? data['colorValue'] as int
    : int.tryParse('${data['colorValue']}');
    return CategoryModel(
      id: id,
      name: name,
      displayName: displayName,
    icon: _resolveIcon(iconKey: iconKey, iconCode: iconCode),
      color: colorValue != null ? Color(colorValue) : colorFromString(id),
      sortOrder: sortOrder,
      isCustom: true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'displayName': displayName,
      'sortOrder': sortOrder,
      // Persist visuals for custom categories
      'iconCode': icon.codePoint,
      'iconKey': iconKeyFor(icon),
  'colorValue': color.toARGB32(),
    };
  }

  /// Computes a consistent color from a string.
  static Color colorFromString(String input) {
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      hash = input.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final double hue = (hash % 360).toDouble();
    final hsv = HSVColor.fromAHSV(1.0, hue, 0.45, 0.85);
    return hsv.toColor();
  }
}

// A curated set of icons that the app supports for custom categories.
// Using const IconData references here keeps the icon font shakeable and avoids
// runtime IconData constructions which break web builds.
const Map<String, IconData> kCategoryIcons = <String, IconData>{
  'category': Icons.category,
  'kitchen': Icons.kitchen,
  'weekend': Icons.weekend,
  'bathtub': Icons.bathtub,
  'bed': Icons.bed,
  'checkroom': Icons.checkroom,
  'chair_alt': Icons.chair_alt,
  'blender': Icons.blender,
  'coffee_maker': Icons.coffee_maker,
  'lightbulb': Icons.lightbulb,
  'tv': Icons.tv,
  'cleaning_services': Icons.cleaning_services,
  'soup_kitchen': Icons.soup_kitchen,
  'iron': Icons.iron,
};

IconData _resolveIcon({String? iconKey, int? iconCode}) {
  if (iconKey != null) {
    final v = kCategoryIcons[iconKey];
    if (v != null) return v;
  }
  if (iconCode != null) {
    // Best-effort: find matching const icon by codePoint
    for (final entry in kCategoryIcons.entries) {
      if (entry.value.codePoint == iconCode) return entry.value;
    }
  }
  return Icons.category;
}

String? iconKeyFor(IconData icon) {
  for (final entry in kCategoryIcons.entries) {
    if (entry.value.codePoint == icon.codePoint && entry.value.fontFamily == icon.fontFamily) {
      return entry.key;
    }
  }
  return null;
}