import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';

class CorrigeDetailView extends StatelessWidget {
  final String id;
  final String titre;
  final String sousTitre;
  final String matiere;
  final String concours;
  final String annee;
  final String? nomFichier;

  const CorrigeDetailView({
    super.key,
    required this.id,
    required this.titre,
    required this.sousTitre,
    required this.matiere,
    required this.concours,
    required this.annee,
    this.nomFichier,
  });

  // ============================================================
  // CHARTE GRAPHIQUE ELITE-PREPA
  // ============================================================

  static const Color primaryColor = Color(0xFF1F3F6E);
  static const Color accentColor = Color(0xFFF0A500);

  static const Color lightBackground = Color(0xFFF5F7FB);
  static const Color darkBackground = Color(0xFF081B32);

  static const Color darkCard = Color(0xFF0F233F);
  static const Color lightText = Color(0xFF202B3C);

  static const Color lightBadge = Color(0xFFEEF3F9);
  static const Color darkBadge = Color(0xFF183454);

  static const Color lightBorder = Color(0xFFE5EAF1);

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
        isDark ? darkBackground : lightBackground;

    final cardColor =
        isDark ? darkCard : Colors.white;

    final textColor =
        isDark ? Colors.white : lightText;

    final secondaryTextColor =
        isDark ? Colors.white70 : Colors.black54;

    final borderColor =
        isDark ? Colors.white10 : lightBorder;

    final fichier = nomFichier?.trim() ?? '';
    final hasFile = fichier.isNotEmpty;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 12,
        leading: IconButton(
          tooltip: 'Retour',
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: accentColor,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détail du corrigé',
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
              // ==================================================
              // EN-TÊTE DU CORRIGÉ
              // ==================================================

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: accentColor,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(7),
                                ),
                                child: const Text(
                                  'CORRIGÉ',
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.7,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                titre,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBadge(
                          icon: Icons.school_outlined,
                          label: matiere,
                          isDark: isDark,
                        ),
                        _buildBadge(
                          icon: Icons.emoji_events_outlined,
                          label: concours,
                          isDark: isDark,
                        ),
                        _buildBadge(
                          icon: Icons.calendar_month_outlined,
                          label: annee,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // INFORMATIONS GÉNÉRALES
              // ==================================================

              _buildSection(
                title: 'Informations générales',
                icon: Icons.info_outline_rounded,
                cardColor: cardColor,
                textColor: textColor,
                borderColor: borderColor,
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
                    'Concours',
                    concours,
                    textColor,
                    secondaryTextColor,
                  ),
                  _buildInfoRow(
                    'Année académique',
                    annee,
                    textColor,
                    secondaryTextColor,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==================================================
              // DESCRIPTION
              // ==================================================

              _buildSection(
                title: 'Description',
                icon: Icons.description_outlined,
                cardColor: cardColor,
                textColor: textColor,
                borderColor: borderColor,
                children: [
                  Text(
                    sousTitre.trim().isEmpty
                        ? 'Aucune description disponible pour ce corrigé.'
                        : sousTitre,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==================================================
              // DOCUMENT ASSOCIÉ
              // ==================================================

              _buildSection(
                title: 'Document associé',
                icon: Icons.picture_as_pdf_outlined,
                cardColor: cardColor,
                textColor: textColor,
                borderColor: borderColor,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? darkBackground
                          : lightBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(
                              alpha: 0.10,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf_rounded,
                            color: Colors.redAccent,
                            size: 29,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasFile
                                    ? fichier
                                    : 'Aucun fichier renseigné',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                hasFile
                                    ? 'Document de correction'
                                    : 'Le fichier PDF n’est pas renseigné.',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: hasFile
                          ? () {
                              context.push(
                                AppRoutes.telechargerCorrige,
                                extra: {
                                  'id': id,
                                  'titre': titre,
                                  'sousTitre': sousTitre,
                                  'matiere': matiere,
                                  'concours': concours,
                                  'annee': annee,
                                  'nomFichier': fichier,
                                  'type': 'corrige',
                                },
                              );
                            }
                          : null,
                      icon: const Icon(
                        Icons.download_rounded,
                      ),
                      label: const Text(
                        'Télécharger le corrigé',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor:  const Color.fromARGB(255, 249, 249, 248),
                        disabledBackgroundColor:
                            isDark
                                ? Colors.white12
                                : Colors.black12,
                        disabledForegroundColor:
                            secondaryTextColor,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  if (!hasFile) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Le téléchargement sera disponible lorsque '
                      'le fichier du corrigé sera renseigné.',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BADGES
  // ============================================================

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    final cleanLabel =
        label.trim().isEmpty ? 'Non renseigné' : label.trim();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? darkBadge : lightBadge,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: accentColor,
          ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              cleanLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARTES DE SECTION
  // ============================================================

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color cardColor,
    required Color textColor,
    required Color borderColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: accentColor,
                size: 21,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
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

  // ============================================================
  // LIGNES D'INFORMATIONS
  // ============================================================

  Widget _buildInfoRow(
    String label,
    String value,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final cleanValue =
        value.trim().isEmpty ? 'Non renseigné' : value.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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
              cleanValue,
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
