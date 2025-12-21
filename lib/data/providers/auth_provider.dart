import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:dating_app/core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isGuest = false;
  bool _initialized = false;
  bool _hasCompletedOnboarding = false;

  static const String _guestModeKey = 'auth_is_guest';

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isGuest => _isGuest;
  bool get isInitialized => _initialized;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  AuthProvider() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });

    // Initialize with current user
    _user = _authService.currentUser;

    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isGuest = prefs.getBool(_guestModeKey) ?? false;
      if (_user != null) {
        _hasCompletedOnboarding =
            await _authService.hasCompletedOnboarding(_user!.uid);
      }
    } catch (_) {
      _isGuest = false;
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> skipLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_guestModeKey, true);
      _isGuest = true;
      notifyListeners();
    } catch (_) {
      _isGuest = true;
      notifyListeners();
    }
  }

  Future<void> _clearGuestMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_guestModeKey);
    } catch (_) {}
    _isGuest = false;
  }

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _authService.signInWithGoogle();

      if (userCredential != null) {
        _user = userCredential.user;
        _hasCompletedOnboarding = await _authService
            .hasCompletedOnboarding(userCredential.user!.uid);
        await _clearGuestMode();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signOut();
      _user = null;
      _hasCompletedOnboarding = false;
      await _clearGuestMode();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final current = _user;
    if (current == null) return;
    await _authService.setOnboardingCompleted(current.uid);
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  Future<void> saveOnboardingData(Map<String, dynamic> data) async {
    final current = _user;
    if (current == null) return;
    await _authService.saveOnboardingData(current.uid, data);
  }
}
