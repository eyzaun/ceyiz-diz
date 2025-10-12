import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

class CategoryProvider with ChangeNotifier {
	final CategoryRepository _repo = CategoryRepository();

		String? _trousseauId;
		String? _userId;
	StreamSubscription? _sub;
	bool _loading = false;
	String _error = '';

	// dynamic categories loaded from firestore for current trousseau
	List<CategoryModel> _custom = [];

	// UI filter state
	final Set<String> _selected = {};

	bool get isLoading => _loading;
	String get errorMessage => _error;
	String? get currentTrousseauId => _trousseauId;
	List<CategoryModel> get customCategories => List.unmodifiable(_custom.where((c) => !c.displayName.startsWith('___DELETED___')));
	List<CategoryModel> get defaultCategories {
		// Filter out deleted defaults
		final deletedDefaultIds = _custom
			.where((c) => c.displayName.startsWith('___DELETED___'))
			.map((c) => c.id.split('__').last)
			.toSet();
		return CategoryModel.defaultCategories
			.where((c) => !deletedDefaultIds.contains(c.id))
			.toList();
	}

	List<CategoryModel> get allCategories {
		// Get non-deleted customs
		final activeCustoms = _custom.where((c) => !c.displayName.startsWith('___DELETED___')).toList();
		
		// Get deleted default IDs
		final deletedDefaultIds = _custom
			.where((c) => c.displayName.startsWith('___DELETED___'))
			.map((c) => c.id.split('__').last)
			.toSet();
		
		// Filter defaults
		final activeDefaults = CategoryModel.defaultCategories
			.where((c) => !deletedDefaultIds.contains(c.id))
			.toList();
		
		// Get customized defaults (those that have custom versions but not deleted)
		final customizedDefaultIds = activeCustoms
			.where((c) => c.id.contains('__'))
			.map((c) => c.id.split('__').last)
			.toSet();
		
		// Remove defaults that have been customized
		final finalDefaults = activeDefaults
			.where((c) => !customizedDefaultIds.contains(c.id))
			.toList();
		
		final combined = [...finalDefaults, ...activeCustoms];
		combined.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
		return combined;
	}

	Set<String> get selectedCategories => Set.unmodifiable(_selected);

		Future<void> bind(String trousseauId, {required String userId}) async {
			if (_trousseauId == trousseauId && _userId == userId) return;
		await _sub?.cancel();
		_trousseauId = trousseauId;
			_userId = userId;
		_loading = true;
		_error = '';
		notifyListeners();
			_sub = _repo.streamCategories(trousseauId, userId).listen((cats) {
			_custom = cats;
			_loading = false;
			// Remove selections that no longer exist
			_selected.removeWhere((id) => !allCategories.any((c) => c.id == id));
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
		_userId = null;
		_custom = [];
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
		return allCategories.firstWhere(
			(c) => c.id == id,
			orElse: () => CategoryModel.getDefaultById('other'),
		);
	}

			Future<bool> addCustom(String id, String name, {int sortOrder = 1000, IconData? icon, Color? color}) async {
			if (_trousseauId == null || _userId == null) return false;
		try {
				final scopedId = '${_userId!}__$id';
				await _repo.addCategory(
					_trousseauId!,
					id: scopedId,
				name: name,
				sortOrder: sortOrder,
					createdBy: _userId!,
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

	Future<bool> removeCustom(String id) async {
			if (_trousseauId == null || _userId == null) return false;
		try {
			// Check if this is a default category
			final isDefault = CategoryModel.defaultCategories.any((c) => c.id == id);
			String scopedId;
			
			if (isDefault) {
				// For default categories, create a hidden custom version with special marker
				scopedId = '${_userId!}__$id';
				final existingCustom = _custom.any((c) => c.id == scopedId);
				if (!existingCustom) {
					// Add as hidden custom category
					final defaultCat = CategoryModel.defaultCategories.firstWhere((c) => c.id == id);
					await _repo.addCategory(
						_trousseauId!,
						id: scopedId,
						name: '___DELETED___${defaultCat.displayName}',
						sortOrder: 9999,
						createdBy: _userId!,
						iconCode: defaultCat.icon.codePoint,
						colorValue: defaultCat.color.toARGB32(),
					);
					return true;
				} else {
					// Already customized, just delete it
					await _repo.removeCategory(_trousseauId!, scopedId);
					return true;
				}
			} else {
				scopedId = id.contains('__') ? id : '${_userId!}__$id';
				await _repo.removeCategory(_trousseauId!, scopedId);
			}
			return true;
		} catch (e) {
			_error = e.toString();
			notifyListeners();
			return false;
		}
	}

	Future<bool> updateCustom(String id, {String? name, IconData? icon, Color? color}) async {
		if (_trousseauId == null || _userId == null) return false;
		try {
			// Check if this is a default category being customized for the first time
			final isDefault = CategoryModel.defaultCategories.any((c) => c.id == id);
			String scopedId;
			
			if (isDefault) {
				// For default categories, create a scoped custom version
				scopedId = '${_userId!}__$id';
				// Check if custom version already exists
				final existingCustom = _custom.any((c) => c.id == scopedId);
				if (!existingCustom) {
					// Add as new custom category
					final defaultCat = CategoryModel.defaultCategories.firstWhere((c) => c.id == id);
					await _repo.addCategory(
						_trousseauId!,
						id: scopedId,
						name: name ?? defaultCat.displayName,
						sortOrder: defaultCat.sortOrder,
						createdBy: _userId!,
						iconCode: icon?.codePoint ?? defaultCat.icon.codePoint,
						colorValue: color?.toARGB32() ?? defaultCat.color.toARGB32(),
					);
					return true;
				}
			} else {
				scopedId = id.contains('__') ? id : '${_userId!}__$id';
			}
			
			await _repo.updateCategory(
				_trousseauId!,
				scopedId,
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

	Future<bool> renameCustom(String id, String newName) async {
			if (_trousseauId == null || _userId == null) return false;
		try {
				final scopedId = id.contains('__') ? id : '${_userId!}__$id';
				await _repo.renameCategory(_trousseauId!, scopedId, newName);
			return true;
		} catch (e) {
			_error = e.toString();
			notifyListeners();
			return false;
		}
	}
}
