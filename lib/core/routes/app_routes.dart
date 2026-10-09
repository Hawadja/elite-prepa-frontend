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
import '../../modules/ressources_pedagogiques/views/sujets_concours_view.dart';
import '../../modules/ressources_pedagogiques/views/add_edit_sujet_view.dart';
import '../../modules/ressources_pedagogiques/views/sujets_gestion_view.dart';
import '../../modules/ressources_pedagogiques/views/sujet_detail_view.dart';
import '../../modules/ressources_pedagogiques/views/corriges_view.dart';
import '../../modules/ressources_pedagogiques/views/add_edit_corrige_view.dart';
import '../../modules/ressources_pedagogiques/views/telecharger_corrige_view.dart';
import '../../modules/ressources_pedagogiques/views/recherche_avancee_view.dart';
import '../../modules/ressources_pedagogiques/views/corrige_detail_view.dart';


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
  static const String sujetsConcours = '/sujets-concours';
  static const String addEditSujet = '/add-edit-sujet';
  static const String sujetsGestion = '/sujets-gestion';
  static const String sujetDetail = '/sujet-detail';
  static const String corriges = '/corriges';
  static const String corrigeDetail = '/corrige-detail';
  static const String addEditCorrige = '/add-edit-corrige';
  static const String telechargerCorrige = '/telecharger-corrige';
  static const String rechercheAvancee = '/recherche-avancee';

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

      // --- Sujets de concours ---
      case sujetsConcours:
        return MaterialPageRoute(
          builder: (_) => const SujetsConcoursView(),
        );

      case sujetsGestion:
        return MaterialPageRoute(
          builder: (_) => const SujetsGestionView(),
        );

      case addEditSujet:
        final args = settings.arguments as Map<String, String?>?;

        return MaterialPageRoute(
          builder: (_) => AddEditSujetView(
            id: args?['id'],
            titre: args?['titre'],
            matiere: args?['matiere'],
            description: args?['description'],
            concours: args?['concours'],
            anneeAcademique: args?['anneeAcademique'],
            nomFichier: args?['nomFichier'],
          ),
        );

      case sujetDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final hasCorrige = args?['hasCorrige'] ?? true;
        return MaterialPageRoute(
          builder: (_) => SujetDetailView(hasCorrige: hasCorrige),
        );

      case corriges:
        return MaterialPageRoute(
          builder: (_) => const CorrigesView(),
        );


      case addEditCorrige:
        final args =
            settings.arguments as Map<String, String?>?;

        return MaterialPageRoute(
          builder: (_) => AddEditCorrigeView(
            id: args?['id'],
            titre: args?['titre'],
            sousTitre: args?['sousTitre'],
            matiere: args?['matiere'],
            concours: args?['concours'],
            annee: args?['annee'],
            nomFichier: args?['nomFichier'],
          ),
        );


      case telechargerCorrige:
        final args =
            settings.arguments as Map<String, String?>?;

        return MaterialPageRoute(
          builder: (_) => TelechargerCorrigeView(
            id: args?['id'],
            titre: args?['titre'],
            sousTitre: args?['sousTitre'],
            matiere: args?['matiere'],
            concours: args?['concours'],
            annee: args?['annee'],
            nomFichier: args?['nomFichier'],
            type: args?['type'] ?? 'corrige',
          ),
        );

      case rechercheAvancee:
        return MaterialPageRoute(
          builder: (_) => const RechercheAvanceeView(),
        );

      case corrigeDetail:
        final args = settings.arguments as Map<String, dynamic>?;

        return MaterialPageRoute(
          builder: (_) => CorrigeDetailView(
            id: args?['id']?.toString() ?? '',
            titre: args?['titre']?.toString() ?? 'Corrigé sans titre',
            sousTitre: args?['sousTitre']?.toString() ?? '',
            matiere: args?['matiere']?.toString() ?? 'Matière non renseignée',
            concours: args?['concours']?.toString() ?? '',
            annee: args?['annee']?.toString() ?? '',
            nomFichier: args?['nomFichier']?.toString(),
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