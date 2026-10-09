import 'package:flutter/material.dart';

class ResultatItem {
  final String titre;
  final String sousTitre;
  final bool isCorrige;

  ResultatItem({
    required this.titre,
    required this.sousTitre,
    this.isCorrige = false,
  });
}

class RechercheAvanceeView extends StatefulWidget {
  const RechercheAvanceeView({super.key});

  @override
  State<RechercheAvanceeView> createState() => _RechercheAvanceeViewState();
}

class _RechercheAvanceeViewState extends State<RechercheAvanceeView> {
  // Couleurs de la charte Elite-Prepa
// Couleurs de la charte Elite-Prepa
  static const Color primaryNavy = Color(0xFF1F3F6E);
  static const Color accentOrange = Color(0xFFF0A500);

  static const Color darkBg = Color(0xFF081B32);
  static const Color darkCardBg = Color(0xFF0F233F);
  static const Color lightBg = Color(0xFFF5F5F5);

  static const Color accentBlue = Color(0xFF1F3F6E);
  static const Color successGreen = Color(0xFF28A745);

  int _currentIndex = 1; // Onglet "Révisions"
  int _currentPage = 1;

  final TextEditingController _searchController =
      TextEditingController(text: 'ondes');

  // Filtres actifs
  String _selectedType = 'Fiches';
  final List<String> _typesRessource = ['Fiches', 'Sujets', 'Corrigés'];

  // Résultats simulés
  final List<ResultatItem> _resultats = [
    ResultatItem(
      titre: 'Ondes mécaniques progressives',
      sousTitre: 'Physique · Fiche de cours',
      isCorrige: false,
    ),
    ResultatItem(
      titre: 'CentraleSupélec 2025 · Ondes',
      sousTitre: 'Physique · Sujet corrigé',
      isCorrige: true,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? darkBg : lightBg;
    final cardBgColor = isDark ? darkCardBg : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final primaryBtnBg = isDark ? const Color(0xFF1B4E8C) : primaryNavy;
    final chipBgUnselected =
        isDark ? const Color(0xFF0D1F38) : const Color(0xFFEEF3F8);

    return Scaffold(
      backgroundColor: backgroundColor,

    // ============================================================
    // APP BAR
    // ============================================================
    appBar: AppBar(
      backgroundColor: primaryNavy,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
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
            'Recherche avancée',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Recherche · Elite-Prepa',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    ),

      // ============================================================
      // CONTENU PRINCIPAL
      // ============================================================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Champ de recherche
              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? accentBlue.withValues(alpha: 0.5): accentBlue,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: 18,
                      color: isDark ? accentBlue : primaryNavy,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. En-tête FILTRES ACTIFS
              Row(
                children: [
                  Icon(
                    Icons.grid_view_rounded,
                    size: 14,
                    color: isDark ? accentBlue : primaryNavy,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'FILTRES ACTIFS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: isDark ? accentBlue : primaryNavy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 3. Bloc TYPE DE RESSOURCE
              _buildSectionCard(
                cardBgColor: cardBgColor,
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.grid_view,
                          size: 14,
                          color: subTextColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'TYPE DE RESSOURCE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: _typesRessource.map((type) {
                        final isSelected = _selectedType == type;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedType = type;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? accentBlue
                                    : chipBgUnselected,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                type,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : subTextColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 4. Bloc MATIÈRE - ANNÉE
              _buildSectionCard(
                cardBgColor: cardBgColor,
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.adjust_rounded,
                          size: 14,
                          color: subTextColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'MATIÈRE - ANNÉE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accentBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Physique',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accentBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '2025–2026',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 5. En-tête RÉSULTATS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.diamond_outlined,
                        size: 14,
                        color: isDark ? accentBlue : primaryNavy,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'RÉSULTATS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: isDark ? accentBlue : primaryNavy,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '6 trouvés',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? accentBlue : primaryNavy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 6. Liste des résultats
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _resultats.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = _resultats[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.titre,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.sousTitre,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (item.isCorrige)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: successGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Corrigé',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // 7. Pagination (1, 2, 3)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [1, 2, 3].map((page) {
                  final isSelected = _currentPage == page;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accentBlue
                            : (isDark
                                ? const Color(0xFF0D1F38)
                                : const Color(0xFFEEF3F8)),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$page',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : subTextColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // 8. Bouton principal "Appliquer · 6 résultats"
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBtnBg,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Appliquer · 6 résultats',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),

      // ============================================================
      // NAVIGATION BOTTOM
      // ============================================================

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,

        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        backgroundColor: isDark
            ? const Color(0xFF081B32)
            : Colors.white,

        indicatorColor: accentOrange.withValues(
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

  Widget _buildSectionCard({
    required Widget child,
    required Color cardBgColor,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: child,
    );
  }
}