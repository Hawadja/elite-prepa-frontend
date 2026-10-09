import 'package:flutter/material.dart';
import '../models/matiere.dart';
import '../../../../core/theme/app_colors.dart';

class AddEditMatiereView extends StatefulWidget {
  final Matiere? matiere;

  const AddEditMatiereView({super.key, this.matiere});

  @override
  State<AddEditMatiereView> createState() => _AddEditMatiereViewState();
}

class _AddEditMatiereViewState extends State<AddEditMatiereView> {
  // Couleurs de la charte Elite-Prepa
  static const Color primaryNavy = Color(0xFF163C6E);
  static const Color darkBg = Color(0xFF091629);
  static const Color darkCardBg = Color(0xFF102542);
  static const Color lightBg = Color(0xFFF6F8FB);
  static const Color accentColor = Color(0xFFF0A500);

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomController;
  late TextEditingController _codeController;
  late TextEditingController _descriptionController;

  int _currentIndex = 1; // "Révisions" sélectionné
  bool _isSubmitting = false;

  bool get _isEditing => widget.matiere != null;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.matiere?.nom ?? '');
    _codeController = TextEditingController(text: widget.matiere?.code ?? '');
    _descriptionController =
        TextEditingController(text: widget.matiere?.description ?? '');
  }

  @override
  void dispose() {
    _nomController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_isEditing) {
        // Logique de modification
      } else {
        // Logique d'ajout
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Matière modifiée avec succès'
                : 'Matière créée avec succès',
          ),
          backgroundColor: Colors.green,
        ),
      );

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
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? darkBg : lightBg;
    final cardFillColor = isDark ? darkCardBg : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,

      // ============================================================
      // APP BAR
      // ============================================================
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Retour',
          icon: const Icon( Icons.arrow_back_ios_new,
            size: 19,
            color: accentColor,
            ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? 'Modifier la matière' : 'Ajouter une matière',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Matières • Elite-Prepa',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      // ============================================================
      // FORMULAIRE
      // ============================================================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Texte explicatif
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardFillColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Créez une matière pour organiser les ressources.',
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Champ : Nom de la matière
                _buildFormField(
                  label: 'Nom de la matière',
                  hintText: 'Ex. Informatique',
                  controller: _nomController,
                  cardColor: cardFillColor,
                  textColor: textColor,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 14),

                // Champ : Code court
                _buildFormField(
                  label: 'Code court',
                  hintText: 'Ex. INFO-MP',
                  controller: _codeController,
                  cardColor: cardFillColor,
                  textColor: textColor,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 14),

                // Champ : Description
                _buildFormField(
                  label: 'Description',
                  hintText: 'Programme et objectifs pédagogiques...',
                  controller: _descriptionController,
                  cardColor: cardFillColor,
                  textColor: textColor,
                  maxLines: 2,
                ),
                const SizedBox(height: 14),

                // Champ : Couleur de repère
                
                const SizedBox(height: 28),

                // Bouton "Créer la matière"
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryNavy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isEditing
                                ? 'Enregistrer la matière'
                                : 'Créer la matière',
                            style: const TextStyle(
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
        indicatorColor: AppColors.accentGold.withValues(alpha: 0.18),
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

  Widget _buildFormField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required Color cardColor,
    required Color textColor,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            style: TextStyle(
              fontSize: 14,
              color: textColor.withAlpha(200),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: textColor.withAlpha(120),
                fontSize: 14,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
          ),
        ],
      ),
    );
  }
}