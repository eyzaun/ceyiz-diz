import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
	final FirebaseStorage _storage;

	StorageService({FirebaseStorage? storage}) : _storage = storage ?? FirebaseStorage.instance;

	/// Upload file (cross-platform)
	/// Web: uses putData with bytes
	/// Mobile: uses putFile
	Future<String> uploadFile({
		required dynamic file, // File for mobile, Uint8List for web
		required String path,
		SettableMetadata? metadata,
	}) async {
		final ref = _storage.ref().child(path);
		
		TaskSnapshot task;
		if (kIsWeb && file is Uint8List) {
			// Web: file is bytes
			task = await ref.putData(file, metadata);
		} else if (file is File) {
			// Mobile: file is File
			task = await ref.putFile(file, metadata);
		} else {
			throw ArgumentError('Invalid file type. Expected File or Uint8List');
		}
		
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

