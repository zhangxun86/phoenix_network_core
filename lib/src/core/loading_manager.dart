import 'package:flutter/foundation.dart';

class LoadingManager extends ChangeNotifier {
  int _requestCount = 0;
  bool get isLoading => _requestCount > 0;

  void addRequest() {
    _requestCount++;
    if (_requestCount == 1) {
      Future.microtask(() => notifyListeners());
    }
  }

  void removeRequest() {
    if (_requestCount > 0) {
      _requestCount--;
      if (_requestCount == 0) {
        Future.microtask(() => notifyListeners());
      }
    }
  }
}