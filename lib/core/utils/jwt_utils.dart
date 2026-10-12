import 'dart:convert';

/// Extrait le userId depuis le payload d'un token JWT, sans vérifier
/// la signature (ça reste un décodage client, pas une validation).
String? extractUserIdFromToken(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    final normalized = base64.normalize(parts[1]);
    final payloadString = utf8.decode(base64.decode(normalized));
    final Map<String, dynamic> payload = jsonDecode(payloadString);
    return payload['userId']?.toString() ??
        payload['id']?.toString() ??
        payload['sub']?.toString() ??
        payload['_id']?.toString();
  } catch (_) {
    return null;
  }
}
