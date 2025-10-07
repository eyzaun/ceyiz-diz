import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../core/constants/app_constants.dart';
import '../models/product_model.dart';

class ProductRepository {
	final FirebaseFirestore _firestore;
	final FirebaseStorage _storage;

	ProductRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
			: _firestore = firestore ?? FirebaseFirestore.instance,
				_storage = storage ?? FirebaseStorage.instance;

	Future<List<ProductModel>> listByTrousseau(String trousseauId) async {
		final query = await _firestore
				.collection(AppConstants.productsCollection)
				.where('trousseauId', isEqualTo: trousseauId)
				.orderBy('createdAt', descending: true)
				.get();
		return query.docs.map((e) => ProductModel.fromFirestore(e)).toList();
	}

	Future<String> _uploadImage(String productId, File file) async {
		final ref = _storage.ref().child('${AppConstants.productImagesPath}/$productId/${DateTime.now().millisecondsSinceEpoch}.jpg');
		final task = await ref.putFile(file);
		return task.ref.getDownloadURL();
	}

	Future<ProductModel> create(ProductModel product, {List<File> images = const []}) async {
		final imageUrls = <String>[];
		for (final f in images) {
			imageUrls.add(await _uploadImage(product.id, f));
		}
		final toSave = product.copyWith(images: imageUrls);
		await _firestore.collection(AppConstants.productsCollection).doc(product.id).set(toSave.toFirestore());
		return toSave;
	}

	Future<void> update(String productId, Map<String, dynamic> updates) async {
		await _firestore.collection(AppConstants.productsCollection).doc(productId).update(updates);
	}

	Future<void> delete(ProductModel product) async {
		for (final url in product.images) {
			try {
				await _storage.refFromURL(url).delete();
			} catch (_) {}
		}
		await _firestore.collection(AppConstants.productsCollection).doc(product.id).delete();
	}
}

