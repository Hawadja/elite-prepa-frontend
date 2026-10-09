import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_colors.dart';

void main() {
WidgetsFlutterBinding.ensureInitialized();

runApp(const ElitePrepaApp());
}

class ElitePrepaApp extends StatelessWidget {
const ElitePrepaApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,
title: 'Elite Prepa',


  theme: ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.icon,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    useMaterial3: true,
    fontFamily: 'Calibri',
  ),

  darkTheme: ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      brightness: Brightness.dark,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.icon,
    ),
    useMaterial3: true,
    fontFamily: 'Calibri',
  ),

  themeMode: ThemeMode.light,

  initialRoute: AppRoutes.home,
  onGenerateRoute: AppRoutes.generateRoute,
);

}
}
