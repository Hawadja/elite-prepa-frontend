import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';

class AddSujetView extends StatefulWidget {
  const AddSujetView({super.key});

  @override
  State<AddSujetView> createState() => _AddSujetViewState();
}

class _AddSujetViewState extends State<AddSujetView> {
  // ============================================================
  // CHARTE ELITE-PREPA
  // ============================================================

  static const Color primaryColor = Color(0xFF1F3F6E);
  static const Color accentColor = Color(0xFFF0A500);
  static const Color darkBg = Color(0xFF081B32);
  static const Color darkCardBg = Color(0xFF102542);
  static const Color lightBg = Color(0xFFF5F5F5);
  static const Color deleteRed = Color(0xFFD9534F);

  int _currentIndex = 2;

  // ============================================================
  // CONTROLEURS
  // ============================================================

  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();
  final TextEditingController _concoursController = TextEditingController();
  final TextEditingController _anneeController = TextEditingController();

  // ============================================================
  // MATIERE
  // ============================================================

  String? _selectedMatiereId;

  // Données temporaires.
  // Plus tard, elles seront remplacées par les matières venant
  // du backend.
  final List<Map<String, String>> _matieres = [
    {
      'id': 'matiere_math',
      'nom': 'Mathématiques',
    },
    {
      'id': 'matiere_physique',
      'nom': 'Physique',
    },
    {
      'id': 'matiere_informatique',
      'nom': 'Informatique',
    },
    {
      'id': 'matiere_chimie',
      'nom': 'Chimie',
    },
  ];

  // ============================================================
  // FICHIER PDF
  // ============================================================

  String? _fileName;
  String? _fileSize;

  bool _isLoading = false;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _concoursController.dispose();
    _anneeController.dispose();
    super.dispose();
  }

  // ============================================================
  // SELECTION DU PDF
  // ============================================================

  void _pickFile() {
    // Démonstration temporaire.
    // Le vrai file_picker sera branché lors de l'intégration
    // avec le backend.
    setState(() {
      _fileName = 'sujet_mines_ponts_2026.pdf';
      _fileSize = '2,4 Mo';
    });
  }

  void _removeFile() {
    setState(() {
      _fileName = null;
      _fileSize = null;
    });
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool _validateForm() {
    if (_titreController.text.trim().isEmpty) {
      _showError('Veuillez saisir le titre du sujet.');
      return false;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showError('Veuillez saisir la description du sujet.');
      return false;
    }

    if (_selectedMatiereId == null) {
      _showError('Veuillez sélectionner une matière.');
      return false;
    }

    if (_concoursController.text.trim().isEmpty) {
      _showError('Veuillez saisir le concours.');
      return false;
    }

    if (_anneeController.text.trim().isEmpty) {
      _showError('Veuillez saisir l’année académique.');
      return false;
    }

    if (_fileName == null) {
      _showError('Veuillez sélectionner le fichier PDF du sujet.');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: deleteRed,
        ),
      );
  }

  // ============================================================
  // AJOUT DU SUJET
  // ============================================================

  Future<void> _submitSujet() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ========================================================
      // FUTURE INTEGRATION BACKEND
      // ========================================================
      //
      // Les données qui seront envoyées au backend seront :
      //
      // {
      //   "titre": _titreController.text.trim(),
      //   "description": _descriptionController.text.trim(),
      //   "fichier": _fileName,
      //   "matiere": _selectedMatiereId,
      //   "concours": _concoursController.text.trim(),
      //   "anneeAcademique": _anneeController.text.trim()
      // }
      //
      // Le champ "corrige" n'est pas nécessaire lors de
      // l'ajout initial du sujet.
      //
      // "dateAjout" est généré automatiquement par MongoDB.

      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sujet de concours ajouté avec succès',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Retour vers SujetsConcoursView.
      // true indique que la liste doit être actualisée.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : ${e.toString()}'),
          backgroundColor: deleteRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // NAVIGATION BAS
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
        Navigator.pop(context);
        break;

      case 3:
        setState(() {
          _currentIndex = index;
        });
        break;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? darkBg : lightBg;
    final cardColor = isDark ? darkCardBg : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor =
        isDark ? Colors.white70 : Colors.black54;

    final inputBackground =
        isDark ? const Color(0xFF0D1F38) : const Color(0xFFF8FAFC);

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
          onPressed: () => Navigator.pop(context, false),
          tooltip: 'Retour',
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ajouter un sujet',
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
          padding: const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // TITRE DE SECTION
              // --------------------------------------------------

              _buildSection(
                cardColor: cardColor,
                child: Text(
                  'Nouveau sujet de concours',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // --------------------------------------------------
              // TITRE
              // --------------------------------------------------

              _buildSection(
                cardColor: cardColor,
                child: _buildTextField(
                  label: 'Titre',
                  hint: 'Ex. Mines-Ponts 2026 · Maths I',
                  controller: _titreController,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                ),
              ),

              const SizedBox(height: 12),

              // --------------------------------------------------
              // DESCRIPTION
              // --------------------------------------------------

              _buildSection(
                cardColor: cardColor,
                child: _buildTextField(
                  label: 'Description',
                  hint: 'Description du sujet de concours',
                  controller: _descriptionController,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  maxLines: 4,
                ),
              ),

              const SizedBox(height: 12),

              // --------------------------------------------------
              // MATIERE
              // --------------------------------------------------

              _buildSection(
                cardColor: cardColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Matière',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedMatiereId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: inputBackground,
                        hintText: 'Sélectionner une matière',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: secondaryTextColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      items: _matieres.map((matiere) {
                        return DropdownMenuItem<String>(
                          value: matiere['id'],
                          child: Text(
                            matiere['nom']!,
                            style: TextStyle(
                              fontSize: 13,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _selectedMatiereId = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // --------------------------------------------------
              // CONCOURS
              // --------------------------------------------------

              _buildSection(
                cardColor: cardColor,
                child: _buildTextField(
                  label: 'Concours',
                  hint: 'Ex. Mines-Ponts',
                  controller: _concoursController,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                ),
              ),

              const SizedBox(height: 12),

              // --------------------------------------------------
              // ANNEE ACADEMIQUE
              // --------------------------------------------------

              _buildSection(
                cardColor: cardColor,
                child: _buildTextField(
                  label: 'Année académique',
                  hint: 'Ex. 2025-2026',
                  controller: _anneeController,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                ),
              ),

              const SizedBox(height: 12),

              // --------------------------------------------------
              // PDF
              // --------------------------------------------------

              _buildSection(
                cardColor: cardColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fichier PDF',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'PDF du sujet · 20 Mo maximum',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_fileName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: inputBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.picture_as_pdf_outlined,
                              size: 24,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _fileName!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                    overflow:
                                        TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _fileSize ?? '',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            TextButton(
                              onPressed: _pickFile,
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize
                                        .shrinkWrap,
                              ),
                              child: const Text(
                                'Remplacer',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),

                            IconButton(
                              onPressed: _removeFile,
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: deleteRed,
                              ),
                              padding: EdgeInsets.zero,
                              constraints:
                                  const BoxConstraints(),
                              tooltip: 'Supprimer',
                            ),
                          ],
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(
                          Icons.upload_file,
                          size: 18,
                        ),
                        label: const Text(
                          'Sélectionner un fichier PDF',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(
                            color: primaryColor.withValues(
                              alpha: 0.45,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(9),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --------------------------------------------------
              // BOUTON AJOUTER
              // --------------------------------------------------

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _submitSujet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        primaryColor.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 21,
                          width: 21,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Ajouter le sujet',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ========================================================
      // NAVIGATION BAS
      // ========================================================

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavigationSelected,
        backgroundColor:
            isDark ? darkBg : Colors.white,
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

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _buildSection({
    required Color cardColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required Color textColor,
    required Color secondaryTextColor,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 13,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13,
              color: secondaryTextColor.withValues(
                alpha: 0.8,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).brightness ==
                    Brightness.dark
                ? const Color(0xFF0D1F38)
                : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
          ),
        ),
      ],
    );
  }
}

