import 'package:dio/dio.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/profil_model.dart';

class ProfilRepository {
  final DioClient _dioClient;

  ProfilRepository({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

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
        data: profil.toJson(),
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
