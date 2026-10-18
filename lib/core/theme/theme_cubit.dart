import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themeKey = 'elite_prepa_theme_mode';

  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  /// Charge le thème sauvegardé.
  Future<void> _loadTheme() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedTheme = preferences.getString(_themeKey);

      if (savedTheme == 'dark') {
        emit(ThemeMode.dark);
      } else if (savedTheme == 'system') {
        emit(ThemeMode.system);
      } else {
        emit(ThemeMode.light);
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement du thème : $e');
    }
  }

  /// Change le thème et sauvegarde le choix.
  Future<void> changeTheme(ThemeMode themeMode) async {
    emit(themeMode);

    try {
      final preferences = await SharedPreferences.getInstance();

      String value;

      switch (themeMode) {
        case ThemeMode.light:
          value = 'light';
          break;
        case ThemeMode.dark:
          value = 'dark';
          break;
        case ThemeMode.system:
          value = 'system';
          break;
      }

      await preferences.setString(_themeKey, value);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du thème : $e');
    }
  }
}