import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/token_storage.dart';
import '../../core/utils/jwt_utils.dart';
import '../repository/auth_repository.dart';
import '../repository/profil_repository.dart';

// States
abstract class OtpState extends Equatable {
  const OtpState();

  @override
  List<Object?> get props => [];
}

class OtpInitial extends OtpState {
  const OtpInitial();
}

class OtpLoading extends OtpState {
  const OtpLoading();
}

class OtpVerified extends OtpState {
  final String token;

  const OtpVerified(this.token);

  @override
  List<Object?> get props => [token];
}

class ProfilCreating extends OtpState {
  const ProfilCreating();
}

class OtpSuccess extends OtpState {
  final String token;
  final String? userId;

  const OtpSuccess(this.token, [this.userId]);

  @override
  List<Object?> get props => [token, userId];
}

class OtpError extends OtpState {
  final String message;

  const OtpError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class OtpCubit extends Cubit<OtpState> {
  final AuthRepository _authRepository;
  final ProfilRepository _profilRepository;
  final TokenStorage _tokenStorage;

  OtpCubit(
    this._authRepository, {
    ProfilRepository? profilRepository,
    TokenStorage? tokenStorage,
  })  : _profilRepository = profilRepository ?? ProfilRepository(),
        _tokenStorage = tokenStorage ?? TokenStorage(),
        super(const OtpInitial());

  /// Vérifie le code OTP et enchaîne avec la création du profil utilisateur
  Future<void> verifyOtp({
    required String email,
    required String code,
    String nom = '',
    String prenom = '',
  }) async {
    emit(const OtpLoading());
    try {
      final tokens = await _authRepository.verifyOtp(email, code);
      await _tokenStorage.saveTokens(
        tokens.accessToken,
        tokens.refreshToken,
      );

      emit(OtpVerified(tokens.accessToken));

      final userId = extractUserIdFromToken(tokens.accessToken);

      if (nom.isNotEmpty || prenom.isNotEmpty) {
        emit(const ProfilCreating());
        if (userId != null && userId.isNotEmpty) {
          await _profilRepository.createProfil(userId, nom, prenom);
        }
      }

      emit(OtpSuccess(tokens.accessToken, userId));
    } catch (e) {
      emit(OtpError(e.toString()));
    }
  }

  /// Demande le renvoi d'un nouveau code OTP
  Future<void> resendOtp(String email) async {
    try {
      await _authRepository.resendOtp(email);
    } catch (e) {
      emit(OtpError(e.toString()));
    }
  }
}
