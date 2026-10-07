import 'package:flutter/material.dart';

import '../../modules/ressources_pedagogiques/views/matieres_view.dart';
import '../../modules/ressources_pedagogiques/views/ressources_dashboard_view.dart';
import '../../modules/ressources_pedagogiques/views/matiere_detail_view.dart';
import '../../modules/ressources_pedagogiques/views/add_edit_matiere_view.dart';
import '../../modules/ressources_pedagogiques/models/matiere.dart';

class AppRoutes {
  static const String home = '/';
  static const String matieres = '/matieres';
  static const String ressourcesDashboard = '/ressources-dashboard';
  static const String matiereDetail = '/matiere-detail';
  static const String addEditMatiere = '/add-edit-matiere';

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

        case addEditMatiere:
        final matiere = settings.arguments as Matiere?;
        return MaterialPageRoute(
          builder: (_) => AddEditMatiereView(matiere: matiere),
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