import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/kac_saat_calculator.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final List<String> trousseauIds;
  final List<String> sharedTrousseauIds;
  final List<String> pinnedSharedTrousseauIds;
  final KacSaatSettings kacSaatSettings;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.lastLoginAt,
    this.trousseauIds = const [],
    this.sharedTrousseauIds = const [],
    this.pinnedSharedTrousseauIds = const [],
    this.kacSaatSettings = const KacSaatSettings(),
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
      trousseauIds: List<String>.from(data['trousseauIds'] ?? []),
      sharedTrousseauIds: List<String>.from(data['sharedTrousseauIds'] ?? []),
      pinnedSharedTrousseauIds: List<String>.from(data['pinnedSharedTrousseauIds'] ?? []),
      kacSaatSettings: data['kacSaatSettings'] != null
          ? KacSaatSettings.fromJson(data['kacSaatSettings'])
          : const KacSaatSettings(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      // Store a normalized lowercased email to allow case-insensitive search
      'emailLower': email.trim().toLowerCase(),
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'trousseauIds': trousseauIds,
      'sharedTrousseauIds': sharedTrousseauIds,
      'pinnedSharedTrousseauIds': pinnedSharedTrousseauIds,
      'kacSaatSettings': kacSaatSettings.toJson(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    List<String>? trousseauIds,
    List<String>? sharedTrousseauIds,
    List<String>? pinnedSharedTrousseauIds,
    KacSaatSettings? kacSaatSettings,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      trousseauIds: trousseauIds ?? this.trousseauIds,
      sharedTrousseauIds: sharedTrousseauIds ?? this.sharedTrousseauIds,
      pinnedSharedTrousseauIds: pinnedSharedTrousseauIds ?? this.pinnedSharedTrousseauIds,
      kacSaatSettings: kacSaatSettings ?? this.kacSaatSettings,
    );
  }
}
