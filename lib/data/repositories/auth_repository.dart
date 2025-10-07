import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthRepository {
	final FirebaseAuth _auth;
	final FirebaseFirestore _firestore;

	AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
			: _auth = auth ?? FirebaseAuth.instance,
				_firestore = firestore ?? FirebaseFirestore.instance;

	Stream<User?> authStateChanges() => _auth.authStateChanges();

	Future<(User, UserModel)> signIn(String email, String password) async {
		final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
		final user = cred.user!;
		final userDoc = await _firestore.collection(AppConstants.usersCollection).doc(user.uid).get();
		final model = userDoc.exists
				? UserModel.fromFirestore(userDoc)
				: await _createUserDoc(user);
		return (user, model);
	}

	Future<(User, UserModel)> signUp(String email, String password, String displayName) async {
		final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
		await cred.user!.updateDisplayName(displayName);
		final model = await _createUserDoc(cred.user!, displayName: displayName);
		return (cred.user!, model);
	}

	Future<void> signOut() => _auth.signOut();

	Future<void> sendPasswordResetEmail(String email) => _auth.sendPasswordResetEmail(email: email);

	Future<UserModel> _createUserDoc(User user, {String? displayName}) async {
		final model = UserModel(
			uid: user.uid,
			email: user.email ?? '',
			displayName: displayName ?? user.displayName ?? user.email?.split('@').first ?? 'Kullanıcı',
			createdAt: DateTime.now(),
			lastLoginAt: DateTime.now(),
			trousseauIds: const [],
			sharedTrousseauIds: const [],
		);
		await _firestore.collection(AppConstants.usersCollection).doc(user.uid).set(model.toFirestore());
		return model;
	}
}

