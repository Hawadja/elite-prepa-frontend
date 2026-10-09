import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';

class SujetDetailView extends StatefulWidget {
  final bool hasCorrige;

  const SujetDetailView({
    super.key,
    this.hasCorrige = true,
  });

  @override
  State<SujetDetailView> createState() => _SujetDetailViewState();
}

class _SujetDetailViewState extends State<SujetDetailView> {
  // ============================================================
  // COULEURS — CHARTE ELITE-PREPA
  // ============================================================

  static const Color primaryNavy = Color(0xFF163C6E);
  static const Color darkBg = Color(0xFF071426);
  static const Color darkCardBg = Color(0xFF0F233F);
  static const Color lightBg = Color(0xFFF6F8FB);
  static const Color accentBlue = Color(0xFF1B55A2);
  static const Color successGreen = Color(0xFF28A745);
  static const Color accentColor = Color(0xFFF0A500);

  // Concours est le troisième onglet.
  int _currentIndex = 2;

  // ============================================================
  // NAVIGATION PRINCIPALE
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
        // Route Révisions à connecter lorsque l'écran sera disponible.
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
        // Route Profil à connecter lorsque l'écran sera disponible.
        setState(() {
          _currentIndex = index;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? darkBg : lightBg;
    final cardBgColor = isDark ? darkCardBg : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    final buttonBg = isDark
        ? const Color(0xFF0F2A4D)
        : const Color(0xFFEFF4FA);

    final primaryBtnBg = isDark
        ? const Color(0xFF1B4E8C)
        : primaryNavy;

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
              'Détail du sujet',
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
      ),

      // ============================================================
      // CONTENU PRINCIPAL
      // ============================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ======================================================
              // 1. MATIÈRE / CONCOURS
              // ======================================================

              _buildCardContainer(
                cardBgColor: cardBgColor,
                isDark: isDark,
                child: Text(
                  'Mathématiques • MP • 4 h',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ======================================================
              // 2. INFORMATIONS
              // ======================================================

              _buildCardContainer(
                cardBgColor: cardBgColor,
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mathématiques I • session 2025 • 12 pages',
                      style: TextStyle(
                        fontSize: 12,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ======================================================
              // 3. SUJET PDF
              // ======================================================

              _buildCardContainer(
                cardBgColor: cardBgColor,
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: buttonBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf_outlined,
                            size: 20,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sujet PDF',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                'mines_ponts_maths1_2025.pdf',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        _buildSmallActionButton(
                          icon: Icons.file_download_outlined,
                          label: 'Télécharger',
                          bgColor: buttonBg,
                          textColor: accentBlue,
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),
                        _buildSmallActionButton(
                          icon: Icons.share_outlined,
                          label: 'Partager',
                          bgColor: buttonBg,
                          textColor: accentBlue,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ======================================================
              // 4. ACTIONS
              // ======================================================

              _buildCardContainer(
                cardBgColor: cardBgColor,
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Télécharger • Partager',
                      style: TextStyle(
                        fontSize: 12,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              // ======================================================
              // 5. CORRIGÉ ASSOCIÉ
              // ======================================================

              if (widget.hasCorrige) ...[
                const SizedBox(height: 12),

                _buildCardContainer(
                  cardBgColor: cardBgColor,
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: successGreen.withValues(
                                alpha: 0.15,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 16,
                              color: successGreen,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Corrigé associé',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  'Corrigé disponible • 16 pages',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: subTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          _buildSmallActionButton(
                            icon: Icons.visibility_outlined,
                            label: 'Voir',
                            bgColor: buttonBg,
                            textColor: accentBlue,
                            onTap: () {},
                          ),
                          const SizedBox(width: 8),
                          _buildSmallActionButton(
                            icon: Icons.file_download_outlined,
                            label: 'Télécharger',
                            bgColor: buttonBg,
                            textColor: accentBlue,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // ======================================================
              // 6. ÉTAT SANS CORRIGÉ
              // ======================================================

              if (!widget.hasCorrige) ...[
                const SizedBox(height: 12),

                _buildCardContainer(
                  cardBgColor: cardBgColor,
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'État sans corrigé',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Aucun corrigé n\'est encore associé à ce sujet.',
                        style: TextStyle(
                          fontSize: 12,
                          color: subTextColor,
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            backgroundColor: buttonBg,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            '+ Ajouter un corrigé',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: accentBlue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ======================================================
              // 7. BOUTON CONSULTER LE CORRIGÉ
              // ======================================================

              if (widget.hasCorrige) ...[
                const SizedBox(height: 20),

                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBtnBg,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Consulter le corrigé',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // ============================================================
      // NAVIGATION BOTTOM
      // ============================================================

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavigationSelected,
        backgroundColor: isDark ? darkBg : Colors.white,
        indicatorColor: accentColor.withValues(alpha: 0.18),
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
  // CARTE RÉUTILISABLE
  // ============================================================

  Widget _buildCardContainer({
    required Widget child,
    required Color cardBgColor,
    required bool isDark,
  }) {
    return Container(
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

  // ============================================================
  // BOUTON D'ACTION
  // ============================================================

  Widget _buildSmallActionButton({
  required IconData icon,
  required String label,
  required Color bgColor,
  required Color textColor,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xFFF0A500),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    ),
  );
}
}