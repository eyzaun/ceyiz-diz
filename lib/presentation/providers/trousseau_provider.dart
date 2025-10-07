import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/trousseau_model.dart';
import '../../data/models/user_model.dart';
import 'auth_provider.dart';

class TrousseauProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  
  List<TrousseauModel> _trousseaus = [];
  List<TrousseauModel> _sharedTrousseaus = [];
  TrousseauModel? _selectedTrousseau;
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
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String? get currentUserId => _authProvider?.currentUser?.uid;
  
  List<TrousseauModel> get allTrousseaus => [..._trousseaus, ..._sharedTrousseaus];
  
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
      _errorMessage = 'Çeyizler dinlenemedi: $e';
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
      _errorMessage = 'Çeyizler yüklenemedi: ${e.toString()}';
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
      final trousseauId = _uuid.v4();
      
      final trousseau = TrousseauModel(
        id: trousseauId,
        name: name,
        description: description,
        ownerId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        totalBudget: totalBudget,
      );
      
      await _firestore
          .collection('trousseaus')
          .doc(trousseauId)
          .set(trousseau.toFirestore());
      
      // Update user's trousseau list
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'trousseauIds': FieldValue.arrayUnion([trousseauId]),
      });
      
      // If live listeners are not yet active, update local list optimistically;
      // otherwise, let the snapshot listeners populate to avoid duplicates.
      if (_ownedSub == null) {
        _trousseaus.insert(0, trousseau);
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'Çeyiz oluşturulamadı: ${e.toString()}';
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
        _errorMessage = 'Çeyiz bulunamadı';
        return false;
      }
      
      // Check permissions
      if (!trousseau.canEdit(_authProvider!.currentUser!.uid)) {
        _errorMessage = 'Bu çeyizi düzenleme yetkiniz yok';
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
      _errorMessage = 'Çeyiz güncellenemedi: ${e.toString()}';
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
        _errorMessage = 'Çeyiz bulunamadı';
        return false;
      }
      
      // Only owner can delete
      if (trousseau.ownerId != _authProvider!.currentUser!.uid) {
        _errorMessage = 'Sadece çeyiz sahibi silebilir';
        return false;
      }
      
      // Delete all products in the trousseau
      final productsQuery = await _firestore
          .collection('products')
          .where('trousseauId', isEqualTo: trousseauId)
          .get();
      
      final batch = _firestore.batch();
      
      for (var doc in productsQuery.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete trousseau
      batch.delete(_firestore.collection('trousseaus').doc(trousseauId));
      
      // Update user's trousseau list
      batch.update(
        _firestore.collection('users').doc(_authProvider!.currentUser!.uid),
        {
          'trousseauIds': FieldValue.arrayRemove([trousseauId]),
        },
      );
      
      await batch.commit();
      
      _trousseaus.removeWhere((t) => t.id == trousseauId);
      if (_selectedTrousseau?.id == trousseauId) {
        _selectedTrousseau = null;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Çeyiz silinemedi: ${e.toString()}';
      notifyListeners();
      return false;
    }
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
        _errorMessage = 'Çeyiz bulunamadı';
        return false;
      }
      
      // Only owner can share
      if (trousseau.ownerId != _authProvider!.currentUser!.uid) {
        _errorMessage = 'Sadece çeyiz sahibi paylaşabilir';
        return false;
      }
      
      // Normalize and find user by email (case-insensitive)
      final normalizedEmail = email.trim().toLowerCase();
      // Prevent sharing to self
      if (_authProvider!.currentUser!.email.toLowerCase() == normalizedEmail) {
        _errorMessage = 'Kendinize paylaşım yapamazsınız';
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
        _errorMessage = 'Kullanıcı bulunamadı';
        return false;
      }
      
      final targetUser = UserModel.fromFirestore(userQuery.docs.first);
      
      // Prepare updates to switch or grant permissions
      Map<String, dynamic> updates = {
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      final alreadyViewer = trousseau.sharedWith.contains(targetUser.uid);
      final alreadyEditor = trousseau.editors.contains(targetUser.uid);

      if (alreadyEditor && !canEdit) {
        // Downgrade: editor -> viewer
        updates['editors'] = FieldValue.arrayRemove([targetUser.uid]);
        updates['sharedWith'] = FieldValue.arrayUnion([targetUser.uid]);
      } else if (alreadyViewer && canEdit) {
        // Upgrade: viewer -> editor
        updates['sharedWith'] = FieldValue.arrayRemove([targetUser.uid]);
        updates['editors'] = FieldValue.arrayUnion([targetUser.uid]);
      } else if (!alreadyViewer && !alreadyEditor) {
        // New share
        if (canEdit) {
          updates['editors'] = FieldValue.arrayUnion([targetUser.uid]);
        } else {
          updates['sharedWith'] = FieldValue.arrayUnion([targetUser.uid]);
        }
      } else {
        // No change needed
        _errorMessage = 'Bu kullanıcı için paylaşım durumu zaten geçerli';
        notifyListeners();
        return false;
      }

      await _firestore
          .collection('trousseaus')
          .doc(trousseauId)
          .update(updates);
      
      // Update target user's shared list
      await _firestore
          .collection('users')
          .doc(targetUser.uid)
          .update({
        'sharedTrousseauIds': FieldValue.arrayUnion([trousseauId]),
      });
      
      // Let live snapshots update local lists; no optimistic local mutation to avoid inconsistencies
      return true;
    } catch (e) {
      _errorMessage = 'Paylaşım yapılamadı: ${e.toString()}';
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
        _errorMessage = 'Çeyiz bulunamadı';
        return false;
      }
      
      // Only owner can remove share
      if (trousseau.ownerId != _authProvider!.currentUser!.uid) {
        _errorMessage = 'Sadece çeyiz sahibi paylaşımı kaldırabilir';
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
      _errorMessage = 'Paylaşım kaldırılamadı: ${e.toString()}';
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
}