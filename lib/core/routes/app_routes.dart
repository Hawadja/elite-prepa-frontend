import 'package:flutter/material.dart';
import '../../utilisateurs/views/screens/login_screen.dart';
import '../../utilisateurs/views/screens/register_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String profil = '/profil';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );

      case otp:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Vérification OTP')),
            body: Center(
              child: Text('Écran OTP pour $email'),
            ),
          ),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Mot de passe oublié')),
            body: const Center(
              child: Text('Écran Mot de passe oublié'),
            ),
          ),
        );

      case resetPassword:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Réinitialisation')),
            body: const Center(
              child: Text('Écran de Réinitialisation'),
            ),
          ),
        );

      case profil:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Profil')),
            body: const Center(
              child: Text('Écran Profil'),
            ),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page introuvable'),
            ),
          ),
        );
    }
  }
}