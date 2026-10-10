import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../utilisateurs/viewmodels/auth_cubit.dart';
import '../../utilisateurs/views/screens/forgot_password_screen.dart';
import '../../utilisateurs/views/screens/login_screen.dart';
import '../../utilisateurs/views/screens/otp_screen.dart';
import '../../utilisateurs/views/screens/profil_screen.dart';
import '../../utilisateurs/views/screens/register_screen.dart';
import '../../utilisateurs/views/screens/reset_password_screen.dart';
import '../screens/splash_screen.dart';
import '../storage/token_storage.dart';

class AppRouter {
  static final TokenStorage _tokenStorage = TokenStorage();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: AuthNotifier.instance,
    redirect: (BuildContext context, GoRouterState state) async {
      final location = state.matchedLocation;

      if (location == '/splash') {
        await Future.delayed(const Duration(milliseconds: 1500));
      }

      final token = await _tokenStorage.getAccessToken();
      final hasToken = token != null && token.isNotEmpty;

      // Traitement prioritaire pour /splash
      if (location == '/splash') {
        return hasToken ? '/home' : '/login';
      }

      final unauthRoutes = [
        '/login',
        '/register',
        '/otp',
        '/forgot-password',
        '/reset-password',
      ];

      final isUnauthRoute = unauthRoutes.contains(location);

      if (hasToken && isUnauthRoute) {
        return '/home';
      }

      if (!hasToken && (location == '/home' || location == '/profil')) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            return OtpScreen(
              email: extra['email']?.toString() ?? '',
              nom: extra['nom']?.toString() ?? '',
              prenom: extra['prenom']?.toString() ?? '',
            );
          }
          final email = extra as String? ?? '';
          return OtpScreen(email: email);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final token = state.extra as String?;
          return ResetPasswordScreen(token: token);
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profil',
        builder: (context, state) {
          String userId = state.extra as String? ?? '';
          if (userId.isEmpty) {
            final authState = context.read<AuthCubit>().state;
            if (authState is Authenticated) {
              userId = authState.user?.id ?? '';
            }
          }
          return ProfilScreen(userId: userId);
        },
      ),
    ],
  );
}



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color navyColor = Color(0xFF1F3F6E);
  static const Color goldColor = Color(0xFFF0A500);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Elite Prépa - Accueil'),
        backgroundColor: navyColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: goldColor),
            onPressed: () {
              final authState = context.read<AuthCubit>().state;
              final userId =
                  authState is Authenticated ? authState.user?.id : null;
              context.push('/profil', extra: userId);
            },
            tooltip: 'Profil',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () {
              context.read<AuthCubit>().logout();
            },
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [navyColor, Color(0xFF2C538F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenue sur Elite Prépa !',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Votre plateforme de gestion et de prépa.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Actions rapides',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: navyColor,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.account_circle, color: goldColor),
                title: const Text('Gérer mon profil'),
                subtitle: const Text('Consulter et modifier mes informations'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  final authState = context.read<AuthCubit>().state;
                  final userId =
                      authState is Authenticated ? authState.user?.id : null;
                  context.push('/profil', extra: userId);
                },
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
