import 'package:dio/dio.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/token_storage.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';

class AuthTokens {
  final String accessToken;
  final String? refreshToken;

  const AuthTokens({
    required this.accessToken,
    this.refreshToken,
  });
}

class AuthRepository {
  final DioClient _dioClient;
  final TokenStorage _tokenStorage;

  AuthRepository({DioClient? dioClient, TokenStorage? tokenStorage})
      : _dioClient = dioClient ?? DioClient(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  /// Déconnecte l'utilisateur en effaçant les tokens stockés
  Future<void> logout() async {
    await _tokenStorage.clearTokens();
  }

  /// Inscription d'un nouvel utilisateur (POST /users/create)
  Future<UserModel> register(UserModel user, String motDePasse) async {
    try {
      final response = await _dioClient.dio.post(
        '/users/create',
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
        // If backend returns only message or basic user data
        return UserModel.fromJson(data);
      }

      return user;
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

  /// Vérification du code OTP envoyé par email (POST /otp/verify)
  Future<AuthTokens> verifyOtp(String email, String code) async {
    try {
      final response = await _dioClient.dio.post(
        '/otp/verify',
        data: {
          'email': email,
          'code': code,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final accessToken = data['accessToken'] ??
            data['token'] ??
            data['access_token'] ??
            (data['data'] is Map<String, dynamic>
                ? data['data']['accessToken'] ?? data['data']['token']
                : null);

        final refreshToken = data['refreshToken'] ??
            data['refresh_token'] ??
            (data['data'] is Map<String, dynamic>
                ? data['data']['refreshToken'] ?? data['data']['refresh_token']
                : null);

        if (accessToken != null && accessToken.toString().isNotEmpty) {
          return AuthTokens(
            accessToken: accessToken.toString(),
            refreshToken: refreshToken?.toString(),
          );
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

  /// Renvoi d'un nouveau code OTP (POST /otp/resend)
  Future<void> resendOtp(String email) async {
    try {
      await _dioClient.dio.post(
        '/otp/resend',
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
            'Erreur lors de l\'envoi du nouveau code OTP.',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  /// Connexion de l'utilisateur avec email et mot de passe (POST /auth/login)
  Future<AuthResponse> login(String email, String motDePasse) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'motDePasse': motDePasse,
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

  /// Demande de réinitialisation de mot de passe (POST /auth/forgot_password)
  Future<void> forgotPassword(String email) async {
    try {
      await _dioClient.dio.post(
        '/auth/forgot_password',
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

  /// Réinitialisation du mot de passe (POST /auth/reset_password)
  Future<void> resetPassword(String tokenOrCode, String nouveauMotDePasse,
      {String? email}) async {
    try {
      await _dioClient.dio.post(
        '/auth/reset_password',
        data: {
          if (email != null && email.isNotEmpty) 'email': email,
          'code': tokenOrCode,
          'nouveauMotDePasse': nouveauMotDePasse,
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

  /// Renouvellement de l'access token avec un refresh token (POST /auth/refresh)
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/refresh',
        data: {
          'refreshToken': refreshToken,
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

