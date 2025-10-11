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
	List<CategoryModel> get customCategories => List.unmodifiable(_custom);
	List<CategoryModel> get defaultCategories => CategoryModel.defaultCategories;

	List<CategoryModel> get allCategories {
		final combined = [...CategoryModel.defaultCategories, ..._custom];
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
				final scopedId = id.contains('__') ? id : '${_userId!}__$id';
				await _repo.removeCategory(_trousseauId!, scopedId);
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
