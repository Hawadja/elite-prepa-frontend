class Sujet {
  final String id;
  final String titre;
  final String description;
  final String fichier;
  final String matiereId;
  final String matiereNom;
  final String concours;
  final String anneeAcademique;
  final String? corrige;
  final DateTime? dateAjout;

  const Sujet({
    required this.id,
    required this.titre,
    required this.description,
    required this.fichier,
    required this.matiereId,
    required this.matiereNom,
    required this.concours,
    required this.anneeAcademique,
    this.corrige,
    this.dateAjout,
  });

  bool get aCorrige => corrige != null && corrige!.trim().isNotEmpty;

  factory Sujet.fromJson(Map<String, dynamic> json) {
    final dynamic matiereJson = json['matiere'];

    String matiereId = '';
    String matiereNom = '';

    if (matiereJson is Map<String, dynamic>) {
      matiereId = (matiereJson['_id'] ?? matiereJson['id'] ?? '').toString();
      matiereNom = (matiereJson['nom'] ?? '').toString();
    } else if (matiereJson != null) {
      matiereId = matiereJson.toString();
    }

    return Sujet(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      titre: (json['titre'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      fichier: (json['fichier'] ?? '').toString(),
      matiereId: matiereId,
      matiereNom: matiereNom,
      concours: (json['concours'] ?? '').toString(),
      anneeAcademique: (json['anneeAcademique'] ?? '').toString(),
      corrige: json['corrige']?.toString(),
      dateAjout: DateTime.tryParse((json['dateAjout'] ?? '').toString()),
    );
  }
}
