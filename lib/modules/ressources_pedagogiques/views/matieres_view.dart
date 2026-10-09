import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../models/matiere.dart';
import '../viewmodels/matiere_viewmodel.dart';

class MatieresView extends StatefulWidget {
  const MatieresView({super.key});

  @override
  State<MatieresView> createState() => _MatieresViewState();
}

class _MatieresViewState extends State<MatieresView> {
  static const Color primaryColor = Color(0xFF1F3F6E);
  static const Color accentColor = Color(0xFFF0A500);
  static const Color lightBackground = Color(0xFFF5F5F5);

  int _currentIndex = 1;

  final MatiereViewModel _viewModel = MatiereViewModel();
  final TextEditingController _searchController = TextEditingController();

  List<Matiere> _matieres = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatieres();
  }

  Future<void> _loadMatieres() async {
    final matieres = await _viewModel.loadMatieres();

    if (!mounted) return;

    setState(() {
      _matieres = matieres;
      _isLoading = false;
    });
  }

  List<Matiere> get _filteredMatieres {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return _matieres;
    }

    return _matieres.where((matiere) {
      return matiere.nom.toLowerCase().contains(query) ||
          matiere.code.toLowerCase().contains(query) ||
          matiere.description.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? theme.colorScheme.surface : lightBackground,

      // ============================================================
      // APP BAR
      // ============================================================
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Retour',
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 19,
            color: accentColor ,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Matières',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Ajouter une matière',
            icon: const Icon(Icons.add),
            color: accentColor,
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                AppRoutes.addEditMatiere,
              );

              if (result == true && context.mounted) {
                _loadMatieres();
              }
            },
          ),
          const SizedBox(width: 6),
        ],
      ),

      // ============================================================
      // CONTENU
      // ============================================================
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: TextField(
                controller: _searchController,
                onChanged: (_) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher une matière...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: accentColor,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  filled: true,
                  fillColor:
                      isDark ? const Color(0xFF102944) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 13,
                    horizontal: 12,
                  ),
                ),
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: accentColor,
                      ),
                    )
                  : _filteredMatieres.isEmpty
                      ? _EmptyState(isDark: isDark)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            6,
                            16,
                            16,
                          ),
                          itemCount: _filteredMatieres.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 7),
                          itemBuilder: (context, index) {
                            final matiere = _filteredMatieres[index];

                            return _MatiereCard(
                              matiere: matiere,
                              isDark: isDark,
                              onChanged: _loadMatieres,
                            );
                          },
                        ),
            ),

            // ========================================================
            // NOMBRE DE MATIÈRES
            // ========================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: Text(
                    '${_matieres.length} matières actives',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
        backgroundColor:
            isDark ? const Color(0xFF081B32) : Colors.white,
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
// CARTE MATIÈRE
// ==================================================================

class _MatiereCard extends StatelessWidget {
  final Matiere matiere;
  final bool isDark;
  final VoidCallback onChanged;

  const _MatiereCard({
    required this.matiere,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.matiereDetail,
            arguments: matiere,
          );
        },
        child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 9,
            ),
          child: Row(
            children: [
              // ========================================================
              // ICÔNE
              // ========================================================
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF1F3F6E).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.menu_book_outlined,
                  color: Color(0xFFF0A500),
                  size: 21,
                ),
              ),

              const SizedBox(width: 9),

              // ========================================================
              // INFORMATIONS
              // ========================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      matiere.nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF1F3F6E),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      matiere.code,
                      style: const TextStyle(
                        color: Color(0xFFF0A500),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      matiere.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            isDark ? Colors.white70 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 4),

              // ========================================================
              // ACTIONS
              // ========================================================
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ----------------------------------------------------
                  // MODIFIER
                  // ----------------------------------------------------
                  IconButton(
                    tooltip: 'Modifier',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                    ),
                    color: const Color(0xFF1F3F6E),
                    onPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        AppRoutes.addEditMatiere,
                        arguments: matiere,
                      );

                      if (result == true && context.mounted) {
                        onChanged();
                      }
                    },
                  ),

                  // ----------------------------------------------------
                  // SUPPRIMER
                  // ----------------------------------------------------

                IconButton(
                  tooltip: 'Supprimer',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                  ),
                  color: Colors.red,
                  onPressed: () async {
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;

                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          backgroundColor: isDark
                              ? const Color(0xFF102542)
                              : Colors.white,
                          title: Text(
                            'Supprimer la matière ?',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            'Voulez-vous vraiment supprimer '
                            '« ${matiere.nom} » ?',
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
                                      : const Color(0xFF1F3F6E),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(dialogContext, true);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                              child: const Text('Supprimer'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmed != true || !context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Matière supprimée avec succès'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );

                    onChanged();
                  },
                ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// ÉTAT VIDE
// ==================================================================

class _EmptyState extends StatelessWidget {
  final bool isDark;

  const _EmptyState({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 48,
              color:
                  isDark ? Colors.white54 : const Color(0xFF1F3F6E),
            ),
            const SizedBox(height: 12),
            Text(
              'Aucune matière trouvée',
              style: TextStyle(
                color:
                    isDark ? Colors.white : const Color(0xFF1F3F6E),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Essayez une autre recherche.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}