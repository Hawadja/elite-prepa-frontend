import 'user_model.dart';

class AuthResponse {
  final UserModel user;
  final String accessToken;
  final String? refreshToken;

  const AuthResponse({
    required this.user,
    required this.accessToken,
    this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> userData;
    if (json['user'] is Map<String, dynamic>) {
      userData = json['user'] as Map<String, dynamic>;
    } else if (json['data'] is Map<String, dynamic>) {
      final inner = json['data'] as Map<String, dynamic>;
      if (inner['user'] is Map<String, dynamic>) {
        userData = inner['user'] as Map<String, dynamic>;
      } else {
        userData = inner;
      }
    } else {
      userData = json;
    }

    final user = UserModel.fromJson(userData);

    final token = json['token'] ??
        json['accessToken'] ??
        json['access_token'] ??
        (json['data'] is Map<String, dynamic>
            ? json['data']['token'] ?? json['data']['accessToken']
            : null);

    final refreshToken = json['refreshToken'] ??
        json['refresh_token'] ??
        (json['data'] is Map<String, dynamic>
            ? json['data']['refreshToken'] ?? json['data']['refresh_token']
            : null);

    return AuthResponse(
      user: user,
      accessToken: (token ?? '').toString(),
      refreshToken: refreshToken?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
    };
  }
}
