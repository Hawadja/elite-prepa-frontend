import 'package:flutter/material.dart';

class AddFicheView extends StatefulWidget {
  const AddFicheView({super.key});

  @override
  State<AddFicheView> createState() => _AddFicheViewState();
}

class _AddFicheViewState extends State<AddFicheView> {
  // ============================================================
  // CHARTE GRAPHIQUE ELITE-PREPA
  // ============================================================

  static const Color primaryColor = Color(0xFF1F3F6E);
  static const Color accentColor = Color(0xFFF0A500);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color deleteRed = Color(0xFFD9534F);

  int _currentIndex = 1;

  // ============================================================
  // FICHIER
  // ============================================================

  String? _fileName = 'limites_continuite.pdf';
  String? _fileSize = '2,4 Mo';

  bool _isUploading = false;

  // ============================================================
  // SÉLECTION DU FICHIER
  // ============================================================

  void _pickFile() {
    // Simulation temporaire.
    // Plus tard : file_picker.
    setState(() {
      _fileName = 'limites_continuite.pdf';
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

    final uploadBoxColor =
        isDark ? const Color(0xFF162A43) : const Color(0xFFEEF3F8);

    final textColor =
        isDark ? Colors.white : const Color(0xFF1F2937);

    final secondaryTextColor =
        isDark ? Colors.white70 : const Color(0xFF64748B);

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
              'Ajouter une fiche',
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
                'Ajouter une fiche de cours',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Importez le document PDF de la fiche de cours.',
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                ),
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------
              // CARTE UPLOAD
              // ------------------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white12
                        : Colors.black12,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // En-tête
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'FICHIER PDF',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          '20 Mo maximum',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ------------------------------------------------
                    // ZONE D'UPLOAD
                    // ------------------------------------------------

                    InkWell(
                      onTap: _isUploading ? null : _pickFile,
                      borderRadius: BorderRadius.circular(12),
                      child: CustomPaint(
                        painter: _DottedBorderPainter(
                          color: isDark
                              ? Colors.white24
                              : primaryColor.withValues(
                                  alpha: 0.35,
                                ),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 30,
                          ),
                          decoration: BoxDecoration(
                            color: uploadBoxColor,
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [

                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(
                                    alpha: 0.10,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.picture_as_pdf_outlined,
                                  size: 28,
                                  color: primaryColor,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                'Déposer un fichier PDF',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                'ou cliquez pour sélectionner',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ------------------------------------------------
                    // FICHIER SÉLECTIONNÉ
                    // ------------------------------------------------

                    if (_fileName != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF162A43)
                              : const Color(0xFFF8FAFC),
                          borderRadius:
                              BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? Colors.white10
                                : Colors.black12,
                          ),
                        ),
                        child: Row(
                          children: [

                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: deleteRed.withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.picture_as_pdf,
                                color: deleteRed,
                                size: 22,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _fileName!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight:
                                          FontWeight.bold,
                                      color: textColor,
                                    ),
                                    overflow:
                                        TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _fileSize ?? '',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Remplacer
                            IconButton(
                              onPressed: _isUploading
                                  ? null
                                  : _pickFile,
                              icon: Icon(
                                Icons.refresh,
                                color: primaryColor,
                                size: 20,
                              ),
                              tooltip: 'Remplacer',
                            ),

                            // Supprimer
                            IconButton(
                              onPressed: _isUploading
                                  ? null
                                  : _removeFile,
                              icon: const Icon(
                                Icons.delete_outline,
                                color: deleteRed,
                                size: 20,
                              ),
                              tooltip: 'Supprimer',
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------
              // BOUTON AJOUTER
              // ------------------------------------------------

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed:
                      _fileName == null || _isUploading
                          ? null
                          : () {
                              setState(() {
                                _isUploading = true;
                              });
                            },
                  icon: const Icon(
                    Icons.add,
                    size: 20,
                  ),
                  label: const Text(
                    'Ajouter la fiche',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
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

// ============================================================
// BORDERURE EN POINTILLÉS
// ============================================================

class _DottedBorderPainter extends CustomPainter {
  final Color color;

  _DottedBorderPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 3.0;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            0,
            0,
            size.width,
            size.height,
          ),
          const Radius.circular(12),
        ),
      );

    for (final pathMetric in path.computeMetrics()) {
      double distance = 0;

      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(
            distance,
            distance + dashWidth,
          ),
          paint,
        );

        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}