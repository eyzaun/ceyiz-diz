import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider extends ChangeNotifier {
  bool _onboardingCompleted = false;
  bool _isLoading = true;

  bool get onboardingCompleted => _onboardingCompleted;
  bool get isLoading => _isLoading;

  OnboardingProvider() {
    _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    } catch (e) {
      _onboardingCompleted = false;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      _onboardingCompleted = true;
      notifyListeners();
    } catch (e) {
      // Error saving onboarding status
    }
  }
}
