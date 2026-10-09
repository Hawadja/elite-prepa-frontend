import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/token_storage.dart';
import '../repository/auth_repository.dart';

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

class OtpSuccess extends OtpState {
  final String token;

  const OtpSuccess(this.token);

  @override
  List<Object?> get props => [token];
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
  final TokenStorage _tokenStorage;

  OtpCubit(
    this._authRepository, {
    TokenStorage? tokenStorage,
  })  : _tokenStorage = tokenStorage ?? TokenStorage(),
        super(const OtpInitial());

  /// Vérifie le code OTP saisi par l'utilisateur et sauvegarde les tokens
  Future<void> verifyOtp(String email, String code) async {
    emit(const OtpLoading());
    try {
      final tokens = await _authRepository.verifyOtp(email, code);
      await _tokenStorage.saveTokens(
        tokens.accessToken,
        tokens.refreshToken,
      );
      emit(OtpSuccess(tokens.accessToken));
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

