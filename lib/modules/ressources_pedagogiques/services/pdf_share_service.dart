import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/storage/token_storage.dart';

class PdfShareService {
  PdfShareService._();

  static const String _baseUrl = 'http://192.168.137.1:3000';

  /// Partage un PDF provenant du backend.
  ///
  /// Types acceptés : sujet, corrige, fiche.
  static Future<void> sharePdf({
    required String id,
    required String type,
    required String titre,
    String? nomFichier,
  }) async {
    final documentId = id.trim();

    if (documentId.isEmpty) {
      throw Exception('Identifiant du document manquant.');
    }

    final token = (await TokenStorage().getAccessToken())?.trim() ?? '';

    if (token.isEmpty) {
      throw Exception('Tu dois te connecter pour partager ce document.');
    }

    final String endpoint;

    switch (type) {
      case 'sujet':
        endpoint = '/api/sujets/${Uri.encodeComponent(documentId)}/download';
        break;
      case 'corrige':
        endpoint =
            '/api/sujets/${Uri.encodeComponent(documentId)}/corrige/download';
        break;
      case 'fiche':
        endpoint =
            '/api/fiches-cours/${Uri.encodeComponent(documentId)}/download';
        break;
      default:
        throw ArgumentError('Type de document non pris en charge : $type');
    }

    final response = await http
        .get(
          Uri.parse('$_baseUrl$endpoint'),
          headers: {
            'Accept': 'application/pdf',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode == 401) {
      throw Exception('Session expirée. Reconnecte-toi.');
    }

    if (response.statusCode == 403) {
      throw Exception('Tu n’as pas l’autorisation de partager ce document.');
    }

    if (response.statusCode == 404) {
      throw Exception('PDF introuvable sur le serveur.');
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Échec du téléchargement du PDF (HTTP ${response.statusCode}).',
      );
    }

    if (response.bodyBytes.length < 5 ||
        String.fromCharCodes(response.bodyBytes.take(5)) != '%PDF-') {
      throw Exception('Le serveur n’a pas renvoyé un PDF valide.');
    }

    final directory = await getTemporaryDirectory();

    var fileName = (nomFichier ?? '').trim();

    if (fileName.isEmpty) fileName = '${type}_$documentId.pdf';

    fileName = fileName.split(RegExp(r'[/\\]')).last;

    if (!fileName.toLowerCase().endsWith('.pdf')) {
      fileName = '$fileName.pdf';
    }

    fileName = fileName.replaceAll(RegExp(r'[<>:"|?*\x00-\x1F]'), '_');

    final file = File('${directory.path}${Platform.pathSeparator}$fileName');

    await file.writeAsBytes(response.bodyBytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        title: titre,
        text: titre,
        files: [XFile(file.path, mimeType: 'application/pdf')],
      ),
    );
  }
}
