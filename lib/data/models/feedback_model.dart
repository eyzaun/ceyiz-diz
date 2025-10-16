import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String message;
  final String? userId;
  final String? email;
  final int? rating;
  final String? appVersion;
  final String? platform;
  final DateTime createdAt;

  // Admin reply fields
  final String? adminReply;
  final DateTime? repliedAt;
  final String? repliedBy;

  FeedbackModel({
    required this.id,
    required this.message,
    this.userId,
    this.email,
    this.rating,
    this.appVersion,
    this.platform,
    required this.createdAt,
    this.adminReply,
    this.repliedAt,
    this.repliedBy,
  });

  factory FeedbackModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedbackModel(
      id: doc.id,
      message: data['message'] ?? '',
      userId: data['userId'],
      email: data['email'],
      rating: data['rating'],
      appVersion: data['appVersion'],
      platform: data['platform'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      adminReply: data['adminReply'],
      repliedAt: (data['repliedAt'] as Timestamp?)?.toDate(),
      repliedBy: data['repliedBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'message': message,
      'userId': userId,
      'email': email,
      'rating': rating,
      'appVersion': appVersion,
      'platform': platform,
      'createdAt': Timestamp.fromDate(createdAt),
      'adminReply': adminReply,
      'repliedAt': repliedAt != null ? Timestamp.fromDate(repliedAt!) : null,
      'repliedBy': repliedBy,
    };
  }

  bool get hasReply => adminReply != null && adminReply!.isNotEmpty;
}
