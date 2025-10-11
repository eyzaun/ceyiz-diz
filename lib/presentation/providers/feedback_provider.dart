import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../data/repositories/feedback_repository.dart';
import '../../data/services/firebase_service.dart';

class FeedbackProvider with ChangeNotifier {
  final FeedbackRepository _repo;
  FeedbackProvider({FeedbackRepository? repo}) : _repo = repo ?? FeedbackRepository();

  final TextEditingController messageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  int? _rating;
  bool _submitting = false;
  String _error = '';

  int? get rating => _rating;
  bool get isSubmitting => _submitting;
  String get errorMessage => _error;

  void setRating(int? value) {
    _rating = value;
    notifyListeners();
  }

  void clear() {
    messageController.clear();
    emailController.clear();
    _rating = null;
    _error = '';
    notifyListeners();
  }

  Future<bool> submit() async {
    final message = messageController.text.trim();
    final email = emailController.text.trim().isEmpty ? null : emailController.text.trim();
    if (message.isEmpty) {
      _error = 'Lütfen geri bildirim mesajını yazın';
      notifyListeners();
      return false;
    }

    _submitting = true;
    _error = '';
    notifyListeners();

    try {
      final user = FirebaseService.auth.currentUser;
      final userId = user?.uid;
      final appVersion = null; // Optionally wire in from package_info_plus
      final platform = kIsWeb
          ? 'web'
          : Platform.isAndroid
              ? 'android'
              : Platform.isIOS
                  ? 'ios'
                  : Platform.isWindows
                      ? 'windows'
                      : Platform.isMacOS
                          ? 'macos'
                          : Platform.isLinux
                              ? 'linux'
                              : 'unknown';

      await _repo.submit(
        message: message,
        email: email,
        rating: _rating,
        userId: userId,
        appVersion: appVersion,
        platform: platform,
      );
      _submitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _submitting = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
