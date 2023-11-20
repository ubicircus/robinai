import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/provider/theme_provider.dart';
import '../../domain/entities/app_themes.dart';

class SettingsPage extends StatelessWidget {
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Teal Theme'),
            onTap: () {
              themeProvider.setTheme(AppThemes.tealTheme);
            },
          ),
          ListTile(
            title: Text('Indigo Theme'),
            onTap: () {
              themeProvider.setTheme(AppThemes.indigoTheme);
            },
          ),
          ListTile(
            title: Text('Charcoal Theme'),
            onTap: () {
              themeProvider.setTheme(AppThemes.charcoalTheme);
            },
          ),
          ListTile(
            title: Text('Purple Theme'),
            onTap: () {
              themeProvider.setTheme(AppThemes.purpleTheme);
            },
          ),
          ListTile(
            title: Text('Amber Theme'),
            onTap: () {
              themeProvider.setTheme(AppThemes.amberTheme);
            },
          ),
          // ... Add
        ],
      ),
    );
  }
}
