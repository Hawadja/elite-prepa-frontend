import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RessourceCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color cardColor;
  final Color textColor;
  final bool isDark;
  final VoidCallback? onModifier;
  final VoidCallback? onSupprimer;

  const RessourceCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.cardColor,
    required this.textColor,
    required this.isDark,
    this.onModifier,
    this.onSupprimer,
  });

  static const Color accentColor = Color(0xFFF0A500);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône du document
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              color: accentColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          // Titre et informations de la fiche
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 3,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  subtitle,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: isDark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 8),

                // Badge PDF
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'PDF',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 4),

          // Menu des actions
          
          PopupMenuButton<String>(
            tooltip: 'Actions',
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            onSelected: (value) {
              switch (value) {
                case 'modifier':
                  onModifier?.call();
                  break;

                case 'supprimer':
                  onSupprimer?.call();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'modifier',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Colors.black,
                    ),
                    SizedBox(width: 10),
                    Text('Modifier'),
                  ],
                ),
              ),

              const PopupMenuDivider(),

              const PopupMenuItem<String>(
                value: 'supprimer',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Supprimer',
                      style: TextStyle(
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),


        ],
      ),
    );
  }
}

