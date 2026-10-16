
import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../models/sujet.dart';
import '../repositories/sujet_repository.dart';
import 'package:go_router/go_router.dart';
import '../services/pdf_share_service.dart';
// ============================================================
// MODÈLE TEMPORAIRE — CORRIGÉ
// À remplacer plus tard par le modèle provenant de l'API
// ============================================================

class CorrigeItem {
  final String id;
  final String titre;
  final String sousTitre;
  final String matiere;
  final String concours;
  final String annee;
  final String nomFichier;

  CorrigeItem({
    required this.id,
    required this.titre,
    required this.sousTitre,
    required this.matiere,
    required this.concours,
    required this.annee,
    required this.nomFichier,
  });
}

// ============================================================
// ÉCRAN LISTE DES CORRIGÉS
// ============================================================

class CorrigesView extends StatefulWidget {
  const CorrigesView({super.key});

  @override
  State<CorrigesView> createState() => _CorrigesViewState();
}

class _CorrigesViewState extends State<CorrigesView> {
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
  // ÉTAT
  // ============================================================

  int _currentIndex = 2;
  int _selectedChipIndex = 0;
  int _currentPage = 1;
  static const int _pageSize = 5;

  final TextEditingController _searchController =
      TextEditingController();

  final List<String> _filters = [
    'Tous',
    'Maths',
    'Physique',
    '2026',
  ];

  // ============================================================
  // DONNÉES PROVENANT DU BACKEND
  // ============================================================

  final SujetRepository _sujetRepository = SujetRepository();

  List<CorrigeItem> _corriges = [];

  bool _isLoading = true;
  String? _errorMessage;

  // ============================================================
  // CYCLE DE VIE
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadCorriges();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Charge les sujets depuis le backend et conserve
  /// uniquement ceux qui possèdent un corrigé.
  Future<void> _loadCorriges() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<Sujet> sujets = [];

      // Première page
      final premierePage = await _sujetRepository.getSujetsPage(
        page: 1,
        limit: 100,
      );

      sujets.addAll(premierePage.items);

      // Pages suivantes, si nécessaire
      for (int page = 2; page <= premierePage.totalPages; page++) {
        final resultat = await _sujetRepository.getSujetsPage(
          page: page,
          limit: 100,
        );

        sujets.addAll(resultat.items);
      }

      final corrigesRecuperes = sujets
          .where((sujet) => sujet.aCorrige)
          .map((sujet) {
            final chemin = sujet.corrige!.trim();

            // Récupère le nom du fichier depuis son chemin backend.
            final nomFichier = chemin
                .split(RegExp(r'[/\\]'))
                .where((partie) => partie.isNotEmpty)
                .last;

            return CorrigeItem(
              id: sujet.id,
              titre: 'Corrigé — ${sujet.titre}',
              sousTitre: sujet.description,
              matiere: sujet.matiereNom.isNotEmpty
                  ? sujet.matiereNom
                  : 'Matière non renseignée',
              concours: sujet.concours,
              annee: sujet.anneeAcademique,
              nomFichier: nomFichier,
            );
          })
          .toList();

      if (!mounted) return;

      setState(() {
        _corriges = corrigesRecuperes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
 

  // ============================================================
  // RECHERCHE / FILTRE
  // ============================================================

  List<CorrigeItem> get _filteredCorriges {
    final search = _searchController.text.trim().toLowerCase();

    Iterable<CorrigeItem> result = _corriges;

    if (search.isNotEmpty) {
      result = result.where(
        (corrige) =>
            corrige.titre.toLowerCase().contains(search) ||
            corrige.sousTitre.toLowerCase().contains(search) ||
            corrige.matiere.toLowerCase().contains(search) ||
            corrige.annee.toLowerCase().contains(search) ||
            corrige.nomFichier.toLowerCase().contains(search),
      );
    }

    switch (_selectedChipIndex) {
      case 1:
        result = result.where(
          (corrige) => corrige.matiere == 'Mathématiques',
        );
        break;

      case 2:
        result = result.where(
          (corrige) => corrige.matiere == 'Physique',
        );
        break;

      case 3:
        result = result.where(
          (corrige) => corrige.annee == '2026',
        );
        break;
    }

    return result.toList();
  }

  List<CorrigeItem> get _paginatedCorriges {
    final corriges = _filteredCorriges;

    if (corriges.isEmpty) {
      return [];
    }

    final totalPages = (corriges.length / _pageSize).ceil();

    // Évite de conserver une page qui n'existe plus
    // après une recherche ou un changement de filtre.
    final page = _currentPage.clamp(1, totalPages);

    final startIndex = (page - 1) * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(
      0,
      corriges.length,
    );

    return corriges.sublist(startIndex, endIndex);
  }

  // ============================================================
  // VOIR
  // ============================================================

  void _onVoirCorrige(CorrigeItem corrige) {
    context.push(
      AppRoutes.corrigeDetail,
      extra: {
        'id': corrige.id,
        'titre': corrige.titre,
        'sousTitre': corrige.sousTitre,
        'matiere': corrige.matiere,
        'concours': corrige.concours,
        'annee': corrige.annee,
        'nomFichier': corrige.nomFichier,
        'type': 'corrige',
      },
    );
  }


  // ============================================================
  // TÉLÉCHARGER
  // ============================================================


  void _onTelechargerCorrige(CorrigeItem corrige) {
    context.push(
      AppRoutes.telechargerCorrige,
      extra: {
        'id': corrige.id,
        'titre': corrige.titre,
        'sousTitre': corrige.sousTitre,
        'matiere': corrige.matiere,
        'concours': corrige.concours,
        'annee': corrige.annee,
        'nomFichier': corrige.nomFichier,
        'type': 'corrige',
      },
    );
  }


  // ============================================================
  // PARTAGER
  // ============================================================

  Future<void> _onPartagerCorrige(CorrigeItem corrige) async {
    try {
      await PdfShareService.sharePdf(
        id: corrige.id,
        type: 'corrige',
        titre: corrige.titre,
        nomFichier: corrige.nomFichier,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de partager le corrigé : $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // MODIFIER
  // ============================================================




  // ============================================================
  // SUPPRIMER
  // ============================================================



  // ============================================================
  // NAVIGATION
  // ============================================================

  void _onNavigationSelected(int index) {
    if (index == _currentIndex) return;

    switch (index) {
      case 0:
        context.go(AppRoutes.ressourcesDashboard);
        break;

      case 1:
        context.go(AppRoutes.fichesCours);
        break;

      case 2:
        context.go(AppRoutes.sujetsGestion);
        break;

      case 3:
        context.push(AppRoutes.profil);
        break;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark =
        theme.brightness == Brightness.dark;

    final backgroundColor =
        isDark ? darkBackground : lightBackground;

    final cardColor =
        isDark ? darkCardColor : Colors.white;

    final textColor =
        isDark ? Colors.white : Colors.black87;

    final secondaryTextColor =
        isDark ? Colors.white70 : Colors.black54;

    final inputColor =
        isDark
            ? const Color(0xFF0D1F38)
            : Colors.white;

    final corriges = _paginatedCorriges;

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
            color: accentColor ,
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
              'Corrigés',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Ressources · Elite-Prepa',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              size: 26,
              color: accentColor,
            ),
            tooltip: 'Ajouter un corrigé',
              onPressed: () async {
                final resultat = await context.push<bool>(
                  AppRoutes.addEditSujet,
                );

                if (resultat == true && mounted) {
                  await _loadCorriges();
                }
              },
          ),
          const SizedBox(width: 6),
        ],
      ),



      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            24,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // TITRE
              // --------------------------------------------------

              Text(
                'Corrigés disponibles',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Consultez et gérez les corrigés disponibles.',
                style: TextStyle(
                  fontSize: 13,
                  color: secondaryTextColor,
                ),
              ),

              const SizedBox(height: 18),

              // --------------------------------------------------
              // RECHERCHE
              // --------------------------------------------------

              Container(
                height: 44,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: inputColor,
                  borderRadius:
                      BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? Colors.white12
                        : Colors.black12,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: 20,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller:
                            _searchController,
                        onChanged: (_) {
                          setState(() {
                            _currentPage = 1;
                          });
                        },
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor,
                        ),
                        decoration:
                            InputDecoration(
                          hintText:
                              'Rechercher un corrigé...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color:
                                secondaryTextColor,
                          ),
                          border:
                              InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_searchController
                        .text
                        .isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _currentPage = 1;
                          });
                        },
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color:
                              secondaryTextColor,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // --------------------------------------------------
              // FILTRES
              // --------------------------------------------------

              SingleChildScrollView(
                scrollDirection:
                    Axis.horizontal,
                child: Row(
                  children:
                      List.generate(
                    _filters.length,
                    (index) {
                      final selected =
                          _selectedChipIndex ==
                              index;

                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          right: 8,
                        ),
                        child: ChoiceChip(
                          label: Text(
                            _filters[index],
                          ),
                          selected: selected,
                          onSelected:
                              (isSelected) {
                            if (!isSelected) {
                              return;
                            }

                            setState(() {
                              _selectedChipIndex =
                                  index;
                              _currentPage = 1;
                            });
                          },
                          labelStyle:
                              TextStyle(
                            fontSize: 12,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: selected
                                ? Colors.white
                                : textColor,
                          ),
                          selectedColor:
                              primaryColor,
                          backgroundColor:
                              inputColor,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                            side: BorderSide(
                              color: selected
                                  ? primaryColor
                                  : (isDark
                                      ? Colors.white12
                                      : Colors.black12),
                            ),
                          ),
                          showCheckmark: false,
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --------------------------------------------------
              // EN-TÊTE LISTE
              // --------------------------------------------------

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Corrigés disponibles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    '${corriges.length} corrigé'
                    '${corriges.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          secondaryTextColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // --------------------------------------------------
              // LISTE
              // --------------------------------------------------

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      color: accentColor,
                    ),
                  ),
                )
              else if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.cloud_off_outlined,
                          size: 42,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Impossible de charger les corrigés.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _loadCorriges,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (corriges.isEmpty)
                _buildEmptyState(
                  isDark: isDark,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                )
              else
                ...corriges.map(
                  (corrige) => Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: _buildCorrigeCard(
                      corrige: corrige,
                      cardColor: cardColor,
                      textColor: textColor,
                      secondaryTextColor:
                          secondaryTextColor,
                      isDark: isDark,
                    ),
                  ),
                ),

              const SizedBox(height: 4),

              // --------------------------------------------------
              // PAGINATION
              // --------------------------------------------------

              if (corriges.isNotEmpty)
                _buildPagination(
                  isDark: isDark,
                  secondaryTextColor:
                      secondaryTextColor,
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
        onDestinationSelected:
            _onNavigationSelected,
        backgroundColor:
            isDark ? darkBackground : Colors.white,
        indicatorColor:
            accentColor.withValues(alpha: 0.18),
        height: 68,
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.menu_book_outlined,
            ),
            selectedIcon: Icon(
              Icons.menu_book,
            ),
            label: 'Révisions',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.school_outlined,
            ),
            selectedIcon: Icon(
              Icons.school,
            ),
            label: 'Concours',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon: Icon(
              Icons.person,
            ),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARTE CORRIGÉ
  // ============================================================

  Widget _buildCorrigeCard({
    required CorrigeItem corrige,
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
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white10
              : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------
          // TITRE + MENU
          // ------------------------------------------------------

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF173C5E)
                      : const Color(0xFFEAF2FB),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_outlined,
                  color: Color(0xFFF0A500),
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  corrige.titre,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              PopupMenuButton<String>(
                tooltip: 'Actions',
                icon: Icon(
                  Icons.more_vert,
                  color: secondaryTextColor,
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'voir':
                      _onVoirCorrige(corrige);
                      break;

                    case 'telecharger':
                      _onTelechargerCorrige(corrige);
                      break;

                    case 'partager':
                      _onPartagerCorrige(corrige);
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
                          Text('Télécharger'),
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
                  ];
                },
              ),


            ],
          ),

          const SizedBox(height: 10),

          // ------------------------------------------------------
          // SOUS-TITRE
          // ------------------------------------------------------

          Text(
            corrige.sousTitre,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: secondaryTextColor,
            ),
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
                icon:
                    Icons.menu_book_outlined,
                label: corrige.matiere,
                isDark: isDark,
                textColor: textColor,
              ),
              _buildInfoChip(
                icon:
                    Icons.calendar_today_outlined,
                label: corrige.annee,
                isDark: isDark,
                textColor: textColor,
              ),
              _buildInfoChip(
                icon:
                    Icons.school_outlined,
                label: corrige.concours,
                isDark: isDark,
                textColor: textColor,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ------------------------------------------------------
          // FICHIER PDF
          // ------------------------------------------------------

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0D1F38)
                  : const Color(0xFFF5F7FA),
              borderRadius:
                  BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.picture_as_pdf,
                  size: 17,
                  color: deleteRed,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    corrige.nomFichier,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0D1F38)
            : const Color(0xFFF5F7FA),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xFFF0A500),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight:
                  FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ÉTAT VIDE
  // ============================================================

  Widget _buildEmptyState({
    required bool isDark,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 40,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? darkCardColor
            : Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white10
              : Colors.black12,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.picture_as_pdf_outlined,
            size: 48,
            color: isDark
                ? Colors.white38
                : Colors.black26,
          ),
          const SizedBox(height: 12),
          Text(
            'Aucun corrigé trouvé',
            style: TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Modifiez votre recherche '
            'ou vos filtres.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color:
                  secondaryTextColor,
            ),
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
    required Color secondaryTextColor,
  }) {
    final totalCorriges = _filteredCorriges.length;

    if (totalCorriges == 0) {
      return const SizedBox.shrink();
    }

    final totalPages = (totalCorriges / _pageSize).ceil();
    final page = _currentPage.clamp(1, totalPages).toInt();

    final debut = (page - 1) * _pageSize + 1;
    final fin = (page * _pageSize).clamp(0, totalCorriges).toInt();

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        Text(
          '$debut–$fin sur $totalCorriges corrigé'
          '${totalCorriges > 1 ? 's' : ''}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: secondaryTextColor,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPageButton(
              icon: Icons.chevron_left,
              onTap: page > 1
                  ? () {
                      setState(() {
                        _currentPage = page - 1;
                      });
                    }
                  : null,
              isDark: isDark,
            ),
            const SizedBox(width: 4),
            ...List.generate(totalPages, (index) {
              final pageNumber = index + 1;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _buildPageNumberButton(
                  pageNumber: pageNumber,
                  isSelected: page == pageNumber,
                  isDark: isDark,
                ),
              );
            }),
            const SizedBox(width: 4),
            _buildPageButton(
              icon: Icons.chevron_right,
              onTap: page < totalPages
                  ? () {
                      setState(() {
                        _currentPage = page + 1;
                      });
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
        color: isDark
            ? const Color(0xFF0D1F38)
            : Colors.white,
        borderRadius:
            BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.white12
              : Colors.black12,
        ),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 18,
          color: onTap != null
              ? (isDark
                  ? Colors.white
                  : Colors.black87)
              : Colors.grey,
        ),
        onPressed: onTap,
      ),
    );
  }

  // ============================================================
  // NUMÉRO DE PAGE
  // ============================================================

  Widget _buildPageNumberButton({
    required int pageNumber,
    required bool isSelected,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentPage = pageNumber;
        });
      },
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (isDark
                  ? const Color(0xFF0D1F38)
                  : Colors.white),
          borderRadius:
              BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark
                    ? Colors.white12
                    : Colors.black12),
          ),
        ),
        child: Text(
          '$pageNumber',
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.bold,
            color: isSelected
                ? Colors.white
                : (isDark
                    ? Colors.white70
                    : Colors.black87),
          ),
        ),
      ),
    );
  }
}

