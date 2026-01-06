import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Logout logic would go here or delegate to AuthViewModel
  void logout() {
    // For now, just reset index or similar cleanup
    _currentIndex = 0;
    // Notify UI to handle navigation if needed, though usually handled by UI button
    notifyListeners();
  }
}
