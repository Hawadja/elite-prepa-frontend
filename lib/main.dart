import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'utilisateurs/viewmodels/auth_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ElitePrepaApp());
}

class ElitePrepaApp extends StatelessWidget {
  const ElitePrepaApp({super.key});

  static const Color primaryColor = Color(0xFF1F3F6E);
  static const Color accentColor = Color(0xFFF0A500);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => AuthCubit()..checkAuthStatus(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Elite Prepa',
        routerConfig: AppRouter.router,
        theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            primary: primaryColor,
            secondary: accentColor,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: backgroundColor,
          iconTheme: const IconThemeData(
            color: primaryColor,
          ),
          useMaterial3: true,
          fontFamily: 'Calibri',
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            primary: primaryColor,
            secondary: accentColor,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'Calibri',
        ),
        themeMode: ThemeMode.light,
      ),
    );
  }
}