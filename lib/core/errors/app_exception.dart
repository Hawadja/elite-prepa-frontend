class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const AppException(
    this.message, {
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;
}

class ApiException extends AppException {
  const ApiException({
    required String message,
    int? statusCode,
    dynamic data,
  }) : super(
          message,
          statusCode: statusCode,
          data: data,
        );
}
