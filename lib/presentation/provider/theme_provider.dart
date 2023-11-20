import 'package:flutter/material.dart';
import '../../domain/entities/app_themes.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _selectedTheme;

  ThemeProvider(this._selectedTheme);

  getTheme() => _selectedTheme;

  setTheme(ThemeData theme) {
    _selectedTheme = theme;
    notifyListeners();
  }
}
