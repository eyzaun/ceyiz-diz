import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../services/firebase_service.dart';

class CategoryRepository {
  static CollectionReference<Map<String, dynamic>> _col(String trousseauId) {
    return FirebaseService.firestore
        .collection('trousseaus')
        .doc(trousseauId)
        .collection('categories');
  }

  Stream<List<CategoryModel>> streamCategories(String trousseauId) {
    // Get all categories for this trousseau (no user filtering needed)
    return _col(trousseauId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CategoryModel.fromMap(d.data(), d.id))
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)));
  }

  Future<void> addCategory(String trousseauId, {
    required String id,
    required String name,
    required String displayName,
    int sortOrder = 1000,
    int? iconCode,
    int? colorValue,
    bool isCustom = false,
  }) async {
    final data = {
      'name': name,
      'displayName': displayName,
      'sortOrder': sortOrder,
      'iconCode': iconCode,
      'colorValue': colorValue ?? CategoryModel.colorFromString(id).toARGB32(),
      'isCustom': isCustom,
    };

    await _col(trousseauId).doc(id).set(data);
  }

  Future<void> removeCategory(String trousseauId, String id) async {
    await _col(trousseauId).doc(id).delete();
  }

  Future<void> renameCategory(String trousseauId, String id, String newName) async {
    await _col(trousseauId).doc(id).update({
      'name': newName,
      'displayName': newName,
    });
  }

  Future<void> updateCategory(String trousseauId, String id, {
    String? name,
    int? iconCode,
    int? colorValue,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) {
      updates['name'] = name;
      updates['displayName'] = name;
    }
    if (iconCode != null) {
      updates['iconCode'] = iconCode;
      // Try to find iconKey for the codePoint
      String? iconKey;
      for (final entry in kCategoryIcons.entries) {
        if (entry.value.codePoint == iconCode) {
          iconKey = entry.key;
          break;
        }
      }
      if (iconKey != null) updates['iconKey'] = iconKey;
    }
    if (colorValue != null) updates['colorValue'] = colorValue;
    
    if (updates.isNotEmpty) {
      await _col(trousseauId).doc(id).update(updates);
    }
  }
  
  /// Initialize default categories for a new trousseau
  Future<void> initializeDefaultCategories(String trousseauId) async {
    final batch = FirebaseService.firestore.batch();
    
    for (final category in CategoryModel.defaultCategories) {
      final docRef = _col(trousseauId).doc(category.id);
      batch.set(docRef, {
        'name': category.name,
        'displayName': category.displayName,
        'sortOrder': category.sortOrder,
        'iconCode': category.icon.codePoint,
        'colorValue': category.color.toARGB32(),
        'isCustom': false,
      });
    }
    
    await batch.commit();
  }
}
