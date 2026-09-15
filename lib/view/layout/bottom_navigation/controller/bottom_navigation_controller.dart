import 'package:flutter/foundation.dart';

class BottomNavigationController extends ChangeNotifier {
  int screenIndex = 0;

  void updateIndex(int index) {
    screenIndex = index;
    notifyListeners();
  }

  void onWillPop(bool pop) {
    if (screenIndex != 0) {
      updateIndex(0);
    }
  }
}
