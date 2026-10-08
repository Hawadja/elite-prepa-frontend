import 'package:dio/dio.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/auth_response.dart';
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

  /// Vérification du code OTP envoyé par email
  /// Fait un POST vers /auth/verify-otp et retourne le token JWT (String)
  Future<String> verifyOtp(String email, String code) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/verify-otp',
        data: {
          'email': email,
          'code': code,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final token = data['token'] ??
            data['accessToken'] ??
            (data['data'] is Map<String, dynamic>
                ? data['data']['token'] ?? data['data']['accessToken']
                : null);

        if (token != null && token.toString().isNotEmpty) {
          return token.toString();
        }
      }

      throw const ApiException(
        message: 'Token non trouvé dans la réponse du serveur.',
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
            'Code OTP invalide ou expiré.',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// Connexion de l'utilisateur avec email et mot de passe
  /// Fait un POST vers /auth/login et retourne un AuthResponse (UserModel + tokens)
  Future<AuthResponse> login(String email, String motDePasse) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'motDePasse': motDePasse,
          'password': motDePasse,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return AuthResponse.fromJson(data);
      }

      throw const ApiException(
        message: 'Format de réponse serveur invalide.',
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
            'Identifiants incorrects. Veuillez réessayer.',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// Demande de réinitialisation de mot de passe
  /// Fait un POST vers /auth/forgot-password avec l'email
  Future<void> forgotPassword(String email) async {
    try {
      await _dioClient.dio.post(
        '/auth/forgot-password',
        data: {
          'email': email,
        },
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
            'Erreur lors de la demande de réinitialisation du mot de passe.',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// Réinitialisation du mot de passe avec le token de réinitialisation
  /// Fait un POST vers /auth/reset-password avec le token et le nouveau mot de passe
  Future<void> resetPassword(String token, String nouveauMotDePasse) async {
    try {
      await _dioClient.dio.post(
        '/auth/reset-password',
        data: {
          'token': token,
          'nouveauMotDePasse': nouveauMotDePasse,
          'password': nouveauMotDePasse,
          'newPassword': nouveauMotDePasse,
        },
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
            'Erreur lors de la réinitialisation du mot de passe.',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// Renouvellement de l'access token avec un refresh token
  /// Fait un POST vers /auth/refresh et retourne le nouveau access token (String)
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/refresh',
        data: {
          'refreshToken': refreshToken,
          'refresh_token': refreshToken,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final token = data['accessToken'] ??
            data['token'] ??
            data['access_token'] ??
            (data['data'] is Map<String, dynamic>
                ? data['data']['accessToken'] ?? data['data']['token']
                : null);

        if (token != null && token.toString().isNotEmpty) {
          return token.toString();
        }
      }

      throw const ApiException(
        message: 'Nouveau token non trouvé dans la réponse du serveur.',
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
            'Session expirée. Veuillez vous re-connecter.',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }
}
