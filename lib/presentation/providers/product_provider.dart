import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:image_picker/image_picker.dart';
import '../../data/models/product_model.dart';
import 'auth_provider.dart';

enum ProductFilter {
  all,
  purchased,
  notPurchased,
}

class ProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();
  
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = false;
  String _errorMessage = '';
  AuthProvider? _authProvider;
  StreamSubscription<QuerySnapshot>? _productsSub;
  String? _listeningTrousseauId;
  
  // Filter states
  ProductFilter _currentFilter = ProductFilter.all;
  Set<String> _selectedCategories = {};
  String _searchQuery = '';
  
  List<ProductModel> get products => _products;
  List<ProductModel> get filteredProducts => _filteredProducts;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  ProductFilter get currentFilter => _currentFilter;
  Set<String> get selectedCategories => _selectedCategories;
  String get searchQuery => _searchQuery;
  
  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider?.isAuthenticated != true) {
      _clearData();
    }
  }
  
  void _clearData() {
    _productsSub?.cancel();
    _productsSub = null;
    _listeningTrousseauId = null;
    _products = [];
    _filteredProducts = [];
    _errorMessage = '';
    _currentFilter = ProductFilter.all;
    _selectedCategories = {};
    _searchQuery = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _productsSub?.cancel();
    _productsSub = null;
    super.dispose();
  }
  
  Future<void> loadProducts(String trousseauId) async {
    debugPrint('📦 loadProducts called for trousseau: $trousseauId');

    // PREVENT DOUBLE LOADING: If already loading this same trousseau, skip
    if (_isLoading && _listeningTrousseauId == trousseauId) {
      debugPrint('⚠️  Already loading this trousseau, skipping duplicate call');
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      // Re-bind live listener if trousseau changed or no active listener
      if (_listeningTrousseauId != trousseauId || _productsSub == null) {
        _productsSub?.cancel();
        _listeningTrousseauId = trousseauId;

        debugPrint('📥 Fetching initial products for trousseau: $trousseauId');

        // First load: get initial data immediately
        final initialSnapshot = await _firestore
            .collection('products')
            .where('trousseauId', isEqualTo: trousseauId)
            .orderBy('createdAt', descending: true)
            .get();

        debugPrint('📦 Fetched ${initialSnapshot.docs.length} products');

        _products = initialSnapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList();
        _applyFilters();
        _isLoading = false;

        debugPrint('✅ Products loaded: ${_products.length} total, ${_filteredProducts.length} filtered');
        notifyListeners();

        // Then setup live listener for real-time updates
        _productsSub = _firestore
            .collection('products')
            .where('trousseauId', isEqualTo: trousseauId)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .listen((snapshot) {
          _products = snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList();
          _applyFilters();
          _isLoading = false;
          notifyListeners();
        }, onError: (e) {
          _errorMessage = 'Ürünler dinlenemedi: $e';
          _isLoading = false;
          notifyListeners();
        });
      } else {
        // Already listening to this trousseau; force refresh filters and notify
        _applyFilters();
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Ürünler yüklenemedi: ${e.toString()}';
      notifyListeners();
    }
  }
  
  void _applyFilters() {
    // Create a new filtered list from all products
    final tempFiltered = _products.where((product) {
      // Apply purchase filter
      bool matchesFilter = true;
      switch (_currentFilter) {
        case ProductFilter.purchased:
          matchesFilter = product.isPurchased;
          break;
        case ProductFilter.notPurchased:
          matchesFilter = !product.isPurchased;
          break;
        case ProductFilter.all:
          matchesFilter = true;
          break;
      }

      // Apply category filter
      bool matchesCategory = _selectedCategories.isEmpty ||
          _selectedCategories.contains(product.category);

      // Apply search filter
      bool matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesFilter && matchesCategory && matchesSearch;
    }).toList();

    // Always update the filtered list, even if it's the same
    _filteredProducts = tempFiltered;
  }
  
  void setFilter(ProductFilter filter) {
    _currentFilter = filter;
    _applyFilters();
    notifyListeners();
  }
  
  void toggleCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    _applyFilters();
    notifyListeners();
  }
  
  void clearCategoryFilter() {
    _selectedCategories.clear();
    _applyFilters();
    notifyListeners();
  }
  
  void setSearchQuery(String query) {
    final normalized = query.trim();
    if (normalized == _searchQuery) return; // avoid redundant rebuilds
    _searchQuery = normalized;
    _applyFilters();
    notifyListeners();
  }
  
  Future<bool> addProduct({
    required String trousseauId,
    required String name,
    String description = '',
    required double price,
    required String category,
    List<XFile>? imageFiles,
    String link = '',
    int quantity = 1,
  }) async {
    if (_authProvider?.currentUser == null) return false;
    final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
    if (fbUser == null) {
      _errorMessage = 'Oturum bulunamadı. Lütfen yeniden giriş yapın.';
      notifyListeners();
      return false;
    }
    
    try {
      _errorMessage = '';
  final userId = _authProvider!.currentUser!.uid;
      final productId = _uuid.v4();
      // Ensure auth is established (avoid race where token isn't attached yet)
      try { await fb_auth.FirebaseAuth.instance.authStateChanges().firstWhere((u) => u != null); } catch (_) {}
      // Ensure fresh auth token (helps with web/App Check preflights)
      try {
        await fb_auth.FirebaseAuth.instance.currentUser?.getIdToken(true);
        await Future.delayed(const Duration(milliseconds: 400));
      } catch (_) {}
      
      // Upload images if provided
      List<String> imageUrls = [];
      if (imageFiles != null && imageFiles.isNotEmpty) {
        final uid = _authProvider!.currentUser!.uid;
        for (var xfile in imageFiles) {
          final bytes = await xfile.readAsBytes();
          final path = 'products/$uid/${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4()}${_extensionFor(xfile.path)}';
          final ref = _storage.ref().child(path);
          final metadata = SettableMetadata(contentType: _mimeTypeFor(xfile.path));
          final task = await ref.putData(bytes, metadata);
          final url = await task.ref.getDownloadURL();
          imageUrls.add(url);
        }
      }
      
      final product = ProductModel(
        id: productId,
        trousseauId: trousseauId,
        name: name,
        description: description,
        price: price,
        category: category,
        images: imageUrls,
        link: link,
        quantity: quantity,
        addedBy: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _firestore
          .collection('products')
          .doc(productId)
          .set(product.toFirestore());
      
      // Update trousseau statistics
      await _updateTrousseauStats(trousseauId);
      
      // Avoid temporary duplicates when a live snapshot listener is active.
      // If there's no active listener (edge/offline cases), update local state optimistically.
      if (_productsSub == null || _listeningTrousseauId != trousseauId) {
        _products.insert(0, product);
        _applyFilters();
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'Ürün eklenemedi: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateProduct({
    required String productId,
    String? name,
    String? description,
    double? price,
    String? category,
    List<XFile>? newImageFiles,
    List<String>? existingImages,
    String? link,
    int? quantity,
    bool? isPurchased,
  }) async {
    if (_authProvider?.currentUser == null) return false;
    
    try {
      _errorMessage = '';
      // Ensure auth is established
      try { await fb_auth.FirebaseAuth.instance.authStateChanges().firstWhere((u) => u != null); } catch (_) {}
      // Ensure fresh auth token before upload
      try {
        await fb_auth.FirebaseAuth.instance.currentUser?.getIdToken(true);
        await Future.delayed(const Duration(milliseconds: 400));
      } catch (_) {}
      
      final product = getProductById(productId);
      if (product == null) {
        _errorMessage = 'Ürün bulunamadı';
        return false;
      }
      
      // Upload new images if provided
      List<String> imageUrls = existingImages ?? product.images;
      if (newImageFiles != null && newImageFiles.isNotEmpty) {
        final uid = _authProvider!.currentUser!.uid;
        for (var xfile in newImageFiles) {
          final bytes = await xfile.readAsBytes();
          final path = 'products/$uid/${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4()}${_extensionFor(xfile.path)}';
          final ref = _storage.ref().child(path);
          final metadata = SettableMetadata(contentType: _mimeTypeFor(xfile.path));
          final task = await ref.putData(bytes, metadata);
          final url = await task.ref.getDownloadURL();
          imageUrls.add(url);
        }
      }
      
      Map<String, dynamic> updates = {
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };
      
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (price != null) updates['price'] = price;
      if (category != null) updates['category'] = category;
      if (link != null) updates['link'] = link;
      if (quantity != null) updates['quantity'] = quantity;
      if (isPurchased != null) {
        updates['isPurchased'] = isPurchased;
        if (isPurchased) {
          updates['purchaseDate'] = Timestamp.fromDate(DateTime.now());
          updates['purchasedBy'] = _authProvider!.currentUser!.uid;
        } else {
          updates['purchaseDate'] = null;
          updates['purchasedBy'] = '';
        }
      }
      updates['images'] = imageUrls;
      
      await _firestore
          .collection('products')
          .doc(productId)
          .update(updates);
      
      // Update trousseau statistics
      await _updateTrousseauStats(product.trousseauId);
      
      // Update local data
      final updatedProduct = product.copyWith(
        name: name ?? product.name,
        description: description ?? product.description,
        price: price ?? product.price,
        category: category ?? product.category,
        images: imageUrls,
        link: link ?? product.link,
        quantity: quantity ?? product.quantity,
        isPurchased: isPurchased ?? product.isPurchased,
        purchaseDate: isPurchased == true ? DateTime.now() : product.purchaseDate,
        purchasedBy: isPurchased == true ? _authProvider!.currentUser!.uid : product.purchasedBy,
        updatedAt: DateTime.now(),
      );
      
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
        _applyFilters();
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Ürün güncellenemedi: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deleteProduct(String productId) async {
    if (_authProvider?.currentUser == null) return false;
    
    try {
      _errorMessage = '';
      
      final product = getProductById(productId);
      if (product == null) {
        _errorMessage = 'Ürün bulunamadı';
        return false;
      }
      
      // Delete images from storage
      if (product.images.isNotEmpty) {
        for (var imageUrl in product.images) {
          try {
            final ref = _storage.refFromURL(imageUrl);
            await ref.delete();
          } catch (_) {}
        }
      }
      
      await _firestore
          .collection('products')
          .doc(productId)
          .delete();
      
      // Update trousseau statistics
      await _updateTrousseauStats(product.trousseauId);
      
      _products.removeWhere((p) => p.id == productId);
      _applyFilters();
      notifyListeners();
      
      return true;
    } catch (e) {
      _errorMessage = 'Ürün silinemedi: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Clone an existing product into the specified target trousseau as a new
  /// independent object. Resets ownership-sensitive fields to avoid
  /// cross-trousseau coupling (new id, addedBy=current user, not purchased).
  Future<bool> cloneProductToTrousseau({
    required String targetTrousseauId,
    required ProductModel source,
  }) async {
    if (_authProvider?.currentUser == null) return false;
    try {
      _errorMessage = '';
      // Ensure auth state is ready before any storage interactions
      try { await fb_auth.FirebaseAuth.instance.authStateChanges().firstWhere((u) => u != null); } catch (_) {}
      try {
        await fb_auth.FirebaseAuth.instance.currentUser?.getIdToken(true);
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (_) {}

      final newId = _uuid.v4();
      final now = DateTime.now();
      final currentUid = _authProvider!.currentUser!.uid;

      // We copy metadata and references; images remain referenced by URL.
      // If deeper isolation is required, implement re-upload of images to the
      // current user's bucket path in a later enhancement.
      final cloned = ProductModel(
        id: newId,
        trousseauId: targetTrousseauId,
        name: source.name,
        description: source.description,
        price: source.price,
        category: source.category,
        images: List<String>.from(source.images),
        link: source.link,
        isPurchased: false,
        purchaseDate: null,
        purchasedBy: '',
        quantity: source.quantity,
        addedBy: currentUid,
        createdAt: now,
        updatedAt: now,
        customFields: Map<String, dynamic>.from(source.customFields),
      );

      await _firestore.collection('products').doc(newId).set(cloned.toFirestore());

      // Update stats for the target trousseau
      await _updateTrousseauStats(targetTrousseauId);

      // If we're currently listening to the target trousseau, optimistic insert
      if (_listeningTrousseauId == targetTrousseauId && _productsSub != null) {
        _products.insert(0, cloned);
        _applyFilters();
        notifyListeners();
      }

      return true;
    } catch (e) {
      _errorMessage = 'Ürün kopyalanamadı: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> togglePurchaseStatus(String productId) async {
    if (_authProvider?.currentUser == null) return false;
    
    final product = getProductById(productId);
    if (product == null) return false;
    
    return updateProduct(
      productId: productId,
      isPurchased: !product.isPurchased,
    );
  }
  
  Future<void> _updateTrousseauStats(String trousseauId) async {
    try {
      final productsQuery = await _firestore
          .collection('products')
          .where('trousseauId', isEqualTo: trousseauId)
          .get();
      
      int totalProducts = 0;
      int purchasedProducts = 0;
      double spentAmount = 0.0;
      Map<String, int> categoryCounts = {};
      
      for (var doc in productsQuery.docs) {
        final product = ProductModel.fromFirestore(doc);
        totalProducts++;
        
        if (product.isPurchased) {
          purchasedProducts++;
          spentAmount += product.totalPrice;
        }
        
        categoryCounts[product.category] = (categoryCounts[product.category] ?? 0) + 1;
      }
      
      await _firestore
          .collection('trousseaus')
          .doc(trousseauId)
          .update({
        'totalProducts': totalProducts,
        'purchasedProducts': purchasedProducts,
        'spentAmount': spentAmount,
        'categoryCounts': categoryCounts,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Trousseau stats update failed: ${e.toString()}');
    }
  }
  
  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
  
  List<ProductModel> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }
  
  Map<String, double> getCategorySpending() {
    Map<String, double> spending = {};
    
    for (var product in _products.where((p) => p.isPurchased)) {
      spending[product.category] = (spending[product.category] ?? 0) + product.totalPrice;
    }
    
    return spending;
  }
  
  double getTotalSpent() {
    return _products
        .where((p) => p.isPurchased)
        .fold(0.0, (acc, p) => acc + p.totalPrice);
  }
  
  double getTotalPlanned() {
    return _products.fold(0.0, (acc, p) => acc + p.totalPrice);
  }
  
  int getPurchasedCount() {
    return _products.where((p) => p.isPurchased).length;
  }
  
  int getNotPurchasedCount() {
    return _products.where((p) => !p.isPurchased).length;
  }
  
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
  
  Stream<List<ProductModel>> getProductStream(String trousseauId) {
    return _firestore
        .collection('products')
        .where('trousseauId', isEqualTo: trousseauId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList());
  }

  String _extensionFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return '.png';
    if (lower.endsWith('.webp')) return '.webp';
    if (lower.endsWith('.gif')) return '.gif';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return '.jpg';
    return '.jpg';
  }

  String _mimeTypeFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}