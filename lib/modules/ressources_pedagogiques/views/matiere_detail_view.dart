import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ressource_card_widget.dart';

class MatiereDetailView extends StatefulWidget {
  final String matiereId;
  final String matiereNom;

  const MatiereDetailView({
    super.key,
    required this.matiereId,
    required this.matiereNom,
  });

  @override
  State<MatiereDetailView> createState() => _MatiereDetailViewState();
}

class _MatiereDetailViewState extends State<MatiereDetailView> {
  int _selectedTabIndex = 0; // 0: Fiches de cours, 1: Sujets

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F5F5);
    final cardColor = isDark ? const Color(0xFF1B263B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  widget.matiereNom.trim().isNotEmpty
                      ? widget.matiereNom.trim()[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.matiereNom,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Détail de la matière',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BARRE D'ACTIONS DU HAUT
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios, size: 14, color: AppColors.primaryBlue),
                  label: const Text(
                    'Retour aux matières',
                    style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  color: isDark ? Colors.white12 : Colors.grey.shade200,
                  iconColor: AppColors.primaryBlue,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.delete_outline,
                  color: isDark ? Colors.white12 : Colors.grey.shade200,
                  iconColor: Colors.redAccent,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.add,
                  color: AppColors.primaryBlue,
                  iconColor: Colors.white,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            // CARTE RECAPITULATIVE DE LA MATIERE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.matiereNom,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Matière scientifique • 2 480 ressources',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem('Fiches de cours', '1 240', textColor),
                      _buildStatItem('Sujets', '1 240', textColor),
                      _buildStatItem('Mise à jour', "Aujourd'hui", textColor),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ONGLETS (FICHES DE COURS / SUJETS)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedTabIndex == 0 ? AppColors.primaryBlue : cardColor,
                      foregroundColor: _selectedTabIndex == 0 ? Colors.white : textColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => setState(() => _selectedTabIndex = 0),
                    child: const Text('Fiches de cours', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedTabIndex == 1 ? AppColors.primaryBlue : cardColor,
                      foregroundColor: _selectedTabIndex == 1 ? Colors.white : textColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => setState(() => _selectedTabIndex = 1),
                    child: const Text('Sujets', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // LISTE DES RESSOURCES
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final titles = ['Limites et continuité', 'Fonctions linéaires', 'Suites numériques', 'Intégrales'];
                final sizes = ['2,4 Mo', '1,8 Mo', '3,1 Mo', '2,1 Mo'];

                return RessourceCardWidget(
                  title: titles[index],
                  subtitle: '${widget.matiereNom} • 2026 • PDF • ${sizes[index]}',
                  cardColor: cardColor,
                  textColor: textColor,
                  isDark: isDark,
                );
              },
            ),
          ],
        ),
      ),

      bottomNavigationBar: NavigationBar(
      selectedIndex: 1,
      onDestinationSelected: (index) {
        // Navigation globale à brancher ensuite.
      },
      backgroundColor: isDark
          ? const Color(0xFF081B32)
          : Colors.white,
      indicatorColor: AppColors.accentGold.withValues(alpha: 0.18),
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

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
      ],
    );
  }
}