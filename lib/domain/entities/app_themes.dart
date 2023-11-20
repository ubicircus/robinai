import 'package:flutter/material.dart';

class AppThemes {
  static final tealTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.teal,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static final indigoTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.indigo,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static final charcoalTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.grey[850],
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static final purpleTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.purple,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static final amberTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.amber,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  // You may want to add a function to get the theme by a unique key or index
  static ThemeData getThemeByName(String themeName) {
    switch (themeName) {
      case 'teal':
        return tealTheme;
      case 'indigo':
        return indigoTheme;
      case 'charcoal':
        return charcoalTheme;
      case 'purple':
        return purpleTheme;
      case 'amber':
        return amberTheme;
      default:
        return tealTheme; // Your default theme
    }
  }
}
