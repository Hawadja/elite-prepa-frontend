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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Elite Prépa',
        routerConfig: AppRouter.router,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: const Color(0xFF1F3F6E),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1F3F6E),
            primary: const Color(0xFF1F3F6E),
            secondary: const Color(0xFFF0A500),
          ),
        ),
      ),
    );
  }
}