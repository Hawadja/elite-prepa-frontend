import 'package:flutter/material.dart';

import '../../modules/ressources_pedagogiques/views/matieres_view.dart';
import '../../modules/ressources_pedagogiques/views/ressources_dashboard_view.dart';
import '../../modules/ressources_pedagogiques/views/matiere_detail_view.dart';

class AppRoutes {
  static const String home = '/';
  static const String matieres = '/matieres';
  static const String ressourcesDashboard = '/ressources-dashboard';
  static const String matiereDetail = '/matiere-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
      case ressourcesDashboard:
        return MaterialPageRoute(
          builder: (_) => const RessourcesDashboardView(),
        );

      case matieres:
        return MaterialPageRoute(
          builder: (_) => const MatieresView(),
        );

      case matiereDetail:
        final arguments = settings.arguments as Map<String, String>;

        return MaterialPageRoute(
          builder: (_) => MatiereDetailView(
            matiereId: arguments['matiereId']!,
            matiereNom: arguments['matiereNom']!,
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