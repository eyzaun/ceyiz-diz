import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String trousseauId;
  final String name;
  final String description;
  final double price;
  final String category;
  final List<String> images;
  final String link;
  final String link2;
  final String link3;
  final bool isPurchased;
  final DateTime? purchaseDate;
  final String purchasedBy;
  final int quantity;
  final String addedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> customFields;

  ProductModel({
    required this.id,
    required this.trousseauId,
    required this.name,
    this.description = '',
    required this.price,
    required this.category,
    this.images = const [],
    this.link = '',
    this.link2 = '',
    this.link3 = '',
    this.isPurchased = false,
    this.purchaseDate,
    this.purchasedBy = '',
    this.quantity = 1,
    required this.addedBy,
    required this.createdAt,
    required this.updatedAt,
    this.customFields = const {},
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      trousseauId: data['trousseauId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      category: data['category'] ?? 'other',
      images: List<String>.from(data['images'] ?? []),
      link: data['link'] ?? '',
      link2: data['link2'] ?? '',
      link3: data['link3'] ?? '',
      isPurchased: data['isPurchased'] ?? false,
      purchaseDate: data['purchaseDate'] != null
          ? (data['purchaseDate'] as Timestamp).toDate()
          : null,
      purchasedBy: data['purchasedBy'] ?? '',
      quantity: data['quantity'] ?? 1,
      addedBy: data['addedBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      customFields: Map<String, dynamic>.from(data['customFields'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'trousseauId': trousseauId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'images': images,
      'link': link,
      'link2': link2,
      'link3': link3,
      'isPurchased': isPurchased,
      'purchaseDate': purchaseDate != null
          ? Timestamp.fromDate(purchaseDate!)
          : null,
      'purchasedBy': purchasedBy,
      'quantity': quantity,
      'addedBy': addedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'customFields': customFields,
    };
  }

  ProductModel copyWith({
    String? id,
    String? trousseauId,
    String? name,
    String? description,
    double? price,
    String? category,
    List<String>? images,
    String? link,
    String? link2,
    String? link3,
    bool? isPurchased,
    DateTime? purchaseDate,
    String? purchasedBy,
    int? quantity,
    String? addedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? customFields,
  }) {
    return ProductModel(
      id: id ?? this.id,
      trousseauId: trousseauId ?? this.trousseauId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      images: images ?? this.images,
      link: link ?? this.link,
      link2: link2 ?? this.link2,
      link3: link3 ?? this.link3,
      isPurchased: isPurchased ?? this.isPurchased,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasedBy: purchasedBy ?? this.purchasedBy,
      quantity: quantity ?? this.quantity,
      addedBy: addedBy ?? this.addedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customFields: customFields ?? this.customFields,
    );
  }

  double get totalPrice => price * quantity;
}