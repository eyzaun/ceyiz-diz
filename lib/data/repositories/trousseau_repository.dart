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
}

