import 'package:flutter/material.dart';

class FicheDetailView extends StatelessWidget {
  final String id;
  final String titre;
  final String matiere;
  final String description;
  final String format;
  final String taille;
  final String? nomFichier;

  const FicheDetailView({
    super.key,
    required this.id,
    required this.titre,
    required this.matiere,
    required this.description,
    required this.format,
    required this.taille,
    this.nomFichier,
  });

  static const Color primaryColor = Color(0xFF1F3F6E);
  static const Color accentColor = Color(0xFFF0A500);
  static const Color lightBackground = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xFF081B32)
        : lightBackground;

    final cardColor = isDark
        ? const Color(0xFF0F233F)
        : Colors.white;

    final textColor = isDark
        ? Colors.white
        : Colors.black87;

    final secondaryTextColor = isDark
        ? Colors.white70
        : Colors.black54;

    final buttonBackground = isDark
        ? const Color(0xFF163C6E)
        : const Color(0xFFEEF3F8);

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 12,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
          ),
          tooltip: 'Retour',
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détail de la fiche',
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

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // En-tête de la fiche
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white10
                        : Colors.black12,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.menu_book_outlined,
                            color: accentColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            titre,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: buttonBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        matiere,
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Informations générales
              _buildSection(
                title: 'Informations',
                icon: Icons.info_outline,
                cardColor: cardColor,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
                children: [
                  _buildInfoRow(
                    'Identifiant',
                    id,
                    textColor,
                    secondaryTextColor,
                  ),
                  _buildInfoRow(
                    'Matière',
                    matiere,
                    textColor,
                    secondaryTextColor,
                  ),
                  _buildInfoRow(
                    'Format',
                    format,
                    textColor,
                    secondaryTextColor,
                  ),
                  _buildInfoRow(
                    'Taille du document',
                    taille,
                    textColor,
                    secondaryTextColor,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Description
              _buildSection(
                title: 'Description du cours',
                icon: Icons.description_outlined,
                cardColor: cardColor,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
                children: [
                  Text(
                    description.trim().isEmpty
                        ? 'Aucune description disponible pour cette fiche.'
                        : description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: textColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Document associé
              _buildSection(
                title: 'Document associé',
                icon: Icons.picture_as_pdf_outlined,
                cardColor: cardColor,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.picture_as_pdf,
                        size: 32,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              nomFichier?.isNotEmpty == true
                                  ? nomFichier!
                                  : 'Aucun fichier renseigné',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$format · $taille',
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text(
                                'La consultation du document sera '
                                'connectée au service de fichiers.',
                              ),
                            ),
                          );
                      },
                      icon: const Icon(
                        Icons.visibility_outlined,
                      ),
                      label: const Text('Consulter le document'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? Colors.white
                            : primaryColor,
                        side: const BorderSide(
                          color: primaryColor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color cardColor,
    required Color textColor,
    required Color secondaryTextColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: secondaryTextColor.withValues(
            alpha: 0.2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: primaryColor,
                size: 21,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: secondaryTextColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value.trim().isEmpty ? 'Non renseigné' : value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}