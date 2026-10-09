import 'package:flutter/material.dart';
import 'add_fiche_view.dart';
class AddEditFicheView extends StatefulWidget {
  final String? id;
  final String? titre;
  final String? matiere;
  final String? description;
  final String? nomFichier;

  const AddEditFicheView({
    super.key,
    this.id,
    this.titre,
    this.matiere,
    this.description,
    this.nomFichier,
  });

  bool get isEditMode => id != null;

  @override
  State<AddEditFicheView> createState() => _AddEditFicheViewState();
}

class _AddEditFicheViewState extends State<AddEditFicheView> {
  static const Color primaryColor = Color(0xFF1F3F6E);
  static const Color accentColor = Color(0xFFF0A500);
  static const Color lightBackground = Color(0xFFF5F5F5);

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titreController;
  late TextEditingController _matiereController;
  late TextEditingController _descriptionController;

  String? _selectedFileName;

  int _currentIndex = 1;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _titreController = TextEditingController(
      text: widget.titre ?? '',
    );

    _matiereController = TextEditingController(
      text: widget.matiere ?? 'Mathématiques',
    );

    _descriptionController = TextEditingController(
      text: widget.description ?? '',
    );

    _selectedFileName = widget.nomFichier;
  }

  @override
  void dispose() {
    _titreController.dispose();
    _matiereController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

Future<void> _pickPDFFile() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const AddFicheView(),
    ),
  );

  if (result != null && mounted) {
    setState(() {
      _selectedFileName = result['name'] as String?;
    });
  }
}

  void _removeSelectedFile() {
    setState(() {
      _selectedFileName = null;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO : connexion API/backend

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      final message = widget.isEditMode
          ? 'Fiche de cours modifiée avec succès'
          : 'Fiche de cours ajoutée avec succès';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
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

  void _onNavigationSelected(int index) {
    if (index == _currentIndex) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark =
        theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? theme.colorScheme.surface
        : lightBackground;

    final cardColor = isDark
        ? const Color(0xFF102542)
        : Colors.white;

    final textColor =
        isDark ? Colors.white : Colors.black87;

    final secondaryTextColor =
        isDark ? Colors.white70 : Colors.black54;

    final pageTitle = widget.isEditMode
        ? 'Modifier la fiche'
        : 'Ajouter une fiche';

    final sectionTitle = widget.isEditMode
        ? 'Modifier la fiche de cours'
        : 'Nouvelle fiche de cours';

    final sectionDescription = widget.isEditMode
        ? 'Modifiez les informations de la fiche.'
        : 'Renseignez les informations de la fiche.';

    final buttonLabel = widget.isEditMode
        ? 'Enregistrer les modifications'
        : 'Ajouter la fiche';

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 19,
            color: accentColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          tooltip: 'Retour',
        ),

        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              pageTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Ressources · Elite-Prepa',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  sectionTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark
                        ? Colors.white
                        : primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  sectionDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: secondaryTextColor,
                  ),
                ),

                const SizedBox(height: 18),

                _buildFormField(
                  label: 'Titre',
                  hintText:
                      'Ex. Limites et continuité',
                  controller: _titreController,
                  cardColor: cardColor,
                  textColor: textColor,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Veuillez saisir un titre';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                _buildFormField(
                  label: 'Matière',
                  hintText: 'Mathématiques',
                  controller: _matiereController,
                  cardColor: cardColor,
                  textColor: textColor,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Veuillez préciser la matière';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                _buildFormField(
                  label: 'Description',
                  hintText:
                      'Objectifs, notions clés et prérequis...',
                  controller:
                      _descriptionController,
                  cardColor: cardColor,
                  textColor: textColor,
                  maxLines: 4,
                ),

                const SizedBox(height: 12),

                _buildPdfPicker(
                  cardColor: cardColor,
                  textColor: textColor,
                  secondaryTextColor:
                      secondaryTextColor,
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting
                        ? null
                        : _submitForm,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            widget.isEditMode
                                ? Icons.save_outlined
                                : Icons.check,
                            size: 19,
                          ),
                    label: Text(
                      _isSubmitting
                          ? 'Enregistrement...'
                          : buttonLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          primaryColor.withValues(
                        alpha: 0.55,
                      ),
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    'Format accepté : PDF · 20 Mo maximum',
                    style: TextStyle(
                      fontSize: 11,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

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
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        14,
        11,
        14,
        5,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          const SizedBox(height: 2),

          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 13,
                color: textColor.withValues(
                  alpha: 0.45,
                ),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(
                vertical: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfPicker({
    required Color cardColor,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    final hasFile = _selectedFileName != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasFile
              ? accentColor
              : Colors.black12,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor.withValues(
                alpha: 0.13,
              ),
              borderRadius:
                  BorderRadius.circular(8),
            ),
            child: Icon(
              hasFile
                  ? Icons.picture_as_pdf
                  : Icons.upload_file_outlined,
              color: accentColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  hasFile
                      ? 'Fichier sélectionné'
                      : 'Ajouter le fichier PDF',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  hasFile
                      ? _selectedFileName!
                      : 'Appuyez pour sélectionner un PDF',
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: hasFile
                        ? accentColor
                        : secondaryTextColor,
                    fontWeight: hasFile
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),

          if (hasFile)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: _pickPDFFile,
                  tooltip: 'Remplacer le PDF',
                  icon: const Icon(
                    Icons.refresh,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                IconButton(
                  onPressed: _removeSelectedFile,
                  tooltip: 'Supprimer le PDF',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ],
            )
          else
            IconButton(
              onPressed: _pickPDFFile,
              tooltip: 'Sélectionner un PDF',
              icon: Icon(
                Icons.chevron_right,
                color: secondaryTextColor,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}