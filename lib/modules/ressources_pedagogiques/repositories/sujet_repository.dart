import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/sujet.dart';

import 'package:file_picker/file_picker.dart';

import '../../../core/storage/token_storage.dart';

/// RÃƒÂ©sultat paginÃƒÂ© retournÃƒÂ© par l'API des sujets.
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
      throw const FormatException('Format de rÃƒÂ©ponse des sujets invalide.');
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
  static const String baseUrl = 'http://192.168.137.1:3000';

  final TokenStorage _tokenStorage = TokenStorage();

  /// Récupère un jeton valide pour les requêtes protégées.
  Future<String> _getToken() async {
    final token = await _tokenStorage.getAccessToken();

    if (token == null || token.trim().isEmpty) {
      throw Exception(
        'Authentification requise. Connecte-toi avant de continuer.',
      );
    }

    return token.trim();
  }

  /// Ajoute un sujet et ses fichiers PDF.
  Future<void> createSujet({
    required String titre,
    required String description,
    required String matiereId,
    required String concours,
    required String anneeAcademique,
    required PlatformFile fichier,
    PlatformFile? corrige,
  }) async {
    final token = await _getToken();

    final uri = Uri.parse('$baseUrl/api/sujets');

    final request = http.MultipartRequest('POST', uri);

    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $token';

    request.fields.addAll({
      'titre': titre.trim(),
      'description': description.trim(),
      'matiere': matiereId,
      'concours': concours.trim(),
      'anneeAcademique': anneeAcademique.trim(),
    });

    request.files.add(
      await _platformFileToMultipart(
        fichier,
        'fichier',
      ),
    );

    if (corrige != null) {
      request.files.add(
        await _platformFileToMultipart(
          corrige,
          'corrige',
        ),
      );
    }

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
    );

    final response = await http.Response.fromStream(streamedResponse);

    _checkResponse(response);
  }

  /// Convertit un fichier sélectionné en pièce jointe HTTP.
  Future<http.MultipartFile> _platformFileToMultipart(
    PlatformFile file,
    String fieldName,
  ) async {
    final extension = file.extension?.toLowerCase();

    if (extension != 'pdf') {
      throw Exception(
        'Le fichier "${file.name}" doit être au format PDF.',
      );
    }

    if (file.size > 10 * 1024 * 1024) {
      throw Exception(
        'Le fichier "${file.name}" dépasse la limite de 10 Mo.',
      );
    }

    if (file.path != null && file.path!.isNotEmpty) {
      return http.MultipartFile.fromPath(
        fieldName,
        file.path!,
        filename: file.name,
      );
    }

    if (file.bytes != null) {
      return http.MultipartFile.fromBytes(
        fieldName,
        file.bytes!,
        filename: file.name,
      );
    }

    throw Exception(
      'Impossible de lire le fichier "${file.name}".',
    );
  }

  /// Modifie les informations textuelles d'un sujet existant.
  ///
  /// Le backend ne permet pas encore de remplacer les PDF.
  Future<void> updateSujet({
    required String id,
    required String titre,
    required String description,
    required String matiereId,
    required String concours,
    required String anneeAcademique,
  }) async {
    if (id.trim().isEmpty) {
      throw ArgumentError(
        'Identifiant du sujet manquant.',
      );
    }

    final token = await _getToken();

    final uri = Uri.parse(
      '$baseUrl/api/sujets/${Uri.encodeComponent(id)}',
    );

    final response = await http
        .put(
          uri,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'titre': titre.trim(),
            'description': description.trim(),
            'matiere': matiereId,
            'concours': concours.trim(),
            'anneeAcademique': anneeAcademique.trim(),
          }),
        )
        .timeout(const Duration(seconds: 15));

    _checkResponse(response);
  }

  /// Supprime un sujet sur le backend.
  Future<void> deleteSujet(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError(
        'Identifiant du sujet manquant.',
      );
    }

    final token = await _getToken();

    final uri = Uri.parse(
      '$baseUrl/api/sujets/${Uri.encodeComponent(id)}',
    );

    final response = await http
        .delete(
          uri,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 15));

    _checkResponse(response);
  }

  /// Vérifie les réponses du backend.
  void _checkResponse(http.Response response) {
    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    String message = 'Erreur du serveur : HTTP ${response.statusCode}';

    try {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        final dynamic serverMessage =
            decoded['message'] ?? decoded['error'];

        if (serverMessage != null) {
          message = serverMessage is List
              ? serverMessage.join('\n')
              : serverMessage.toString();
        }
      }
    } catch (_) {
      // La réponse n'est pas nécessairement au format JSON.
    }

    if (response.statusCode == 401) {
      message = 'Session expirée ou utilisateur non authentifié.';
    } else if (response.statusCode == 403) {
      message = 'Accès refusé : un compte administrateur est requis.';
    } else if (response.statusCode == 413) {
      message = 'Le fichier envoyé est trop volumineux.';
    }

    throw Exception(message);
  }

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
          'Le serveur a renvoyÃƒÂ© une rÃƒÂ©ponse invalide.',
        );
      }

      return SujetsPage.fromJson(decoded);
    } catch (e) {
      throw Exception('Impossible de charger les sujets : $e');
    }
  }

  /// CompatibilitÃƒÂ© avec les ÃƒÂ©ventuels ÃƒÂ©crans utilisant dÃƒÂ©jÃƒÂ  getSujets().
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

  /// RÃƒÂ©cupÃƒÂ¨re un sujet par son identifiant.
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

