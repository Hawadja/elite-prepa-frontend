import 'package:flutter/material.dart';

class AddFicheView extends StatefulWidget {
  const AddFicheView({super.key});

  @override
  State<AddFicheView> createState() => _AddFicheViewState();
}

class _AddFicheViewState extends State<AddFicheView> {
  // Couleurs de la charte
  static const Color darkBg = Color(0xFF091629);
  static const Color darkCardBg = Color(0xFF102542);
  static const Color lightBg = Color(0xFFF6F8FB);
  static const Color accentBlue = Color(0xFF1A56A6);
  static const Color primaryNavy = Color(0xFF163C6E);
  static const Color deleteRed = Color(0xFFD9534F);

  int _currentIndex = 1; // Onglet "Révisions"

  // État du fichier sélectionné
  String? _fileName = 'limites_continuite.pdf';
  String? _fileSize = '2,4 Mo';
  bool _isUploading = false;

  void _pickFile() {
    // Simuler le choix d'un fichier via file_picker
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? darkBg : lightBg;
    final cardFillColor = isDark ? darkCardBg : Colors.white;
    final uploadBoxBg = isDark ? const Color(0xFF0D1F38) : const Color(0xFFEEF3F8);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

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
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: Text(
              'E',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? accentBlue : primaryNavy,
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ajouter une fiche',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              isDark ? 'Ressources • Dark Mode' : 'Ressources • Light Mode',
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardFillColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête de la zone d'upload
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'UPLOAD ZONE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      '20 Mo maximum',
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Zone de dépôt
                InkWell(
                  onTap: _pickFile,
                  borderRadius: BorderRadius.circular(10),
                  child: CustomPaint(
                    painter: _DottedBorderPainter(
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      decoration: BoxDecoration(
                        color: uploadBoxBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.upload_outlined,
                            size: 32,
                            color: isDark ? accentBlue : primaryNavy,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Déposer un fichier PDF',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ou cliquez pour sélectionner',
                            style: TextStyle(
                              fontSize: 12,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Fichier Sélectionné (si présent)
                if (_fileName != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF091629) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icône document
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? darkCardBg : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.description_outlined,
                            size: 22,
                            color: isDark ? accentBlue : primaryNavy,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Nom + Taille du fichier
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

                        // Bouton Remplacer
                        OutlinedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.refresh, size: 14),
                          label: const Text('Remplacer', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? accentBlue : primaryNavy,
                            side: BorderSide(
                              color: (isDark ? accentBlue : primaryNavy).withOpacity(0.5),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Bouton Supprimer
                        IconButton(
                          onPressed: _removeFile,
                          icon: const Icon(Icons.delete_outline, size: 20, color: deleteRed),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Supprimer',
                        ),
                      ],
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
}

// Custom Painter pour dessiner la bordure en pointillés autour de la zone d'upload
class _DottedBorderPainter extends CustomPainter {
  final Color color;

  _DottedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(10),
      ));

    for (final pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}