import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Solo persiste una preferencia visual; nunca credenciales ni incidencias.
class ThemeState extends ChangeNotifier {
  final SharedPreferences preferences;
  ThemeState(this.preferences);
  bool get dark => preferences.getBool('darkTheme') ?? false;
  ThemeMode get mode => dark ? ThemeMode.dark : ThemeMode.light;
  Future<void> toggle() async {
    await preferences.setBool('darkTheme', !dark);
    notifyListeners();
  }
}
