import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ressource_card_widget.dart';
import '../models/matiere.dart';
import '../../../core/routes/app_routes.dart';
import 'add_edit_fiche_view.dart';

class MatiereDetailView extends StatefulWidget {
  final Matiere matiere;

  const MatiereDetailView({
    super.key,
    required this.matiere,
  });

  @override
  State<MatiereDetailView> createState() => _MatiereDetailViewState();
}

class _MatiereDetailViewState extends State<MatiereDetailView> {
  int _selectedTabIndex = 0;
  int _currentIndex = 1;
  static const Color accentColor = Color(0xFFF0A500);

  // Ressources de démonstration affichées dans le détail d'une matière.
final List<Map<String, String>> _ressources = [
  {
    'id': '1',
    'titre': 'Limites et continuité',
    'taille': '2,4 Mo',
    'fichier': 'limites_continuite.pdf',
  },
  {
    'id': '2',
    'titre': 'Fonctions linéaires',
    'taille': '1,8 Mo',
    'fichier': 'fonctions_lineaires.pdf',
  },
  {
    'id': '3',
    'titre': 'Suites numériques',
    'taille': '3,1 Mo',
    'fichier': 'suites_numeriques.pdf',
  },
  {
    'id': '4',
    'titre': 'Intégrales',
    'taille': '2,1 Mo',
    'fichier': 'integrales.pdf',
  },
];

Future<void> _modifierRessource(
  Map<String, String> ressource,
) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AddEditFicheView(
        id: ressource['id'],
        titre: ressource['titre'],
        matiere: widget.matiere.nom,
        nomFichier: ressource['fichier'],
      ),
    ),
  );

  if (result == true && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Formulaire de modification validé.',
        ),
      ),
    );
  }
}

Future<void> _supprimerRessource(
  Map<String, String> ressource,
) async {
  final confirmation = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Supprimer la ressource'),
      content: Text(
        'Voulez-vous vraiment supprimer '
        '"${ressource['titre']}" ?',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext, false);
          },
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext, true);
          },
          child: const Text(
            'Supprimer',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );

  if (confirmation != true || !mounted) return;

  setState(() {
    _ressources.removeWhere(
      (item) => item['id'] == ressource['id'],
    );
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Ressource supprimée de la liste.'),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final cardColor =
        isDark ? AppColors.cardDark : AppColors.cardLight;

    final textColor =
        isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  widget.matiere.nom.trim().isNotEmpty
                      ? widget.matiere.nom
                          .trim()[0]
                          .toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.matiere.nom,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Détail de la matière',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TextButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 14,
                    color: Color(0xFFF0A500),
                  ),
                  label: const Text(
                    'Retour aux matières',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),

                _buildActionButton(
                  icon: Icons.edit_outlined,
                  color: isDark
                      ? Colors.white12
                      : Colors.grey.shade200,
                  iconColor: accentColor,
                  onTap: () async {
                    await Navigator.pushNamed(
                      context,
                      AppRoutes.addEditMatiere,
                      arguments: widget.matiere,
                    );
                  },
                ),

                const SizedBox(width: 8),

                _buildActionButton(
                  icon: Icons.delete_outline,
                  color: isDark
                      ? Colors.white12
                      : Colors.grey.shade200,
                  iconColor: Colors.redAccent,
                  onTap: () {},
                ),

                const SizedBox(width: 8),

                _buildActionButton(
                  icon: Icons.add,
                  color: AppColors.primaryBlue,
                  iconColor: accentColor,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.matiere.nom,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${widget.matiere.code} • ${widget.matiere.description}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(
                        'Fiches de cours',
                        '1 240',
                        textColor,
                      ),
                      _buildStatItem(
                        'Sujets',
                        '1 240',
                        textColor,
                      ),
                      _buildStatItem(
                        'Mise à jour',
                        "Aujourd'hui",
                        textColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _selectedTabIndex == 0
                              ? AppColors.primaryBlue
                              : cardColor,
                      foregroundColor:
                          _selectedTabIndex == 0
                              ? Colors.white
                              : textColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedTabIndex = 0;
                      });
                    },
                    child: const Text(
                      'Fiches de cours',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _selectedTabIndex == 1
                              ? AppColors.primaryBlue
                              : cardColor,
                      foregroundColor:
                          _selectedTabIndex == 1
                              ? Colors.white
                              : textColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedTabIndex = 1;
                      });
                    },
                    child: const Text(
                      'Sujets',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            ListView.separated(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final titles = [
                  'Limites et continuité',
                  'Fonctions linéaires',
                  'Suites numériques',
                  'Intégrales',
                ];

                final sizes = [
                  '2,4 Mo',
                  '1,8 Mo',
                  '3,1 Mo',
                  '2,1 Mo',
                ];

                return RessourceCardWidget(
                  title: titles[index],
                  subtitle:
                      '${widget.matiere.nom} • 2026 • PDF • ${sizes[index]}',
                  cardColor: cardColor,
                  textColor: textColor,
                  isDark: isDark,
                  onModifier: () {
                    _modifierRessource(_ressources[index]);
                  },
                  onSupprimer: () {
                    _supprimerRessource(_ressources[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor:
            isDark ? const Color(0xFF081B32) : Colors.white,
        indicatorColor:
            AppColors.accentGold.withValues(alpha: 0.18),
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

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}