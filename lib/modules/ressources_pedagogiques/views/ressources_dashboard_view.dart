import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../repositories/matiere_repository.dart';
import '../repositories/fiche_cours_repository.dart';
import '../repositories/sujet_repository.dart';
import '../models/fiche_cours.dart';
import '../models/sujet.dart';

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
  int _currentIndex = 0;

  final MatiereRepository _matiereRepository = MatiereRepository();
  final FicheCoursRepository _ficheCoursRepository =
      FicheCoursRepository();
  final SujetRepository _sujetRepository = SujetRepository();

  int? _nombreMatieres;
  int? _nombreFichesCours;
  int? _nombreSujets;
  int? _nombreCorriges;

  // Ressources récentes récupérées depuis le backend.
  List<FicheCours> _fichesRecentes = [];
  List<Sujet> _sujetsRecents = [];

  bool _chargementRessourcesRecentes = true;
  String? _erreurRessourcesRecentes;

  @override
  void initState() {
    super.initState();
    _chargerStatistiques();
    _chargerRessourcesRecentes();
  }

  Future<void> _chargerStatistiques() async {
    try {
      // 1. Récupérer les matières
      final matieres = await _matiereRepository.getMatieres();

      // 2. Récupérer les fiches de cours
      // 2. Récupérer les fiches de cours
      final resultatFiches =
          await _ficheCoursRepository.getFichesCours();

      final nombreFichesCours =
          resultatFiches['total'] as int;

      // 3. Récupérer les sujets et leurs corrigés
      final premierePage = await _sujetRepository.getSujetsPage(
        page: 1,
        limit: 100,
      );

      int nombreSujets = premierePage.total;

      int nombreCorriges = premierePage.items
          .where((sujet) => sujet.aCorrige)
          .length;

      // Parcourir les autres pages pour compter tous les corrigés.
      for (int page = 2; page <= premierePage.totalPages; page++) {
        final resultat = await _sujetRepository.getSujetsPage(
          page: page,
          limit: 100,
        );

        nombreCorriges += resultat.items
            .where((sujet) => sujet.aCorrige)
            .length;
      }

      if (!mounted) return;

      setState(() {
        _nombreMatieres = matieres.length;
        _nombreFichesCours = nombreFichesCours;
        _nombreSujets = nombreSujets;
        _nombreCorriges = nombreCorriges;
      });
    } catch (e, stackTrace) {
      debugPrint(
        'Erreur lors du chargement des statistiques : $e',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _chargerRessourcesRecentes() async {
    if (!mounted) return;

    setState(() {
      _chargementRessourcesRecentes = true;
      _erreurRessourcesRecentes = null;
    });

    try {
      final resultats = await Future.wait([
        _ficheCoursRepository.getFichesCours(
          page: 1,
          limit: 5,
        ),
        _sujetRepository.getSujetsPage(
          page: 1,
          limit: 5,
          sort: 'dateAjout',
          order: 'desc',
        ),
      ]);

      final resultatFiches =
          resultats[0] as Map<String, dynamic>;

      final resultatSujets = resultats[1] as dynamic;

      final fiches = List<FicheCours>.from(
        resultatFiches['data'] as List,
      );

      final sujets = List<Sujet>.from(
        resultatSujets.items as List,
      );

      if (!mounted) return;

      setState(() {
        _fichesRecentes = fiches;
        _sujetsRecents = sujets;
        _chargementRessourcesRecentes = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erreurRessourcesRecentes =
            'Impossible de charger les ressources récentes.';
        _chargementRessourcesRecentes = false;
      });

      debugPrint('Erreur des ressources récentes : $e');
    }
  }

  List<Widget> _construireCartesRecentes(bool isDark) {
    final List<Map<String, dynamic>> ressources = [];

    for (final fiche in _fichesRecentes) {
      ressources.add({
        'titre': fiche.titre,
        'matiere': fiche.matiereNom,
        'type': 'Fiche de cours',
        'date': fiche.dateAjout,
        'icon': Icons.menu_book_outlined,
      });
    }

    for (final sujet in _sujetsRecents) {
      ressources.add({
        'titre': sujet.titre,
        'matiere': sujet.matiereNom,
        'type': sujet.aCorrige
            ? 'Sujet · Corrigé disponible'
            : 'Sujet de concours',
        'date': sujet.dateAjout,
        'icon': Icons.picture_as_pdf_outlined,
      });
    }

    ressources.sort((a, b) {
      final DateTime? dateA = a['date'] as DateTime?;
      final DateTime? dateB = b['date'] as DateTime?;

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      return dateB.compareTo(dateA);
    });

    final recentes = ressources.take(5).toList();

    return [
      for (int i = 0; i < recentes.length; i++) ...[
        _ContentCard(
          title: recentes[i]['titre'] as String,
          subtitle: _formaterSousTitre(recentes[i]),
          icon: recentes[i]['icon'] as IconData,
        ),
        if (i < recentes.length - 1)
          const SizedBox(height: 10),
      ],
    ];
  }

  String _formaterSousTitre(Map<String, dynamic> ressource) {
    final matiere = (ressource['matiere'] as String).trim();
    final type = ressource['type'] as String;
    final date = ressource['date'] as DateTime?;

    final informations = <String>[];

    if (matiere.isNotEmpty) {
      informations.add(matiere);
    }

    informations.add(type);

    if (date != null) {
      final jour = date.day.toString().padLeft(2, '0');
      final mois = date.month.toString().padLeft(2, '0');

      informations.add('Ajoutée le $jour/$mois/${date.year}');
    }

    return informations.join(' · ');
  }

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

    // Bouton d'actualisation à droite
    actions: [
    IconButton(
    tooltip: 'Actualiser les ressources',
    icon: const Icon(Icons.refresh),
    onPressed: _chargerStatistiques,
    ),
    const SizedBox(width: 8),
    ],
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
                    value: _nombreMatieres?.toString() ?? '...',
                    icon: Icons.menu_book_outlined,
                    onTap: () {
                      context.push(AppRoutes.matieres);
                    },
                  ),

                  _StatCard(
                    title: 'Fiches de cours',
                    value: _nombreFichesCours?.toString() ?? '...',
                    icon: Icons.description_outlined,
                    onTap: () async {
                      await context.push(AppRoutes.fichesCours);

                      if (!mounted) return;

                      await _chargerStatistiques();
                    },
                  ),


                  _StatCard(
                    title: 'Sujets',
                    value: _nombreSujets?.toString() ?? '...',
                    icon: Icons.assignment_outlined,
                    onTap: () {
                      context.push(AppRoutes.sujetsGestion);
                    },
                  ),

                  _StatCard(
                    title: 'Corrigés disponibles',
                    value: _nombreCorriges?.toString() ?? '...',
                    icon: Icons.check_circle_outline,
                    iconColor: Color(0xFFF0A500),
                    onTap: () {
                      context.push(AppRoutes.corriges);
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
                    context.push(AppRoutes.rechercheAvancee);
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

              if (_chargementRessourcesRecentes)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: RessourcesDashboardView.accentColor,
                      ),
                    ),
                  )
                else if (_erreurRessourcesRecentes != null)
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.cloud_off_outlined,
                            color: RessourcesDashboardView.accentColor,
                            size: 30,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _erreurRessourcesRecentes!,
                            textAlign: TextAlign.center,
                          ),
                          TextButton.icon(
                            onPressed: _chargerRessourcesRecentes,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_fichesRecentes.isEmpty && _sujetsRecents.isEmpty)
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.library_books_outlined,
                            size: 36,
                            color: RessourcesDashboardView.accentColor,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Aucune ressource disponible',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._construireCartesRecentes(isDark),

                const SizedBox(height: 16),

              // ======================================================
              // VOIR TOUTES LES RESSOURCES
              // ======================================================
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    context.push(AppRoutes.toutesRessources);
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
  final Color? iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
    this.iconColor,
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
              color: iconColor ?? RessourcesDashboardView.accentColor,
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
                color: const Color(0xFFF0A500),
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