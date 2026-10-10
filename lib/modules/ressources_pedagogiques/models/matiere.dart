
class Matiere {
  final String id;
  final String nom;
  final String code;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Matiere({
    required this.id,
    required this.nom,
    required this.code,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  /// Convertit les données JSON du backend en objet Matiere.
  factory Matiere.fromJson(Map<String, dynamic> json) {
    return Matiere(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      nom: (json['nom'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  /// Convertit l'objet Matiere en JSON pour l'API.
  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'code': code,
      'description': description,
    };
  }

  /// Convertit une date JSON en DateTime si elle est valide.
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}

