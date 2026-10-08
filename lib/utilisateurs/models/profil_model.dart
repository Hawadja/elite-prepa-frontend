import 'user_model.dart';

class ProfilModel {
  final String id;
  final UserModel? user;
  final String? photoUrl;
  final String? telephone;
  final String? adresse;
  final DateTime? dateNaissance;
  final String? bio;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfilModel({
    required this.id,
    this.user,
    this.photoUrl,
    this.telephone,
    this.adresse,
    this.dateNaissance,
    this.bio,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfilModel.fromJson(Map<String, dynamic> json) {
    UserModel? parsedUser;
    if (json['user'] is Map<String, dynamic>) {
      parsedUser = UserModel.fromJson(json['user'] as Map<String, dynamic>);
    } else if (json['userId'] is Map<String, dynamic>) {
      parsedUser = UserModel.fromJson(json['userId'] as Map<String, dynamic>);
    }

    return ProfilModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      user: parsedUser,
      photoUrl: json['photoUrl']?.toString(),
      telephone: json['telephone']?.toString(),
      adresse: json['adresse']?.toString(),
      dateNaissance: json['dateNaissance'] != null
          ? DateTime.tryParse(json['dateNaissance'].toString())
          : null,
      bio: json['bio']?.toString(),
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
      if (user != null) 'user': user!.toJson(),
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (telephone != null) 'telephone': telephone,
      if (adresse != null) 'adresse': adresse,
      if (dateNaissance != null)
        'dateNaissance': dateNaissance!.toIso8601String(),
      if (bio != null) 'bio': bio,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  ProfilModel copyWith({
    String? id,
    UserModel? user,
    String? photoUrl,
    String? telephone,
    String? adresse,
    DateTime? dateNaissance,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfilModel(
      id: id ?? this.id,
      user: user ?? this.user,
      photoUrl: photoUrl ?? this.photoUrl,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProfilModel &&
        other.id == id &&
        other.user == user &&
        other.photoUrl == photoUrl &&
        other.telephone == telephone &&
        other.adresse == adresse &&
        other.dateNaissance == dateNaissance &&
        other.bio == bio &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        user.hashCode ^
        photoUrl.hashCode ^
        telephone.hashCode ^
        adresse.hashCode ^
        dateNaissance.hashCode ^
        bio.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'ProfilModel(id: $id, user: $user, photoUrl: $photoUrl, telephone: $telephone, adresse: $adresse, dateNaissance: $dateNaissance, bio: $bio, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
