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
    return _col(trousseauId)
        .orderBy('sortOrder', descending: false)
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
  }) async {
    final data = CategoryModel(
      id: id,
      name: name,
      displayName: displayName ?? name,
      icon: CategoryModel.getDefaultById('other').icon,
      color: CategoryModel.colorFromString(id),
      sortOrder: sortOrder,
      isCustom: true,
    ).toMap();

    await _col(trousseauId).doc(id).set(data, SetOptions(merge: true));
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
