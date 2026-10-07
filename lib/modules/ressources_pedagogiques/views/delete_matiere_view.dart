import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/matiere.dart';

class DeleteMatiereView extends StatefulWidget {
  final Matiere? matiere;

  const DeleteMatiereView({
    super.key,
    this.matiere,
  });

  @override
  State<DeleteMatiereView> createState() => _DeleteMatiereViewState();
}

class _DeleteMatiereViewState extends State<DeleteMatiereView> {
  static const Color deleteRed = Color(0xFFD9534F);

  int _currentIndex = 1; // Révisions
  bool _isDeleting = false;

  Future<void> _confirmDelete() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      // La suppression backend n'est pas encore implémentée.
      // Elle sera ajoutée lorsque le repository/viewmodel
      // sera connecté à l'API.

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Matière supprimée avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      // Retourner true afin que la liste parent puisse
      // se rafraîchir.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final cardColor = isDark
        ? AppColors.cardDark
        : AppColors.cardLight;

    final textColor = isDark
        ? Colors.white
        : Colors.black87;

    final secondaryTextColor = isDark
        ? Colors.white70
        : Colors.black54;

    final nomMatiere = widget.matiere?.nom ?? 'Mathématiques';

    return Scaffold(
      backgroundColor: backgroundColor,

      // ============================================================
      // APP BAR
      // ============================================================
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: const Text(
          'Confirmation de suppression',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ============================================================
      // CONTENU PRINCIPAL
      // ============================================================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------------
              // 1. EN-TÊTE
              // ------------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: deleteRed.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Confirmation de suppression',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 20, 11, 11),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ------------------------------------------------------
              // 2. QUESTION PRINCIPALE
              // ------------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '× ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: deleteRed,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Supprimer la matière « $nomMatiere » ?',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: deleteRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ------------------------------------------------------
              // 3. CONSÉQUENCE
              // ------------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conséquence',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Les ressources associées devront être réaffectées.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textColor.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ------------------------------------------------------
              // 4. ANNULER
              // ------------------------------------------------------
              InkWell(
                onTap: () => Navigator.pop(context, false),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Annuler',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Conserver la matière',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ------------------------------------------------------
              // 5. SUPPRESSION
              // ------------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isDeleting ? null : _confirmDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: deleteRed,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: deleteRed.withValues(
                      alpha: 0.5,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isDeleting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Supprimer définitivement',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ============================================================
      // NAVIGATION
      // ============================================================
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: isDark
            ? const Color(0xFF081B32)
            : Colors.white,
        indicatorColor: AppColors.accentGold.withValues(
          alpha: 0.18,
        ),
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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

