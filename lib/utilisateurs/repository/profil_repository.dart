import 'package:dio/dio.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/profil_model.dart';

class ProfilRepository {
  final DioClient _dioClient;

  ProfilRepository({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  /// Création du profil d'un utilisateur (POST /profil/create)
  Future<ProfilModel> createProfil(
    String userId,
    String nom,
    String prenom, {
    String? telephone,
    String? ville,
    DateTime? dateNaissance,
    String? lieuDeNaissance,
    String? photoUrl,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/profil/create',
        data: {
          'userId': userId,
          'nom': nom,
          'prenom': prenom,
          if (telephone != null && telephone.isNotEmpty) 'telephone': telephone,
          if (ville != null && ville.isNotEmpty) 'ville': ville,
          if (dateNaissance != null)
            'dateNaissance': dateNaissance.toIso8601String(),
          if (lieuDeNaissance != null && lieuDeNaissance.isNotEmpty)
            'lieuDeNaissance': lieuDeNaissance,
          if (photoUrl != null && photoUrl.isNotEmpty) 'photoUrl': photoUrl,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['profil'] is Map<String, dynamic>) {
          return ProfilModel.fromJson(data['profil'] as Map<String, dynamic>);
        } else if (data['data'] is Map<String, dynamic>) {
          final innerData = data['data'] as Map<String, dynamic>;
          if (innerData['profil'] is Map<String, dynamic>) {
            return ProfilModel.fromJson(
                innerData['profil'] as Map<String, dynamic>);
          }
          return ProfilModel.fromJson(innerData);
        }
        return ProfilModel.fromJson(data);
      }

      return ProfilModel(
        id: '',
        userId: userId,
        nom: nom,
        prenom: prenom,
        telephone: telephone,
        photoUrl: photoUrl,
        ville: ville,
        dateNaissance: dateNaissance,
        lieuDeNaissance: lieuDeNaissance,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      final backendMessage = e.response?.data is Map<String, dynamic>
          ? e.response?.data['message']?.toString() ??
              e.response?.data['error']?.toString()
          : null;
      throw ApiException(
        message: backendMessage ??
            e.message ??
            'Erreur lors de la création du profil.',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// Récupère le profil d'un utilisateur par son ID (GET /profil/get/:userId)
  Future<ProfilModel> getProfil(String userId) async {
    try {
      final response = await _dioClient.dio.get('/profil/get/$userId');

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['profil'] is Map<String, dynamic>) {
          return ProfilModel.fromJson(data['profil'] as Map<String, dynamic>);
        } else if (data['data'] is Map<String, dynamic>) {
          final innerData = data['data'] as Map<String, dynamic>;
          if (innerData['profil'] is Map<String, dynamic>) {
            return ProfilModel.fromJson(
                innerData['profil'] as Map<String, dynamic>);
          }
          return ProfilModel.fromJson(innerData);
        }
        return ProfilModel.fromJson(data);
      }

      throw const ApiException(
        message:
            'Format de réponse serveur invalide lors de la récupération du profil.',
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      final backendMessage = e.response?.data is Map<String, dynamic>
          ? e.response?.data['message']?.toString() ??
              e.response?.data['error']?.toString()
          : null;
      throw ApiException(
        message: backendMessage ??
            e.message ??
            'Impossible de récupérer le profil utilisateur.',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// Met à jour le profil d'un utilisateur par son ID (PATCH /profil/update/:userId)
  Future<ProfilModel> updateProfil(String userId, ProfilModel profil) async {
    try {
      final response = await _dioClient.dio.patch(
        '/profil/update/$userId',
        data: profil.toUpdateJson(),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['profil'] is Map<String, dynamic>) {
          return ProfilModel.fromJson(data['profil'] as Map<String, dynamic>);
        } else if (data['data'] is Map<String, dynamic>) {
          final innerData = data['data'] as Map<String, dynamic>;
          if (innerData['profil'] is Map<String, dynamic>) {
            return ProfilModel.fromJson(
                innerData['profil'] as Map<String, dynamic>);
          }
          return ProfilModel.fromJson(innerData);
        }
        return ProfilModel.fromJson(data);
      }

      throw const ApiException(
        message:
            'Format de réponse serveur invalide lors de la mise à jour du profil.',
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      final backendMessage = e.response?.data is Map<String, dynamic>
          ? e.response?.data['message']?.toString() ??
              e.response?.data['error']?.toString()
          : null;
      throw ApiException(
        message: backendMessage ??
            e.message ??
            'Erreur lors de la mise à jour du profil.',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }
}
