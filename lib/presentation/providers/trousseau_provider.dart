import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/trousseau_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/category_repository.dart';
import 'auth_provider.dart';

class TrousseauProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CategoryRepository _categoryRepo = CategoryRepository();
  
  List<TrousseauModel> _trousseaus = [];
  List<TrousseauModel> _sharedTrousseaus = [];
  TrousseauModel? _selectedTrousseau;
  String? _selectedTrousseauId; // Shared selected trousseau ID for both tabs
  bool _isLoading = false;
  String _errorMessage = '';
  AuthProvider? _authProvider;
  
  // Live listeners
  StreamSubscription<QuerySnapshot>? _ownedSub;
  StreamSubscription<QuerySnapshot>? _sharedSub;
  StreamSubscription<QuerySnapshot>? _editorsSub;
  
  List<TrousseauModel> get trousseaus => _trousseaus;
  List<TrousseauModel> get sharedTrousseaus => _sharedTrousseaus;
  TrousseauModel? get selectedTrousseau => _selectedTrousseau;
  String? get selectedTrousseauId => _selectedTrousseauId;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String? get currentUserId => _authProvider?.currentUser?.uid;
  
  List<TrousseauModel> get allTrousseaus => [..._trousseaus, ..._sharedTrousseaus];
  
  // Pinned trousseaus: owned + pinned shared trousseaus
  List<TrousseauModel> get pinnedTrousseaus {
    final pinnedIds = _authProvider?.currentUser?.pinnedSharedTrousseauIds ?? [];
    final pinnedShared = _sharedTrousseaus.where((t) => pinnedIds.contains(t.id)).toList();
    return [..._trousseaus, ...pinnedShared];
  }
  
  // Set selected trousseau ID (shared across tabs)
  void setSelectedTrousseauId(String? trousseauId) {
    if (_selectedTrousseauId != trousseauId) {
      _selectedTrousseauId = trousseauId;
      notifyListeners();
    }
  }
  
  // Auto-select first pinned trousseau if none selected
  void ensureSelection() {
    if (_selectedTrousseauId == null || !pinnedTrousseaus.any((t) => t.id == _selectedTrousseauId)) {
      if (pinnedTrousseaus.isNotEmpty) {
        _selectedTrousseauId = pinnedTrousseaus.first.id;
        notifyListeners();
      }
    }
  }
  
  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider?.isAuthenticated == true) {
      _bindStreams();
    } else {
      _clearData();
    }
  }
  
  void _clearData() {
    _cancelStreams();
    _trousseaus = [];
    _sharedTrousseaus = [];
    _selectedTrousseau = null;
    _selectedTrousseauId = null;
    _errorMessage = '';
    notifyListeners();
  }

  void _cancelStreams() {
    _ownedSub?.cancel();
    _sharedSub?.cancel();
    _editorsSub?.cancel();
    _ownedSub = null;
    _sharedSub = null;
    _editorsSub = null;
  }

  void _bindStreams() {
    final userId = _authProvider?.currentUser?.uid;
    if (userId == null) return;
    _cancelStreams();
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    _ownedSub = _firestore
        .collection('trousseaus')
        .where('ownerId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _trousseaus = snapshot.docs
          .map((doc) => TrousseauModel.fromFirestore(doc))
          .toList();
      _syncSelected();
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _errorMessage = 'Failed to listen to trousseaus: $e'; // Will be localized in UI layer
      _isLoading = false;
      notifyListeners();
    });

    _sharedSub = _firestore
        .collection('trousseaus')
        .where('sharedWith', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final sharedList = snapshot.docs
          .map((doc) => TrousseauModel.fromFirestore(doc))
          .toList();
      _mergeSharedLists(sharedList: sharedList);
      _syncSelected();
      notifyListeners();
    });

    _editorsSub = _firestore
        .collection('trousseaus')
        .where('editors', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final editorList = snapshot.docs
          .map((doc) => TrousseauModel.fromFirestore(doc))
          .toList();
      _mergeSharedLists(editorsList: editorList);
      _syncSelected();
      notifyListeners();
    });
  }

  void _mergeSharedLists({List<TrousseauModel>? sharedList, List<TrousseauModel>? editorsList}) {
    final map = <String, TrousseauModel>{ for (var t in _sharedTrousseaus) t.id: t };
    if (sharedList != null) {
      for (var t in sharedList) { map[t.id] = t; }
    }
    if (editorsList != null) {
      for (var t in editorsList) { map[t.id] = t; }
    }
    _sharedTrousseaus = map.values.toList()
      ..sort((a,b) => b.updatedAt.compareTo(a.updatedAt));
  }

  void _syncSelected() {
    if (_selectedTrousseau == null) return;
    final id = _selectedTrousseau!.id;
    final newer = getTrousseauById(id);
    if (newer != null) {
      _selectedTrousseau = newer;
    }
  }
  
  Future<void> loadTrousseaus() async {
    if (_authProvider?.currentUser == null) return;
    
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      
      final userId = _authProvider!.currentUser!.uid;
      
      // Load owned trousseaus
      final ownedQuery = await _firestore
          .collection('trousseaus')
          .where('ownerId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();
      
      _trousseaus = ownedQuery.docs
          .map((doc) => TrousseauModel.fromFirestore(doc))
          .toList();
      
      // Load shared trousseaus
      final sharedQuery = await _firestore
          .collection('trousseaus')
          .where('sharedWith', arrayContains: userId)
          .orderBy('updatedAt', descending: true)
          .get();
      
      _sharedTrousseaus = sharedQuery.docs
          .map((doc) => TrousseauModel.fromFirestore(doc))
          .toList();
      
      // Load editor trousseaus
      final editorQuery = await _firestore
          .collection('trousseaus')
          .where('editors', arrayContains: userId)
          .orderBy('updatedAt', descending: true)
          .get();
      
      for (var doc in editorQuery.docs) {
        final trousseau = TrousseauModel.fromFirestore(doc);
        if (!_sharedTrousseaus.any((t) => t.id == trousseau.id)) {
          _sharedTrousseaus.add(trousseau);
        }
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load trousseaus: ${e.toString()}'; // Will be localized in UI layer
      notifyListeners();
    }
  }
  
  Future<bool> createTrousseau({
    required String name,
    String description = '',
    double totalBudget = 0.0,
  }) async {
    if (_authProvider?.currentUser == null) return false;
    
    try {
      _errorMessage = '';
      
      final userId = _authProvider!.currentUser!.uid;
      final now = DateTime.now();
      
      final newTrousseau = TrousseauModel(
        id: '', // Firestore will generate
        name: name,
        description: description,
        ownerId: userId,
        sharedWith: [],
        editors: [],
        createdAt: now,
        updatedAt: now,
        categoryCounts: {},
        totalProducts: 0,
        purchasedProducts: 0,
        totalBudget: totalBudget,
        spentAmount: 0.0,
        coverImage: '',
        settings: {},
      );
      
      await _firestore.collection('trousseaus').add(newTrousseau.toFirestore()).then((docRef) async {
        // Initialize default categories for this trousseau
        await _categoryRepo.initializeDefaultCategories(docRef.id);
      });
      // Don't add to local list; stream listener will handle it automatically
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create trousseau: ${e.toString()}'; // Will be localized in UI layer
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateTrousseau({
    required String trousseauId,
    String? name,
    String? description,
    double? totalBudget,
    String? coverImage,
    Map<String, dynamic>? settings,
  }) async {
    if (_authProvider?.currentUser == null) return false;
    
    try {
      _errorMessage = '';
      
      final trousseau = getTrousseauById(trousseauId);
      if (trousseau == null) {
        _errorMessage = 'Trousseau not found'; // Will be localized in UI layer
        return false;
      }
      
      // Check permissions
      if (!trousseau.canEdit(_authProvider!.currentUser!.uid)) {
        _errorMessage = 'No edit permission'; // Will be localized in UI layer
        return false;
      }
      
      Map<String, dynamic> updates = {
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };
      
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (totalBudget != null) updates['totalBudget'] = totalBudget;
      if (coverImage != null) updates['coverImage'] = coverImage;
      if (settings != null) updates['settings'] = settings;
      
      await _firestore
          .collection('trousseaus')
          .doc(trousseauId)
          .update(updates);
      
      // Update local data
      final updatedTrousseau = trousseau.copyWith(
        name: name ?? trousseau.name,
        description: description ?? trousseau.description,
        totalBudget: totalBudget ?? trousseau.totalBudget,
        coverImage: coverImage ?? trousseau.coverImage,
        settings: settings ?? trousseau.settings,
        updatedAt: DateTime.now(),
      );
      
      final index = _trousseaus.indexWhere((t) => t.id == trousseauId);
      if (index != -1) {
        _trousseaus[index] = updatedTrousseau;
      } else {
        final sharedIndex = _sharedTrousseaus.indexWhere((t) => t.id == trousseauId);
        if (sharedIndex != -1) {
          _sharedTrousseaus[sharedIndex] = updatedTrousseau;
        }
      }
      
      if (_selectedTrousseau?.id == trousseauId) {
        _selectedTrousseau = updatedTrousseau;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update trousseau: ${e.toString()}'; // Will be localized in UI layer
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deleteTrousseau(String trousseauId) async {
    if (_authProvider?.currentUser == null) return false;
    
    try {
      _errorMessage = '';
      
      final trousseau = getTrousseauById(trousseauId);
      if (trousseau == null) {
        _errorMessage = 'Trousseau not found'; // Will be localized in UI layer
        return false;
      }
      
      // Check permissions
      if (trousseau.ownerId != _authProvider!.currentUser!.uid) {
        _errorMessage = 'Only owner can delete'; // Will be localized in UI layer
        return false;
      }
      
      // Delete all subcollections first
      // 1. Delete products
      final productsSnapshot = await _firestore
          .collection('trousseaus')
          .doc(trousseauId)
          .collection('products')
          .get();
      
      for (var doc in productsSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // 2. Delete categories
      final categoriesSnapshot = await _firestore
          .collection('trousseaus')
          .doc(trousseauId)
          .collection('categories')
          .get();
      
      for (var doc in categoriesSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Delete the trousseau
      await _firestore.collection('trousseaus').doc(trousseauId).delete();
      
      _trousseaus.removeWhere((t) => t.id == trousseauId);
      
      if (_selectedTrousseau?.id == trousseauId) {
        _selectedTrousseau = _trousseaus.isNotEmpty ? _trousseaus.first : null;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete trousseau: ${e.toString()}'; // Will be localized in UI layer
      notifyListeners();
      return false;
    }
  }

  /// Convenience to get the current user's single trousseau id.
  String? myTrousseauId() {
    if (_trousseaus.isNotEmpty) return _trousseaus.first.id;
    return null;
  }
  
  Future<bool> shareTrousseau({
    required String trousseauId,
    required String email,
    bool canEdit = false,
  }) async {
    if (_authProvider?.currentUser == null) return false;
    
    try {
      _errorMessage = '';
      
      final trousseau = getTrousseauById(trousseauId);
      if (trousseau == null) {
        _errorMessage = 'Trousseau not found'; // Will be localized in UI layer
        return false;
      }
      
      // Only owner can share
      if (trousseau.ownerId != _authProvider!.currentUser!.uid) {
        _errorMessage = 'Only owner can share'; // Will be localized in UI layer
        return false;
      }
      
      // Normalize and find user by email (case-insensitive)
      final normalizedEmail = email.trim().toLowerCase();
      // Prevent sharing to self
      if (_authProvider!.currentUser!.email.toLowerCase() == normalizedEmail) {
        _errorMessage = 'Cannot share with self'; // Will be localized in UI layer
        notifyListeners();
        return false;
      }

      // Find user by normalized email (requires 'emailLower' in user docs)
      final userQuery = await _firestore
          .collection('users')
          .where('emailLower', isEqualTo: normalizedEmail)
          .limit(1)
          .get();
      
      if (userQuery.docs.isEmpty) {
        _errorMessage = 'User not found'; // Will be localized in UI layer
        return false;
      }
      
      final targetUser = UserModel.fromFirestore(userQuery.docs.first);
      
      // Check if there's already a pending invitation for this trousseau
      final existingInvitation = await _firestore
          .collection('users')
          .doc(targetUser.uid)
          .collection('trousseauInvitations')
          .where('trousseauId', isEqualTo: trousseauId)
          .where('ownerId', isEqualTo: trousseau.ownerId)
          .limit(1)
          .get();
      
      if (existingInvitation.docs.isNotEmpty) {
        _errorMessage = 'Invitation already sent'; // Will be localized in UI layer
        notifyListeners();
        return false;
      }
      
      // Instead of immediately granting access, create an invitation for the recipient
      // Recipient will accept/reject the invitation. Invitation stored under the target user's doc.
      final invitation = {
        'trousseauId': trousseauId,
        'trousseauName': trousseau.name,
        'ownerId': trousseau.ownerId,
        'ownerEmail': _authProvider?.currentUser?.email ?? '',
        'canEdit': canEdit,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      };

      await _firestore
          .collection('users')
          .doc(targetUser.uid)
          .collection('trousseauInvitations')
          .add(invitation);

      return true;
    } catch (e) {
      _errorMessage = 'Failed to share: ${e.toString()}'; // Will be localized in UI layer
      notifyListeners();
      return false;
    }
  }

  /// Recipient accepts an invitation. This will add the recipient to the trousseau's
  /// `sharedWith` or `editors` arrays, update the user's `sharedTrousseauIds` and remove the invitation.
  Future<bool> acceptShare({
    required String invitationDocPath,
    required String trousseauId,
  }) async {
    if (_authProvider?.currentUser == null) return false;

    try {
      _errorMessage = '';
      final userId = _authProvider!.currentUser!.uid;

      // Read invitation
      final invRef = FirebaseFirestore.instance.doc(invitationDocPath);
      final invSnap = await invRef.get();
      if (!invSnap.exists) return false;
      final inv = invSnap.data() as Map<String, dynamic>;
      final canEdit = inv['canEdit'] == true;

      // Update trousseau doc: add to editors or sharedWith
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };
      if (canEdit) {
        updates['editors'] = FieldValue.arrayUnion([userId]);
      } else {
        updates['sharedWith'] = FieldValue.arrayUnion([userId]);
      }

      await _firestore.collection('trousseaus').doc(trousseauId).update(updates);

      // Update user's shared list
      await _firestore.collection('users').doc(userId).update({
        'sharedTrousseauIds': FieldValue.arrayUnion([trousseauId]),
      });

      // Delete invitation
      await invRef.delete();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to accept share: ${e.toString()}'; // Will be localized in UI layer
      notifyListeners();
      return false;
    }
  }

  /// Recipient rejects an invitation. Simply delete invitation doc.
  Future<bool> declineShare({
    required String invitationDocPath,
  }) async {
    if (_authProvider?.currentUser == null) return false;

    try {
      _errorMessage = '';
      final invRef = FirebaseFirestore.instance.doc(invitationDocPath);
      await invRef.delete();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to decline invitation: ${e.toString()}'; // Will be localized in UI layer
      notifyListeners();
      return false;
    }
  }

  /// Allow current user to remove their own access to a shared trousseau (revoke self).
  Future<bool> leaveSharedTrousseau({
    required String trousseauId,
  }) async {
    if (_authProvider?.currentUser == null) return false;

    try {
      _errorMessage = '';
      final userId = _authProvider!.currentUser!.uid;

      await _firestore.collection('trousseaus').doc(trousseauId).update({
        'sharedWith': FieldValue.arrayRemove([userId]),
        'editors': FieldValue.arrayRemove([userId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      await _firestore.collection('users').doc(userId).update({
        'sharedTrousseauIds': FieldValue.arrayRemove([trousseauId]),
      });

      return true;
    } catch (e) {
      _errorMessage = 'Failed to leave sharing: ${e.toString()}'; // Will be localized in UI layer
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> removeShare({
    required String trousseauId,
    required String userId,
  }) async {
    if (_authProvider?.currentUser == null) return false;
    
    try {
      _errorMessage = '';
      
      final trousseau = getTrousseauById(trousseauId);
      if (trousseau == null) {
        _errorMessage = 'Trousseau not found'; // Will be localized in UI layer
        return false;
      }
      
      // Owner can remove anyone's access; a recipient can remove their own access (self-revoke)
      final currentUid = _authProvider!.currentUser!.uid;
      if (trousseau.ownerId != currentUid && userId != currentUid) {
        _errorMessage = 'Only owner can remove sharing'; // Will be localized in UI layer
        return false;
      }
      
      await _firestore
          .collection('trousseaus')
          .doc(trousseauId)
          .update({
        'sharedWith': FieldValue.arrayRemove([userId]),
        'editors': FieldValue.arrayRemove([userId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      
      // Update target user's shared list
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'sharedTrousseauIds': FieldValue.arrayRemove([trousseauId]),
      });
      
      // Live snapshots will update local data; no manual local mutation required
      return true;
    } catch (e) {
      _errorMessage = 'Failed to remove sharing: ${e.toString()}'; // Will be localized in UI layer
      notifyListeners();
      return false;
    }
  }
  
  void selectTrousseau(TrousseauModel trousseau) {
    _selectedTrousseau = trousseau;
    notifyListeners();
  }
  
  void clearSelection() {
    _selectedTrousseau = null;
    notifyListeners();
  }
  
  TrousseauModel? getTrousseauById(String id) {
    try {
      return allTrousseaus.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
  
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
  
  Stream<List<TrousseauModel>> getTrousseauStream(String userId) {
    return _firestore
        .collection('trousseaus')
        .where('ownerId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TrousseauModel.fromFirestore(doc))
            .toList());
  }
  
  Stream<TrousseauModel?> getSingleTrousseauStream(String trousseauId) {
    return _firestore
        .collection('trousseaus')
        .doc(trousseauId)
        .snapshots()
        .map((doc) => doc.exists ? TrousseauModel.fromFirestore(doc) : null);
  }
  
  // Pin/Unpin shared trousseau
  bool isSharedTrousseauPinned(String trousseauId) {
    final pinnedIds = _authProvider?.currentUser?.pinnedSharedTrousseauIds ?? [];
    return pinnedIds.contains(trousseauId);
  }
  
  Future<bool> pinSharedTrousseau(String trousseauId) async {
    if (_authProvider?.currentUser == null) return false;
    
    try {
      _errorMessage = '';
      
      // Check if it's a shared trousseau
      final trousseau = getTrousseauById(trousseauId);
      if (trousseau == null) {
        _errorMessage = 'Trousseau not found'; // Will be localized in UI layer
        return false;
      }
      
      // Only shared trousseaus can be pinned
      if (trousseau.ownerId == _authProvider!.currentUser!.uid) {
        _errorMessage = 'Cannot pin own trousseau'; // Will be localized in UI layer
        return false;
      }
      
      final userId = _authProvider!.currentUser!.uid;
      
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'pinnedSharedTrousseauIds': FieldValue.arrayUnion([trousseauId]),
      });
      
      // Update local user model
      final currentUser = _authProvider!.currentUser!;
      final updatedPinnedIds = [...currentUser.pinnedSharedTrousseauIds];
      if (!updatedPinnedIds.contains(trousseauId)) {
        updatedPinnedIds.add(trousseauId);
      }
      
      _authProvider!.updateUser(
        currentUser.copyWith(pinnedSharedTrousseauIds: updatedPinnedIds),
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add to home: ${e.toString()}'; // Will be localized in UI layer
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> unpinSharedTrousseau(String trousseauId) async {
    if (_authProvider?.currentUser == null) return false;
    
    try {
      _errorMessage = '';
      
      final userId = _authProvider!.currentUser!.uid;
      
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'pinnedSharedTrousseauIds': FieldValue.arrayRemove([trousseauId]),
      });
      
      // Update local user model
      final currentUser = _authProvider!.currentUser!;
      final updatedPinnedIds = [...currentUser.pinnedSharedTrousseauIds];
      updatedPinnedIds.remove(trousseauId);
      
      _authProvider!.updateUser(
        currentUser.copyWith(pinnedSharedTrousseauIds: updatedPinnedIds),
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to remove from home: ${e.toString()}'; // Will be localized in UI layer
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> togglePinSharedTrousseau(String trousseauId) async {
    if (isSharedTrousseauPinned(trousseauId)) {
      return await unpinSharedTrousseau(trousseauId);
    } else {
      return await pinSharedTrousseau(trousseauId);
    }
  }
}