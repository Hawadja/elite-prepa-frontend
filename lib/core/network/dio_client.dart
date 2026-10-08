import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../errors/app_exception.dart';

const String apiBaseUrl = 'https://api.eliteprepa.com/api';

class DioClient {
  late final Dio _dio;

  DioClient({Dio? dio, String? baseUrl}) {
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
        onRequest: (options, handler) {
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
        onError: (DioException error, handler) {
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
