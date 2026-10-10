import 'package:flutter/foundation.dart';

import '../models/fiche_cours.dart';
import '../repositories/fiche_cours_repository.dart';

class FicheCoursViewModel extends ChangeNotifier {
  final FicheCoursRepository _repository = FicheCoursRepository();

  List<FicheCours> _fiches = [];

  bool _isLoading = false;
  String? _errorMessage;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;

  String? _matiere;
  String? _concours;
  String? _anneeAcademique;
  String _search = '';

  List<FicheCours> get fiches => List.unmodifiable(_fiches);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  int get currentPage => _currentPage;

  int get totalPages => _totalPages;

  int get totalItems => _totalItems;

  String? get matiere => _matiere;

  String? get concours => _concours;

  String? get anneeAcademique => _anneeAcademique;

  String get search => _search;

  Future<void> chargerFiches({
    bool nouvelleRecherche = false,
  }) async {
    if (nouvelleRecherche) {
      _currentPage = 1;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final resultat = await _repository.getFichesCours(
        page: _currentPage,
        limit: 10,
        matiere: _matiere,
        concours: _concours,
        anneeAcademique: _anneeAcademique,
        search: _search,
      );

      _fiches = resultat['data'] as List<FicheCours>;
      _currentPage = resultat['page'] as int;
      _totalPages = resultat['totalPages'] as int;
      _totalItems = resultat['total'] as int;
    } catch (e) {
      _errorMessage = e.toString();
      _fiches = [];
      _totalItems = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rechercher(String valeur) async {
    _search = valeur.trim();
    await chargerFiches(nouvelleRecherche: true);
  }

  Future<void> filtrerMatiere(String? valeur) async {
    _matiere = valeur;
    await chargerFiches(nouvelleRecherche: true);
  }

  Future<void> filtrerConcours(String? valeur) async {
    _concours = valeur;
    await chargerFiches(nouvelleRecherche: true);
  }

  Future<void> filtrerAnneeAcademique(String? valeur) async {
    _anneeAcademique = valeur;
    await chargerFiches(nouvelleRecherche: true);
  }

  Future<void> allerPage(int page) async {
    if (page < 1 || page > _totalPages || page == _currentPage) {
      return;
    }

    _currentPage = page;
    await chargerFiches();
  }

  Future<void> actualiser() async {
    await chargerFiches();
  }
}

