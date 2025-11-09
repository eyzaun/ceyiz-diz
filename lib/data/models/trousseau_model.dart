import 'package:cloud_firestore/cloud_firestore.dart';

class TrousseauModel {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final List<String> sharedWith;
  final List<String> editors;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, int> categoryCounts;
  final int totalProducts;
  final int purchasedProducts;
  final double totalBudget;
  final double spentAmount;
  final String coverImage;
  final Map<String, dynamic> settings;
  final int sortOrder;

  TrousseauModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    this.sharedWith = const [],
    this.editors = const [],
    required this.createdAt,
    required this.updatedAt,
    this.categoryCounts = const {},
    this.totalProducts = 0,
    this.purchasedProducts = 0,
    this.totalBudget = 0.0,
    this.spentAmount = 0.0,
    this.coverImage = '',
    this.settings = const {},
    this.sortOrder = 0,
  });

  factory TrousseauModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TrousseauModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      ownerId: data['ownerId'] ?? '',
      sharedWith: List<String>.from(data['sharedWith'] ?? []),
      editors: List<String>.from(data['editors'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      categoryCounts: Map<String, int>.from(data['categoryCounts'] ?? {}),
      totalProducts: data['totalProducts'] ?? 0,
      purchasedProducts: data['purchasedProducts'] ?? 0,
      totalBudget: (data['totalBudget'] ?? 0.0).toDouble(),
      spentAmount: (data['spentAmount'] ?? 0.0).toDouble(),
      coverImage: data['coverImage'] ?? '',
      settings: Map<String, dynamic>.from(data['settings'] ?? {}),
      sortOrder: data['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'sharedWith': sharedWith,
      'editors': editors,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'categoryCounts': categoryCounts,
      'totalProducts': totalProducts,
      'purchasedProducts': purchasedProducts,
      'totalBudget': totalBudget,
      'spentAmount': spentAmount,
      'coverImage': coverImage,
      'settings': settings,
      'sortOrder': sortOrder,
    };
  }

  TrousseauModel copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    List<String>? sharedWith,
    List<String>? editors,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, int>? categoryCounts,
    int? totalProducts,
    int? purchasedProducts,
    double? totalBudget,
    double? spentAmount,
    String? coverImage,
    Map<String, dynamic>? settings,
    int? sortOrder,
  }) {
    return TrousseauModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      sharedWith: sharedWith ?? this.sharedWith,
      editors: editors ?? this.editors,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryCounts: categoryCounts ?? this.categoryCounts,
      totalProducts: totalProducts ?? this.totalProducts,
      purchasedProducts: purchasedProducts ?? this.purchasedProducts,
      totalBudget: totalBudget ?? this.totalBudget,
      spentAmount: spentAmount ?? this.spentAmount,
      coverImage: coverImage ?? this.coverImage,
      settings: settings ?? this.settings,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  bool canEdit(String userId) {
    return ownerId == userId || editors.contains(userId);
  }

  bool canView(String userId) {
    return ownerId == userId || editors.contains(userId) || sharedWith.contains(userId);
  }
}