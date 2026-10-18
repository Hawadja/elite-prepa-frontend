class ProfilModel {
  final String id;
  final String userId;
  final String nom;
  final String prenom;
  final String? telephone;
  final String? photoUrl;
  final String? ville;
  final DateTime? dateNaissance;
  final String? lieuDeNaissance;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfilModel({
    required this.id,
    required this.userId,
    required this.nom,
    required this.prenom,
    this.telephone,
    this.photoUrl,
    this.ville,
    this.dateNaissance,
    this.lieuDeNaissance,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfilModel.fromJson(Map<String, dynamic> json) {
    final rawUserId = json['userId'];
    final userId = rawUserId is Map<String, dynamic>
        ? (rawUserId['_id'] ?? '').toString()
        : (rawUserId ?? '').toString();

    final nom = (json['nom'] ??
            (json['userId'] is Map ? (json['userId'] as Map)['nom'] : null) ??
            (json['user'] is Map ? (json['user'] as Map)['nom'] : null) ??
            '')
        .toString();

    final prenom = (json['prenom'] ??
            (json['userId'] is Map ? (json['userId'] as Map)['prenom'] : null) ??
            (json['user'] is Map ? (json['user'] as Map)['prenom'] : null) ??
            '')
        .toString();

    final telephone = (json['telephone'] ??
            (json['userId'] is Map ? (json['userId'] as Map)['telephone'] : null) ??
            (json['user'] is Map ? (json['user'] as Map)['telephone'] : null))
        ?.toString();

    return ProfilModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: userId,
      nom: nom,
      prenom: prenom,
      telephone: telephone,
      photoUrl: json['photoUrl']?.toString(),
      ville: json['ville']?.toString(),
      dateNaissance: json['dateNaissance'] != null
          ? DateTime.tryParse(json['dateNaissance'].toString())
          : null,
      lieuDeNaissance: json['lieuDeNaissance']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'nom': nom,
      'prenom': prenom,
      if (telephone != null) 'telephone': telephone,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (ville != null) 'ville': ville,
      if (dateNaissance != null)
        'dateNaissance': dateNaissance!.toIso8601String(),
      if (lieuDeNaissance != null) 'lieuDeNaissance': lieuDeNaissance,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      if (telephone != null && telephone!.isNotEmpty) 'telephone': telephone,
      if (photoUrl != null && photoUrl!.isNotEmpty) 'photoUrl': photoUrl,
      if (ville != null && ville!.isNotEmpty) 'ville': ville,
      if (dateNaissance != null)
        'dateNaissance': dateNaissance!.toIso8601String(),
      if (lieuDeNaissance != null && lieuDeNaissance!.isNotEmpty)
        'lieuDeNaissance': lieuDeNaissance,
    };
  }

  ProfilModel copyWith({
    String? id,
    String? userId,
    String? nom,
    String? prenom,
    String? telephone,
    String? photoUrl,
    String? ville,
    DateTime? dateNaissance,
    String? lieuDeNaissance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfilModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      telephone: telephone ?? this.telephone,
      photoUrl: photoUrl ?? this.photoUrl,
      ville: ville ?? this.ville,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      lieuDeNaissance: lieuDeNaissance ?? this.lieuDeNaissance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProfilModel &&
        other.id == id &&
        other.userId == userId &&
        other.nom == nom &&
        other.prenom == prenom &&
        other.telephone == telephone &&
        other.photoUrl == photoUrl &&
        other.ville == ville &&
        other.dateNaissance == dateNaissance &&
        other.lieuDeNaissance == lieuDeNaissance &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        nom.hashCode ^
        prenom.hashCode ^
        (telephone?.hashCode ?? 0) ^
        photoUrl.hashCode ^
        ville.hashCode ^
        dateNaissance.hashCode ^
        lieuDeNaissance.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'ProfilModel(id: $id, userId: $userId, nom: $nom, prenom: $prenom, telephone: $telephone, photoUrl: $photoUrl, ville: $ville, dateNaissance: $dateNaissance, lieuDeNaissance: $lieuDeNaissance, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
