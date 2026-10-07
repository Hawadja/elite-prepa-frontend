import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RessourceCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color cardColor;
  final Color textColor;
  final bool isDark;

  const RessourceCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.cardColor,
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
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
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.remove_red_eye_outlined, size: 18, color: AppColors.primaryBlue),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.file_download_outlined, size: 18, color: AppColors.primaryBlue),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryBlue),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.share_outlined, size: 18, color: AppColors.primaryBlue),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}