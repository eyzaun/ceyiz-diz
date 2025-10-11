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

  Stream<List<CategoryModel>> streamCategories(String trousseauId, String userId) {
    // Filter to only categories created by the current user; sort client-side
    return _col(trousseauId)
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CategoryModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<void> addCategory(String trousseauId, {
    required String id,
    required String name,
    String? displayName,
    int sortOrder = 1000,
    required String createdBy,
    int? iconCode,
    int? colorValue,
  }) async {
    final data = {
      'name': name,
      'displayName': displayName ?? name,
      'sortOrder': sortOrder,
      'iconCode': iconCode,
      'colorValue': colorValue ?? CategoryModel.colorFromString(id).toARGB32(),
    };

    await _col(trousseauId).doc(id).set({
      ...data,
      'createdBy': createdBy,
    }, SetOptions(merge: true));
  }

  Future<void> removeCategory(String trousseauId, String id) async {
    await _col(trousseauId).doc(id).delete();
  }

  Future<void> renameCategory(String trousseauId, String id, String newName) async {
    await _col(trousseauId).doc(id).set({
      'name': newName,
      'displayName': newName,
    }, SetOptions(merge: true));
  }
}
