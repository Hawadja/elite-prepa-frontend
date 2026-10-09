import 'dart:async';

import 'package:flutter/material.dart';

class TelechargerCorrigeView extends StatefulWidget {
  final String? id;
  final String? titre;
  final String? sousTitre;
  final String? matiere;
  final String? concours;
  final String? annee;
  final String? nomFichier;

  /// Permet d'utiliser cet écran pour un corrigé ou une fiche de cours.
  /// Valeurs attendues : 'corrige' ou 'fiche'.
  final String type;

  const TelechargerCorrigeView({
    super.key,
    this.id,
    this.titre,
    this.sousTitre,
    this.matiere,
    this.concours,
    this.annee,
    this.nomFichier,
    this.type = 'corrige',
  });

  @override
  State<TelechargerCorrigeView> createState() =>
      _TelechargerCorrigeViewState();
}

class _TelechargerCorrigeViewState
    extends State<TelechargerCorrigeView> {
  double _downloadProgress = 0;
  Timer? _timer;
  bool _downloadFinished = false;

  bool get isFiche => widget.type == 'fiche';

  bool get isSujet => widget.type == 'sujet';

  String get resourceName {
    if (isFiche) return 'fiche de cours';
    if (isSujet) return 'sujet de concours';
    return 'corrigé';
  }

  String get resourceNameCapitalized {
    if (isFiche) return 'Fiche de cours';
    if (isSujet) return 'Sujet de concours';
    return 'Corrigé';
  }



  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  void _startDownload() {
    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          _downloadProgress += 0.05;

          if (_downloadProgress >= 1) {
            _downloadProgress = 1;
            _downloadFinished = true;
            timer.cancel();
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor =
        isDark ? const Color(0xFF081B32) : const Color(0xFFF5F5F5);

    final cardColor =
        isDark ? const Color(0xFF102542) : Colors.white;

    final primaryColor = const Color(0xFF1F3F6E);

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: Text(
          'Télécharger $resourceName',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                resourceNameCapitalized,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : primaryColor,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                widget.titre ?? 'Ressource pédagogique',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 20),

              // Informations
              Card(
                color: cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _infoRow(
                        context,
                        Icons.menu_book_outlined,
                        'Matière',
                        widget.matiere ?? 'Non renseignée',
                      ),

                      if (!isFiche) ...[
                        const SizedBox(height: 14),

                        _infoRow(
                          context,
                          Icons.school_outlined,
                          'Concours',
                          widget.concours ?? 'Non renseigné',
                        ),

                        const SizedBox(height: 14),

                        _infoRow(
                          context,
                          Icons.calendar_today_outlined,
                          'Année',
                          widget.annee ?? 'Non renseignée',
                        ),
                      ],

                      const SizedBox(height: 14),

                      _infoRow(
                        context,
                        Icons.picture_as_pdf_outlined,
                        'Fichier',
                        widget.nomFichier ?? 'Document PDF',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Progression
              Card(
                color: cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _downloadFinished
                                ? Icons.check_circle
                                : Icons.download,
                            color: _downloadFinished
                                ? Colors.green
                                : primaryColor,
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              _downloadFinished
                                  ? 'Téléchargement terminé'
                                  : 'Téléchargement en cours...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      LinearProgressIndicator(
                        value: _downloadProgress,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(10),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        '${(_downloadProgress * 100).toInt()} %',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Fichier PDF
              Card(
                color: cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0A500).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf,
                          color: Color(0xFFF0A500),
                          size: 32,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.nomFichier ??
                                  'document.pdf',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Document PDF',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white60
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _downloadFinished
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '$resourceNameCapitalized téléchargé avec succès.',
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.download),
                  label: Text(
                    _downloadFinished
                        ? 'Télécharger $resourceName'
                        : 'Téléchargement...',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
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
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 21,
          color: const Color(0xFFF0A500),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? Colors.white60
                      : Colors.black54,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}





