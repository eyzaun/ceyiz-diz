import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/category_repository.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
  loading,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CategoryRepository _categoryRepo = CategoryRepository();
  
  User? _firebaseUser;
  UserModel? _currentUser;
  AuthStatus _status = AuthStatus.uninitialized;
  String _errorMessage = '';
  bool _updateAvailable = false;
  String _latestVersion = '';
  bool _forceUpdate = false;
  String _updateMessage = 'Uygulamanın yeni bir sürümü mevcut. Daha iyi deneyim için lütfen güncelleyin.';
  
  AuthProvider() {
    _init();
  }
  
  User? get firebaseUser => _firebaseUser;
  UserModel? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get updateAvailable => _updateAvailable;
  String get latestVersion => _latestVersion;
  bool get forceUpdate => _forceUpdate;
  String get updateMessage => _updateMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  
  void _init() {
    // Ensure web persistence is LOCAL so auth survives reloads and headers attach
    if (kIsWeb) {
      _auth.setPersistence(Persistence.LOCAL).catchError((_) {});
    }
    
    // Check for updates immediately on init (fire and forget)
    _checkForUpdates();
    
    _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        _status = AuthStatus.unauthenticated;
        _currentUser = null;
        _firebaseUser = null;
      } else {
        _firebaseUser = user;
        await _loadUserData(user.uid);
        _status = AuthStatus.authenticated;
      }
      notifyListeners();
    });
  }
  
  Future<void> _loadUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      
      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);
        // Ensure a single trousseau exists for this user
        await _ensureSingleTrousseau(_currentUser!);
        await _updateLastLogin();
        await _checkForUpdates();
      } else {
        await _createUserDocument();
      }
    } catch (e) {
      _errorMessage = 'Kullanıcı verisi yüklenemedi: ${e.toString()}';
      notifyListeners();
    }
  }
  
  Future<void> _createUserDocument() async {
    if (_firebaseUser == null) return;
    
    try {
      final userModel = UserModel(
        uid: _firebaseUser!.uid,
        email: _firebaseUser!.email ?? '',
        displayName: _firebaseUser!.displayName ?? _firebaseUser!.email?.split('@')[0] ?? 'Kullanıcı',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        trousseauIds: [],
        sharedTrousseauIds: [],
      );
      
      await _firestore
          .collection('users')
          .doc(_firebaseUser!.uid)
          .set(userModel.toFirestore());
      
      _currentUser = userModel;
      // Create initial trousseau for this new user
      await _ensureSingleTrousseau(_currentUser!);
    } catch (e) {
      _errorMessage = 'Kullanıcı belgesi oluşturulamadı: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Ensure the user has exactly one trousseau; if none exists, create a default one.
  Future<void> _ensureSingleTrousseau(UserModel user) async {
    try {
      // If already has 1+, keep the first as canonical and do not create more
      if (user.trousseauIds.isNotEmpty) return;

      // Check in Firestore if any existing trousseau with ownerId (defensive)
      final existing = await _firestore
          .collection('trousseaus')
          .where('ownerId', isEqualTo: user.uid)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        // Sync the id into user.trousseauIds for consistency
        final id = existing.docs.first.id;
        await _firestore.collection('users').doc(user.uid).update({
          'trousseauIds': FieldValue.arrayUnion([id]),
        });
        _currentUser = _currentUser?.copyWith(
          trousseauIds: [..._currentUser!.trousseauIds, id],
        );
        return;
      }

      // Create a default trousseau
      final trousseauRef = _firestore.collection('trousseaus').doc();
      await trousseauRef.set({
        'name': 'Benim Çeyizim',
        'description': 'İlk çeyiziniz otomatik oluşturuldu',
        'ownerId': user.uid,
        'sharedWith': <String>[],
        'editors': <String>[],
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'categoryCounts': <String, int>{},
        'totalProducts': 0,
        'purchasedProducts': 0,
        'totalBudget': 0.0,
        'spentAmount': 0.0,
        'coverImage': '',
        'settings': <String, dynamic>{},
      });
      
      // Initialize default categories for this trousseau
      await _categoryRepo.initializeDefaultCategories(trousseauRef.id);
      
      await _firestore.collection('users').doc(user.uid).update({
        'trousseauIds': FieldValue.arrayUnion([trousseauRef.id]),
      });
      _currentUser = _currentUser?.copyWith(
        trousseauIds: [..._currentUser!.trousseauIds, trousseauRef.id],
      );
    } catch (e) {
      debugPrint('İlk çeyiz oluşturulamadı: $e');
    }
  }
  
  Future<void> _updateLastLogin() async {
    if (_currentUser == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Son giriş güncellenemedi: ${e.toString()}');
    }
  }
  
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = '';
      notifyListeners();
      
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (result.user != null) {
        _firebaseUser = result.user;
        await _loadUserData(result.user!.uid);
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.unauthenticated;
      
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.';
          break;
        case 'wrong-password':
          _errorMessage = 'Hatalı şifre girdiniz.';
          break;
        case 'invalid-email':
          _errorMessage = 'Geçersiz e-posta adresi.';
          break;
        case 'user-disabled':
          _errorMessage = 'Bu kullanıcı hesabı devre dışı bırakılmış.';
          break;
        case 'too-many-requests':
          _errorMessage = 'Çok fazla başarısız deneme. Lütfen daha sonra tekrar deneyin.';
          break;
        case 'network-request-failed':
          _errorMessage = 'İnternet bağlantınızı kontrol edin.';
          break;
        default:
          _errorMessage = 'Giriş yapılamadı. Lütfen tekrar deneyin.';
      }
      
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Beklenmeyen bir hata oluştu: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = '';
      notifyListeners();
      
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (result.user != null) {
        await result.user!.updateDisplayName(displayName);
        _firebaseUser = result.user;
        
        final userModel = UserModel(
          uid: result.user!.uid,
          email: email.trim(),
          displayName: displayName,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          trousseauIds: [],
          sharedTrousseauIds: [],
        );
        
        await _firestore
            .collection('users')
            .doc(result.user!.uid)
        .set(userModel.toFirestore());
        
        _currentUser = userModel;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.unauthenticated;
      
      switch (e.code) {
        case 'weak-password':
          _errorMessage = 'Şifre çok zayıf. En az 6 karakter olmalıdır.';
          break;
        case 'email-already-in-use':
          _errorMessage = 'Bu e-posta adresi zaten kullanımda.';
          break;
        case 'invalid-email':
          _errorMessage = 'Geçersiz e-posta adresi.';
          break;
        case 'operation-not-allowed':
          _errorMessage = 'E-posta/şifre girişi etkin değil.';
          break;
        case 'network-request-failed':
          _errorMessage = 'İnternet bağlantınızı kontrol edin.';
          break;
        default:
          _errorMessage = 'Kayıt oluşturulamadı. Lütfen tekrar deneyin.';
      }
      
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Beklenmeyen bir hata oluştu: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _status = AuthStatus.unauthenticated;
      _firebaseUser = null;
      _currentUser = null;
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Çıkış yapılamadı: ${e.toString()}';
      notifyListeners();
    }
  }
  
  Future<bool> resetPassword(String email) async {
    try {
      _errorMessage = '';
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.';
          break;
        case 'invalid-email':
          _errorMessage = 'Geçersiz e-posta adresi.';
          break;
        default:
          _errorMessage = 'Şifre sıfırlama e-postası gönderilemedi.';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Beklenmeyen bir hata oluştu: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    if (_firebaseUser == null || _currentUser == null) return false;
    
    try {
      _errorMessage = '';
      
      if (displayName != null) {
        await _firebaseUser!.updateDisplayName(displayName);
      }
      
      if (photoURL != null) {
        await _firebaseUser!.updatePhotoURL(photoURL);
      }
      
      Map<String, dynamic> updates = {};
      if (displayName != null) updates['displayName'] = displayName;
      if (photoURL != null) updates['photoURL'] = photoURL;
      
      if (updates.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .update(updates);
        
        _currentUser = _currentUser!.copyWith(
          displayName: displayName ?? _currentUser!.displayName,
        );
        
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'Profil güncellenemedi: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_firebaseUser == null || _firebaseUser!.email == null) return false;
    
    try {
      _errorMessage = '';
      
      // Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: _firebaseUser!.email!,
        password: currentPassword,
      );
      
      await _firebaseUser!.reauthenticateWithCredential(credential);
      await _firebaseUser!.updatePassword(newPassword);
      
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          _errorMessage = 'Mevcut şifreniz hatalı.';
          break;
        case 'weak-password':
          _errorMessage = 'Yeni şifre çok zayıf. En az 6 karakter olmalıdır.';
          break;
        case 'requires-recent-login':
          _errorMessage = 'Lütfen tekrar giriş yapın.';
          break;
        default:
          _errorMessage = 'Şifre değiştirilemedi.';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Beklenmeyen bir hata oluştu: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deleteAccount(String password) async {
    if (_firebaseUser == null || _firebaseUser!.email == null) return false;
    
    try {
      _errorMessage = '';
      
      // Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: _firebaseUser!.email!,
        password: password,
      );
      
      await _firebaseUser!.reauthenticateWithCredential(credential);
      
      // Delete user data from Firestore
      await _firestore
          .collection('users')
          .doc(_firebaseUser!.uid)
          .delete();
      
      // Delete auth account
      await _firebaseUser!.delete();
      
      _status = AuthStatus.unauthenticated;
      _firebaseUser = null;
      _currentUser = null;
      notifyListeners();
      
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          _errorMessage = 'Şifreniz hatalı.';
          break;
        case 'requires-recent-login':
          _errorMessage = 'Lütfen tekrar giriş yapın.';
          break;
        default:
          _errorMessage = 'Hesap silinemedi.';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Beklenmeyen bir hata oluştu: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  Future<void> _checkForUpdates() async {
    if (kIsWeb) return; // Skip on web
    
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuildNumber = int.parse(packageInfo.buildNumber);

      // Get latest version from Firestore
      final doc = await _firestore.collection('app_versions').doc('latest').get();
      if (doc.exists) {
        final data = doc.data()!;
        final latestVersion = data['version'] as String;
        final latestBuildNumber = data['buildNumber'] as int;
        final forceUpdate = data['forceUpdate'] as bool? ?? false;
        final updateMessage = data['updateMessage'] as String? ?? 
          'Uygulamanın yeni bir sürümü mevcut. Daha iyi deneyim için lütfen güncelleyin.';

        if (latestBuildNumber > currentBuildNumber) {
          _updateAvailable = true;
          _latestVersion = latestVersion;
          _forceUpdate = forceUpdate;
          _updateMessage = updateMessage;
          notifyListeners();
          debugPrint('Update available: $latestVersion (build $latestBuildNumber)');
        }
      }
    } catch (e) {
      // Silently fail, don't show error for update check
      debugPrint('Update check failed: $e');
    }
  }
}