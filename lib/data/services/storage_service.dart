import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
	final FirebaseStorage _storage;

	StorageService({FirebaseStorage? storage}) : _storage = storage ?? FirebaseStorage.instance;

	Future<String> uploadFile({
		required File file,
		required String path,
		SettableMetadata? metadata,
	}) async {
		final ref = _storage.ref().child(path);
		final task = await ref.putFile(file, metadata);
		return task.ref.getDownloadURL();
	}

	Future<void> deleteByUrl(String url) async {
		try {
			final ref = _storage.refFromURL(url);
			await ref.delete();
		} catch (_) {
			// ignore
		}
	}
}

