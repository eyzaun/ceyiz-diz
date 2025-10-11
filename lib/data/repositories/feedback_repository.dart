import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class FeedbackRepository {
  static const String collectionPath = 'feedback';

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseService.firestore.collection(collectionPath);

  Future<void> submit({
    required String message,
    String? userId,
    String? email,
    int? rating,
    String? appVersion,
    String? platform,
  }) async {
    final now = FieldValue.serverTimestamp();
    final data = <String, dynamic>{
      'message': message,
      'userId': userId,
      'email': email,
      'rating': rating,
      'appVersion': appVersion,
      'platform': platform,
      'createdAt': now,
    }..removeWhere((key, value) => value == null);

    await _col.add(data);
  }
}
