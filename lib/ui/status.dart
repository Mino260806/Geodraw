import 'package:flutter/material.dart';

class UiStatus extends ChangeNotifier {
  bool _isLoading = false;
  bool _isLocked = false;

  bool get isLoading => _isLoading;
  set isLoading(newValue) {
    _isLoading = newValue;
    notifyListeners();
  }
  bool get isLocked => _isLocked;
  set isLocked(newValue) {
    _isLocked = newValue;
    notifyListeners();
  }
}