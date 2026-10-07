import 'package:flutter/material.dart';

import '../../modules/ressources_pedagogiques/models/matiere.dart';
import '../../modules/ressources_pedagogiques/views/add_edit_matiere_view.dart';
import '../../modules/ressources_pedagogiques/views/matiere_detail_view.dart';
import '../../modules/ressources_pedagogiques/views/matieres_view.dart';
import '../../modules/ressources_pedagogiques/views/ressources_dashboard_view.dart';
import '../../modules/ressources_pedagogiques/views/delete_matiere_view.dart';
import '../../modules/ressources_pedagogiques/views/add_edit_fiche_view.dart';
import '../../modules/ressources_pedagogiques/views/fiches_cours_view.dart';
import '../../modules/ressources_pedagogiques/views/delete_fiche_view.dart';

class AppRoutes {
  static const String home = '/';
  static const String matieres = '/matieres';
  static const String ressourcesDashboard = '/ressources-dashboard';
  static const String matiereDetail = '/matiere-detail';
  static const String addEditMatiere = '/add-edit-matiere';
  static const String deleteMatiere = '/delete-matiere';
  static const String addEditFiche = '/add-edit-fiche';
  static const String fichesCours = '/fiches-cours';
  static const String deleteFiche = '/delete-fiche';
  static const String addFiche = '/add-fiche';

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
        final matiere = settings.arguments as Matiere;

        return MaterialPageRoute(
          builder: (_) => MatiereDetailView(
            matiere: matiere,
          ),
        );

      case addEditMatiere:
        final matiere = settings.arguments as Matiere?;

        return MaterialPageRoute(
          builder: (_) => AddEditMatiereView(
            matiere: matiere,
          ),
        );

      case deleteMatiere:
        final matiere = settings.arguments as Matiere;

        return MaterialPageRoute(
          builder: (_) => DeleteMatiereView(
            matiere: matiere,
          ),
        );

      case addFiche:
        return MaterialPageRoute(
          builder: (_) => const AddEditFicheView(),
        );

      case fichesCours:
        return MaterialPageRoute(
          builder: (_) => const FichesCoursView(),
        );

      case deleteFiche:
        final fiche = settings.arguments as FicheItem?;
        return MaterialPageRoute(
          builder: (_) => DeleteFicheView(fiche: fiche),
        );

      /*case addFiche:
        return MaterialPageRoute(
          builder: (_) => const AddFicheView(),
        );*/

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