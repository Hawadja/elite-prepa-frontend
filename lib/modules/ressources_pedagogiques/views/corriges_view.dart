
import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';

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

  final TextEditingController _searchController =
      TextEditingController();

  final List<String> _filters = [
    'Tous',
    'Maths',
    'Physique',
    '2026',
  ];

  // ============================================================
  // DONNÉES TEMPORAIRES
  // À remplacer plus tard par les données de l'API
  // ============================================================

  final List<CorrigeItem> _corriges = [
    CorrigeItem(
      id: '1',
      titre: 'Corrigé 1 — Limites et continuité',
      sousTitre: 'Corrigé du sujet sur les limites et la continuité',
      matiere: 'Mathématiques',
      concours: 'Concours',
      annee: '2026',
      nomFichier: 'corrige_limites_continuite_2026.pdf',
    ),
    CorrigeItem(
      id: '2',
      titre: 'Corrigé 2 — Cinématique',
      sousTitre: 'Corrigé du sujet de cinématique',
      matiere: 'Physique',
      concours: 'Concours',
      annee: '2026',
      nomFichier: 'corrige_cinematique_2026.pdf',
    ),
    CorrigeItem(
      id: '3',
      titre: 'Corrigé 3 — Électromagnétisme',
      sousTitre: 'Corrigé du sujet d’électromagnétisme',
      matiere: 'Physique',
      concours: 'Concours',
      annee: '2026',
      nomFichier: 'corrige_electromagnetisme_2026.pdf',
    ),
  ];

  // ============================================================
  // CYCLE DE VIE
  // ============================================================

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  // ============================================================
  // VOIR
  // ============================================================

  void _onVoirCorrige(CorrigeItem corrige) {
    Navigator.pushNamed(
      context,
      AppRoutes.corrigeDetail,
      arguments: {
        'id': corrige.id,
        'titre': corrige.titre,
        'sousTitre': corrige.sousTitre,
        'matiere': corrige.matiere,
        'concours': corrige.concours,
        'annee': corrige.annee,
        'nomFichier': corrige.nomFichier,
      },
    );
  }

  // ============================================================
  // TÉLÉCHARGER
  // ============================================================

  void _onTelechargerCorrige(CorrigeItem corrige) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Téléchargement de : ${corrige.nomFichier}',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // PARTAGER
  // ============================================================

  void _onPartagerCorrige(CorrigeItem corrige) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Partage de : ${corrige.titre}',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // MODIFIER
  // ============================================================

  void _onModifierCorrige(CorrigeItem corrige) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Modification de : ${corrige.titre}',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // SUPPRIMER
  // ============================================================

  Future<void> _onSupprimerCorrige(
    CorrigeItem corrige,
  ) async {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              isDark ? darkCardColor : Colors.white,
          title: Text(
            'Supprimer le corrigé ?',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Voulez-vous vraiment supprimer '
            '« ${corrige.titre} » ?',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: isDark
                      ? Colors.white70
                      : primaryColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
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

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _corriges.removeWhere(
        (item) => item.id == corrige.id,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Corrigé supprimé avec succès',
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _onNavigationSelected(int index) {
    if (index == _currentIndex) {
      return;
    }

    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.ressourcesDashboard,
          (route) => false,
        );
        break;

      case 1:
        setState(() {
          _currentIndex = index;
        });
        break;

      case 2:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.sujetsConcours,
          (route) => false,
        );
        break;

      case 3:
        setState(() {
          _currentIndex = index;
        });
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

    final corriges = _filteredCorriges;

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
            ),
            tooltip: 'Ajouter un corrigé',
            onPressed: () {
              // Écran d'ajout à créer ensuite
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Ajout d’un corrigé',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
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

              if (corriges.isEmpty)
                _buildEmptyState(
                  isDark: isDark,
                  textColor: textColor,
                  secondaryTextColor:
                      secondaryTextColor,
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
                  color: primaryColor,
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
                  color:
                      secondaryTextColor,
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'voir':
                      _onVoirCorrige(corrige);
                      break;

                    case 'telecharger':
                      _onTelechargerCorrige(
                        corrige,
                      );
                      break;

                    case 'partager':
                      _onPartagerCorrige(
                        corrige,
                      );
                      break;

                    case 'modifier':
                      _onModifierCorrige(
                        corrige,
                      );
                      break;

                    case 'supprimer':
                      _onSupprimerCorrige(
                        corrige,
                      );
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
                          Text(
                            'Supprimer',
                            style: TextStyle(
                              color: deleteRed,
                            ),
                          ),
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
            color: primaryColor,
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
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '1–${_filteredCorriges.length} sur '
          '${_filteredCorriges.length} corrigé'
          '${_filteredCorriges.length > 1 ? 's' : ''}',
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.w500,
            color:
                secondaryTextColor,
          ),
        ),
        Row(
          children: [
            _buildPageButton(
              icon: Icons.chevron_left,
              onTap: _currentPage > 1
                  ? () {
                      setState(() {
                        _currentPage--;
                      });
                    }
                  : null,
              isDark: isDark,
            ),
            const SizedBox(width: 4),
            _buildPageNumberButton(
              pageNumber: 1,
              isSelected:
                  _currentPage == 1,
              isDark: isDark,
            ),
            const SizedBox(width: 4),
            _buildPageNumberButton(
              pageNumber: 2,
              isSelected:
                  _currentPage == 2,
              isDark: isDark,
            ),
            const SizedBox(width: 4),
            _buildPageNumberButton(
              pageNumber: 3,
              isSelected:
                  _currentPage == 3,
              isDark: isDark,
            ),
            const SizedBox(width: 4),
            _buildPageButton(
              icon: Icons.chevron_right,
              onTap: _currentPage < 3
                  ? () {
                      setState(() {
                        _currentPage++;
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

