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
  /// We don't persist icon/color; instead they are derived consistently from the ID.
  factory CategoryModel.fromMap(Map<String, dynamic> data, String id) {
    final name = (data['name'] ?? id).toString();
    final displayName = (data['displayName'] ?? name).toString();
    final sortOrder = (data['sortOrder'] is int)
        ? data['sortOrder'] as int
        : int.tryParse('${data['sortOrder']}') ?? 1000;
    return CategoryModel(
      id: id,
      name: name,
      displayName: displayName,
      icon: Icons.category,
      color: colorFromString(id),
      sortOrder: sortOrder,
      isCustom: true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'displayName': displayName,
      'sortOrder': sortOrder,
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