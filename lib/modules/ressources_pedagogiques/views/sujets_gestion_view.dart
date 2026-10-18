import 'package:flutter/material.dart';

import 'dart:async';

import '../../../core/routes/app_routes.dart';
import '../viewmodels/sujet_viewmodel.dart';
import '../repositories/sujet_repository.dart';
import 'telecharger_corrige_view.dart';
import 'package:go_router/go_router.dart';
import '../services/pdf_share_service.dart';
import '../repositories/matiere_repository.dart';
import '../models/matiere.dart';

class SujetGestionItem {
  final String id;
  final String titre;
  final String sousTitre;
  final String matiere;
  final String matiereId;
  final String concours;
  final String annee;
  final bool aCorrige;

  SujetGestionItem({
    required this.id,
    required this.titre,
    required this.sousTitre,
    required this.matiere,
    required this.matiereId,
    required this.concours,
    required this.annee,
    this.aCorrige = true,
  });
}

class SujetsGestionView extends StatefulWidget {
  const SujetsGestionView({super.key});

  @override
  State<SujetsGestionView> createState() => _SujetsGestionViewState();
}

class _SujetsGestionViewState extends State<SujetsGestionView> {
  // ============================================================
  // CHARTE GRAPHIQUE ELITE-PREPA
  // ============================================================

  static const Color primaryColor = Color(0xFF1F3F6E);
  static const Color accentColor = Color(0xFFF0A500);

  static const Color darkBackground = Color(0xFF081B32);
  static const Color darkCardColor = Color(0xFF102542);

  static const Color lightBackground = Color(0xFFF5F5F5);

  static const Color deleteRed = Color(0xFFD9534F);

  // ============================================================
  // Ã‰TAT
  // ============================================================

  int _currentIndex = 2;
  int _currentPage = 1;

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  final MatiereRepository _matiereRepository = MatiereRepository();

  List<Matiere> _matieresDisponibles = [];
  List<String> _anneesDisponibles = [];
  List<String> _concoursDisponibles = [];

  String? _matiereSelectionnee;
  String? _anneeSelectionnee;
  String? _concoursSelectionne;
  int get _nombreFiltresActifs {
  int nombre = 0;

  if (_matiereSelectionnee != null) nombre++;
  if (_anneeSelectionnee != null) nombre++;
  if (_concoursSelectionne != null) nombre++;

  return nombre;
}

  // ============================================================
  // DONNÃ‰ES DU BACKEND
  // ============================================================

  final SujetViewModel _sujetViewModel = SujetViewModel();
  final SujetRepository _sujetRepository = SujetRepository();

  List<SujetGestionItem> _sujets = [];

  bool _isLoading = true;
  String? _errorMessage;

  int _totalSujets = 0;
  int _totalPages = 1;

  static const int _pageSize = 10;

  // ============================================================
  // CYCLE DE VIE
  // ============================================================

  @override
  void initState() {
    super.initState();
    _chargerFiltresDynamiques();
    _chargerSujets();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // CHARGEMENT DES SUJETS DEPUIS LE BACKEND
  // ============================================================

  Future<void> _chargerFiltresDynamiques() async {
    try {
      // Charger les matières depuis le backend.
      final matieres = await _matiereRepository.getMatieres();

      // Récupérer toutes les pages de sujets pour construire
      // les listes complètes des années et des concours.
      final Set<String> annees = {};
      final Set<String> concours = {};

      final premierePage = await _sujetViewModel.loadSujets(
        page: 1,
        limit: 100,
      );

      for (final sujet in premierePage.items) {
        final annee = sujet.anneeAcademique.trim();
        final nomConcours = sujet.concours.trim();

        if (annee.isNotEmpty) {
          annees.add(annee);
        }

        if (nomConcours.isNotEmpty) {
          concours.add(nomConcours);
        }
      }

      for (int page = 2; page <= premierePage.totalPages; page++) {
        final resultat = await _sujetViewModel.loadSujets(
          page: page,
          limit: 100,
        );

        for (final sujet in resultat.items) {
          final annee = sujet.anneeAcademique.trim();
          final nomConcours = sujet.concours.trim();

          if (annee.isNotEmpty) {
            annees.add(annee);
          }

          if (nomConcours.isNotEmpty) {
            concours.add(nomConcours);
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _matieresDisponibles = matieres
            .where((matiere) => matiere.id.isNotEmpty && matiere.nom.isNotEmpty)
            .toList()
          ..sort(
            (a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()),
          );

        _anneesDisponibles = annees.toList()
          ..sort((a, b) => b.compareTo(a));

        _concoursDisponibles = concours.toList()
          ..sort(
            (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
          );
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement des filtres : $e');
    }
  }

  Future<void> _chargerSujets() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final resultat = await _sujetViewModel.loadSujets(
        matiere: _matiereSelectionnee,
        concours: _concoursSelectionne,
        anneeAcademique: _anneeSelectionnee,
        search: _searchController.text.trim(),
        page: _currentPage,
        limit: _pageSize,
      );

      if (!mounted) return;

      setState(() {
        _sujets = resultat.items.map((sujet) {
          return SujetGestionItem(
            id: sujet.id,
            titre: sujet.titre,
            sousTitre: sujet.description,
            matiere: sujet.matiereNom.isNotEmpty
                ? sujet.matiereNom
                : 'Matiere non renseigner',
            concours: sujet.concours,
            annee: sujet.anneeAcademique,
            aCorrige: sujet.aCorrige,
            matiereId: sujet.matiereId,
          );
        }).toList();

        _totalSujets = resultat.total;
        _totalPages = resultat.totalPages < 1 ? 1 : resultat.totalPages;

        _currentPage = resultat.page;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // RECHERCHE / FILTRE
  // ============================================================

  List<SujetGestionItem> get _filteredSujets => _sujets;
    Future<void> _appliquerFiltre({
    String? matiere,
    String? annee,
    String? concours,
    bool reinitialiser = false,
  }) async {
    setState(() {
      _matiereSelectionnee = reinitialiser ? null : matiere;
      _anneeSelectionnee = reinitialiser ? null : annee;
      _concoursSelectionne = reinitialiser ? null : concours;
      _currentPage = 1;
    });

    await _chargerSujets();
  }

  // ============================================================
  // AJOUTER
  // ============================================================

 

  Future<void> _onAddSujet() async {
    final result = await context.push<bool>(AppRoutes.addEditSujet);

    if (result == true && mounted) {
      // Revenir Ã  la premiÃ¨re page pour afficher le sujet ajoutÃ©.
      setState(() {
        _currentPage = 1;
      });

      // Recharger les sujets depuis le backend.
      await _chargerSujets();
    }
  }

  // ============================================================
  // MODIFIER
  // ============================================================


  Future<void> _onModifierSujet(SujetGestionItem sujet) async {
    final result = await context.push<bool>(
      AppRoutes.addEditSujet,
      extra: {
        'id': sujet.id,
        'titre': sujet.titre,
        'matiereId': sujet.matiereId,
        'description': sujet.sousTitre,
        'concours': sujet.concours,
        'anneeAcademique': sujet.annee,
        'nomFichier': null,
      },
    );

    if (result == true && mounted) {
      await _chargerSujets();
    }
  }


  // ============================================================
  // VOIR
  // ============================================================

  void _onVoirSujet(SujetGestionItem sujet) {
    context.push(
    AppRoutes.sujetDetail,
    extra: {
    'id': sujet.id,
    'hasCorrige': sujet.aCorrige,
    },
    );
  }


  // ============================================================
  // TÃ‰LÃ‰CHARGER
  // ============================================================

  void _onTelechargerSujet(SujetGestionItem sujet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TelechargerCorrigeView(
          id: sujet.id,
          titre: sujet.titre,
          sousTitre: sujet.sousTitre,
          matiere: sujet.matiere,
          concours: sujet.concours,
          annee: sujet.annee,
          nomFichier: null,
          type: 'sujet',
        ),
      ),
    );
  }

  // ============================================================
  // PARTAGER
  // ============================================================

  Future<void> _onPartagerSujet(SujetGestionItem sujet) async {
    try {
      await PdfShareService.sharePdf(
        id: sujet.id,
        type: 'sujet',
        titre: sujet.titre,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de partager le sujet : $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // SUPPRIMER
  // ============================================================

  Future<void> _onSupprimerSujet(SujetGestionItem sujet) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? darkCardColor : Colors.white,
          title: Text(
            'Supprimer le sujet ?',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Voulez-vous vraiment supprimer « ${sujet.titre} » ?',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: isDark ? Colors.white70 : primaryColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: deleteRed,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await _sujetRepository.deleteSujet(sujet.id);

      if (!mounted) return;

      await _chargerSujets();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sujet supprimé avec succès'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de supprimer le sujet : $e'),
          backgroundColor: deleteRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // MENU D'ACTIONS
  // ============================================================

  // ============================================================
  // NAVIGATION
  // ============================================================


  void _onNavigationSelected(int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.ressourcesDashboard);
        break;

      case 1:
        context.go(AppRoutes.fichesCours);
        break;

      case 2:
        // Nous sommes dÃ©jÃ  sur l'Ã©cran de gestion des sujets.
        break;

      case 3:
        context.push(AppRoutes.profil);
        break;
    }
  }



  // ============================================================
  // BUILD
  // ============================================================
  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
    required Color textColor,
    required Color inputColor,
    required bool isDark,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
        color: selected ? Colors.white : textColor,
      ),
      selectedColor: primaryColor,
      backgroundColor: inputColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected
              ? primaryColor
              : (isDark ? Colors.white12 : Colors.black12),
        ),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
    );
  }

  Future<void> _ouvrirFiltres({
    required Color textColor,
    required Color inputColor,
    required bool isDark,
  }) async {
    String? matiereTemp = _matiereSelectionnee;
    String? anneeTemp = _anneeSelectionnee;
    String? concoursTemp = _concoursSelectionne;

    final resultat = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  20 + MediaQuery.of(context).viewInsets.bottom,
                ),
                decoration: BoxDecoration(
                  color: isDark ? darkCardColor : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          const Icon(
                            Icons.tune_rounded,
                            color: accentColor,
                            size: 25,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Filtrer les sujets',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: Icon(Icons.close, color: textColor),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _buildFilterDropdown<Matiere>(
                        label: 'Matière',
                        hint: 'Toutes les matières',
                        value: matiereTemp == null
                            ? null
                            : _matieresDisponibles.cast<Matiere?>().firstWhere(
                                  (m) => m?.id == matiereTemp,
                                  orElse: () => null,
                                ),
                        items: _matieresDisponibles,
                        itemLabel: (matiere) => matiere.nom,
                        textColor: textColor,
                        inputColor: inputColor,
                        isDark: isDark,
                        onChanged: (value) {
                          setSheetState(() {
                            matiereTemp = value?.id;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildFilterDropdown<String>(
                        label: 'Année académique',
                        hint: 'Toutes les années',
                        value: anneeTemp,
                        items: _anneesDisponibles,
                        itemLabel: (annee) => annee,
                        textColor: textColor,
                        inputColor: inputColor,
                        isDark: isDark,
                        onChanged: (value) {
                          setSheetState(() {
                            anneeTemp = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildFilterDropdown<String>(
                        label: 'Concours',
                        hint: 'Tous les concours',
                        value: concoursTemp,
                        items: _concoursDisponibles,
                        itemLabel: (concours) => concours,
                        textColor: textColor,
                        inputColor: inputColor,
                        isDark: isDark,
                        onChanged: (value) {
                          setSheetState(() {
                            concoursTemp = value;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setSheetState(() {
                                  matiereTemp = null;
                                  anneeTemp = null;
                                  concoursTemp = null;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: const BorderSide(color: primaryColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Réinitialiser'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(sheetContext, true);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Appliquer',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (resultat == true && mounted) {
      setState(() {
        _matiereSelectionnee = matiereTemp;
        _anneeSelectionnee = anneeTemp;
        _concoursSelectionne = concoursTemp;
        _currentPage = 1;
      });

      await _chargerSujets();
    }
  }

  Widget _buildFilterDropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required List<T> items,
    required String Function(T item) itemLabel,
    required ValueChanged<T?> onChanged,
    required Color textColor,
    required Color inputColor,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          key: ValueKey('$label-$value'),
          initialValue: value,
          isExpanded: true,
          hint: Text(
            hint,
            overflow: TextOverflow.ellipsis,
          ),
          dropdownColor: isDark ? darkCardColor : Colors.white,
          style: TextStyle(color: textColor, fontSize: 14),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: accentColor,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: inputColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: primaryColor,
                width: 1.5,
              ),
            ),
          ),
          items: [
            DropdownMenuItem<T>(
              value: null,
              child: Text(
                hint,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: textColor),
              ),
            ),
            ...items.map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemLabel(item),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? darkBackground : lightBackground;

    final cardColor = isDark ? darkCardColor : Colors.white;

    final textColor = isDark ? Colors.white : Colors.black87;

    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

    final inputColor = isDark ? const Color(0xFF0D1F38) : Colors.white;

    final sujets = _filteredSujets;

    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 19,
            color: accentColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          tooltip: 'Retour',
        ),

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sujets de concours',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Ressources Â· Elite-Prepa',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // TITRE DE SECTION
              // --------------------------------------------------

              Text(
                'Sujets de concours',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Consultez et gerez les sujets disponibles.',
                style: TextStyle(fontSize: 13, color: secondaryTextColor),
              ),

              const SizedBox(height: 18),

              // --------------------------------------------------
              // RECHERCHE + AJOUT
              // --------------------------------------------------
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: inputColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, size: 20, color: accentColor),

                          const SizedBox(width: 8),

                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (_) {
                                _searchDebounce?.cancel();

                                setState(() {
                                  _currentPage = 1;
                                });

                                _searchDebounce = Timer(
                                  const Duration(milliseconds: 400),
                                  () {
                                    if (mounted) {
                                      _chargerSujets();
                                    }
                                  },
                                );
                              },
                              style: TextStyle(fontSize: 13, color: textColor),
                              decoration: InputDecoration(
                                hintText: 'Rechercher un sujet...',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: secondaryTextColor,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),

                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchDebounce?.cancel();
                                _searchController.clear();

                                setState(() {
                                  _currentPage = 1;
                                });

                                _chargerSujets();
                              },
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: secondaryTextColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: _onAddSujet,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text(
                        'Ajouter',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // --------------------------------------------------
              // FILTRES
              // --------------------------------------------------
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _ouvrirFiltres(
                          textColor: textColor,
                          inputColor: inputColor,
                          isDark: isDark,
                        );
                      },
                      icon: const Icon(
                        Icons.tune_rounded,
                        size: 19,
                      ),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Flexible(
                            child: Text(
                              'Filtres',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_nombreFiltresActifs > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$_nombreFiltresActifs',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        side: BorderSide(
                          color: _nombreFiltresActifs > 0
                              ? primaryColor
                              : (isDark ? Colors.white24 : Colors.black12),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  if (_nombreFiltresActifs > 0) ...[
                    const SizedBox(width: 10),
                    TextButton.icon(
                      onPressed: () {
                        _appliquerFiltre(reinitialiser: true);
                      },
                      icon: const Icon(Icons.restart_alt_rounded, size: 18),
                      label: const Text('Effacer'),
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? Colors.white70 : primaryColor,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 20),

              // --------------------------------------------------
              // EN-TÃŠTE LISTE
              // --------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sujets disponibles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  Text(
                    '$_totalSujets sujet${_totalSujets > 1 ? 's' : ''}',
                    style: TextStyle(fontSize: 12, color: secondaryTextColor),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // --------------------------------------------------
              // LISTE
              // --------------------------------------------------
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: accentColor),
                  ),
                )
              else if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_off_outlined,
                        size: 40,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Impossible de charger les sujets.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Verifiez la connexion au serveur puis ressayez.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _chargerSujets,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Ressayer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                )
              else if (sujets.isEmpty)
                _buildEmptyState(
                  isDark: isDark,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                )
              else
                ...sujets.map(
                  (sujet) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildSujetCard(
                      sujet: sujet,
                      cardColor: cardColor,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      isDark: isDark,
                    ),
                  ),
                ),

              // --------------------------------------------------
              // PAGINATION
              // --------------------------------------------------
              if (sujets.isNotEmpty)
                _buildPagination(
                  isDark: isDark,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                ),
            ],
          ),
        ),
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavigationSelected,
        backgroundColor: isDark ? darkBackground : Colors.white,
        indicatorColor: accentColor.withValues(alpha: 0.18),
        height: 68,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Revisions',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Concours',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARTE SUJET
  // ============================================================

  Widget _buildSujetCard({
    required SujetGestionItem sujet,
    required Color cardColor,
    required Color textColor,
    required Color secondaryTextColor,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------
          // TITRE + MENU
          // ------------------------------------------------------

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  sujet.titre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              PopupMenuButton<String>(
                tooltip: 'Actions',
                icon: Icon(Icons.more_vert, color: Colors.black),
                onSelected: (value) {
                  switch (value) {
                    case 'voir':
                      _onVoirSujet(sujet);
                      break;

                    case 'telecharger':
                      _onTelechargerSujet(sujet);
                      break;

                    case 'partager':
                      _onPartagerSujet(sujet);
                      break;

                    case 'modifier':
                      _onModifierSujet(sujet);
                      break;

                    case 'supprimer':
                      _onSupprimerSujet(sujet);
                      break;
                  }
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem<String>(
                      value: 'voir',
                      child: Row(
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            size: 19,
                            color: Colors.black,
                          ),
                          SizedBox(width: 10),
                          Text('Voir'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'telecharger',
                      child: Row(
                        children: [
                          Icon(
                            Icons.file_download_outlined,
                            size: 19,
                            color: Colors.black,
                          ),
                          SizedBox(width: 10),
                          Text('Telecharger'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'partager',
                      child: Row(
                        children: [
                          Icon(
                            Icons.share_outlined,
                            size: 19,
                            color: Colors.black,
                          ),
                          SizedBox(width: 10),
                          Text('Partager'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'modifier',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 19,
                            color: Colors.black,
                          ),
                          SizedBox(width: 10),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'supprimer',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 19,
                            color: deleteRed,
                          ),
                          SizedBox(width: 10),
                          Text('Supprimer', style: TextStyle(color: deleteRed)),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ------------------------------------------------------
          // SOUS-TITRE
          // ------------------------------------------------------
          Text(
            sujet.sousTitre,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: secondaryTextColor),
          ),

          const SizedBox(height: 12),

          // ------------------------------------------------------
          // INFORMATIONS
          // ------------------------------------------------------
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                icon: Icons.menu_book_outlined,
                label: sujet.matiere,
                isDark: isDark,
                textColor: textColor,
              ),
              _buildInfoChip(
                icon: Icons.calendar_today_outlined,
                label: sujet.annee,
                isDark: isDark,
                textColor: textColor,
              ),
              _buildInfoChip(
                icon: Icons.school_outlined,
                label: sujet.concours,
                isDark: isDark,
                textColor: textColor,
              ),
            ],
          ),

          if (sujet.aCorrige) ...[
            const SizedBox(height: 12),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF173C2D)
                        : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 15,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Corriger disponible',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // CHIP INFORMATION
  // ============================================================

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required bool isDark,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1F38) : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accentColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION TILE
  // ============================================================

  // ============================================================
  // Ã‰TAT VIDE
  // ============================================================

  Widget _buildEmptyState({
    required bool isDark,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: isDark ? darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.description_outlined,
            size: 48,
            color: isDark ? Colors.white38 : Colors.black26,
          ),
          const SizedBox(height: 12),
          Text(
            'Aucun sujet trouver',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Modifiez votre recherche ou vos filtres.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: secondaryTextColor),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGINATION
  // ============================================================

  Widget _buildPagination({
    required bool isDark,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    final int debut = _totalSujets == 0
        ? 0
        : ((_currentPage - 1) * _pageSize) + 1;

    final int fin = ((_currentPage * _pageSize) > _totalSujets)
        ? _totalSujets
        : _currentPage * _pageSize;

    final int pagesVisibles = _totalPages < 3 ? _totalPages : 3;

    final int premierePageVisible = _totalPages <= 3
        ? 1
        : (_currentPage <= 2
              ? 1
              : (_currentPage >= _totalPages
                    ? _totalPages - 2
                    : _currentPage - 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            '$debut â $fin sur $_totalSujets sujet'
            '${_totalSujets > 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: secondaryTextColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPageButton(
              icon: Icons.chevron_left,
              onTap: !_isLoading && _currentPage > 1
                  ? () {
                      setState(() {
                        _currentPage--;
                      });
                      _chargerSujets();
                    }
                  : null,
              isDark: isDark,
            ),
            const SizedBox(width: 4),
            for (
              int page = premierePageVisible;
              page < premierePageVisible + pagesVisibles;
              page++
            ) ...[
              _buildPageNumberButton(
                pageNumber: page,
                isSelected: _currentPage == page,
                isDark: isDark,
              ),
              if (page < pagesVisibles) const SizedBox(width: 4),
            ],
            const SizedBox(width: 4),
            _buildPageButton(
              icon: Icons.chevron_right,
              onTap: !_isLoading && _currentPage < _totalPages
                  ? () {
                      setState(() {
                        _currentPage++;
                      });
                      _chargerSujets();
                    }
                  : null,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // BOUTON PAGINATION
  // ============================================================

  Widget _buildPageButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1F38) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 18,
          color: onTap != null
              ? (isDark ? Colors.white : Colors.black87)
              : Colors.grey,
        ),
        onPressed: onTap,
      ),
    );
  }

  // ============================================================
  // NUMÃ‰RO DE PAGE
  // ============================================================

  Widget _buildPageNumberButton({
    required int pageNumber,
    required bool isSelected,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: !_isLoading && _currentPage != pageNumber
          ? () {
              setState(() {
                _currentPage = pageNumber;
              });
              _chargerSujets();
            }
          : null,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (isDark ? const Color(0xFF0D1F38) : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? Colors.white12 : Colors.black12),
          ),
        ),
        child: Text(
          '$pageNumber',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }
}
