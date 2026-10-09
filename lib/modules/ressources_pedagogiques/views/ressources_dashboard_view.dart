import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';

class RessourcesDashboardView extends StatefulWidget {
  const RessourcesDashboardView({super.key});

  static const Color primaryColor = Color(0xFF1F3F6E);
  static const Color accentColor = Color(0xFFF0A500);
  static const Color lightBackground = Color(0xFFF5F5F5);

  @override
  State<RessourcesDashboardView> createState() =>
      _RessourcesDashboardViewState();
}

class _RessourcesDashboardViewState
    extends State<RessourcesDashboardView> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? theme.colorScheme.surface : RessourcesDashboardView.lightBackground,

      // ============================================================
      // APP BAR
      // ============================================================
appBar: AppBar(
  backgroundColor: RessourcesDashboardView.primaryColor,
  foregroundColor: Colors.white,
  elevation: 0,
  titleSpacing: 12,

  leading: Container(
    margin: const EdgeInsets.only(
      left: 12,
      top: 8,
      bottom: 8,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    ),
    alignment: Alignment.center,
    child: const Text(
      'E',
      style: TextStyle(
        color: RessourcesDashboardView.primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),

  title: const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Ressources',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        'Dashboard · Elite-Prepa',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
    ],
  ),
),

      // ============================================================
      // CONTENU
      // ============================================================
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ======================================================
              // MESSAGE D'ACCUEIL
              // ======================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: RessourcesDashboardView.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Bonjour Chloé · Prépa MP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ======================================================
              // STATISTIQUES
              // ======================================================
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.25,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StatCard(
                    title: 'Matières',
                    value: '8',
                    icon: Icons.menu_book_outlined,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.matieres,
                      );
                    },
                  ),

                  _StatCard(
                    title: 'Fiches de cours',
                    value: '42',
                    icon: Icons.description_outlined,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.fichesCours,
                      );
                    },
                  ),

                  _StatCard(
                    title: 'Sujets',
                    value: '27',
                    icon: Icons.assignment_outlined,
                    onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.sujetsGestion,
                    );
                  },
                  ),

                  _StatCard(
                    title: 'Corrigés disponibles',
                    value: '19',
                    icon: Icons.check_circle_outline,
                     onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.corriges,
                    );
                  },
                  ),
                ],
              ),

                           const SizedBox(height: 20),

              // ======================================================
              // RECHERCHE AVANCÉE
              // ======================================================
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.rechercheAvancee,
                    );
                  },
                  icon: const Icon(
                    Icons.manage_search,
                    size: 22,
                  ),
                  label: const Text(
                    'Recherche avancée',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        RessourcesDashboardView.primaryColor,
                    side: const BorderSide(
                      color: RessourcesDashboardView.primaryColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ======================================================
              // TITRE SECTION
              // ======================================================
              Text(
                'Ressources récentes',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isDark
                      ? Colors.white
                      : RessourcesDashboardView.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // ======================================================
              // RESSOURCE 1
              // ======================================================
              const _ContentCard(
                title: 'Limites et contenu',
                subtitle: 'Mathématiques · ajoutée aujourd’hui',
                icon: Icons.menu_book_outlined,
              ),

              const SizedBox(height: 10),

              // ======================================================
              // RESSOURCE 2
              // ======================================================
              const _ContentCard(
                title: 'Sujet CentraleSupélec 2025 · Corrigé',
                subtitle: 'Physique · corrigé disponible',
                icon: Icons.picture_as_pdf_outlined,
              ),

              const SizedBox(height: 16),

              // ======================================================
              // VOIR TOUTES LES RESSOURCES
              // ======================================================
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.matieres,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        RessourcesDashboardView.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'Voir toutes les ressources',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ============================================================
      // NAVIGATION INFÉRIEURE
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

        indicatorColor:
            RessourcesDashboardView.accentColor.withValues(
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
}

// ==================================================================
// CARTE STATISTIQUE
// ==================================================================

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 9,
          ),
          child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: RessourcesDashboardView.accentColor,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: isDark
                          ? Colors.white
                          : RessourcesDashboardView.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? Colors.white70
                          : Colors.black54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
    );
  }
}

// ==================================================================
// CARTE RESSOURCE
// ==================================================================

class _ContentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ContentCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: RessourcesDashboardView.primaryColor
                    .withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                icon,
                size: 20,
                color: RessourcesDashboardView.primaryColor,
              ),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? Colors.white
                          : RessourcesDashboardView.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? Colors.white70
                          : Colors.black54,
                      fontSize: 10,
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
}