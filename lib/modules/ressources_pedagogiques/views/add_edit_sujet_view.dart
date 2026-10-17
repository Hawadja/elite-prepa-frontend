import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/matiere.dart';
import '../repositories/matiere_repository.dart';
import 'package:go_router/go_router.dart';
import '../repositories/sujet_repository.dart';

class AddEditSujetView extends StatefulWidget {
  const AddEditSujetView({
    super.key,
    this.id,
    this.titre,
    this.matiereId,
    this.description,
    this.concours,
    this.anneeAcademique,
    this.nomFichier,
  });

  final String? id;
  final String? titre;
  final String? matiereId;
  final String? description;
  final String? concours;
  final String? anneeAcademique;
  final String? nomFichier;

  bool get isEditing => id != null && id!.trim().isNotEmpty;

  @override
  State<AddEditSujetView> createState() => _AddEditSujetViewState();
}

class _AddEditSujetViewState extends State<AddEditSujetView> {
  final _formKey = GlobalKey<FormState>();

  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _concoursController = TextEditingController();
  final _anneeController = TextEditingController();

  String? _matiereSelectionnee;
  PlatformFile? _fichierSujet;
  PlatformFile? _fichierCorrige;

  bool _isLoading = false;

  final MatiereRepository _matiereRepository = MatiereRepository();
  final SujetRepository _sujetRepository = SujetRepository();

  List<Matiere> _matieres = [];
  bool _chargementMatieres = true;
  String? _erreurMatieres;

  static const Color _primaryColor = Color(0xFF1F3F6E);
  static const Color _accentColor = Color(0xFFF0A500);

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _concoursController.dispose();
    _anneeController.dispose();
    super.dispose();
  }

  Future<void> _selectionnerPdf({required bool estCorrige}) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        allowMultiple: false,
        withData: true,
      );

      if (!mounted || result == null || result.files.isEmpty) {
        return;
      }

      final fichier = result.files.single;

      if (fichier.size > 10 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Le fichier ne doit pas depasser 10 Mo.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        if (estCorrige) {
          _fichierCorrige = fichier;
        } else {
          _fichierSujet = fichier;
        }
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de selectionner le fichier : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _retirerPdf({required bool estCorrige}) {
    setState(() {
      if (estCorrige) {
        _fichierCorrige = null;
      } else {
        _fichierSujet = null;
      }
    });
  }

  Future<void> _soumettreFormulaire() async {
  FocusScope.of(context).unfocus();

  if (_isLoading) return;

  if (!_formKey.currentState!.validate()) {
    return;
  }

  if (_matiereSelectionnee == null ||
      _matiereSelectionnee!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Veuillez selectionner une matiere.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  if (!widget.isEditing && _fichierSujet == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Veuillez sélectionner le PDF du sujet.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    if (widget.isEditing) {
      await _sujetRepository.updateSujet(
        id: widget.id!,
        titre: _titreController.text.trim(),
        description: _descriptionController.text.trim(),
        matiereId: _matiereSelectionnee!,
        concours: _concoursController.text.trim(),
        anneeAcademique: _anneeController.text.trim(),
        fichier: _fichierSujet,
        corrige: _fichierCorrige,
      );
          } else {
      await _sujetRepository.createSujet(
        titre: _titreController.text.trim(),
        description: _descriptionController.text.trim(),
        matiereId: _matiereSelectionnee!,
        concours: _concoursController.text.trim(),
        anneeAcademique: _anneeController.text.trim(),
        fichier: _fichierSujet!,
        corrige: _fichierCorrige,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEditing
              ? 'Sujet modifié avec succès !'
              : 'Sujet ajouté avec succès !',
        ),
        backgroundColor: Colors.green,
      ),
    );

  context.pop(true);
  } catch (e) {
    if (!mounted) return;

    final message = e.toString().replaceFirst('Exception: ', '');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Fchec de l'enenregistrement : $message"),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xFF081B32)
        : const Color(0xFFF5F5F5);

    final cardColor = isDark
        ? const Color(0xFF102542)
        : Colors.white;

    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);

    final secondaryColor = isDark
        ? Colors.white70
        : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Ajouter un sujet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _primaryColor.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: _accentColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informations du sujet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Renseignez les informations du concours.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildLabel('Titre du sujet *', textColor),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titreController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _inputDecoration(
                        hint: 'Ex. : Ã‰preuve de mathÃ©matiques 2026',
                        icon: Icons.title_rounded,
                        isDark: isDark,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le titre est obligatoire.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildLabel('Description *', textColor),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      minLines: 3,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _inputDecoration(
                        hint: 'DÃ©crivez briÃ¨vement le sujet...',
                        icon: Icons.description_outlined,
                        isDark: isDark,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La description est obligatoire.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildLabel('MatiÃ¨re *', textColor),
                    const SizedBox(height: 8),
                    
                    if (_chargementMatieres)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_erreurMatieres != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _erreurMatieres!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _chargementMatieres = true;
                                _erreurMatieres = null;
                              });
                              _chargerMatieres();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('RÃ©essayer'),
                          ),
                        ],
                      )
                    else if (_matieres.isEmpty)
                      const Text(
                        'Aucune matiÃ¨re disponible.',
                        style: TextStyle(color: Colors.orange),
                      )
                    else
                      DropdownButtonFormField<String>(
                        initialValue: _matiereSelectionnee,
                        isExpanded: true,
                        decoration: _inputDecoration(
                          hint: 'SÃ©lectionner une matiÃ¨re',
                          icon: Icons.school_outlined,
                          isDark: isDark,
                        ),
                        items: _matieres.map((matiere) {
                          return DropdownMenuItem<String>(
                            value: matiere.id,
                            child: Text(matiere.nom),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _matiereSelectionnee = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sÃ©lectionner une matiÃ¨re.';
                          }
                          return null;
                        },
                      ),

                    const SizedBox(height: 20),

                    _buildLabel('Concours *', textColor),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _concoursController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(
                        hint: 'Ex. : ENS, ENSET, Polytechnique',
                        icon: Icons.emoji_events_outlined,
                        isDark: isDark,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le concours est obligatoire.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildLabel('AnnÃ©e acadÃ©mique *', textColor),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _anneeController,
                      decoration: _inputDecoration(
                        hint: 'Ex. : 2025-2026',
                        icon: Icons.calendar_month_outlined,
                        isDark: isDark,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lâ€™annÃ©e acadÃ©mique est obligatoire.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _primaryColor.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Documents PDF',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Format PDF uniquement, 10 Mo maximum par fichier.',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('Sujet du concours *', textColor),
                    const SizedBox(height: 8),
                    _buildPdfPicker(
                      fichier: _fichierSujet,
                      estCorrige: false,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 20),

                    _buildLabel('CorrigÃ© (facultatif)', textColor),
                    const SizedBox(height: 8),
                    _buildPdfPicker(
                      fichier: _fichierCorrige,
                      estCorrige: true,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _soumettreFormulaire,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text(
                    'Enregistrer le sujet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: Text(
                  '* Champs obligatoires',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required bool isDark,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? Colors.white38 : Colors.grey.shade500,
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        color: _primaryColor,
        size: 21,
      ),
      filled: true,
      fillColor: isDark
          ? const Color(0xFF081B32)
          : const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _primaryColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildPdfPicker({
    required PlatformFile? fichier,
    required bool estCorrige,
    required bool isDark,
  }) {
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);

    if (fichier != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _accentColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _accentColor.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.picture_as_pdf_rounded,
              color: Colors.red,
              size: 30,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fichier.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(fichier.size / (1024 * 1024)).toStringAsFixed(2)} Mo',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Retirer le fichier',
              onPressed: () => _retirerPdf(estCorrige: estCorrige),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
              ),
            ),
          ],
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: () => _selectionnerPdf(estCorrige: estCorrige),
      icon: const Icon(
        Icons.upload_file_rounded,
        color: _accentColor,
      ),
      label: Text(
        estCorrige ? 'Ajouter le corrigÃ© PDF' : 'Choisir le sujet PDF',
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor,
        minimumSize: const Size(double.infinity, 52),
        alignment: Alignment.centerLeft,
        side: BorderSide(
          color: isDark ? Colors.white24 : Colors.grey.shade300,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  @override
  void initState() {
    super.initState();

    _titreController.text = widget.titre ?? '';
    _descriptionController.text = widget.description ?? '';
    _concoursController.text = widget.concours ?? '';
    _anneeController.text = widget.anneeAcademique ?? '';

    _chargerMatieres();
  }

  Future<void> _chargerMatieres() async {
    try {
      final matieres = await _matiereRepository.getMatieres();

      if (!mounted) return;

      setState(() {
      _matieres = matieres;

      final matiereExiste = matieres.any(
        (matiere) => matiere.id == widget.matiereId,
      );

      _matiereSelectionnee = matiereExiste ? widget.matiereId : null;

      _chargementMatieres = false;
      _erreurMatieres = null;
    });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _chargementMatieres = false;
        _erreurMatieres = 'Impossible de charger les matiÃ¨res.';
      });
    }
  }
}
