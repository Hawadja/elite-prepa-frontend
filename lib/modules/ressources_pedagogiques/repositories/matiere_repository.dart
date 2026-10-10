import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/matiere.dart';

class MatiereRepository {
  static const String _baseUrl = 'http://192.168.137.1:3000';

  /// Afficher toutes les matières.
  Future<List<Matiere>> getMatieres() async {
    final uri = Uri.parse('$_baseUrl/api/matieres');

    try {
      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'Erreur du serveur : HTTP ${response.statusCode}',
        );
      }

      final dynamic data = jsonDecode(response.body);

      if (data is! List) {
        throw const FormatException(
          'Le serveur n’a pas renvoyé une liste de matières.',
        );
      }

      return data.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException(
            'Format JSON d’une matière invalide.',
          );
        }

        return Matiere.fromJson(item);
      }).toList();
    } catch (e) {
      throw Exception(
        'Impossible de charger les matières : $e',
      );
    }
  }

  /// Ajouter une matière.
  ///
  /// Le jeton JWT est fourni par le mécanisme d'authentification
  /// de l'application, géré par le membre responsable de ce module.
  Future<void> createMatiere(
    Matiere matiere, {
    required String token,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/matieres');

    final response = await http
        .post(
          uri,
          headers: _authorizedHeaders(token),
          body: jsonEncode(matiere.toJson()),
        )
        .timeout(const Duration(seconds: 15));

    _checkResponse(response);
  }

  /// Modifier une matière existante.
  Future<void> updateMatiere(
    Matiere matiere, {
    required String token,
  }) async {
    if (matiere.id.isEmpty) {
      throw ArgumentError(
        'Impossible de modifier une matière sans identifiant.',
      );
    }

    final uri = Uri.parse(
      '$_baseUrl/api/matieres/${Uri.encodeComponent(matiere.id)}',
    );

    final response = await http
        .put(
          uri,
          headers: _authorizedHeaders(token),
          body: jsonEncode(matiere.toJson()),
        )
        .timeout(const Duration(seconds: 15));

    _checkResponse(response);
  }

  /// Supprimer une matière.
  Future<void> deleteMatiere(
    String id, {
    required String token,
  }) async {
    if (id.isEmpty) {
      throw ArgumentError(
        'Impossible de supprimer une matière sans identifiant.',
      );
    }

    final uri = Uri.parse(
      '$_baseUrl/api/matieres/${Uri.encodeComponent(id)}',
    );

    final response = await http
        .delete(
          uri,
          headers: _authorizedHeaders(token),
        )
        .timeout(const Duration(seconds: 15));

    _checkResponse(response);
  }

  /// En-têtes des requêtes protégées.
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

  /// Vérifier la réponse du backend.
  void _checkResponse(http.Response response) {
    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    String message = 'Erreur du serveur : HTTP ${response.statusCode}';

    try {
      final dynamic data = jsonDecode(response.body);

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
      message = 'Authentification requise. Vérifie la session avec '
          'le membre responsable du module.';
    } else if (response.statusCode == 403) {
      message = 'Accès refusé : le compte doit avoir le rôle '
          'administrateur.';
    }

    throw Exception(message);
  }
}
