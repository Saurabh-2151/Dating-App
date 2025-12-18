import 'package:dating_app/core/services/match_service.dart';
import 'package:dating_app/data/models/users/user_model.dart';
import 'package:flutter/material.dart';

class DiscoverProvider with ChangeNotifier {
  final PageController pageController = PageController();
  final MatchService _matchService = MatchService();

  bool _disposed = false;

  List<User> users = [];
  bool isLoading = true;
  int currentIndex = 0;

  DiscoverProvider() {
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      users = await _matchService.getDiscoverableUsers();
      isLoading = false;
      if (!_disposed) {
        notifyListeners();
      }
    } catch (e) {
      isLoading = false;
      if (!_disposed) {
        notifyListeners();
      }
      rethrow;
    }
  }

  void onPageChanged(int index) {
    currentIndex = index;
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> swipeLeft() async {
    if (currentIndex < users.length) {
      await _matchService.dislikeUser(users[currentIndex].id);
      _goToNextProfile();
    }
  }

  Future<void> swipeRight() async {
    if (currentIndex < users.length) {
      await _matchService.likeUser(users[currentIndex].id);
      _goToNextProfile();
    }
  }

  Future<void> superLike() async {
    if (currentIndex < users.length) {
      await _matchService.superLikeUser(users[currentIndex].id);
      _goToNextProfile();
    }
  }

  void _goToNextProfile() {
    if (currentIndex < users.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      users.removeAt(currentIndex);
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    pageController.dispose();
    super.dispose();
  }
}
