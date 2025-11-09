import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

class CategoryProvider with ChangeNotifier {
	final CategoryRepository _repo = CategoryRepository();

	String? _trousseauId;
	StreamSubscription? _sub;
	bool _loading = false;
	String _error = '';

	// Categories loaded from Firestore for current trousseau
	List<CategoryModel> _categories = [];

	// UI filter state
	final Set<String> _selected = {};

	bool get isLoading => _loading;
	String get errorMessage => _error;
	String? get currentTrousseauId => _trousseauId;
	
	// All categories for this trousseau
	List<CategoryModel> get allCategories => List.unmodifiable(_categories);

	Set<String> get selectedCategories => Set.unmodifiable(_selected);

	Future<void> bind(String trousseauId, {required String userId}) async {
		if (_trousseauId == trousseauId) return;
		
		await _sub?.cancel();
		_trousseauId = trousseauId;
		_loading = true;
		_error = '';
		notifyListeners();
		
		// Stream categories for this trousseau
		_sub = _repo.streamCategories(trousseauId).listen((cats) {
			// CRITICAL: Check if we're still bound to this trousseau
			// Stream callbacks can arrive after bind() was called for a different trousseau
			if (_trousseauId != trousseauId) {
				return;
			}
			
			// BACKWARD COMPATIBILITY: Tüm kategorileri kabul et (eski userId__ prefix'li dahil)
			// Firebase'de her çeyiz kendi subcollection'ında olduğu için zaten scope'lu
			_categories = cats;
			
			_loading = false;
			// Remove selections that no longer exist
			_selected.removeWhere((id) => !_categories.any((c) => c.id == id));
			notifyListeners();
		}, onError: (e) {
			_error = e.toString();
			_loading = false;
			notifyListeners();
		});
	}

	Future<void> disposeBinding() async {
		await _sub?.cancel();
		_sub = null;
		_trousseauId = null;
		_categories = [];
		_selected.clear();
		notifyListeners();
	}

	void toggleCategory(String id) {
		if (_selected.contains(id)) {
			_selected.remove(id);
		} else {
			_selected.add(id);
		}
		notifyListeners();
	}

	void clearSelection() {
		_selected.clear();
		notifyListeners();
	}

	CategoryModel getById(String id) {
		return _categories.firstWhere(
			(c) => c.id == id,
			orElse: () => CategoryModel.getDefaultById('other'),
		);
	}

	Future<bool> addCustom(String id, String name, {int sortOrder = 1000, IconData? icon, Color? color}) async {
		if (_trousseauId == null) return false;
		try {
			await _repo.addCategory(
				_trousseauId!,
				id: id,
				name: name,
				displayName: name,
				sortOrder: sortOrder,
				iconCode: icon?.codePoint,
				colorValue: color?.toARGB32(),
			);
			return true;
		} catch (e) {
			_error = e.toString();
			notifyListeners();
			return false;
		}
	}

	Future<bool> removeCategory(String id) async {
		if (_trousseauId == null) return false;
		try {
			await _repo.removeCategory(_trousseauId!, id);
			return true;
		} catch (e) {
			_error = e.toString();
			notifyListeners();
			return false;
		}
	}

	Future<bool> updateCategory(String id, {String? name, IconData? icon, Color? color}) async {
		if (_trousseauId == null) return false;
		try {
			await _repo.updateCategory(
				_trousseauId!,
				id,
				name: name,
				iconCode: icon?.codePoint,
				colorValue: color?.toARGB32(),
			);
			return true;
		} catch (e) {
			_error = e.toString();
			notifyListeners();
			return false;
		}
	}

	/// Update category sort order
	Future<bool> updateCategoryOrder(String categoryId, int newOrder) async {
		if (_trousseauId == null) return false;
		try {
			await _repo.updateCategoryOrder(_trousseauId!, categoryId, newOrder);
			return true;
		} catch (e) {
			_error = e.toString();
			notifyListeners();
			return false;
		}
	}

	/// Batch update category orders (for drag & drop reordering)
	Future<bool> updateCategoryOrders(Map<String, int> categoryOrders) async {
		if (_trousseauId == null) return false;
		try {
			await _repo.updateCategoryOrders(_trousseauId!, categoryOrders);
			return true;
		} catch (e) {
			_error = e.toString();
			notifyListeners();
			return false;
		}
	}
}

