import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/fiche_cours.dart';
import 'package:file_picker/file_picker.dart';

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

    /// Créer une fiche de cours avec son fichier PDF.
  Future<void> createFicheCours({
    required String titre,
    required String description,
    required String matiereId,
    required String concours,
    required String anneeAcademique,
    required PlatformFile fichier,
    required String token,
  }) async {
    if (token.trim().isEmpty) {
      throw ArgumentError(
        'Le jeton d’authentification est obligatoire.',
      );
    }

    if (fichier.extension?.toLowerCase() != 'pdf') {
      throw Exception('Le fichier doit être au format PDF.');
    }

    if (fichier.size > 10 * 1024 * 1024) {
      throw Exception('Le fichier PDF ne doit pas dépasser 10 Mo.');
    }

    if (titre.trim().isEmpty ||
        description.trim().isEmpty ||
        matiereId.trim().isEmpty ||
        concours.trim().isEmpty ||
        anneeAcademique.trim().isEmpty) {
      throw Exception(
        'Tous les champs obligatoires doivent être renseignés.',
      );
    }

    final uri = Uri.parse('$baseUrl$endpoint');

    final request = http.MultipartRequest('POST', uri);

    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer ${token.trim()}';

    request.fields.addAll({
      'titre': titre.trim(),
      'description': description.trim(),
      'matiere': matiereId.trim(),
      'concours': concours.trim(),
      'anneeAcademique': anneeAcademique.trim(),
    });

    http.MultipartFile fichierMultipart;

    if (fichier.path != null && fichier.path!.isNotEmpty) {
      fichierMultipart = await http.MultipartFile.fromPath(
        'fichier',
        fichier.path!,
        filename: fichier.name,
      );
    } else if (fichier.bytes != null) {
      fichierMultipart = http.MultipartFile.fromBytes(
        'fichier',
        fichier.bytes!,
        filename: fichier.name,
      );
    } else {
      throw Exception(
        'Impossible de lire le fichier PDF sélectionné.',
      );
    }

    request.files.add(fichierMultipart);

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
    );

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    _checkResponse(response);
  }

  /// Modifier les informations d'une fiche de cours.
  Future<void> updateFicheCours(
    String id, {
    required String titre,
    required String description,
    required String token,
  }) async {
    if (id.trim().isEmpty) {
      throw ArgumentError(
        'Impossible de modifier une fiche sans identifiant.',
      );
    }

    final uri = Uri.parse(
      '$baseUrl$endpoint/${Uri.encodeComponent(id)}',
    );

    final response = await http
        .put(
          uri,
          headers: _authorizedHeaders(token),
          body: jsonEncode({
            'titre': titre.trim(),
            'description': description.trim(),
          }),
        )
        .timeout(const Duration(seconds: 15));

    _checkResponse(response);
  }

  /// Supprimer une fiche de cours.
  Future<void> deleteFicheCours(
    String id, {
    required String token,
  }) async {
    if (id.trim().isEmpty) {
      throw ArgumentError(
        'Impossible de supprimer une fiche sans identifiant.',
      );
    }

    final uri = Uri.parse(
      '$baseUrl$endpoint/${Uri.encodeComponent(id)}',
    );

    final response = await http
        .delete(
          uri,
          headers: _authorizedHeaders(token),
        )
        .timeout(const Duration(seconds: 15));

    _checkResponse(response);
  }

  int _toInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  Map<String, String> _authorizedHeaders(String token) {
    if (token.trim().isEmpty) {
      throw ArgumentError(
        'Le jeton d’authentification est obligatoire.',
      );
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token.trim()}',
    };
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    String message =
        'Erreur du serveur : HTTP ${response.statusCode}';

    try {
      final dynamic data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (data is Map<String, dynamic>) {
        final dynamic serverMessage =
            data['message'] ?? data['error'];

        if (serverMessage != null) {
          message = serverMessage.toString();
        }
      }
    } catch (_) {
      // Conserver le message HTTP si la réponse n'est pas du JSON.
    }

    if (response.statusCode == 401) {
      message = 'Authentification requise. Vérifie ta session.';
    } else if (response.statusCode == 403) {
      message =
          'Accès refusé : le compte doit avoir le rôle administrateur.';
    }

    throw Exception(message);
  }
}