import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String displayName;
  final IconData icon;
  final Color color;
  final int sortOrder;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.icon,
    required this.color,
    required this.sortOrder,
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

  static CategoryModel getCategoryById(String id) {
    return defaultCategories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => defaultCategories.last,
    );
  }
}