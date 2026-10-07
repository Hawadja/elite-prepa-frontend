import 'package:flutter/material.dart';

import '../../modules/ressources_pedagogiques/views/ressources_dashboard_view.dart';
import '../../modules/ressources_pedagogiques/views/matieres_view.dart';

class AppRoutes {
  static const String home = '/';
  static const String matieres = '/matieres';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const RessourcesDashboardView(),
        );
        
      case matieres:
        return MaterialPageRoute(
          builder: (_) => const MatieresView(),
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