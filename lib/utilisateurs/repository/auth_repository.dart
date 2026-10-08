import 'package:dio/dio.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DioClient _dioClient;

  AuthRepository({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  /// Inscription d'un nouvel utilisateur
  /// Fait un POST vers /auth/register et retourne l'utilisateur créé ou lève une ApiException
  Future<UserModel> register(UserModel user, String motDePasse) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/register',
        data: {
          'nom': user.nom,
          'prenom': user.prenom,
          'email': user.email,
          'motDePasse': motDePasse,
          if (user.roleId.isNotEmpty) 'roleId': user.roleId,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['user'] is Map<String, dynamic>) {
          return UserModel.fromJson(data['user'] as Map<String, dynamic>);
        } else if (data['data'] is Map<String, dynamic>) {
          final innerData = data['data'] as Map<String, dynamic>;
          if (innerData['user'] is Map<String, dynamic>) {
            return UserModel.fromJson(
                innerData['user'] as Map<String, dynamic>);
          }
          return UserModel.fromJson(innerData);
        }
        return UserModel.fromJson(data);
      }

      throw const ApiException(
        message: 'Format de réponse backend invalide.',
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
            'Erreur lors de l\'inscription. Veuillez réessayer.',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }
}
