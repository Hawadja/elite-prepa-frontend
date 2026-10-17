import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/theme/theme_cubit.dart';
import 'utilisateurs/viewmodels/auth_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ElitePrepaApp());
}

class ElitePrepaApp extends StatelessWidget {
  const ElitePrepaApp({super.key});

  static const Color primaryColor = Color(0xFF1F3F6E);
  static const Color accentColor = Color(0xFFF0A500);

  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color darkBackground = Color(0xFF081B32);
  static const Color darkCard = Color(0xFF0F233F);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit()..checkAuthStatus(),
        ),
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Elite Prepa',
            routerConfig: AppRouter.router,

            // =========================
            // THÈME CLAIR
            // =========================
            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: primaryColor,
                primary: primaryColor,
                secondary: accentColor,
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: lightBackground,
              iconTheme: const IconThemeData(
                color: primaryColor,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: primaryColor,
                elevation: 0,
              ),
              cardTheme: const CardThemeData(
                color: Colors.white,
                elevation: 1,
              ),
              useMaterial3: true,
              fontFamily: 'Calibri',
            ),

            // =========================
            // THÈME SOMBRE
            // =========================
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: primaryColor,
                primary: primaryColor,
                secondary: accentColor,
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: darkBackground,
              cardColor: darkCard,
              appBarTheme: const AppBarTheme(
                backgroundColor: darkBackground,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              cardTheme: const CardThemeData(
                color: darkCard,
                elevation: 1,
              ),
              dividerColor: Colors.white12,
              useMaterial3: true,
              fontFamily: 'Calibri',
            ),

            // Le thème dépend maintenant du ThemeCubit.
            themeMode: themeMode,
          );
        },
      ),
    );
  }
}