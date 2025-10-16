import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../models/feedback_model.dart';

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
      // Admin reply fields - created as null so admin can fill them in Firebase Console
      'adminReply': null,
      'repliedAt': null,
      'repliedBy': null,
    };

    // Remove null values except for admin reply fields
    data.removeWhere((key, value) =>
      value == null && !['adminReply', 'repliedAt', 'repliedBy'].contains(key));

    await _col.add(data);
  }

  /// Get all feedback from a specific user
  Stream<List<FeedbackModel>> getUserFeedbackStream(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedbackModel.fromFirestore(doc))
            .toList());
  }

  /// Get user feedback as a one-time fetch
  Future<List<FeedbackModel>> getUserFeedback(String userId) async {
    final snapshot = await _col
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => FeedbackModel.fromFirestore(doc))
        .toList();
  }
}
