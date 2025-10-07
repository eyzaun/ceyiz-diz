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
      loadTrousseaus();
    } else {
      _clearData();
    }
  }
  
  void _clearData() {
    _trousseaus = [];
    _sharedTrousseaus = [];
    _selectedTrousseau = null;
    _errorMessage = '';
    notifyListeners();
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
      
      _trousseaus.insert(0, trousseau);
      notifyListeners();
      
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
      
      // Find user by email
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (userQuery.docs.isEmpty) {
        _errorMessage = 'Kullanıcı bulunamadı';
        return false;
      }
      
      final targetUser = UserModel.fromFirestore(userQuery.docs.first);
      
      // Check if already shared
      if (trousseau.sharedWith.contains(targetUser.uid) ||
          trousseau.editors.contains(targetUser.uid)) {
        _errorMessage = 'Bu kullanıcı ile zaten paylaşılmış';
        return false;
      }
      
      Map<String, dynamic> updates = {
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };
      
      if (canEdit) {
        updates['editors'] = FieldValue.arrayUnion([targetUser.uid]);
      } else {
        updates['sharedWith'] = FieldValue.arrayUnion([targetUser.uid]);
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
      
      // Update local data
      final index = _trousseaus.indexWhere((t) => t.id == trousseauId);
      if (index != -1) {
        final updatedTrousseau = _trousseaus[index].copyWith(
          sharedWith: canEdit
              ? _trousseaus[index].sharedWith
              : [..._trousseaus[index].sharedWith, targetUser.uid],
          editors: canEdit
              ? [..._trousseaus[index].editors, targetUser.uid]
              : _trousseaus[index].editors,
          updatedAt: DateTime.now(),
        );
        _trousseaus[index] = updatedTrousseau;
        
        if (_selectedTrousseau?.id == trousseauId) {
          _selectedTrousseau = updatedTrousseau;
        }
      }
      
      notifyListeners();
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
      
      // Update local data
      final index = _trousseaus.indexWhere((t) => t.id == trousseauId);
      if (index != -1) {
        final updatedTrousseau = _trousseaus[index].copyWith(
          sharedWith: _trousseaus[index].sharedWith
              .where((id) => id != userId)
              .toList(),
          editors: _trousseaus[index].editors
              .where((id) => id != userId)
              .toList(),
          updatedAt: DateTime.now(),
        );
        _trousseaus[index] = updatedTrousseau;
        
        if (_selectedTrousseau?.id == trousseauId) {
          _selectedTrousseau = updatedTrousseau;
        }
      }
      
      notifyListeners();
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