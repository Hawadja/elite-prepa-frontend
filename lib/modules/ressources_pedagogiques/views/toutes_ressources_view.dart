import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';

class ToutesRessourcesView extends StatelessWidget {
  const ToutesRessourcesView({super.key});

  static const Color primaryColor = Color(0xFF1F3F6E);
  static const Color accentColor = Color(0xFFF0A500);
  static const Color lightBackground = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
        isDark ? Theme.of(context).scaffoldBackgroundColor : lightBackground;

    final textColor = isDark ? Colors.white : const Color(0xFF202124);

    final ressources = <_RessourceItem>[
      _RessourceItem(
        titre: 'Matières',
        description: 'Consulter et gérer les matières',
        icone: Icons.menu_book_rounded,
        route: AppRoutes.matieres,
      ),
      _RessourceItem(
        titre: 'Fiches de cours',
        description: 'Retrouver les fiches de cours disponibles',
        icone: Icons.description_rounded,
        route: AppRoutes.fichesCours,
      ),
      _RessourceItem(
        titre: 'Sujets de concours',
        description: 'Consulter les sujets des différents concours',
        icone: Icons.assignment_rounded,
        route: AppRoutes.sujetsGestion,
      ),
      _RessourceItem(
        titre: 'Corrigés disponibles',
        description: 'Accéder aux corrigés des sujets',
        icone: Icons.picture_as_pdf_rounded,
        route: AppRoutes.corriges,
      ),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Retour',
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: accentColor,
            size: 19,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Toutes les ressources',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Explorez les ressources pédagogiques',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choisissez une catégorie pour accéder aux ressources '
              'correspondantes.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            ...ressources.map(
              (ressource) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _RessourceCard(
                  ressource: ressource,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pushNamed(context, ressource.route);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RessourceItem {
  final String titre;
  final String description;
  final IconData icone;
  final String route;

  const _RessourceItem({
    required this.titre,
    required this.description,
    required this.icone,
    required this.route,
  });
}

class _RessourceCard extends StatelessWidget {
  final _RessourceItem ressource;
  final bool isDark;
  final VoidCallback onTap;

  const _RessourceCard({
    required this.ressource,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: isDark ? const Color(0xFF252525) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0A500).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  ressource.icone,
                  color: const Color(0xFFF0A500),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ressource.titre,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF1F3F6E),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      ressource.description,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
                color: Color(0xFFF0A500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

