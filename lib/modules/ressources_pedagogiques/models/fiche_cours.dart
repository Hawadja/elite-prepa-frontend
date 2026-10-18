class FicheCours {
  final String id;
  final String titre;
  final String description;
  final String fichier;
  final String matiereId;
  final String matiereNom;
  final String concours;
  final String anneeAcademique;
  final DateTime? dateAjout;

  const FicheCours({
    required this.id,
    required this.titre,
    required this.description,
    required this.fichier,
    required this.matiereId,
    required this.matiereNom,
    required this.concours,
    required this.anneeAcademique,
    this.dateAjout,
  });

  factory FicheCours.fromJson(Map<String, dynamic> json) {
    final matiere = json['matiere'];

    String matiereId = '';
    String matiereNom = '';

    if (matiere is Map<String, dynamic>) {
      matiereId = (matiere['_id'] ?? matiere['id'] ?? '').toString();
      matiereNom = (matiere['nom'] ?? matiere['titre'] ?? '').toString();
    } else if (matiere != null) {
      matiereId = matiere.toString();
    }

    DateTime? date;

    if (json['dateAjout'] != null) {
      date = DateTime.tryParse(json['dateAjout'].toString());
    }

    return FicheCours(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      titre: (json['titre'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      fichier: (json['fichier'] ?? '').toString(),
      matiereId: matiereId,
      matiereNom: matiereNom,
      concours: (json['concours'] ?? '').toString(),
      anneeAcademique: (json['anneeAcademique'] ?? '').toString(),
      dateAjout: date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'description': description,
      'fichier': fichier,
      'matiere': matiereId,
      'concours': concours,
      'anneeAcademique': anneeAcademique,
    };
  }
}