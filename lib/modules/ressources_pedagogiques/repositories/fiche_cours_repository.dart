import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/fiche_cours.dart';

class FicheCoursRepository {

  static const String baseUrl = 'http://192.168.137.1:3000';
  static const String endpoint = '/api/fiches-cours';

  Future<Map<String, dynamic>> getFichesCours({
    int page = 1,
    int limit = 10,
    String? matiere,
    String? concours,
    String? anneeAcademique,
    String? search,
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sort': 'dateAjout',
      'order': 'desc',
    };

    if (matiere != null && matiere.trim().isNotEmpty) {
      queryParameters['matiere'] = matiere.trim();
    }

    if (concours != null && concours.trim().isNotEmpty) {
      queryParameters['concours'] = concours.trim();
    }

    if (anneeAcademique != null &&
        anneeAcademique.trim().isNotEmpty) {
      queryParameters['anneeAcademique'] =
          anneeAcademique.trim();
    }

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    final uri = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: queryParameters,
    );

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de récupérer les fiches de cours '
        '(HTTP ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Format de réponse inattendu pour les fiches de cours.',
      );
    }

    final data = decoded['data'];
    final pagination = decoded['pagination'];

    if (data is! List) {
      throw const FormatException(
        'La liste des fiches de cours est absente de la réponse.',
      );
    }

    final fiches = data
        .whereType<Map<String, dynamic>>()
        .map(FicheCours.fromJson)
        .toList();

    final paginationData =
        pagination is Map<String, dynamic>
            ? pagination
            : <String, dynamic>{};

    return {
      'data': fiches,
      'page': _toInt(paginationData['page'], page),
      'limit': _toInt(paginationData['limit'], limit),
      'total': _toInt(paginationData['total'], fiches.length),
      'totalPages': _toInt(
        paginationData['totalPages'],
        1,
      ),
    };
  }

  Future<FicheCours> getFicheCoursById(String id) async {
    final uri = Uri.parse('$baseUrl$endpoint/$id');

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de récupérer cette fiche '
        '(HTTP ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Format de fiche de cours inattendu.',
      );
    }

    return FicheCours.fromJson(decoded);
  }

  int _toInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}