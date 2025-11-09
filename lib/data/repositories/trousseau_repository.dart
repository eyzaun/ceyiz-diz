import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../models/trousseau_model.dart';

class TrousseauRepository {
	final FirebaseFirestore _firestore;

	TrousseauRepository({FirebaseFirestore? firestore})
			: _firestore = firestore ?? FirebaseFirestore.instance;

	Future<List<TrousseauModel>> listOwned(String userId) async {
		final q = await _firestore
				.collection(AppConstants.trousseausCollection)
				.where('ownerId', isEqualTo: userId)
				.orderBy('updatedAt', descending: true)
				.get();
		return q.docs.map((e) => TrousseauModel.fromFirestore(e)).toList();
	}

	Future<List<TrousseauModel>> listShared(String userId) async {
		final q = await _firestore
				.collection(AppConstants.trousseausCollection)
				.where('sharedWith', arrayContains: userId)
				.orderBy('updatedAt', descending: true)
				.get();
		return q.docs.map((e) => TrousseauModel.fromFirestore(e)).toList();
	}

	Future<List<TrousseauModel>> listEditor(String userId) async {
		final q = await _firestore
				.collection(AppConstants.trousseausCollection)
				.where('editors', arrayContains: userId)
				.orderBy('updatedAt', descending: true)
				.get();
		return q.docs.map((e) => TrousseauModel.fromFirestore(e)).toList();
	}

	Future<void> create(TrousseauModel trousseau) async {
		await _firestore.collection(AppConstants.trousseausCollection).doc(trousseau.id).set(trousseau.toFirestore());
	}

	Future<void> update(String id, Map<String, dynamic> updates) async {
		await _firestore.collection(AppConstants.trousseausCollection).doc(id).update(updates);
	}

	Future<void> delete(String id) async {
		await _firestore.collection(AppConstants.trousseausCollection).doc(id).delete();
	}

	/// Update trousseau sort order
	Future<void> updateTrousseauOrder(String trousseauId, int newOrder) async {
		await _firestore.collection(AppConstants.trousseausCollection).doc(trousseauId).update({
			'sortOrder': newOrder,
			'updatedAt': FieldValue.serverTimestamp(),
		});
	}

	/// Batch update trousseau orders (for reordering multiple trousseaus at once)
	Future<void> updateTrousseauOrders(Map<String, int> trousseauOrders) async {
		final batch = _firestore.batch();

		trousseauOrders.forEach((trousseauId, order) {
			final docRef = _firestore.collection(AppConstants.trousseausCollection).doc(trousseauId);
			batch.update(docRef, {
				'sortOrder': order,
				'updatedAt': FieldValue.serverTimestamp(),
			});
		});

		await batch.commit();
	}

	/// Get user-specific trousseau order preferences
	Future<Map<String, int>> getUserTrousseauOrder(String userId) async {
		try {
			final doc = await _firestore
					.collection('user_preferences')
					.doc(userId)
					.get();
			
			if (doc.exists && doc.data()?['trousseauOrder'] != null) {
				final orderData = doc.data()!['trousseauOrder'] as Map<String, dynamic>;
				return orderData.map((key, value) => MapEntry(key, value as int));
			}
			return {};
		} catch (e) {
			return {};
		}
	}

	/// Update user-specific trousseau order preferences
	Future<void> updateUserTrousseauOrder(String userId, Map<String, int> trousseauOrder) async {
		await _firestore
				.collection('user_preferences')
				.doc(userId)
				.set({
			'trousseauOrder': trousseauOrder,
			'updatedAt': FieldValue.serverTimestamp(),
		}, SetOptions(merge: true));
	}
}


