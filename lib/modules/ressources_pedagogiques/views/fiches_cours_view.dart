import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import 'add_edit_fiche_view.dart';
import 'delete_fiche_view.dart';

class FicheItem {
  final String id;
  final String titre;
  final String matiere;
  final String description;
  final String format;
  final String taille;
  final String? nomFichier;

  FicheItem({
    required this.id,
    required this.titre,
    required this.matiere,
    this.description = '',
    this.format = 'PDF',
    required this.taille,
    this.nomFichier,
  });
}

class FichesCoursView extends StatefulWidget {
  const FichesCoursView({super.key});

  @override
  State<FichesCoursView> createState() => _FichesCoursViewState();
}

class _FichesCoursViewState extends State<FichesCoursView> {
  // ============================================================
  // CHARTE ELITE-PREPA
  // ============================================================

  static const Color primaryColor = Color(0xFF1F3F6E);
  static const Color accentColor = Color(0xFFF0A500);
  static const Color lightBackground = Color(0xFFF5F5F5);

  int _currentIndex = 1;

  final TextEditingController _searchController =
      TextEditingController();

  String _selectedMatiere = 'Toutes';

  // Données de démonstration
final List<FicheItem> _fiches = [
  FicheItem(
    id: '1',
    titre: 'Limites et continuité',
    matiere: 'Mathématiques',
    description:
        'Cours sur les limites, la continuité et les propriétés fondamentales.',
    taille: '2,4 Mo',
    nomFichier: 'limites_continuite.pdf',
  ),
  FicheItem(
    id: '2',
    titre: 'Ondes mécaniques',
    matiere: 'Physique',
    description:
        'Cours sur les ondes mécaniques progressives.',
    taille: '3,1 Mo',
    nomFichier: 'ondes_mecaniques.pdf',
  ),
  FicheItem(
    id: '3',
    titre: 'Réduction des endomorphismes',
    matiere: 'Mathématiques',
    description:
        'Cours sur la diagonalisation et la réduction des endomorphismes.',
    taille: '1,8 Mo',
    nomFichier: 'reduction_endomorphismes.pdf',
  ),
];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // AJOUT D'UNE FICHE
  // ============================================================

  Future<void> _onAddFiche() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.addFiche,
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // FILTRAGE
  // ============================================================

  List<FicheItem> get _filteredFiches {
    final query = _searchController.text.trim().toLowerCase();

    return _fiches.where((fiche) {
      final matchesSearch =
          fiche.titre.toLowerCase().contains(query) ||
          fiche.matiere.toLowerCase().contains(query);

      final matchesMatiere =
          _selectedMatiere == 'Toutes' ||
          fiche.matiere == _selectedMatiere;

      return matchesSearch && matchesMatiere;
    }).toList();
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _onNavigationSelected(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    // Pour l'instant, les autres destinations ne sont pas encore
    // connectées à leurs écrans.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? theme.colorScheme.surface
        : lightBackground;

    final cardColor = isDark
        ? const Color(0xFF102542)
        : Colors.white;

    final textColor = isDark
        ? Colors.white
        : Colors.black87;

    final secondaryTextColor = isDark
        ? Colors.white70
        : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 12,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
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
              'Fiches de cours',
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
            onPressed: _onAddFiche,
            tooltip: 'Ajouter une fiche',
            icon: const Icon(
              Icons.add,
              size: 28,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),

      // ==========================================================
      // CONTENU
      // ==========================================================

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // EN-TÊTE
              // --------------------------------------------------

              Text(
                'Toutes les fiches de cours',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isDark
                      ? Colors.white
                      : primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '${_filteredFiches.length} fiche(s) disponible(s)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: secondaryTextColor,
                ),
              ),

              const SizedBox(height: 14),

              // --------------------------------------------------
              // RECHERCHE
              // --------------------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? Colors.white10
                        : Colors.black12,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) {
                    setState(() {});
                  },
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.search,
                      size: 20,
                      color: secondaryTextColor,
                    ),
                    hintText: 'Rechercher une fiche...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: secondaryTextColor,
                    ),
                    border: InputBorder.none,
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                icon: Icon(
                                  Icons.clear,
                                  size: 18,
                                  color: secondaryTextColor,
                                ),
                              )
                            : null,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // --------------------------------------------------
              // FILTRE MATIÈRE
              // --------------------------------------------------

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showMatiereFilter(
                    context,
                    isDark,
                  ),
                  icon: const Icon(
                    Icons.filter_list,
                    size: 18,
                  ),
                  label: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Matière : $_selectedMatiere',
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark
                        ? Colors.white
                        : primaryColor,
                    side: BorderSide(
                      color: isDark
                          ? Colors.white24
                          : Colors.black12,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // --------------------------------------------------
              // LISTE
              // --------------------------------------------------

              if (_filteredFiches.isEmpty)
                _buildEmptyState(
                  cardColor: cardColor,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: _filteredFiches.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _buildFicheCard(
                      fiche: _filteredFiches[index],
                      cardColor: cardColor,
                      textColor: textColor,
                      secondaryTextColor:
                          secondaryTextColor,
                    );
                  },
                ),

              const SizedBox(height: 18),

              // --------------------------------------------------
              // PAGINATION
              // --------------------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? Colors.white10
                        : Colors.black12,
                  ),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.chevron_left,
                        size: 20,
                      ),
                      color: secondaryTextColor,
                      tooltip: 'Page précédente',
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius:
                            BorderRadius.circular(7),
                      ),
                      child: const Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        '2',
                        style: TextStyle(
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        '3',
                        style: TextStyle(
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.chevron_right,
                        size: 20,
                      ),
                      color: secondaryTextColor,
                      tooltip: 'Page suivante',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),

      // ==========================================================
      // NAVIGATION INFÉRIEURE
      // ==========================================================

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,

        onDestinationSelected:
            _onNavigationSelected,

        backgroundColor: isDark
            ? const Color(0xFF081B32)
            : Colors.white,

        indicatorColor:
            accentColor.withValues(alpha: 0.18),

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
            label: 'Révisions',
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
  // CARTE FICHE
  // ============================================================

  Widget _buildFicheCard({
    required FicheItem fiche,
    required Color cardColor,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(
                      alpha: 0.14,
                    ),
                    borderRadius:
                        BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_outlined,
                    color: accentColor,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        fiche.titre,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        fiche.matiere,
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: secondaryTextColor,
                  ),
                  onSelected: (value) {
                    _handleFicheAction(
                      value,
                      fiche,
                    );
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'voir',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading:
                            Icon(Icons.visibility_outlined),
                        title: Text('Voir'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'telecharger',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading:
                            Icon(Icons.download_outlined),
                        title: Text('Télécharger'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'modifier',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading:
                            Icon(Icons.edit_outlined),
                        title: Text('Modifier'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'supprimer',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading:
                            Icon(Icons.delete_outline),
                        title: Text('Supprimer'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'partager',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading:
                            Icon(Icons.share_outlined),
                        title: Text('Partager'),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 11),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: secondaryTextColor.withValues(
                  alpha: 0.07,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 15,
                    color: secondaryTextColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    fiche.format,
                    style: TextStyle(
                      fontSize: 11,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '·',
                    style: TextStyle(
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    fiche.taille,
                    style: TextStyle(
                      fontSize: 11,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ÉTAT VIDE
  // ============================================================

  Widget _buildEmptyState({
    required Color cardColor,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(
            Icons.description_outlined,
            size: 45,
            color: secondaryTextColor,
          ),
          const SizedBox(height: 12),
          Text(
            'Aucune fiche trouvée',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Modifiez votre recherche ou votre filtre.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTRE MATIÈRE
  // ============================================================

  void _showMatiereFilter(
    BuildContext context,
    bool isDark,
  ) {
    final matieres = [
      'Toutes',
      'Mathématiques',
      'Physique',
      'Chimie',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark
          ? const Color(0xFF102542)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(18),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtrer par matière',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white
                        : primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                ...matieres.map(
                  (matiere) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(matiere),
                    leading: Icon(
                      _selectedMatiere == matiere
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color:
                          _selectedMatiere == matiere
                              ? primaryColor
                              : Colors.grey,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedMatiere = matiere;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ACTIONS FICHE
  // ============================================================

  void _handleFicheAction(
    String action,
    FicheItem fiche,
  ) {
    switch (action) {
      case 'voir':
        _showMessage(
          'Ouverture de ${fiche.titre}',
        );
        break;

      case 'telecharger':
        _showMessage(
          'Téléchargement de ${fiche.titre}',
        );
        break;

      case 'modifier':
        _onEditFiche(fiche);
        break;

      

      case 'supprimer':
        _onDeleteFiche(fiche);
        break;

      case 'partager':
        _showMessage(
          'Partage de ${fiche.titre}',
        );
        break;
    }
  }

  Future<void> _onEditFiche(FicheItem fiche) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AddEditFicheView(
        id: fiche.id,
        titre: fiche.titre,
        matiere: fiche.matiere,
        description: fiche.description,
        nomFichier: fiche.nomFichier,
      ),
    ),
  );

  if (result == true && mounted) {
    setState(() {});
  }
}


Future<void> _onDeleteFiche(FicheItem fiche) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DeleteFicheView(
        fiche: fiche,
      ),
    ),
  );

  if (result == true && mounted) {
    setState(() {
      _fiches.removeWhere(
        (item) => item.id == fiche.id,
      );
    });
  }
}
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}