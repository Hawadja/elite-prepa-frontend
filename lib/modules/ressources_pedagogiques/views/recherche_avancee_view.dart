import 'dart:async';

import 'package:flutter/material.dart';

import '../models/fiche_cours.dart';
import '../models/matiere.dart';
import '../models/sujet.dart';
import '../repositories/fiche_cours_repository.dart';
import '../repositories/matiere_repository.dart';
import '../repositories/sujet_repository.dart';

class ResultatItem {
  final String id;
  final String titre;
  final String sousTitre;
  final bool isCorrige;
  final String type;

  const ResultatItem({
    required this.id,
    required this.titre,
    required this.sousTitre,
    required this.type,
    this.isCorrige = false,
  });
}

class RechercheAvanceeView extends StatefulWidget {
  const RechercheAvanceeView({super.key});

  @override
  State<RechercheAvanceeView> createState() =>
      _RechercheAvanceeViewState();
}

class _RechercheAvanceeViewState
    extends State<RechercheAvanceeView> {
  static const Color primaryNavy = Color(0xFF1F3F6E);
  static const Color accentOrange = Color(0xFFF0A500);
  static const Color darkBg = Color(0xFF081B32);
  static const Color darkCardBg = Color(0xFF0F233F);
  static const Color lightBg = Color(0xFFF5F5F5);
  static const Color successGreen = Color(0xFF28A745);

  static const int _pageSize = 10;

  final FicheCoursRepository _ficheRepository =
      FicheCoursRepository();

  final SujetRepository _sujetRepository = SujetRepository();

  final MatiereRepository _matiereRepository =
      MatiereRepository();

  final TextEditingController _searchController =
      TextEditingController();

  final TextEditingController _concoursController =
      TextEditingController();

  final TextEditingController _anneeController =
      TextEditingController();

  Timer? _debounce;

  int _currentIndex = 1;
  int _currentPage = 1;

  String _selectedType = 'Fiches';
  String? _selectedMatiereId;

  final List<String> _typesRessource = [
    'Fiches',
    'Sujets',
    'Corrigés',
  ];

  List<Matiere> _matieres = [];
  List<ResultatItem> _resultats = [];

  bool _isLoading = false;
  bool _isLoadingMatieres = false;

  String? _errorMessage;
  int _totalResults = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);

    _chargerDonneesInitiales();
  }

  Future<void> _chargerDonneesInitiales() async {
    await _chargerMatieres();
    if (!mounted) return;

    await _rechercher(page: 1);
  }

  Future<void> _chargerMatieres() async {
    setState(() {
      _isLoadingMatieres = true;
    });

    try {
      final matieres = await _matiereRepository.getMatieres();

      if (!mounted) return;

      setState(() {
        _matieres = matieres;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _matieres = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMatieres = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () {
        if (!mounted) return;
        _rechercher(page: 1);
      },
    );
  }

  Future<void> _rechercher({int page = 1}) async {
    if (_isLoading) {
      // Une recherche plus récente pourra être relancée ensuite.
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = page;
    });

    try {
      final search = _searchController.text.trim();
      final concours = _concoursController.text.trim();
      final annee = _anneeController.text.trim();

      List<ResultatItem> resultats;
      int total;
      int totalPages;

      if (_selectedType == 'Fiches') {
        final response = await _ficheRepository.getFichesCours(
          page: page,
          limit: _pageSize,
          matiere: _selectedMatiereId,
          concours: concours,
          anneeAcademique: annee,
          search: search,
        );

        final fiches =
            response['data'] as List<FicheCours>;

        resultats = fiches.map((fiche) {
          return ResultatItem(
            id: fiche.id,
            titre: fiche.titre,
            sousTitre: _construireSousTitre(
              fiche.matiereNom,
              fiche.concours,
              fiche.anneeAcademique,
              'Fiche de cours',
            ),
            type: 'Fiche',
          );
        }).toList();

        total = response['total'] as int;
        totalPages = response['totalPages'] as int;
      } else if (_selectedType == 'Sujets') {
        final response = await _sujetRepository.getSujetsPage(
          page: page,
          limit: _pageSize,
          matiere: _selectedMatiereId,
          concours: concours,
          anneeAcademique: annee,
          search: search,
        );

        resultats = response.items.map((sujet) {
          return ResultatItem(
            id: sujet.id,
            titre: sujet.titre,
            sousTitre: _construireSousTitre(
              sujet.matiereNom,
              sujet.concours,
              sujet.anneeAcademique,
              'Sujet de concours',
            ),
            type: 'Sujet',
            isCorrige: sujet.aCorrige,
          );
        }).toList();

        total = response.total;
        totalPages = response.totalPages;
      } else {
        // Le backend ne filtre pas directement les corrigés.
        // On récupère les sujets correspondant aux filtres,
        // puis on ne conserve que ceux ayant un corrigé.
        final response = await _sujetRepository.getSujetsPage(
          page: 1,
          limit: 1000,
          matiere: _selectedMatiereId,
          concours: concours,
          anneeAcademique: annee,
          search: search,
        );

        final sujetsAvecCorrige = response.items
            .where((sujet) => sujet.aCorrige)
            .toList();

        total = sujetsAvecCorrige.length;
        totalPages = (total / _pageSize).ceil();

        final start = (page - 1) * _pageSize;

        final pageSujets = start >= total
            ? <Sujet>[]
            : sujetsAvecCorrige
                .skip(start)
                .take(_pageSize)
                .toList();

        resultats = pageSujets.map((sujet) {
          return ResultatItem(
            id: sujet.id,
            titre: sujet.titre,
            sousTitre: _construireSousTitre(
              sujet.matiereNom,
              sujet.concours,
              sujet.anneeAcademique,
              'Corrigé disponible',
            ),
            type: 'Corrigé',
            isCorrige: true,
          );
        }).toList();
      }

      if (!mounted) return;

      setState(() {
        _resultats = resultats;
        _totalResults = total;
        _totalPages = totalPages;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _resultats = [];
        _totalResults = 0;
        _totalPages = 0;
        _errorMessage = _nettoyerErreur(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _construireSousTitre(
    String matiere,
    String concours,
    String annee,
    String type,
  ) {
    final elements = <String>[];

    if (matiere.trim().isNotEmpty) {
      elements.add(matiere.trim());
    }

    if (concours.trim().isNotEmpty) {
      elements.add(concours.trim());
    }

    if (annee.trim().isNotEmpty) {
      elements.add(annee.trim());
    }

    elements.add(type);

    return elements.join(' · ');
  }

  String _nettoyerErreur(Object erreur) {
    return erreur
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('Bad state: ', '');
  }

  void _changerType(String type) {
    if (_selectedType == type) return;

    setState(() {
      _selectedType = type;
    });

    _rechercher(page: 1);
  }

  void _changerMatiere(String? id) {
    setState(() {
      _selectedMatiereId = id;
    });

    _rechercher(page: 1);
  }

  void _reinitialiserFiltres() {
    _debounce?.cancel();

    setState(() {
      _selectedType = 'Fiches';
      _selectedMatiereId = null;
      _concoursController.clear();
      _anneeController.clear();
      _searchController.clear();
    });

    _rechercher(page: 1);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _concoursController.dispose();
    _anneeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? darkBg : lightBg;
    final cardBgColor = isDark ? darkCardBg : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Retour',
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recherche avancée',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Recherche · Elite-Prepa',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Réinitialiser les filtres',
            onPressed: _reinitialiserFiltres,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchField(
                isDark: isDark,
                cardBgColor: cardBgColor,
                textColor: textColor,
              ),
              const SizedBox(height: 16),

              _buildSectionHeading(
                icon: Icons.grid_view_rounded,
                title: 'FILTRES DE RECHERCHE',
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              _buildSectionCard(
                cardBgColor: cardBgColor,
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      'TYPE DE RESSOURCE',
                      subTextColor,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _typesRessource.map((type) {
                        final selected = _selectedType == type;

                        return ChoiceChip(
                          label: Text(type),
                          selected: selected,
                          selectedColor: primaryNavy,
                          backgroundColor: isDark
                              ? const Color(0xFF0D1F38)
                              : const Color(0xFFEEF3F8),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: selected
                                ? Colors.white
                                : subTextColor,
                          ),
                          onSelected: (_) => _changerType(type),
                          side: BorderSide.none,
                          showCheckmark: false,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    _buildFieldLabel('MATIÈRE', subTextColor),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String?>(
                      initialValue: _selectedMatiereId,
                      isExpanded: true,
                      dropdownColor: cardBgColor,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                      ),
                      decoration: _inputDecoration(
                        hint: _isLoadingMatieres
                            ? 'Chargement des matières...'
                            : 'Toutes les matières',
                        isDark: isDark,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Toutes les matières'),
                        ),
                        ..._matieres.map(
                          (matiere) => DropdownMenuItem<String?>(
                            value: matiere.id,
                            child: Text(
                              matiere.nom,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: _isLoadingMatieres
                          ? null
                          : _changerMatiere,
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel('CONCOURS', subTextColor),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _concoursController,
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: _inputDecoration(
                        hint: 'Ex. : CentraleSupélec',
                        isDark: isDark,
                        icon: Icons.school_outlined,
                      ),
                      onSubmitted: (_) => _rechercher(page: 1),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldLabel(
                      'ANNÉE ACADÉMIQUE',
                      subTextColor,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _anneeController,
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: _inputDecoration(
                        hint: 'Ex. : 2025-2026',
                        isDark: isDark,
                        icon: Icons.calendar_today_outlined,
                      ),
                      onSubmitted: (_) => _rechercher(page: 1),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () => _rechercher(page: 1),
                        icon: const Icon(Icons.search, size: 18),
                        label: const Text('Appliquer les filtres'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryNavy,
                          foregroundColor: Colors.white,
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
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeading(
                    icon: Icons.diamond_outlined,
                    title: 'RÉSULTATS',
                    isDark: isDark,
                  ),
                  Text(
                    '$_totalResults trouvé${_totalResults > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? accentOrange : primaryNavy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 35),
                  child: Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(
                          color: accentOrange,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Recherche en cours...',
                          style: TextStyle(color: subTextColor),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_errorMessage != null)
                _buildMessageCard(
                  icon: Icons.cloud_off_outlined,
                  title: 'Impossible de charger les résultats',
                  message: _errorMessage!,
                  cardBgColor: cardBgColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  action: ElevatedButton.icon(
                    onPressed: () => _rechercher(page: _currentPage),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                )
              else if (_resultats.isEmpty)
                _buildMessageCard(
                  icon: Icons.search_off_rounded,
                  title: 'Aucun résultat',
                  message:
                      'Essaie un autre titre ou modifie les filtres.',
                  cardBgColor: cardBgColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _resultats.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _buildResultCard(
                      item: _resultats[index],
                      cardBgColor: cardBgColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      isDark: isDark,
                    );
                  },
                ),

              if (!_isLoading &&
                  _errorMessage == null &&
                  _totalPages > 1) ...[
                const SizedBox(height: 20),
                _buildPagination(isDark, subTextColor),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == _currentIndex) return;

          setState(() {
            _currentIndex = index;
          });

          // La navigation globale est gérée par le routeur
          // de l'application. On ne change pas de page ici.
        },
        backgroundColor: isDark ? darkBg : Colors.white,
        indicatorColor: accentOrange.withValues(alpha: 0.18),
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

  Widget _buildSearchField({
    required bool isDark,
    required Color cardBgColor,
    required Color textColor,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryNavy,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            size: 21,
            color: accentOrange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: 'Rechercher une ressource...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black45,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Effacer la recherche',
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.close, size: 18),
                      ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Lancer la recherche',
            onPressed: () => _rechercher(page: 1),
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: accentOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading({
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: isDark ? accentOrange : primaryNavy,
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: isDark ? accentOrange : primaryNavy,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.4,
        color: color,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required bool isDark,
    IconData? icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? Colors.white54 : Colors.black45,
        fontSize: 13,
      ),
      prefixIcon: icon == null
          ? null
          : Icon(
              icon,
              size: 18,
              color: accentOrange,
            ),
      filled: true,
      fillColor: isDark
          ? const Color(0xFF0D1F38)
          : const Color(0xFFEEF3F8),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: primaryNavy,
          width: 1.3,
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required Widget child,
    required Color cardBgColor,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: child,
    );
  }

  Widget _buildResultCard({
    required ResultatItem item,
    required Color cardBgColor,
    required Color textColor,
    required Color subTextColor,
    required bool isDark,
  }) {
    final icon = switch (item.type) {
      'Fiche' => Icons.menu_book_outlined,
      'Sujet' => Icons.description_outlined,
      _ => Icons.picture_as_pdf_outlined,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: accentOrange,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.titre,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.sousTitre,
                  style: TextStyle(
                    fontSize: 11,
                    color: subTextColor,
                  ),
                ),
              ],
            ),
          ),
          if (item.isCorrige)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: successGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Corrigé',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageCard({
    required IconData icon,
    required String title,
    required String message,
    required Color cardBgColor,
    required Color textColor,
    required Color subTextColor,
    Widget? action,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 38,
            color: accentOrange,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: subTextColor,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 14),
            action,
          ],
        ],
      ),
    );
  }

  Widget _buildPagination(
    bool isDark,
    Color subTextColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'Page précédente',
          onPressed: _currentPage > 1
              ? () => _rechercher(page: _currentPage - 1)
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        ..._pagesVisibles().map((page) {
          final selected = page == _currentPage;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: InkWell(
              onTap: () => _rechercher(page: page),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? primaryNavy
                      : (isDark
                          ? const Color(0xFF0D1F38)
                          : const Color(0xFFEEF3F8)),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$page',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : subTextColor,
                  ),
                ),
              ),
            ),
          );
        }),
        IconButton(
          tooltip: 'Page suivante',
          onPressed: _currentPage < _totalPages
              ? () => _rechercher(page: _currentPage + 1)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  List<int> _pagesVisibles() {
    if (_totalPages <= 0) return [];

    final start = (_currentPage - 2).clamp(
      1,
      _totalPages,
    );

    final end = (start + 4).clamp(
      1,
      _totalPages,
    );

    return [
      for (int page = start; page <= end; page++) page,
    ];
  }
}