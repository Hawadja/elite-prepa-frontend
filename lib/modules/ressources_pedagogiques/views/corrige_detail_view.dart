import 'package:flutter/material.dart';

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

final textColor = isDark ? Colors.white : Colors.black87;

final secondaryTextColor =
    isDark ? Colors.white70 : Colors.black54;

final badgeColor = isDark
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
      tooltip: 'Retour',
      icon: const Icon(
        Icons.arrow_back_ios_new,
        size: 20,
      ),
      onPressed: () => Navigator.pop(context),
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
          // En-tête : icône et titre sur la même ligne.
          Container(
            padding: const EdgeInsets.all(12),
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
                        color: accentColor.withValues(
                          alpha: 0.15,
                        ),
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
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
                    color: badgeColor,
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

          // Informations générales.
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
                'Concours',
                concours,
                textColor,
                secondaryTextColor,
              ),
              _buildInfoRow(
                'Année',
                annee,
                textColor,
                secondaryTextColor,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Description du corrigé.
          _buildSection(
            title: 'Description',
            icon: Icons.description_outlined,
            cardColor: cardColor,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            children: [
              Text(
                sousTitre.trim().isEmpty
                    ? 'Aucune description disponible pour ce corrigé.'
                    : sousTitre,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: textColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Document PDF associé.
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
                          nomFichier?.trim().isNotEmpty == true
                              ? nomFichier!
                              : 'Aucun fichier renseigné',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Document de correction',
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
                    Navigator.pushNamed(
                      context,
                      '/telecharger-corrige',
                      arguments: {
                        'id': id,
                        'titre': titre,
                        'sousTitre': sousTitre,
                        'matiere': matiere,
                        'concours': concours,
                        'annee': annee,
                        'nomFichier': nomFichier,
                        'type': 'corrige',
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.download_outlined,
                  ),
                  label: const Text('Télécharger le corrigé'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        isDark ? Colors.white : primaryColor,
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
color: secondaryTextColor.withValues(alpha: 0.2),
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

