
class AppRoutes {
  AppRoutes._();

  // Accueil et dashboard
  static const String home = '/';
  static const String ressourcesDashboard = '/ressources-dashboard';

  // Authentification
  static const String register = '/register';
  static const String otp = '/otp';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String profil = '/profil';

  // Matières
  static const String matieres = '/matieres';
  static const String matiereDetail = '/matiere-detail';
  static const String addEditMatiere = '/add-edit-matiere';

  // Fiches de cours
  static const String addEditFiche = '/add-edit-fiche';
  static const String fichesCours = '/fiches-cours';
  static const String addFiche = '/add-fiche';
  static const String ficheDetail = '/fiche-detail';

  // Sujets de concours
  static const String sujetsConcours = '/sujets-concours';
  static const String addEditSujet = '/add-edit-sujet';
  static const String sujetsGestion = '/sujets-gestion';
  static const String sujetDetail = '/sujet-detail';

  // Corrigés
  static const String corriges = '/corriges';
  static const String corrigeDetail = '/corrige-detail';
  static const String addEditCorrige = '/add-edit-corrige';
  static const String telechargerCorrige = '/telecharger-corrige';

  // Recherche et consultation
  static const String rechercheAvancee = '/recherche-avancee';
  static const String toutesRessources = '/toutes-ressources';
}