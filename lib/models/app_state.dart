import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  // Placeholder for app-level state. Extend as needed.
  int bottomNavIndex = 0;

  void setBottomNav(int idx) {
    bottomNavIndex = idx;
    notifyListeners();
  }
}
