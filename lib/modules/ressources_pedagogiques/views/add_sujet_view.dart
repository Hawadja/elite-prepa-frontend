import 'package:flutter/material.dart';

class AddSujetView extends StatefulWidget {
  const AddSujetView({super.key});

  @override
  State<AddSujetView> createState() => _AddSujetViewState();
}

class _AddSujetViewState extends State<AddSujetView> {
  // Couleurs de la charte Elite-Prepa
  static const Color primaryNavy = Color(0xFF163C6E);
  static const Color darkBg = Color(0xFF091629);
  static const Color darkCardBg = Color(0xFF102542);
  static const Color lightBg = Color(0xFFF6F8FB);
  static const Color accentBlue = Color(0xFF1A56A6);
  static const Color deleteRed = Color(0xFFD9534F);

  int _currentIndex = 2; // Onglet "Concours"

  // Contrôleurs de formulaire
  final TextEditingController _titreController =
      TextEditingController(text: 'Titre du sujet');
  final TextEditingController _matiereFiliereController =
      TextEditingController(text: 'Mathématiques · MP');
  final TextEditingController _concoursAnneeDureeController =
      TextEditingController(text: 'Mines-Ponts · 2026 · 4 h');

  // État du fichier PDF
  String? _fileName = 'sujet_mines_ponts_2026.pdf';
  String? _fileSize = '2,4 Mo';
  bool _isLoading = false;

  @override
  void dispose() {
    _titreController.dispose();
    _matiereFiliereController.dispose();
    _concoursAnneeDureeController.dispose();
    super.dispose();
  }

  void _pickFile() {
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

  Future<void> _submitSujet() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simuler l'enregistrement via API/Backend
      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sujet de concours ajouté avec succès'),
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
          _isLoading = false;
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
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final fileBoxBg = isDark ? const Color(0xFF0D1F38) : const Color(0xFFEEF3F8);

    return Scaffold(
      backgroundColor: backgroundColor,

      // ============================================================
      // APP BAR
      // ============================================================
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ajouter un sujet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              'Sujets • Elite-Prepa',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: subTextColor,
              ),
            ),
          ],
        ),
      ),

      // ============================================================
      // CONTENU PRINCIPAL
      // ============================================================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. En-tête : Nouveau sujet de concours
              _buildFormSection(
                cardColor: cardFillColor,
                child: Text(
                  'Nouveau sujet de concours',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 2. Champ Titre
              _buildFormSection(
                cardColor: cardFillColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Titre',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _titreController,
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 3. Champ Matière · Filière
              _buildFormSection(
                cardColor: cardFillColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Matière · Filière',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _matiereFiliereController,
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 4. Champ Concours · Année · Durée
              _buildFormSection(
                cardColor: cardFillColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Concours · Année · Durée',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _concoursAnneeDureeController,
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 5. Zone Upload PDF
              _buildFormSection(
                cardColor: cardFillColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload PDF',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_upward,
                          size: 14,
                          color: textColor.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Déposer un sujet · 20 Mo maximum',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Carte d'aperçu du fichier PDF
                    if (_fileName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: fileBoxBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 22,
                              color: isDark ? accentBlue : primaryNavy,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _fileName!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _fileSize ?? '',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: subTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: _pickFile,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Remplacer',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? accentBlue : primaryNavy,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              onPressed: _removeFile,
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: deleteRed,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: 'Supprimer',
                            ),
                          ],
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.upload_file, size: 18),
                        label: const Text('Sélectionner un fichier PDF'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? accentBlue : primaryNavy,
                          side: BorderSide(
                            color: (isDark ? accentBlue : primaryNavy)
                                .withOpacity(0.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 6. Bouton "Ajouter le sujet"
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitSujet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryNavy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),

      // ============================================================
      // NAVIGATION BOTTOM
      // ============================================================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white10 : Colors.black12,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: backgroundColor,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: accentBlue,
          unselectedItemColor: isDark ? Colors.white54 : Colors.grey[600],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: 'Révisions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.square_outlined),
              label: 'Concours',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.circle_outlined),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection({
    required Color cardColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}