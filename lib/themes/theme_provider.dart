import 'package:flutter/material.dart';
import 'package:twitmania/themes/dark_mode.dart';
import 'package:twitmania/themes/light_mode.dart';

class ThemeProvider with ChangeNotifier {
  // Initially, set it as light mode.
  ThemeData _themeData = lightMode;

  // Get the current theme
  ThemeData get themeData => _themeData;

  // Is it dark mode currently?
  bool get isDarkMode => _themeData == darkMode;

  // Set the theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;

    // update UI
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
