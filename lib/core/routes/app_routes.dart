import 'package:flutter/material.dart';
import '../../utilisateurs/views/screens/forgot_password_screen.dart';
import '../../utilisateurs/views/screens/login_screen.dart';
import '../../utilisateurs/views/screens/otp_screen.dart';
import '../../utilisateurs/views/screens/register_screen.dart';
import '../../utilisateurs/views/screens/reset_password_screen.dart';

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
          builder: (_) => OtpScreen(email: email),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
        );

      case resetPassword:
        final token = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(token: token),
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