import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthRepository {
	final FirebaseAuth _auth;
	final FirebaseFirestore _firestore;
	final GoogleSignIn _googleSignIn;

	AuthRepository({
		FirebaseAuth? auth,
		FirebaseFirestore? firestore,
		GoogleSignIn? googleSignIn,
	})	: _auth = auth ?? FirebaseAuth.instance,
				_firestore = firestore ?? FirebaseFirestore.instance,
				_googleSignIn = googleSignIn ?? GoogleSignIn(
					// Web için client ID gerekli
					// Android/iOS için google-services.json'dan otomatik alınır
					clientId: kIsWeb 
						? '95358046515-uav630b45kfo7i9fpd58ruu7oc8tcju2.apps.googleusercontent.com'
						: null,
					scopes: <String>[
						'email',
						'profile',
					],
				);

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

	/// Google Sign-In
	///
	/// Returns (User, UserModel) tuple on success
	/// Throws FirebaseAuthException on failure
	Future<(User, UserModel)> signInWithGoogle() async {
		try {
			// IMPORTANT: Sign out from Google first to force account picker
			// This allows users to select different Google accounts each time
			await _googleSignIn.signOut();

			// Trigger Google Sign-In flow
			final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
			
			if (googleUser == null) {
				// User canceled the sign-in
				throw FirebaseAuthException(
					code: 'ERROR_ABORTED_BY_USER',
					message: 'Sign in aborted by user',
				);
			}

			// Obtain auth details from request
			final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

			// Create a new credential
			final credential = GoogleAuthProvider.credential(
				accessToken: googleAuth.accessToken,
				idToken: googleAuth.idToken,
			);

			// Sign in to Firebase with Google credential
			final UserCredential userCredential = await _auth.signInWithCredential(credential);
			final user = userCredential.user!;

			// Check if user document exists, if not create it
			final userDoc = await _firestore.collection(AppConstants.usersCollection).doc(user.uid).get();
			
			final model = userDoc.exists
					? UserModel.fromFirestore(userDoc)
					: await _createUserDoc(
							user,
							displayName: user.displayName ?? googleUser.displayName ?? googleUser.email.split('@').first,
							photoURL: user.photoURL ?? googleUser.photoUrl,
						);

			return (user, model);
		} on FirebaseAuthException {
			// Re-throw FirebaseAuthException as-is
			rethrow;
		} catch (e) {
			// Convert generic errors to FirebaseAuthException
			if (e.toString().contains('popup_closed_by_user') || 
			    e.toString().contains('popup_closed')) {
				throw FirebaseAuthException(
					code: 'popup_closed',
					message: 'Popup closed by user',
				);
			}
			
			// Generic error
			throw FirebaseAuthException(
				code: 'unknown',
				message: e.toString(),
			);
		}
	}

	/// Google Sign-Out
	/// 
	/// Signs out from both Firebase and Google
	Future<void> signOutGoogle() async {
		await Future.wait([
			_auth.signOut(),
			_googleSignIn.signOut(),
		]);
	}

	Future<UserModel> _createUserDoc(User user, {String? displayName, String? photoURL}) async {
		final model = UserModel(
			uid: user.uid,
			email: user.email ?? '',
			displayName: displayName ?? user.displayName ?? user.email?.split('@').first ?? 'Kullanıcı',
			photoURL: photoURL ?? user.photoURL,
			createdAt: DateTime.now(),
			lastLoginAt: DateTime.now(),
			trousseauIds: const [],
			sharedTrousseauIds: const [],
		);
		await _firestore.collection(AppConstants.usersCollection).doc(user.uid).set(model.toFirestore());
		return model;
	}
}

