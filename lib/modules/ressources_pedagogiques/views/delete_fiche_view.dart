import 'package:flutter/material.dart';

import '../views/fiches_cours_view.dart';

class DeleteFicheView extends StatefulWidget {
  final FicheItem? fiche;

  const DeleteFicheView({
    super.key,
    this.fiche,
  });

  @override
  State<DeleteFicheView> createState() => _DeleteFicheViewState();
}

class _DeleteFicheViewState extends State<DeleteFicheView> {
  // ============================================================
  // CHARTE GRAPHIQUE ELITE-PREPA
  // ============================================================

  static const Color primaryColor = Color(0xFF1F3F6E);
  static const Color accentColor = Color(0xFFF0A500);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color deleteRed = Color(0xFFD9534F);

  int _currentIndex = 1;
  bool _isDeleting = false;

  // ============================================================
  // SUPPRESSION
  // ============================================================

  Future<void> _confirmDelete() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      // Plus tard :
      // await _viewModel.deleteFiche(widget.fiche?.id ?? '');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Fiche de cours supprimée avec succès',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur : ${e.toString()}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _onNavigationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor =
        isDark ? const Color(0xFF0F172A) : lightBackground;

    final cardColor =
        isDark ? const Color(0xFF1E293B) : Colors.white;

    final textColor =
        isDark ? Colors.white : const Color(0xFF1F2937);

    final secondaryTextColor =
        isDark ? Colors.white70 : const Color(0xFF64748B);

    final titreFiche =
        widget.fiche?.titre ?? 'Cette fiche';

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
            Navigator.pop(context, false);
          },
          tooltip: 'Retour',
        ),

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Supprimer la fiche',
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

      // ========================================================
      // CONTENU
      // ========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ------------------------------------------------
              // TITRE
              // ------------------------------------------------

              Text(
                'Confirmation de suppression',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Vérifiez les informations avant de supprimer '
                'définitivement cette fiche.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: secondaryTextColor,
                ),
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------
              // FICHE À SUPPRIMER
              // ------------------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: deleteRed.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: deleteRed.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: deleteRed,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Supprimer cette fiche ?',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            titreFiche,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: deleteRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ------------------------------------------------
              // CONSÉQUENCE
              // ------------------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 22,
                      color: primaryColor,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Conséquence',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'La fiche ne sera plus accessible aux '
                            'étudiants après sa suppression.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ------------------------------------------------
              // ANNULER
              // ------------------------------------------------

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isDeleting
                      ? null
                      : () {
                          Navigator.pop(context, false);
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(
                      color: primaryColor.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Annuler',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ------------------------------------------------
              // SUPPRIMER
              // ------------------------------------------------

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed:
                      _isDeleting ? null : _confirmDelete,
                  icon: _isDeleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.delete_outline,
                          size: 20,
                        ),
                  label: Text(
                    _isDeleting
                        ? 'Suppression...'
                        : 'Supprimer définitivement',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: deleteRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // ========================================================
      // NAVIGATION BOTTOM
      // ========================================================

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
}