import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../errors/app_exception.dart';
import '../storage/token_storage.dart';

const String apiBaseUrl = 'http://10.147.86.32:3000/api/v1';

class DioClient {
  late final Dio _dio;
  final TokenStorage _tokenStorage;
  final VoidCallback? _onLogout;

  DioClient({
    Dio? dio,
    String? baseUrl,
    TokenStorage? tokenStorage,
    this._onLogout,
  })  : _tokenStorage = tokenStorage ?? TokenStorage() {
    _dio = dio ??
        Dio(
          BaseOptions(
            baseUrl: baseUrl ?? apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await _tokenStorage.getAccessToken();
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }

          if (kDebugMode) {
            debugPrint('---> ${options.method.toUpperCase()} ${options.uri}');
            debugPrint('Headers: ${options.headers}');
            if (options.data != null) {
              debugPrint('Data: ${options.data}');
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint(
                '<--- ${response.statusCode} ${response.requestOptions.uri}');
            debugPrint('Response Data: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          final path = error.requestOptions.path;
          final isAuthEndpoint = path.contains('/auth/login') ||
              path.contains('/auth/refresh') ||
              path.contains('/auth/forgot_password') ||
              path.contains('/auth/reset_password') ||
              path.contains('/users/create') ||
              path.contains('/otp/verify');
          final isRetry = error.requestOptions.extra['isRetry'] == true;

          if (error.response?.statusCode == 401 && !isAuthEndpoint && !isRetry) {
            try {
              final refreshToken = await _tokenStorage.getRefreshToken();
              if (refreshToken != null && refreshToken.isNotEmpty) {
                final refreshDio =
                    Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
                final response = await refreshDio.post(
                  '/auth/refresh',
                  data: {
                    'refreshToken': refreshToken,
                  },
                );

                final data = response.data;
                String? newAccessToken;
                if (data is Map<String, dynamic>) {
                  newAccessToken = data['accessToken']?.toString() ??
                      data['token']?.toString() ??
                      data['access_token']?.toString() ??
                      (data['data'] is Map<String, dynamic>
                          ? data['data']['accessToken']?.toString() ??
                              data['data']['token']?.toString()
                          : null);
                }

                if (newAccessToken != null && newAccessToken.isNotEmpty) {
                  await _tokenStorage.saveTokens(newAccessToken, refreshToken);

                  final options = error.requestOptions;
                  options.headers['Authorization'] = 'Bearer $newAccessToken';
                  options.extra['isRetry'] = true;

                  final retryResponse = await _dio.fetch(options);
                  return handler.resolve(retryResponse);
                }
              }
            } catch (e) {
              if (kDebugMode) {
                debugPrint('Échec du rafraîchissement du token: $e');
              }
            }

            await _tokenStorage.clearTokens();
            _onLogout?.call();
          }

          final customException = _parseDioError(error);
          if (kDebugMode) {
            debugPrint('<--- ERROR ${error.requestOptions.uri}');
            debugPrint('Error Message: ${customException.message}');
          }

          final updatedError = DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            type: error.type,
            error: customException,
            message: customException.message,
          );

          return handler.reject(updatedError);
        },
      ),
    );
  }

  Dio get dio => _dio;

  ApiException _parseDioError(DioException error) {
    String message;
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('message') &&
          responseData['message'] != null) {
        message = responseData['message'].toString();
        return ApiException(
          message: message,
          statusCode: statusCode,
          data: responseData,
        );
      } else if (responseData.containsKey('error') &&
          responseData['error'] != null) {
        message = responseData['error'].toString();
        return ApiException(
          message: message,
          statusCode: statusCode,
          data: responseData,
        );
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Délai de connexion dépassé. Veuillez réessayer.';
        break;
      case DioExceptionType.connectionError:
        message =
            'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
        break;
      case DioExceptionType.badResponse:
        switch (statusCode) {
          case 400:
            message = 'Requête invalide.';
            break;
          case 401:
            message = 'Non autorisé. Veuillez vous connecter.';
            break;
          case 403:
            message = 'Accès refusé.';
            break;
          case 404:
            message = 'Ressource introuvable.';
            break;
          case 409:
            message = 'Cette entrée existe déjà (conflit).';
            break;
          case 422:
            message = 'Données soumises invalides.';
            break;
          case 500:
          case 502:
          case 503:
            message = 'Erreur serveur. Veuillez réessayer plus tard.';
            break;
          default:
            message = 'Erreur serveur ($statusCode).';
        }
        break;
      case DioExceptionType.cancel:
        message = 'La requête a été annulée.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Certificat de sécurité invalide.';
        break;
      case DioExceptionType.unknown:
      default:
        message = 'Une erreur inattendue est survenue.';
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: responseData,
    );
  }
}
