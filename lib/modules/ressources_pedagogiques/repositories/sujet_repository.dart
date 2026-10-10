import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/sujet.dart';

/// RÃ©sultat paginÃ© retournÃ© par l'API des sujets.
class SujetsPage {
  final List<Sujet> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const SujetsPage({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory SujetsPage.fromJson(Map<String, dynamic> json) {
    final dynamic data = json['data'];
    final dynamic pagination = json['pagination'];

    if (data is! List || pagination is! Map<String, dynamic>) {
      throw const FormatException('Format de rÃ©ponse des sujets invalide.');
    }

    return SujetsPage(
      items: data.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Sujet JSON invalide.');
        }

        return Sujet.fromJson(item);
      }).toList(),
      page: _toInt(pagination['page'], 1),
      limit: _toInt(pagination['limit'], 10),
      total: _toInt(pagination['total'], 0),
      totalPages: _toInt(pagination['totalPages'], 0),
    );
  }

  static int _toInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

class SujetRepository {
  static const String baseUrl = 'http://10.2.7.69:3000';

  /// Charge une page de sujets depuis le backend.
  Future<SujetsPage> getSujetsPage({
    String? matiere,
    String? concours,
    String? anneeAcademique,
    String? search,
    int page = 1,
    int limit = 10,
    String sort = 'dateAjout',
    String order = 'desc',
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sort': sort,
      'order': order,
    };

    if (matiere != null && matiere.trim().isNotEmpty) {
      query['matiere'] = matiere.trim();
    }

    if (concours != null && concours.trim().isNotEmpty) {
      query['concours'] = concours.trim();
    }

    if (anneeAcademique != null && anneeAcademique.trim().isNotEmpty) {
      query['anneeAcademique'] = anneeAcademique.trim();
    }

    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }

    final uri = Uri.parse('$baseUrl/api/sujets')
        .replace(queryParameters: query);

    try {
      final response = await http
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Erreur du serveur : HTTP ${response.statusCode}');
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Le serveur a renvoyÃ© une rÃ©ponse invalide.',
        );
      }

      return SujetsPage.fromJson(decoded);
    } catch (e) {
      throw Exception('Impossible de charger les sujets : $e');
    }
  }

  /// CompatibilitÃ© avec les Ã©ventuels Ã©crans utilisant dÃ©jÃ  getSujets().
  Future<List<Sujet>> getSujets({
    String? matiere,
    String? concours,
    String? anneeAcademique,
    String? search,
    int page = 1,
    int limit = 10,
    String sort = 'dateAjout',
    String order = 'desc',
  }) async {
    final result = await getSujetsPage(
      matiere: matiere,
      concours: concours,
      anneeAcademique: anneeAcademique,
      search: search,
      page: page,
      limit: limit,
      sort: sort,
      order: order,
    );

    return result.items;
  }

  /// RÃ©cupÃ¨re un sujet par son identifiant.
  Future<Sujet> getSujetById(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('Identifiant du sujet manquant.');
    }

    final uri = Uri.parse('$baseUrl/api/sujets/${Uri.encodeComponent(id)}');

    final response = await http
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de charger le sujet : HTTP ${response.statusCode}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Sujet JSON invalide.');
    }

    return Sujet.fromJson(decoded);
  }
}
