import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/storage/token_storage.dart';
import '../models/sujet.dart';
import '../viewmodels/sujet_viewmodel.dart';

class SujetDetailView extends StatefulWidget {
  final String id;
  final bool hasCorrige;

  const SujetDetailView({
    super.key,
    required this.id,
    this.hasCorrige = false,
  });

  @override
  State<SujetDetailView> createState() => _SujetDetailViewState();
}

class _SujetDetailViewState extends State<SujetDetailView> {
  static const Color primaryNavy = Color(0xFF1F3F6E);
  static const Color darkBg = Color(0xFF081B32);
  static const Color darkCardBg = Color(0xFF0F233F);
  static const Color lightBg = Color(0xFFF5F7FB);
  static const Color accentColor = Color(0xFFF0A500);
  static const Color successGreen = Color(0xFF28A745);

  int _currentIndex = 2;

  final SujetViewModel _viewModel = SujetViewModel();
  late Future<Sujet> _sujetFuture;

  @override
  void initState() {
    super.initState();
    _sujetFuture = _viewModel.loadSujetById(widget.id);
  }

  void _onNavigationSelected(int index) {
    if (index == _currentIndex) return;

    switch (index) {
      case 0:
        context.go(AppRoutes.ressourcesDashboard);
        break;
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La section Révisions sera disponible prochainement.'),
          ),
        );
        break;
      case 2:
        context.go(AppRoutes.sujetsConcours);
        break;
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La section Profil sera disponible prochainement.'),
          ),
        );
        break;
    }
  }

  Future<void> _telechargerSujet(Sujet sujet) async {
    final token = await TokenStorage().getAccessToken();
    if (!mounted) return;

    context.push(
      AppRoutes.telechargerCorrige,
      extra: {
        'id': sujet.id,
        'titre': sujet.titre,
        'sousTitre': sujet.description,
        'matiere': sujet.matiereNom,
        'concours': sujet.concours,
        'annee': sujet.anneeAcademique,
        'nomFichier': sujet.fichier.split('/').last,
        'token': token?.trim(),
        'type': 'sujet',
      },
    );
  }

  Future<void> _telechargerCorrige(Sujet sujet) async {
    final token = await TokenStorage().getAccessToken();
    if (!mounted) return;

    context.push(
      AppRoutes.telechargerCorrige,
      extra: {
        'id': sujet.id,
        'titre': sujet.titre,
        'sousTitre': sujet.description,
        'matiere': sujet.matiereNom,
        'concours': sujet.concours,
        'annee': sujet.anneeAcademique,
        'nomFichier': sujet.corrige?.split('/').last,
        'token': token?.trim(),
        'type': 'corrige',
      },
    );
  }

  void _ajouterCorrige(Sujet sujet) {
    context.push(
      AppRoutes.addEditCorrige,
      extra: {
        'titre': sujet.titre,
        'sousTitre': sujet.description,
        'matiere': sujet.matiereNom,
        'concours': sujet.concours,
        'annee': sujet.anneeAcademique,
      },
    );
  }

  void _consulterCorrige(Sujet sujet) {
    context.push(
      AppRoutes.corrigeDetail,
      extra: {
        'id': sujet.id,
        'titre': sujet.titre,
        'sousTitre': sujet.description,
        'matiere': sujet.matiereNom,
        'concours': sujet.concours,
        'annee': sujet.anneeAcademique,
        'nomFichier': sujet.corrige?.split('/').last,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? darkBg : lightBg;
    final cardColor = isDark ? darkCardBg : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF202B3C);
    final secondaryColor = isDark ? Colors.white70 : Colors.black54;
    final softColor = isDark
        ? const Color(0xFF183454)
        : const Color(0xFFEEF3F9);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          tooltip: 'Retour',
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: accentColor,
            size: 19,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détail du sujet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Ressources · Elite-Prepa',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<Sujet>(
          future: _sujetFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: accentColor),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Impossible de charger les détails du sujet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textColor),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            _sujetFuture =
                                _viewModel.loadSujetById(widget.id);
                          });
                        },
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final sujet = snapshot.data!;
            final hasCorrige = sujet.aCorrige;
            final fileName = sujet.fichier.trim().isEmpty
                ? 'Fichier PDF'
                : sujet.fichier.split('/').last;

            return RefreshIndicator(
              color: accentColor,
              onRefresh: () async {
                final future = _viewModel.loadSujetById(widget.id);
                setState(() => _sujetFuture = future);
                await future;
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                children: [
                  // En-tête du sujet
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1F3F6E),
                          Color(0xFF163052),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 15,
                                color: accentColor,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'SUJET DE CONCOURS',
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          sujet.titre.isNotEmpty
                              ? sujet.titre
                              : 'Sujet sans titre',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            height: 1.3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildHeaderTag(
                              Icons.menu_book_outlined,
                              sujet.matiereNom.isNotEmpty
                                  ? sujet.matiereNom
                                  : 'Matière non renseignée',
                            ),
                            _buildHeaderTag(
                              Icons.emoji_events_outlined,
                              sujet.concours.isNotEmpty
                                  ? sujet.concours
                                  : 'Concours non renseigné',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildSectionTitle(
                    'Informations générales',
                    Icons.info_outline,
                    textColor,
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(cardColor, isDark),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.menu_book_outlined,
                          label: 'Matière',
                          value: sujet.matiereNom.isNotEmpty
                              ? sujet.matiereNom
                              : 'Non renseignée',
                          textColor: textColor,
                          secondaryColor: secondaryColor,
                          softColor: softColor,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          icon: Icons.emoji_events_outlined,
                          label: 'Concours',
                          value: sujet.concours.isNotEmpty
                              ? sujet.concours
                              : 'Non renseigné',
                          textColor: textColor,
                          secondaryColor: secondaryColor,
                          softColor: softColor,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Année académique',
                          value: sujet.anneeAcademique.isNotEmpty
                              ? sujet.anneeAcademique
                              : 'Non renseignée',
                          textColor: textColor,
                          secondaryColor: secondaryColor,
                          softColor: softColor,
                        ),
                      ],
                    ),
                  ),

                  if (sujet.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildSectionTitle(
                      'Description',
                      Icons.subject_outlined,
                      textColor,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: _cardDecoration(cardColor, isDark),
                      child: Text(
                        sujet.description,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  _buildSectionTitle(
                    'Document du sujet',
                    Icons.picture_as_pdf_outlined,
                    textColor,
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(cardColor, isDark),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 52,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf_outlined,
                            color: accentColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Document PDF',
                                style: TextStyle(
                                  color: secondaryColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _telechargerSujet(sujet),
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Télécharger le sujet'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryNavy,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle(
                    'Corrigé associé',
                    Icons.fact_check_outlined,
                    textColor,
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(cardColor, isDark),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: (hasCorrige
                                        ? successGreen
                                        : accentColor)
                                    .withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                hasCorrige
                                    ? Icons.check_circle_outline
                                    : Icons.pending_outlined,
                                color: hasCorrige
                                    ? successGreen
                                    : accentColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hasCorrige
                                        ? 'Corrigé disponible'
                                        : 'Aucun corrigé associé',
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    hasCorrige
                                        ? 'Le corrigé est associé à ce sujet.'
                                        : 'Le corrigé de ce sujet n’est pas encore disponible.',
                                    style: TextStyle(
                                      color: secondaryColor,
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (hasCorrige) ...[
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _consulterCorrige(sujet),
                              icon: const Icon(Icons.visibility_outlined),
                              label: const Text('Consulter le corrigé'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: accentColor,
                                side: const BorderSide(
                                  color: accentColor,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: () => _telechargerCorrige(sujet),
                              icon: const Icon(Icons.download_outlined),
                              label: const Text('Télécharger le corrigé'),
                              style: TextButton.styleFrom(
                                foregroundColor: textColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ] else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _ajouterCorrige(sujet),
                              icon: const Icon(Icons.add),
                              label: const Text('Ajouter un corrigé'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.black87,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
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
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavigationSelected,
        backgroundColor: isDark ? darkBg : Colors.white,
        indicatorColor: accentColor.withValues(alpha: 0.18),
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

  Widget _buildHeaderTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accentColor, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    IconData icon,
    Color textColor,
  ) {
    return Row(
      children: [
        Icon(icon, color: accentColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration(Color cardColor, bool isDark) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: isDark ? Colors.white10 : const Color(0xFFE5EAF1),
      ),
      boxShadow: [
        if (!isDark)
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color textColor,
    required Color secondaryColor,
    required Color softColor,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: softColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accentColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: secondaryColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
