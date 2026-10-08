import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  OtpCubit(this._authRepository) : super(const OtpInitial());

  /// Vérifie le code OTP saisi par l'utilisateur
  Future<void> verifyOtp(String email, String code) async {
    emit(const OtpLoading());
    try {
      final token = await _authRepository.verifyOtp(email, code);
      emit(OtpSuccess(token));
    } catch (e) {
      emit(OtpError(e.toString()));
    }
  }
}
