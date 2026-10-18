import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../models/matiere.dart';
import '../models/fiche_cours.dart';
import '../models/sujet.dart';
import '../repositories/matiere_repository.dart';
import '../repositories/fiche_cours_repository.dart';
import '../repositories/sujet_repository.dart';

class MatiereDetailView extends StatefulWidget {
  final Matiere matiere;

  const MatiereDetailView({
    super.key,
    required this.matiere,
  });

  @override
  State<MatiereDetailView> createState() => _MatiereDetailViewState();
}

class _MatiereDetailViewState extends State<MatiereDetailView> {
  int _selectedTabIndex = 0;
  int _currentIndex = 1;
  static const Color accentColor = Color(0xFFF0A500);

  bool _chargement = true;
  String? _erreur;
  List<FicheCours> _fiches = [];
  List<Sujet> _sujets = [];

  bool get _afficherFiches => _selectedTabIndex == 0;

  @override
  void initState() {
    super.initState();
    _chargerRessources();
  }

  Future<void> _chargerRessources() async {
    if (mounted) {
      setState(() {
        _chargement = true;
        _erreur = null;
      });
    }

    try {
      final resultats = await Future.wait<dynamic>([
        FicheCoursRepository().getFichesCours(
          matiere: widget.matiere.id,
          page: 1,
          limit: 100,
        ),
        SujetRepository().getSujetsPage(
          matiere: widget.matiere.id,
          page: 1,
          limit: 100,
        ),
      ]);

      final fichesResultat =
          resultats[0] as Map<String, dynamic>;
      final sujetsResultat = resultats[1] as SujetsPage;

      final fiches = (fichesResultat['data'] as List)
          .cast<FicheCours>();

      if (!mounted) return;

      setState(() {
        _fiches = fiches;
        _sujets = sujetsResultat.items;
        _chargement = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _chargement = false;
        _erreur = 'Impossible de charger les ressources. '
            'Vérifiez la connexion au serveur.';
      });
    }
  }

  Future<void> _ajouterFiche() async {
    final result = await context.push(
      AppRoutes.addEditFiche,
      extra: {
        'matiere': widget.matiere.nom,
        'matiereId': widget.matiere.id,
      },
    );

    if (!mounted) return;

    if (result == true) {
      await _chargerRessources();
    }
  }

  Future<void> _ajouterSujet() async {
    final result = await context.push(
      AppRoutes.addEditSujet,
      extra: {
        'matiereId': widget.matiere.id,
      },
    );

    if (!mounted) return;

    if (result == true) {
      await _chargerRessources();
    }
  }

  Future<void> _modifierFiche(FicheCours fiche) async {
    final result = await context.push(
      AppRoutes.addEditFiche,
      extra: {
        'id': fiche.id,
        'titre': fiche.titre,
        'matiere': widget.matiere.nom,
        'matiereId': widget.matiere.id,
        'description': fiche.description,
        'nomFichier': fiche.fichier.split('/').last,
      },
    );

    if (!mounted) return;

    if (result == true) {
      await _chargerRessources();
    }
  }

  Future<void> _modifierSujet(Sujet sujet) async {
    final result = await context.push(
      AppRoutes.addEditSujet,
      extra: {
        'id': sujet.id,
        'titre': sujet.titre,
        'matiereId': widget.matiere.id,
        'description': sujet.description,
        'concours': sujet.concours,
        'anneeAcademique': sujet.anneeAcademique,
        'nomFichier': sujet.fichier.split('/').last,
      },
    );

    if (!mounted) return;

    if (result == true) {
      await _chargerRessources();
    }
  }

  Future<void> _supprimerRessource({
    required String id,
    required String titre,
    required bool estFiche,
  }) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer "$titre" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmation != true || !mounted) return;

    try {
      final token = await TokenStorage().getAccessToken();

      if (token == null || token.trim().isEmpty) {
        throw Exception('Session expirée. Reconnectez-vous.');
      }

      if (estFiche) {
        await FicheCoursRepository().deleteFicheCours(
          id,
          token: token.trim(),
        );
      } else {
        await SujetRepository().deleteSujet(id);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ressource supprimée avec succès.'),
          backgroundColor: Colors.green,
        ),
      );

      await _chargerRessources();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Suppression impossible : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _modifierMatiere() async {
    final result = await context.push(
      AppRoutes.addEditMatiere,
      extra: widget.matiere,
    );

    if (!mounted) return;

    if (result == true) {
      context.pop(true);
    }
  }

  Future<void> _supprimerMatiere() async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer la matière'),
        content: Text(
          'Voulez-vous vraiment supprimer "${widget.matiere.nom}" ? '
          'Cette action peut être refusée si des ressources y sont liées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmation != true || !mounted) return;

    try {
      final token = await TokenStorage().getAccessToken();

      if (token == null || token.trim().isEmpty) {
        throw Exception('Session expirée. Reconnectez-vous.');
      }

      await MatiereRepository().deleteMatiere(
        widget.matiere.id,
        token: token.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Matière supprimée avec succès.'),
          backgroundColor: Colors.green,
        ),
      );

      context.pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Suppression impossible : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _ouvrirFiche(FicheCours fiche) async {
    await context.push(
      AppRoutes.ficheDetail,
      extra: {
        'id': fiche.id,
        'titre': fiche.titre,
        'matiere': widget.matiere.nom,
        'description': fiche.description,
        'format': 'PDF',
        'taille': '',
        'nomFichier': fiche.fichier.split('/').last,
      },
    );
  }

  Future<void> _ouvrirSujet(Sujet sujet) async {
    await context.push(
      AppRoutes.sujetDetail,
      extra: {
        'id': sujet.id,
        'hasCorrige': sujet.aCorrige,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final cardColor =
        isDark ? AppColors.cardDark : AppColors.cardLight;
    final textColor = isDark ? Colors.white : Colors.black87;

    final nombreRessources =
        _afficherFiches ? _fiches.length : _sujets.length;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.matiere.nom,
              style: const TextStyle(
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
      body: RefreshIndicator(
        onRefresh: _chargerRessources,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 14,
                    ),
                    label: const Text('Retour aux matières'),
                    style: TextButton.styleFrom(
                      foregroundColor: accentColor,
                    ),
                  ),
                ),
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  color: isDark ? Colors.white12 : Colors.grey.shade200,
                  iconColor: accentColor,
                  onTap: _modifierMatiere,
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.delete_outline,
                  color: isDark ? Colors.white12 : Colors.grey.shade200,
                  iconColor: Colors.redAccent,
                  onTap: _supprimerMatiere,
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.add,
                  color: AppColors.primaryBlue,
                  iconColor: accentColor,
                  onTap: _afficherFiches ? _ajouterFiche : _ajouterSujet,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
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
                    widget.matiere.nom,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.matiere.code} • ${widget.matiere.description}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Fiches de cours',
                          _chargement ? '…' : '${_fiches.length}',
                          textColor,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Sujets',
                          _chargement ? '…' : '${_sujets.length}',
                          textColor,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Ressources',
                          _chargement
                              ? '…'
                              : '${_fiches.length + _sujets.length}',
                          textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildTab(
                    title: 'Fiches de cours',
                    selected: _selectedTabIndex == 0,
                    cardColor: cardColor,
                    textColor: textColor,
                    onTap: () => setState(() => _selectedTabIndex = 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTab(
                    title: 'Sujets',
                    selected: _selectedTabIndex == 1,
                    cardColor: cardColor,
                    textColor: textColor,
                    onTap: () => setState(() => _selectedTabIndex = 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_chargement)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_erreur != null)
              _buildMessage(
                message: _erreur!,
                icon: Icons.cloud_off_outlined,
                textColor: textColor,
                action: TextButton.icon(
                  onPressed: _chargerRessources,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              )
            else if (nombreRessources == 0)
              _buildMessage(
                message: _afficherFiches
                    ? 'Aucune fiche de cours pour cette matière.'
                    : 'Aucun sujet de concours pour cette matière.',
                icon: Icons.folder_open_outlined,
                textColor: textColor,
                action: ElevatedButton.icon(
                  onPressed:
                      _afficherFiches ? _ajouterFiche : _ajouterSujet,
                  icon: const Icon(Icons.add),
                  label: Text(
                    _afficherFiches ? 'Ajouter une fiche' : 'Ajouter un sujet',
                  ),
                ),
              )
            else
              ..._afficherFiches
                  ? _fiches.map(
                      (fiche) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildRessourceCard(
                          titre: fiche.titre,
                          sousTitre: [
                            widget.matiere.nom,
                            if (fiche.anneeAcademique.isNotEmpty)
                              fiche.anneeAcademique,
                            'PDF',
                          ].join(' • '),
                          cardColor: cardColor,
                          textColor: textColor,
                          isDark: isDark,
                          onOuvrir: () => _ouvrirFiche(fiche),
                          onModifier: () => _modifierFiche(fiche),
                          onSupprimer: () => _supprimerRessource(
                            id: fiche.id,
                            titre: fiche.titre,
                            estFiche: true,
                          ),
                        ),
                      ),
                    )
                  : _sujets.map(
                      (sujet) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildRessourceCard(
                          titre: sujet.titre,
                          sousTitre: [
                            widget.matiere.nom,
                            if (sujet.concours.isNotEmpty) sujet.concours,
                            if (sujet.anneeAcademique.isNotEmpty)
                              sujet.anneeAcademique,
                            sujet.aCorrige ? 'Corrigé disponible' : 'Sans corrigé',
                          ].join(' • '),
                          cardColor: cardColor,
                          textColor: textColor,
                          isDark: isDark,
                          onOuvrir: () => _ouvrirSujet(sujet),
                          onModifier: () => _modifierSujet(sujet),
                          onSupprimer: () => _supprimerRessource(
                            id: sujet.id,
                            titre: sujet.titre,
                            estFiche: false,
                          ),
                        ),
                      ),
                    ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor:
            isDark ? const Color(0xFF081B32) : Colors.white,
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

  Widget _buildTab({
    required String title,
    required bool selected,
    required Color cardColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? AppColors.primaryBlue : cardColor,
        foregroundColor: selected ? Colors.white : textColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: onTap,
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRessourceCard({
    required String titre,
    required String sousTitre,
    required Color cardColor,
    required Color textColor,
    required bool isDark,
    required VoidCallback onOuvrir,
    required VoidCallback onModifier,
    required VoidCallback onSupprimer,
  }) {
    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: ListTile(
        onTap: onOuvrir,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.picture_as_pdf_outlined,
            color: accentColor,
          ),
        ),
        title: Text(
          titre,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            sousTitre,
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'modifier') onModifier();
            if (value == 'supprimer') onSupprimer();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'modifier',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Modifier'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'supprimer',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text('Supprimer'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage({
    required String message,
    required IconData icon,
    required Color textColor,
    required Widget action,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor),
          ),
          const SizedBox(height: 12),
          action,
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
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

