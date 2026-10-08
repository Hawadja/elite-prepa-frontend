import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';

class SujetConcoursItem {
  final String id;
  final String titre;
  final String matiere;
  final String description;
  final String concours;
  final String anneeAcademique;
  final String nomFichier;
  final String filiere;
  final String duree;
  final bool corrigeDisponible;
  final bool showActionsAdmin;

  const SujetConcoursItem({
    required this.id,
    required this.titre,
    required this.matiere,
    required this.description,
    required this.concours,
    required this.anneeAcademique,
    required this.nomFichier,
    required this.filiere,
    required this.duree,
    required this.corrigeDisponible,
    required this.showActionsAdmin,
  });
}

class SujetsConcoursView extends StatefulWidget {
  const SujetsConcoursView({super.key});

  @override
  State<SujetsConcoursView> createState() => _SujetsConcoursViewState();
}

class _SujetsConcoursViewState extends State<SujetsConcoursView> {
  // ============================================================
  // COULEURS ELITE-PREPA
  // ============================================================

  static const Color primaryColor = Color(0xFF1F3F6E);
  static const Color accentColor = Color(0xFFF0A500);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color darkBackground = Color(0xFF081B32);

  int _currentIndex = 2;

  final TextEditingController _searchController = TextEditingController();

  String _selectedMatiere = 'Toutes';

  // ============================================================
  // DONNÉES DE DÉMONSTRATION
  // ============================================================

final List<SujetConcoursItem> _sujets = [
  const SujetConcoursItem(
    id: '1',
    titre: 'Mines-Ponts 2025 · Maths I',
    matiere: 'Mathématiques',
    description:
        'Sujet de mathématiques du concours Mines-Ponts 2025.',
    concours: 'Mines-Ponts',
    anneeAcademique: '2024-2025',
    nomFichier: 'mines_ponts_2025_maths_1.pdf',
    filiere: 'MP',
    duree: '4 h',
    corrigeDisponible: true,
    showActionsAdmin: false,
  ),

  const SujetConcoursItem(
    id: '2',
    titre: 'CentraleSupélec 2025 · Physique',
    matiere: 'Physique',
    description:
        'Sujet de physique du concours CentraleSupélec 2025.',
    concours: 'CentraleSupélec',
    anneeAcademique: '2024-2025',
    nomFichier: 'centrale_supelec_2025_physique.pdf',
    filiere: 'PSI',
    duree: '4 h',
    corrigeDisponible: true,
    showActionsAdmin: false,
  ),

  const SujetConcoursItem(
    id: '3',
    titre: 'CCINP 2024 · Informatique',
    matiere: 'Informatique',
    description:
        'Sujet d’informatique du concours CCINP 2024.',
    concours: 'CCINP',
    anneeAcademique: '2023-2024',
    nomFichier: 'ccinP_2024_informatique.pdf',
    filiere: 'MP',
    duree: '3 h',
    corrigeDisponible: false,
    showActionsAdmin: true,
  ),
];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        setState(() {
          _currentIndex = index;
        });
        break;

      case 3:
        setState(() {
          _currentIndex = index;
        });
        break;
    }
  }

  // ============================================================
  // AJOUT D'UN SUJET
  // ============================================================

  Future<void> _onAddSujet() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.addEditSujet,
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // ACTIONS DU MENU
  // ============================================================

void _onVoirSujet(SujetConcoursItem sujet) {
  Navigator.pushNamed(
    context,
    AppRoutes.sujetsGestion,
  );
}

  void _onTelechargerSujet(SujetConcoursItem sujet) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Télécharger : ${sujet.titre}'),
      ),
    );
  }

Future<void> _onModifierSujet(
  SujetConcoursItem sujet,
) async {
  final result = await Navigator.pushNamed(
    context,
    AppRoutes.addEditSujet,
    arguments: {
      'id': sujet.id,
      'titre': sujet.titre,
      'matiere': sujet.matiere,
      'description': sujet.description,
      'concours': sujet.concours,
      'anneeAcademique': sujet.anneeAcademique,
      'nomFichier': sujet.nomFichier,
    },
  );

  if (result == true && mounted) {
    setState(() {});
  }
}

  void _onSupprimerSujet(SujetConcoursItem sujet) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Supprimer : ${sujet.titre}'),
      ),
    );
  }

  void _onPartagerSujet(SujetConcoursItem sujet) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Partager : ${sujet.titre}'),
      ),
    );
  }

  // ============================================================
  // RECHERCHE
  // ============================================================

  List<SujetConcoursItem> get _filteredSujets {
    final search = _searchController.text.trim().toLowerCase();

    return _sujets.where((sujet) {
      final matchesSearch =
          search.isEmpty ||
          sujet.titre.toLowerCase().contains(search) ||
          sujet.matiere.toLowerCase().contains(search) ||
          sujet.filiere.toLowerCase().contains(search);

      final matchesMatiere =
          _selectedMatiere == 'Toutes' ||
          sujet.matiere == _selectedMatiere;

      return matchesSearch && matchesMatiere;
    }).toList();
  }

  List<String> get _matieres {
    final matieres =
        _sujets.map((sujet) => sujet.matiere).toSet().toList();

    matieres.sort();

    return ['Toutes', ...matieres];
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor =
        isDark ? darkBackground : lightBackground;

    final cardColor =
        isDark ? const Color(0xFF102542) : Colors.white;

    final textColor =
        isDark ? Colors.white : Colors.black87;

    final secondaryTextColor =
        isDark ? Colors.white70 : Colors.black54;

    final sujets = _filteredSujets;

    return Scaffold(
      backgroundColor: backgroundColor,

      // ==========================================================
      // APP BAR
      // ==========================================================

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
          onPressed: () => Navigator.pop(context),
          tooltip: 'Retour',
        ),

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sujets de concours',
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
              size: 25,
            ),
            color: accentColor,
            onPressed: _onAddSujet,
            tooltip: 'Ajouter un sujet',
          ),
          const SizedBox(width: 6),
        ],
      ),

      // ==========================================================
      // CONTENU
      // ==========================================================

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sujets disponibles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${sujets.length} sujet${sujets.length > 1 ? 's' : ''} disponible${sujets.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 13,
                        color: secondaryTextColor,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // RECHERCHE
                    // ==================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
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
                          fontSize: 14,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.search,
                            size: 20,
                            color: secondaryTextColor,
                          ),
                          hintText: 'Rechercher un sujet...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                          border: InputBorder.none,
                          suffixIcon:
                              _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        size: 19,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ==================================================
                    // FILTRE MATIÈRE
                    // ==================================================

                    Row(
                      children: [
                        Text(
                          'Matière :',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 8),

                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _matieres.map((matiere) {
                                final selected =
                                    _selectedMatiere == matiere;

                                return Padding(
                                  padding: const EdgeInsets.only(
                                    right: 8,
                                  ),
                                  child: ChoiceChip(
                                    label: Text(matiere),
                                    selected: selected,
                                    onSelected: (_) {
                                      setState(() {
                                        _selectedMatiere = matiere;
                                      });
                                    },
                                    selectedColor:
                                        accentColor.withValues(
                                      alpha: 0.20,
                                    ),
                                    labelStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: selected
                                          ? primaryColor
                                          : secondaryTextColor,
                                    ),
                                    side: BorderSide(
                                      color: selected
                                          ? accentColor
                                          : (isDark
                                              ? Colors.white24
                                              : Colors.black12),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // LISTE
                    // ==================================================

                    if (sujets.isEmpty)
                      _buildEmptyState(
                        cardColor: cardColor,
                        textColor: textColor,
                        secondaryTextColor:
                            secondaryTextColor,
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount: sujets.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final sujet = sujets[index];

                          return _buildSujetCard(
                            sujet: sujet,
                            cardColor: cardColor,
                            textColor: textColor,
                            secondaryTextColor:
                                secondaryTextColor,
                          );
                        },
                      ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // BOUTON AJOUT
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _onAddSujet,
                        icon: const Icon(
                          Icons.add,
                          size: 20,
                        ),
                        label: const Text(
                          'Ajouter un sujet',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ==========================================================
      // NAVIGATION BOTTOM
      // ==========================================================

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavigationSelected,
        backgroundColor:
            isDark ? darkBackground : Colors.white,
        indicatorColor: accentColor.withValues(
          alpha: 0.18,
        ),
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
  // CARTE SUJET
  // ============================================================

  Widget _buildSujetCard({
    required SujetConcoursItem sujet,
    required Color cardColor,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------------
          // TITRE + MENU ⋮
          // ----------------------------------------------------------

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  sujet.titre,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),

              if (sujet.showActionsAdmin)
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  icon: Icon(
                    Icons.more_vert,
                    size: 22,
                    color: secondaryTextColor,
                  ),
                  tooltip: 'Actions',
                  onSelected: (value) {
                    switch (value) {
                      case 'voir':
                        _onVoirSujet(sujet);
                        break;

                      case 'telecharger':
                        _onTelechargerSujet(sujet);
                        break;

                      case 'modifier':
                        _onModifierSujet(sujet);
                        break;

                      case 'supprimer':
                        _onSupprimerSujet(sujet);
                        break;

                      case 'partager':
                        _onPartagerSujet(sujet);
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
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
                            Icons.download_outlined,
                            size: 19,
                          ),
                          SizedBox(width: 10),
                          Text('Télécharger'),
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
                          ),
                          SizedBox(width: 10),
                          Text('Supprimer'),
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
                  ],
                ),
            ],
          ),

          const SizedBox(height: 10),

          // ----------------------------------------------------------
          // INFORMATIONS
          // ----------------------------------------------------------

          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildInfoChip(
                icon: Icons.menu_book_outlined,
                text: sujet.matiere,
                textColor: secondaryTextColor,
              ),
              _buildInfoChip(
                icon: Icons.school_outlined,
                text: sujet.filiere,
                textColor: secondaryTextColor,
              ),
              _buildInfoChip(
                icon: Icons.schedule_outlined,
                text: sujet.duree,
                textColor: secondaryTextColor,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ----------------------------------------------------------
          // CORRIGÉ
          // ----------------------------------------------------------

          Row(
            children: [
              Icon(
                sujet.corrigeDisponible
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                size: 18,
                color: sujet.corrigeDisponible
                    ? Colors.green
                    : secondaryTextColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  sujet.corrigeDisponible
                      ? 'Corrigé disponible'
                      : 'Corrigé non disponible',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: sujet.corrigeDisponible
                        ? Colors.green
                        : secondaryTextColor,
                  ),
                ),
              ),
            ],
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
    required String text,
    required Color textColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: textColor,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : Colors.black12,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 42,
            color: secondaryTextColor,
          ),
          const SizedBox(height: 12),
          Text(
            'Aucun sujet trouvé',
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
              fontSize: 13,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}